# 企业级数据库架构设计
## 对标携程旅行 - 高并发数据库解决方案

---

## 📊 当前架构问题分析

### ❌ 现有架构缺陷

| 问题类别 | 描述 | 影响 |
|---------|------|------|
| **并发控制** | 无锁机制、无队列管理 | 高并发下数据竞争、死锁 |
| **连接管理** | 单例模式，无连接池 | 连接耗尽、性能瓶颈 |
| **缓存机制** | 无内存缓存 | 每次都读库，DB压力大 |
| **事务支持** | 简单事务，无分布式事务 | 数据一致性问题 |
| **性能监控** | 无指标收集 | 无法发现性能瓶颈 |
| **容错机制** | 无降级策略 | 单点故障影响全局 |
| **数据分片** | 不支持分库分表 | 单表数据量受限 |

### 🎯 携程级别需求

- **并发量**: 10万+ QPS
- **响应时间**: P99 < 50ms
- **数据量**: 亿级记录
- **可用性**: 99.99%
- **数据一致性**: 强一致性
- **容灾能力**: 多活架构

---

## 🏗️ 企业级架构设计

### 1. 分层架构

```
┌─────────────────────────────────────────┐
│        应用层 (Business Logic)           │
├─────────────────────────────────────────┤
│      缓存层 (L1 Memory + L2 Disk)       │
├─────────────────────────────────────────┤
│    数据访问层 (DAL - Connection Pool)    │
├─────────────────────────────────────────┤
│     存储层 (RDB + KV + 对象存储)         │
└─────────────────────────────────────────┘
```

### 2. 核心组件

#### 2.1 连接池管理器
- **最大连接数**: 200
- **最小连接数**: 10
- **连接超时**: 5s
- **空闲回收**: 30s
- **健康检查**: 每10s

#### 2.2 多级缓存
```
L1 缓存 (内存) -> L2 缓存 (持久化) -> 数据库
  1ms              10ms              50ms
  命中率90%        命中率9%          命中率1%
```

#### 2.3 读写分离
```
写操作 -> 主库 (Master)
                ↓ 同步
读操作 -> 从库1 (Slave1) / 从库2 (Slave2)
```

#### 2.4 数据分片策略
```
用户ID Hash -> Shard 0 (0-999)
            -> Shard 1 (1000-1999)
            -> Shard 2 (2000-2999)
            -> ...
```

---

## 🚀 性能优化策略

### 1. 并发控制

#### 乐观锁
```typescript
UPDATE user_info 
SET balance = balance - 100, version = version + 1
WHERE user_id = ? AND version = ?
```

#### 悲观锁
```typescript
SELECT * FROM user_info WHERE user_id = ? FOR UPDATE
```

#### 分布式锁
```typescript
// Redis分布式锁
SETNX lock:user:{userId} {timestamp} EX 10
```

### 2. 批量操作优化

```typescript
// 批量插入
INSERT INTO browse_history (user_id, item_id, ...) VALUES
  (?, ?, ...), (?, ?, ...), ... // 1000条/批次

// 批量更新
UPDATE favorite SET status = 
  CASE id
    WHEN 1 THEN 'active'
    WHEN 2 THEN 'deleted'
  END
WHERE id IN (1, 2, ...)
```

### 3. 索引策略

```sql
-- 复合索引
CREATE INDEX idx_user_favorite ON favorite(user_id, item_type, create_time);

-- 覆盖索引
CREATE INDEX idx_browse_cover ON browse_history(user_id) 
  INCLUDE (item_id, browse_time);

-- 分区索引
CREATE INDEX idx_time_partition ON browse_history(create_time)
  PARTITION BY RANGE (create_time);
```

### 4. 查询优化

```typescript
// 分页优化 - 使用游标
SELECT * FROM browse_history 
WHERE user_id = ? AND id > ?
ORDER BY id LIMIT 20

// 延迟关联
SELECT * FROM user_info 
WHERE id IN (
  SELECT user_id FROM favorite WHERE item_type = 'hotel' LIMIT 1000
)

// 使用物化视图
CREATE MATERIALIZED VIEW user_stats AS
SELECT user_id, COUNT(*) as favorite_count, MAX(create_time) as last_time
FROM favorite GROUP BY user_id
```

---

## 💾 缓存策略

### 1. Cache-Aside Pattern

```typescript
// 读取
const data = await cache.get(key);
if (data) return data;

const dbData = await db.query(key);
await cache.set(key, dbData, TTL);
return dbData;

// 写入
await db.update(key, data);
await cache.delete(key); // 删除缓存
```

### 2. 缓存预热

```typescript
// 应用启动时预热热点数据
async function warmupCache() {
  const hotUsers = await getHotUsers(); // Top 1000用户
  for (const user of hotUsers) {
    await cache.set(`user:${user.id}`, user, 3600);
  }
}
```

### 3. 缓存击穿防护

```typescript
// 布隆过滤器
if (!bloomFilter.contains(key)) {
  return null; // 数据肯定不存在
}

// 互斥锁
const lock = await distributedLock.acquire(key);
if (lock) {
  try {
    const data = await db.query(key);
    await cache.set(key, data);
    return data;
  } finally {
    await lock.release();
  }
}
```

