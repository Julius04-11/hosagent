/**
 * 数据库服务 - 统一管理所有数据库操作
 * 提供简化的API接口给业务层使用
 */
import { PreferencesManager } from './PreferencesManager';
import { RelationalDatabaseManager, UserInfo, FavoriteRecord, BrowseHistory } from './RelationalDatabaseManager';

export class DatabaseService {
  private static instance: DatabaseService;
  private preferencesManager: PreferencesManager;
  private relationalDBManager: RelationalDatabaseManager;
  private isInitialized: boolean = false;

  private constructor() {
    this.preferencesManager = PreferencesManager.getInstance();
    this.relationalDBManager = RelationalDatabaseManager.getInstance();
  }

  public static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  /**
   * 初始化所有数据库
   */
  async initialize(context: Context): Promise<void> {
    if (this.isInitialized) {
      console.info('[DatabaseService] 数据库已初始化，跳过');
      return;
    }

    try {
      console.info('[DatabaseService] 开始初始化数据库...');
      
      // 并行初始化两个数据库
      await Promise.all([
        this.preferencesManager.initialize(context),
        this.relationalDBManager.initialize(context)
      ]);

      this.isInitialized = true;
      console.info('[DatabaseService] 数据库初始化完成');
    } catch (error) {
      console.error('[DatabaseService] 数据库初始化失败:', error);
      throw new Error('DatabaseService initialization failed');
    }
  }

  // ==================== 首选项数据库操作 ====================

  /**
   * 保存用户设置
   */
  async saveUserSetting(key: string, value: string | number | boolean): Promise<void> {
    if (typeof value === 'string') {
      await this.preferencesManager.putString(key, value);
    } else if (typeof value === 'number') {
      await this.preferencesManager.putNumber(key, value);
    } else if (typeof value === 'boolean') {
      await this.preferencesManager.putBoolean(key, value);
    }
  }

  /**
   * 获取用户设置
   */
  async getUserSetting<T>(key: string, defaultValue: T): Promise<T> {
    if (typeof defaultValue === 'string') {
      return await this.preferencesManager.getString(key, defaultValue as string) as T;
    } else if (typeof defaultValue === 'number') {
      return await this.preferencesManager.getNumber(key, defaultValue as number) as T;
    } else if (typeof defaultValue === 'boolean') {
      return await this.preferencesManager.getBoolean(key, defaultValue as boolean) as T;
    }
    return defaultValue;
  }

  /**
   * 保存当前用户ID
   */
  async saveCurrentUserId(userId: string): Promise<void> {
    await this.preferencesManager.putString('current_user_id', userId);
  }

  /**
   * 获取当前用户ID
   */
  async getCurrentUserId(): Promise<string> {
    return await this.preferencesManager.getString('current_user_id', 'user_' + Date.now());
  }

  /**
   * 保存用户是否首次使用
   */
  async setFirstTimeLaunch(isFirstTime: boolean): Promise<void> {
    await this.preferencesManager.putBoolean('is_first_time', isFirstTime);
  }

  /**
   * 检查是否首次使用
   */
  async isFirstTimeLaunch(): Promise<boolean> {
    return await this.preferencesManager.getBoolean('is_first_time', true);
  }

  // ==================== 关系型数据库操作 ====================

  /**
   * 保存用户信息
   */
  async saveUserInfo(userInfo: UserInfo): Promise<number> {
    return await this.relationalDBManager.saveUserInfo(userInfo);
  }

  /**
   * 获取用户信息
   */
  async getUserInfo(userId: string): Promise<UserInfo | null> {
    return await this.relationalDBManager.getUserInfo(userId);
  }

  /**
   * 添加收藏
   */
  async addFavorite(favorite: FavoriteRecord): Promise<number> {
    return await this.relationalDBManager.addFavorite(favorite);
  }

  /**
   * 获取用户收藏列表
   */
  async getUserFavorites(userId: string): Promise<FavoriteRecord[]> {
    return await this.relationalDBManager.getUserFavorites(userId);
  }

  /**
   * 删除收藏
   */
  async removeFavorite(userId: string, itemId: string, itemType: string): Promise<number> {
    return await this.relationalDBManager.removeFavorite(userId, itemId, itemType);
  }

  /**
   * 检查是否已收藏
   */
  async isFavorited(userId: string, itemId: string, itemType: string): Promise<boolean> {
    const favorites = await this.getUserFavorites(userId);
    return favorites.some(fav => fav.itemId === itemId && fav.itemType === itemType);
  }

  /**
   * 添加浏览历史
   */
  async addBrowseHistory(history: BrowseHistory): Promise<number> {
    return await this.relationalDBManager.addBrowseHistory(history);
  }

  /**
   * 获取用户浏览历史
   */
  async getUserBrowseHistory(userId: string, limit: number = 20): Promise<BrowseHistory[]> {
    return await this.relationalDBManager.getUserBrowseHistory(userId, limit);
  }

  /**
   * 清空用户浏览历史
   */
  async clearBrowseHistory(userId: string): Promise<number> {
    return await this.relationalDBManager.clearBrowseHistory(userId);
  }

  /**
   * 清空所有数据（谨慎使用）
   */
  async clearAllData(): Promise<void> {
    await this.preferencesManager.clear();
    const userId = await this.getCurrentUserId();
    await this.clearBrowseHistory(userId);
    // 注意：不清除用户信息和收藏
    console.info('[DatabaseService] 部分数据已清空');
  }
}

// 数据库键接口
interface DBKeysInterface {
  CURRENT_USER_ID: string;
  IS_FIRST_TIME: string;
  LANGUAGE: string;
  THEME: string;
  NOTIFICATION_ENABLED: string;
  LOCATION_PERMISSION: string;
}

// 数据库服务常量
export const DB_KEYS: DBKeysInterface = {
  CURRENT_USER_ID: 'current_user_id',
  IS_FIRST_TIME: 'is_first_time',
  LANGUAGE: 'app_language',
  THEME: 'app_theme',
  NOTIFICATION_ENABLED: 'notification_enabled',
  LOCATION_PERMISSION: 'location_permission'
};
