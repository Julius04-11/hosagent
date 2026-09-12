/**
 * 企业级多级缓存系统
 * L1: 内存缓存 (LRU)
 * L2: ArkData KV持久化缓存
 * 支持缓存预热、过期策略、缓存穿透防护
 */
import { preferences } from '@kit.ArkData';

interface CacheEntry<T> {
  value: T;
  expireAt: number;
  hitCount: number;
  createdAt: number;
}

interface CacheConfig {
  l1MaxSize: number;          // L1缓存最大条目数
  l2MaxSize: number;          // L2缓存最大条目数
  defaultTTL: number;         // 默认过期时间(ms)
  enableL2: boolean;          // 是否启用L2缓存
  enableBloomFilter: boolean; // 是否启用布隆过滤器
}

/**
 * LRU缓存实现
 */
class LRUCache<T> {
  private cache: Map<string, CacheEntry<T>> = new Map();
  private maxSize: number;

  constructor(maxSize: number) {
    this.maxSize = maxSize;
  }

  get(key: string): T | null {
    const entry = this.cache.get(key);
    if (!entry) {
      return null;
    }

    // 检查是否过期
    if (Date.now() > entry.expireAt) {
      this.cache.delete(key);
      return null;
    }

    // LRU: 移到最后
    this.cache.delete(key);
    entry.hitCount++;
    this.cache.set(key, entry);
    return entry.value;
  }

  set(key: string, value: T, ttl: number): void {
    // 如果超过最大容量，删除最早的条目
    if (this.cache.size >= this.maxSize && !this.cache.has(key)) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }

    const entry: CacheEntry<T> = {
      value,
      expireAt: Date.now() + ttl,
      hitCount: 0,
      createdAt: Date.now()
    };

    this.cache.set(key, entry);
  }

  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
  }

  size(): number {
    return this.cache.size;
  }

  keys(): string[] {
    return Array.from(this.cache.keys());
  }
}

/**
 * 简易布隆过滤器
 */
class BloomFilter {
  private bitArray: boolean[];
  private size: number;
  private hashCount: number;

  constructor(size: number = 10000, hashCount: number = 3) {
    this.size = size;
    this.hashCount = hashCount;
    this.bitArray = new Array(size).fill(false);
  }

  add(item: string): void {
    const hashes = this.getHashes(item);
    for (const hash of hashes) {
      this.bitArray[hash] = true;
    }
  }

  contains(item: string): boolean {
    const hashes = this.getHashes(item);
    return hashes.every(hash => this.bitArray[hash]);
  }

  private getHashes(item: string): number[] {
    const hashes: number[] = [];
    for (let i = 0; i < this.hashCount; i++) {
      const hash = this.hash(item + i) % this.size;
      hashes.push(hash);
    }
    return hashes;
  }

