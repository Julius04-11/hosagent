/**
 * 企业级数据库连接池管理器
 * 支持高并发场景的连接复用和管理
 */
import relationalStore from '@ohos.data.relationalStore';

interface PoolConfig {
  minConnections: number;      // 最小连接数
  maxConnections: number;      // 最大连接数
  acquireTimeout: number;      // 获取连接超时时间(ms)
  idleTimeout: number;         // 空闲连接超时时间(ms)
  healthCheckInterval: number; // 健康检查间隔(ms)
}

interface ConnectionWrapper {
  connection: relationalStore.RdbStore;
  id: string;
  createdAt: number;
  lastUsedAt: number;
  isActive: boolean;
  queryCount: number;
}

export class ConnectionPoolManager {
  private static instance: ConnectionPoolManager;
  private pool: ConnectionWrapper[] = [];
  private waitQueue: Array<(conn: ConnectionWrapper) => void> = [];
  private config: PoolConfig;
  private context: Context | null = null;
  private storeConfig: relationalStore.StoreConfig | null = null;
  private healthCheckTimer: number | null = null;

  // 性能指标
  private metrics = {
    totalConnections: 0,
    activeConnections: 0,
    waitingRequests: 0,
    totalAcquired: 0,
    totalReleased: 0,
    totalCreated: 0,
    totalDestroyed: 0,
    acquireTime: [] as number[],
    errors: 0
  };

  private constructor() {
    this.config = {
      minConnections: 10,
      maxConnections: 200,
      acquireTimeout: 5000,
      idleTimeout: 30000,
      healthCheckInterval: 10000
    };
  }

  public static getInstance(): ConnectionPoolManager {
    if (!ConnectionPoolManager.instance) {
      ConnectionPoolManager.instance = new ConnectionPoolManager();
    }
    return ConnectionPoolManager.instance;
  }

  /**
   * 初始化连接池
   */
  async initialize(context: Context, storeConfig: relationalStore.StoreConfig): Promise<void> {
    console.info('[ConnectionPool] 初始化连接池...');
    this.context = context;
    this.storeConfig = storeConfig;

    // 创建最小连接数
    const promises: Promise<void>[] = [];
    for (let i = 0; i < this.config.minConnections; i++) {
      promises.push(this.createConnection());
    }
    await Promise.all(promises);

    // 启动健康检查
    this.startHealthCheck();

    console.info(`[ConnectionPool] 连接池初始化完成，连接数: ${this.pool.length}`);
  }

  /**
   * 获取连接
   */
  async acquire(): Promise<ConnectionWrapper> {
    const startTime = Date.now();
    this.metrics.waitingRequests++;

    try {
      // 从池中获取空闲连接
      const idleConnection = this.pool.find(conn => !conn.isActive);
      if (idleConnection) {
        idleConnection.isActive = true;
        idleConnection.lastUsedAt = Date.now();
        this.metrics.activeConnections++;
        this.metrics.totalAcquired++;
        this.metrics.waitingRequests--;
        this.recordAcquireTime(Date.now() - startTime);
        console.debug(`[ConnectionPool] 获取连接: ${idleConnection.id}`);
        return idleConnection;
      }

      // 如果池未满，创建新连接
      if (this.pool.length < this.config.maxConnections) {
        await this.createConnection();
        return await this.acquire(); // 递归获取
      }

      // 池已满，进入等待队列
      console.warn('[ConnectionPool] 连接池已满，进入等待队列');
      return await this.waitForConnection();
    } catch (error) {
      this.metrics.errors++;
      this.metrics.waitingRequests--;
      console.error('[ConnectionPool] 获取连接失败:', error);
      throw error;
    }
  }

  /**
   * 释放连接
   */
  release(connection: ConnectionWrapper): void {
    console.debug(`[ConnectionPool] 释放连接: ${connection.id}`);
    connection.isActive = false;
    connection.lastUsedAt = Date.now();
    this.metrics.activeConnections--;
    this.metrics.totalReleased++;

    // 如果有等待的请求，立即分配
    const waitingRequest = this.waitQueue.shift();
    if (waitingRequest) {
      connection.isActive = true;
      this.metrics.activeConnections++;
      waitingRequest(connection);
    }
  }