---

## 🔒 事务管理

### 1. 本地事务

```typescript
async function transferPoints(fromUser: string, toUser: string, amount: number) {
  const tx = await db.beginTransaction();
  try {
    await tx.execute('UPDATE user SET points = points - ? WHERE id = ?', [amount, fromUser]);
    await tx.execute('UPDATE user SET points = points + ? WHERE id = ?', [amount, toUser]);
    await tx.commit();
  } catch (error) {
    await tx.rollback();
    throw error;
  }
}
```

### 2. 分布式事务 (Saga模式)

```typescript
class BookingService {
  async bookHotel(userId: string, hotelId: string) {
    const sagaId = generateSagaId();
    
    try {
      // Step 1: 锁定库存
      await this.inventoryService.lockInventory(sagaId, hotelId);
      
      // Step 2: 扣减积分
      await this.userService.deductPoints(sagaId, userId, 1000);
      
      // Step 3: 创建订单
      await this.orderService.createOrder(sagaId, userId, hotelId);
      
      // 提交Saga
      await this.sagaLog.commit(sagaId);
    } catch (error) {
      // 补偿操作
      await this.compensate(sagaId);
      throw error;
    }
  }
  
  async compensate(sagaId: string) {
    const steps = await this.sagaLog.getSteps(sagaId);
    // 反向执行补偿
    for (const step of steps.reverse()) {
      await step.compensate();
    }
  }
}
```

---

## 📈 性能监控

### 1. 关键指标

```typescript
interface DBMetrics {
  // 性能指标
  qps: number;              // 每秒查询数
  avgLatency: number;       // 平均延迟
  p99Latency: number;       // P99延迟
  
  // 资源指标
  connectionPoolSize: number;
  activeConnections: number;
  cacheHitRate: number;
  
  // 错误指标
  errorRate: number;
  timeoutCount: number;
  deadlockCount: number;
}
```

### 2. 慢查询监控

```typescript
class QueryMonitor {
  private slowQueryThreshold = 100; // 100ms
  
  async monitor(query: string, params: any[], executor: Function) {
    const start = Date.now();
    try {
      const result = await executor();
      const duration = Date.now() - start;
      
      if (duration > this.slowQueryThreshold) {
        this.logSlowQuery({
          query,
          params,
          duration,
          timestamp: new Date()
        });
      }
      
      return result;
    } catch (error) {
      this.logError(query, params, error);
      throw error;
    }
  }
}
```

---

## 🛡️ 容错与降级

### 1. 熔断器模式

```typescript
class CircuitBreaker {
  private failureCount = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  private readonly threshold = 5;
  private readonly timeout = 60000; // 60s
  
  async execute(operation: Function) {
    if (this.state === 'OPEN') {
      if (Date.now() - this.openTime > this.timeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }
    
    try {
      const result = await operation();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.openTime = Date.now();
    }
  }
  
  private onSuccess() {
    this.failureCount = 0;
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
    }
  }
}
```

### 2. 降级策略

```typescript
class DegradationService {
  async getUserInfo(userId: string): Promise<UserInfo> {
    try {
      // 尝试从数据库读取
      return await this.db.getUserInfo(userId);
    } catch (error) {
      console.error('DB error, using fallback');
      
      // 降级：从缓存读取（可能是过期数据）
      const cached = await this.cache.get(`user:${userId}`);
      if (cached) return cached;
      
      // 降级：返回默认数据
      return this.getDefaultUserInfo(userId);
    }
  }
}
```

---

## 🎯 携程级别性能对比

| 指标 | 当前架构 | 企业级架构 | 携程标准 |
|------|---------|-----------|---------|
| **QPS** | <100 | 100,000+ | 100,000+ |
| **P99延迟** | >500ms | <50ms | <50ms |
| **并发连接** | 单连接 | 200连接池 | 1000+ |
| **缓存命中率** | 0% | >90% | >95% |
| **可用性** | 95% | 99.99% | 99.99% |
| **数据一致性** | 弱 | 强 | 强 |

---

## 📚 技术栈选型

### 数据库
- **关系型**: SQLite (单机) / PostgreSQL (云端)
- **键值型**: ArkData Preferences (配置) / Redis (缓存)
- **文档型**: 用户画像、行为分析

### 缓存
- **L1**: 内存缓存 (Map/LRU)
- **L2**: ArkData KV
- **L3**: Redis集群

### 监控
- **APM**: 华为云APM
- **日志**: HiLog + ELK
- **追踪**: OpenTelemetry

---

## 🚀 实施路线图

### Phase 1: 基础增强 (1周)
- ✅ 连接池
- ✅ 基础缓存
- ✅ 性能监控

### Phase 2: 高级特性 (2周)
- ✅ 读写分离
- ✅ 分布式锁
- ✅ 熔断降级

### Phase 3: 企业级 (4周)
- ✅ 数据分片
- ✅ 分布式事务
- ✅ 多活架构

---

**结论**: 现有架构需要全面升级才能支撑携程级别的高并发场景。