  private hash(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

/**
 * 多级缓存管理器
 */
export class MultiLevelCache {
  private static instance: MultiLevelCache;
  private l1Cache: LRUCache<any>;
  private l2Store: preferences.Preferences | null = null;
  private bloomFilter: BloomFilter;
  private config: CacheConfig;

  // 性能指标
  private metrics = {
    l1Hits: 0,
    l1Misses: 0,
    l2Hits: 0,
    l2Misses: 0,
    sets: 0,
    deletes: 0,
    bloomFilterRejects: 0
  };

  private constructor() {
    this.config = {
      l1MaxSize: 1000,
      l2MaxSize: 10000,
      defaultTTL: 300000, // 5分钟
      enableL2: true,
      enableBloomFilter: true
    };

    this.l1Cache = new LRUCache(this.config.l1MaxSize);
    this.bloomFilter = new BloomFilter();
  }

  public static getInstance(): MultiLevelCache {
    if (!MultiLevelCache.instance) {
      MultiLevelCache.instance = new MultiLevelCache();
    }
    return MultiLevelCache.instance;
  }

  /**
   * 初始化L2缓存
   */
  async initialize(context: Context): Promise<void> {
    if (this.config.enableL2) {
      try {
        this.l2Store = await preferences.getPreferences(context, 'SmartTravelCache');
        console.info('[MultiLevelCache] L2缓存初始化成功');
      } catch (error) {
        console.error('[MultiLevelCache] L2缓存初始化失败:', error);
      }
    }
    console.info('[MultiLevelCache] 多级缓存初始化完成');
  }

  /**
   * 获取缓存
   */
  async get<T>(key: string): Promise<T | null> {
    // 布隆过滤器检查
    if (this.config.enableBloomFilter && !this.bloomFilter.contains(key)) {
      this.metrics.bloomFilterRejects++;
      return null;
    }

    // L1缓存查询
    const l1Value = this.l1Cache.get(key);
    if (l1Value !== null) {
      this.metrics.l1Hits++;
      console.debug(`[MultiLevelCache] L1命中: ${key}`);
      return l1Value as T;
    }
    this.metrics.l1Misses++;

    // L2缓存查询
    if (this.config.enableL2 && this.l2Store) {
      try {
        const l2Value = await this.l2Store.get(key, null);
        if (l2Value !== null) {
          this.metrics.l2Hits++;
          console.debug(`[MultiLevelCache] L2命中: ${key}`);
          
          // 回填到L1
          const parsed = JSON.parse(l2Value as string);
          this.l1Cache.set(key, parsed.value, parsed.expireAt - Date.now());
          return parsed.value as T;
        }
      } catch (error) {
        console.error('[MultiLevelCache] L2查询失败:', error);
      }
    }
    this.metrics.l2Misses++;

    return null;
  }

  /**
   * 设置缓存
   */
  async set<T>(key: string, value: T, ttl?: number): Promise<void> {
    const actualTTL = ttl || this.config.defaultTTL;
    this.metrics.sets++;

    // 布隆过滤器添加
    if (this.config.enableBloomFilter) {
      this.bloomFilter.add(key);
    }

    // L1缓存设置
    this.l1Cache.set(key, value, actualTTL);

    // L2缓存设置
    if (this.config.enableL2 && this.l2Store) {
      try {
        const entry = {
          value,
          expireAt: Date.now() + actualTTL
        };
        await this.l2Store.put(key, JSON.stringify(entry));
        await this.l2Store.flush();
      } catch (error) {
        console.error('[MultiLevelCache] L2设置失败:', error);
      }
    }

    console.debug(`[MultiLevelCache] 缓存设置: ${key}, TTL: ${actualTTL}ms`);
  }

  /**
   * 删除缓存
   */
  async delete(key: string): Promise<void> {
    this.metrics.deletes++;

    // L1删除
    this.l1Cache.delete(key);

    // L2删除
    if (this.config.enableL2 && this.l2Store) {
      try {
        await this.l2Store.delete(key);
        await this.l2Store.flush();
      } catch (error) {
        console.error('[MultiLevelCache] L2删除失败:', error);
      }
    }

    console.debug(`[MultiLevelCache] 缓存删除: ${key}`);
  }

  /**
   * 批量设置（缓存预热）
   */
  async batchSet<T>(entries: Array<{ key: string; value: T; ttl?: number }>): Promise<void> {
    console.info(`[MultiLevelCache] 批量设置缓存: ${entries.length}条`);
    const promises: Promise<void>[] = [];
    
    for (const entry of entries) {
      promises.push(this.set(entry.key, entry.value, entry.ttl));
    }

    await Promise.all(promises);
    console.info('[MultiLevelCache] 批量设置完成');
  }

  /**
   * 清空缓存
   */
  async clear(): Promise<void> {
    this.l1Cache.clear();

    if (this.config.enableL2 && this.l2Store) {
      try {
        await this.l2Store.clear();
        await this.l2Store.flush();
      } catch (error) {
        console.error('[MultiLevelCache] L2清空失败:', error);
      }
    }

    console.info('[MultiLevelCache] 缓存已清空');
  }

  /**
   * 获取缓存命中率
   */
  getHitRate(): { l1: string; l2: string; overall: string } {
    const l1Total = this.metrics.l1Hits + this.metrics.l1Misses;
    const l2Total = this.metrics.l2Hits + this.metrics.l2Misses;
    const overallHits = this.metrics.l1Hits + this.metrics.l2Hits;
    const overallTotal = l1Total + this.metrics.l2Misses;

    return {
      l1: l1Total > 0 ? ((this.metrics.l1Hits / l1Total) * 100).toFixed(2) + '%' : '0%',
      l2: l2Total > 0 ? ((this.metrics.l2Hits / l2Total) * 100).toFixed(2) + '%' : '0%',
      overall: overallTotal > 0 ? ((overallHits / overallTotal) * 100).toFixed(2) + '%' : '0%'
    };
  }

  /**
   * 获取性能指标
   */
  getMetrics() {
    return {
      ...this.metrics,
      hitRate: this.getHitRate(),
      l1Size: this.l1Cache.size(),
      bloomFilterRejectRate: this.metrics.sets > 0
        ? ((this.metrics.bloomFilterRejects / this.metrics.sets) * 100).toFixed(2) + '%'
        : '0%'
    };
  }

  /**
   * 更新配置
   */
  updateConfig(config: Partial<CacheConfig>): void {
    this.config = { ...this.config, ...config };
    if (config.l1MaxSize) {
      this.l1Cache = new LRUCache(config.l1MaxSize);
    }
    console.info('[MultiLevelCache] 配置已更新:', this.config);
  }
}