  /**
   * 创建新连接
   */
  private async createConnection(): Promise<void> {
    if (!this.context || !this.storeConfig) {
      throw new Error('连接池未初始化');
    }

    try {
      const rdbStore = await relationalStore.getRdbStore(this.context, this.storeConfig);
      const wrapper: ConnectionWrapper = {
        connection: rdbStore,
        id: `conn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        createdAt: Date.now(),
        lastUsedAt: Date.now(),
        isActive: false,
        queryCount: 0
      };

      this.pool.push(wrapper);
      this.metrics.totalConnections++;
      this.metrics.totalCreated++;
      console.info(`[ConnectionPool] 创建连接: ${wrapper.id}, 总数: ${this.pool.length}`);
    } catch (error) {
      this.metrics.errors++;
      console.error('[ConnectionPool] 创建连接失败:', error);
      throw error;
    }
  }

  /**
   * 等待连接可用
   */
  private waitForConnection(): Promise<ConnectionWrapper> {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        const index = this.waitQueue.indexOf(resolve);
        if (index > -1) {
          this.waitQueue.splice(index, 1);
        }
        this.metrics.waitingRequests--;
        reject(new Error('获取连接超时'));
      }, this.config.acquireTimeout);

      this.waitQueue.push((conn: ConnectionWrapper) => {
        clearTimeout(timeoutId);
        this.metrics.waitingRequests--;
        resolve(conn);
      });
    });
  }

  /**
   * 健康检查
   */
  private startHealthCheck(): void {
    this.healthCheckTimer = setInterval(() => {
      this.performHealthCheck();
    }, this.config.healthCheckInterval);
  }

  private async performHealthCheck(): Promise<void> {
    const now = Date.now();
    const idleConnections = this.pool.filter(conn => !conn.isActive);

    for (const conn of idleConnections) {
      // 检查是否超过空闲超时时间
      if (now - conn.lastUsedAt > this.config.idleTimeout) {
        // 如果连接数大于最小值，则销毁
        if (this.pool.length > this.config.minConnections) {
          await this.destroyConnection(conn);
        }
      }
    }

    // 确保至少有最小连接数
    while (this.pool.length < this.config.minConnections) {
      await this.createConnection();
    }

    console.debug(`[ConnectionPool] 健康检查完成, 连接数: ${this.pool.length}, 活跃: ${this.metrics.activeConnections}`);
  }

  /**
   * 销毁连接
   */
  private async destroyConnection(connection: ConnectionWrapper): Promise<void> {
    const index = this.pool.indexOf(connection);
    if (index > -1) {
      this.pool.splice(index, 1);
      this.metrics.totalConnections--;
      this.metrics.totalDestroyed++;
      console.info(`[ConnectionPool] 销毁连接: ${connection.id}`);
    }
  }

  /**
   * 执行查询（自动管理连接）
   */
  async executeQuery<T>(query: (store: relationalStore.RdbStore) => Promise<T>): Promise<T> {
    const connection = await this.acquire();
    try {
      connection.queryCount++;
      const result = await query(connection.connection);
      return result;
    } finally {
      this.release(connection);
    }
  }

  /**
   * 执行事务
   */
  async executeTransaction<T>(
    operations: (store: relationalStore.RdbStore) => Promise<T>
  ): Promise<T> {
    const connection = await this.acquire();
    try {
      // 注意：鸿蒙RDB暂不支持显式事务，但操作是原子性的
      const result = await operations(connection.connection);
      return result;
    } catch (error) {
      console.error('[ConnectionPool] 事务执行失败:', error);
      throw error;
    } finally {
      this.release(connection);
    }
  }

  /**
   * 记录获取连接的时间
   */
  private recordAcquireTime(time: number): void {
    this.metrics.acquireTime.push(time);
    // 只保留最近1000条记录
    if (this.metrics.acquireTime.length > 1000) {
      this.metrics.acquireTime.shift();
    }
  }

  /**
   * 获取性能指标
   */
  getMetrics() {
    const acquireTimes = this.metrics.acquireTime;
    const avgAcquireTime = acquireTimes.length > 0
      ? acquireTimes.reduce((a, b) => a + b, 0) / acquireTimes.length
      : 0;

    return {
      ...this.metrics,
      avgAcquireTime,
      poolSize: this.pool.length,
      idleConnections: this.pool.filter(c => !c.isActive).length,
      utilizationRate: this.pool.length > 0 
        ? (this.metrics.activeConnections / this.pool.length * 100).toFixed(2) + '%'
        : '0%'
    };
  }

  /**
   * 关闭连接池
   */
  async shutdown(): Promise<void> {
    console.info('[ConnectionPool] 关闭连接池...');
    
    if (this.healthCheckTimer) {
      clearInterval(this.healthCheckTimer);
    }

    // 等待所有活跃连接完成
    let waitCount = 0;
    while (this.metrics.activeConnections > 0 && waitCount < 30) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      waitCount++;
    }

    // 清空连接池
    this.pool = [];
    this.waitQueue = [];
    this.metrics.totalConnections = 0;
    this.metrics.activeConnections = 0;

    console.info('[ConnectionPool] 连接池已关闭');
  }

  /**
   * 更新配置
   */
  updateConfig(config: Partial<PoolConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[ConnectionPool] 配置已更新:', this.config);
  }
}
