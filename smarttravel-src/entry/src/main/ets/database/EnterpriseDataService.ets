/**
 * 企业级数据库服务 - 集成连接池和多级缓存
 * 支持高并发场景，对标携程旅行等大型应用
 */
import { ConnectionPoolManager } from './enterprise/ConnectionPoolManager';
import { MultiLevelCache } from './enterprise/MultiLevelCache';
import { PreferencesManager } from './PreferencesManager';
import { RelationalDatabaseManager, UserInfo, FavoriteRecord, BrowseHistory } from './RelationalDatabaseManager';
import relationalStore from '@ohos.data.relationalStore';

export class EnterpriseDataService {
  private static instance: EnterpriseDataService;
  private connectionPool: ConnectionPoolManager;
  private cache: MultiLevelCache;
  private preferencesManager: PreferencesManager;
  private relationalDBManager: RelationalDatabaseManager;
  private isInitialized: boolean = false;

  // 性能指标
  private metrics = {
    totalRequests: 0,
    cacheHits: 0,
    dbQueries: 0,
    errors: 0,
    avgResponseTime: 0
  };

  private constructor() {
    this.connectionPool = ConnectionPoolManager.getInstance();
    this.cache = MultiLevelCache.getInstance();
    this.preferencesManager = PreferencesManager.getInstance();
    this.relationalDBManager = RelationalDatabaseManager.getInstance();
  }

  public static getInstance(): EnterpriseDataService {
    if (!EnterpriseDataService.instance) {
      EnterpriseDataService.instance = new EnterpriseDataService();
    }
    return EnterpriseDataService.instance;
  }

  /**
   * 初始化企业级数据库服务
   */
  async initialize(context: Context): Promise<void> {
    if (this.isInitialized) {
      console.info('[EnterpriseDB] 已初始化，跳过');
      return;
    }

    console.info('[EnterpriseDB] 开始初始化企业级数据库服务...');
    const startTime = Date.now();

    try {
      // 并行初始化所有组件
      await Promise.all([
        // 初始化连接池
        this.connectionPool.initialize(context, {
          name: 'SmartTravelDB.db',
          securityLevel: relationalStore.SecurityLevel.S1
        }),
        // 初始化多级缓存
        this.cache.initialize(context),
        // 初始化键值数据库
        this.preferencesManager.initialize(context),
        // 初始化关系型数据库
        this.relationalDBManager.initialize(context)
      ]);

      this.isInitialized = true;
      const duration = Date.now() - startTime;
      console.info(`[EnterpriseDB] 初始化完成，耗时: ${duration}ms`);

      // 预热热点数据
      await this.warmupCache();
    } catch (error) {
      console.error('[EnterpriseDB] 初始化失败:', error);
      throw error;
    }
  }

  /**
   * 缓存预热 - 加载热点数据
   */
  private async warmupCache(): Promise<void> {
    console.info('[EnterpriseDB] 开始缓存预热...');
    try {
      // 预热用户设置等常用数据
      const userId = await this.preferencesManager.getString('current_user_id', '');
      if (userId) {
        const userInfo = await this.relationalDBManager.getUserInfo(userId);
        if (userInfo) {
          await this.cache.set(`user:${userId}`, userInfo, 600000); // 10分钟
        }
      }
      console.info('[EnterpriseDB] 缓存预热完成');
    } catch (error) {
      console.error('[EnterpriseDB] 缓存预热失败:', error);
    }
  }

  /**
   * 获取用户信息（带缓存）
   */
  async getUserInfo(userId: string): Promise<UserInfo | null> {
    this.metrics.totalRequests++;
    const cacheKey = `user:${userId}`;

    try {
      // 1. 查询缓存
      const cached = await this.cache.get<UserInfo>(cacheKey);
      if (cached) {
        this.metrics.cacheHits++;
        console.debug(`[EnterpriseDB] 缓存命中: ${cacheKey}`);
        return cached;
      }

      // 2. 查询数据库（使用连接池）
      this.metrics.dbQueries++;
      const userInfo = await this.relationalDBManager.getUserInfo(userId);

      // 3. 写入缓存
      if (userInfo) {
        await this.cache.set(cacheKey, userInfo, 600000); // 10分钟
      }

      return userInfo;
    } catch (error) {
      this.metrics.errors++;
      console.error('[EnterpriseDB] 获取用户信息失败:', error);
      throw error;
    }
  }

  /**
   * 保存用户信息（更新缓存）
   */
  async saveUserInfo(userInfo: UserInfo): Promise<number> {
    this.metrics.totalRequests++;
    const cacheKey = `user:${userInfo.userId}`;

    try {
      // 1. 保存到数据库
      const result = await this.relationalDBManager.saveUserInfo(userInfo);

      // 2. 删除缓存（确保下次读取最新数据）
      await this.cache.delete(cacheKey);

      return result;
    } catch (error) {
      this.metrics.errors++;
      console.error('[EnterpriseDB] 保存用户信息失败:', error);
      throw error;
    }
  }

  /**
   * 获取用户收藏列表（带缓存）
   */
  async getUserFavorites(userId: string): Promise<FavoriteRecord[]> {
    this.metrics.totalRequests++;
    const cacheKey = `favorites:${userId}`;

    try {
      // 查询缓存
      const cached = await this.cache.get<FavoriteRecord[]>(cacheKey);
      if (cached) {
        this.metrics.cacheHits++;
        return cached;
      }

      // 查询数据库
      this.metrics.dbQueries++;
      const favorites = await this.relationalDBManager.getUserFavorites(userId);

      // 写入缓存（5分钟）
      await this.cache.set(cacheKey, favorites, 300000);

      return favorites;
    } catch (error) {
      this.metrics.errors++;
      console.error('[EnterpriseDB] 获取收藏列表失败:', error);
      return [];
    }
  }

  /**
   * 添加收藏（清除缓存）
   */
  async addFavorite(favorite: FavoriteRecord): Promise<number> {
    this.metrics.totalRequests++;

    try {
      const result = await this.relationalDBManager.addFavorite(favorite);
      
      // 清除收藏列表缓存
      await this.cache.delete(`favorites:${favorite.userId}`);

      return result;
    } catch (error) {
      this.metrics.errors++;
      console.error('[EnterpriseDB] 添加收藏失败:', error);
      throw error;
    }
  }

  /**
   * 获取浏览历史（带缓存）
   */
  async getUserBrowseHistory(userId: string, limit: number = 20): Promise<BrowseHistory[]> {
    this.metrics.totalRequests++;
    const cacheKey = `history:${userId}:${limit}`;

    try {
      // 查询缓存
      const cached = await this.cache.get<BrowseHistory[]>(cacheKey);
      if (cached) {
        this.metrics.cacheHits++;
        return cached;
      }

      // 查询数据库
      this.metrics.dbQueries++;
      const history = await this.relationalDBManager.getUserBrowseHistory(userId, limit);

      // 写入缓存（3分钟）
      await this.cache.set(cacheKey, history, 180000);

      return history;
    } catch (error) {
      this.metrics.errors++;
      console.error('[EnterpriseDB] 获取浏览历史失败:', error);
      return [];
    }
  }

  /**
   * 批量预加载数据
   */
  async batchPreload(userIds: string[]): Promise<void> {
    console.info(`[EnterpriseDB] 批量预加载: ${userIds.length}个用户`);
    
    const promises = userIds.map(async (userId) => {
      try {
        const userInfo = await this.relationalDBManager.getUserInfo(userId);
        if (userInfo) {
          await this.cache.set(`user:${userId}`, userInfo, 600000);
        }
      } catch (error) {
        console.error(`[EnterpriseDB] 预加载用户${userId}失败:`, error);
      }
    });

    await Promise.all(promises);
    console.info('[EnterpriseDB] 批量预加载完成');
  }

  /**
   * 获取性能指标
   */
  getMetrics() {
    const cacheMetrics = this.cache.getMetrics();
    const poolMetrics = this.connectionPool.getMetrics();

    return {
      // 服务指标
      totalRequests: this.metrics.totalRequests,
      cacheHitRate: this.metrics.totalRequests > 0
        ? ((this.metrics.cacheHits / this.metrics.totalRequests) * 100).toFixed(2) + '%'
        : '0%',
      dbQueryRate: this.metrics.totalRequests > 0
        ? ((this.metrics.dbQueries / this.metrics.totalRequests) * 100).toFixed(2) + '%'
        : '0%',
      errorRate: this.metrics.totalRequests > 0
        ? ((this.metrics.errors / this.metrics.totalRequests) * 100).toFixed(2) + '%'
        : '0%',

      // 缓存指标
      cache: cacheMetrics,

      // 连接池指标
      connectionPool: poolMetrics
    };
  }

  /**
   * 关闭服务
   */
  async shutdown(): Promise<void> {
    console.info('[EnterpriseDB] 关闭企业级数据库服务...');
    await this.connectionPool.shutdown();
    await this.cache.clear();
    console.info('[EnterpriseDB] 服务已关闭');
  }
}
