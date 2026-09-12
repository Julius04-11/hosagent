/**
 * 关系型数据库管理器 - 简化版
 * 修复编译错误，仅保留核心功能
 */
import { relationalStore } from '@kit.ArkData';

// 基础接口定义
export interface UserInfo {
  id?: number;
  userId: string;
  username: string;
  email?: string;
  avatar?: string;
  createdAt?: number;
  updatedAt?: number;
}

export interface FavoriteRecord {
  id?: number;
  userId: string;
  itemId: string;
  itemType: string;
  itemTitle: string;
  itemDescription?: string;
  itemImageUrl?: string;
  createdAt: number;
}

export interface BrowseHistory {
  id?: number;
  userId: string;
  itemId: string;
  itemType: string;
  itemTitle: string;
  visitCount: number;
  lastVisitTime: number;
  createdAt: number;
}

export class RelationalDatabaseManager {
  private static instance: RelationalDatabaseManager;
  private store: relationalStore.RdbStore | null = null;
  private readonly dbName: string = 'SmartTravel.db';
  private readonly dbVersion: number = 1;

  private constructor() {}

  static getInstance(): RelationalDatabaseManager {
    if (!RelationalDatabaseManager.instance) {
      RelationalDatabaseManager.instance = new RelationalDatabaseManager();
    }
    return RelationalDatabaseManager.instance;
  }

  async initialize(context: Context): Promise<void> {
    if (this.store) {
      console.info('[RelationalDB] 数据库已初始化');
      return;
    }

    try {
      const config: relationalStore.StoreConfig = {
        name: this.dbName,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.store = await relationalStore.getRdbStore(context, config);
      console.info('[RelationalDB] 数据库初始化成功');

      await this.createTables();
    } catch (error) {
      console.error('[RelationalDB] 初始化失败:', JSON.stringify(error));
      throw new Error('Database initialization failed');
    }
  }

  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    try {
      // 用户表
      const createUserTableSql = `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT UNIQUE NOT NULL,
        username TEXT NOT NULL,
        email TEXT,
        avatar TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )`;
      await this.store.executeSql(createUserTableSql);

      // 收藏表
      const createFavoriteTableSql = `CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        itemType TEXT NOT NULL,
        itemTitle TEXT NOT NULL,
        itemDescription TEXT,
        itemImageUrl TEXT,
        createdAt INTEGER NOT NULL,
        UNIQUE(userId, itemId, itemType)
      )`;
      await this.store.executeSql(createFavoriteTableSql);

      // 浏览历史表
      const createHistoryTableSql = `CREATE TABLE IF NOT EXISTS browse_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        itemType TEXT NOT NULL,
        itemTitle TEXT NOT NULL,
        visitCount INTEGER DEFAULT 1,
        lastVisitTime INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        UNIQUE(userId, itemId, itemType)
      )`;
      await this.store.executeSql(createHistoryTableSql);

      console.info('[RelationalDB] 表创建成功');
    } catch (error) {
      console.error('[RelationalDB] 创建表失败:', JSON.stringify(error));
      throw new Error('Failed to create tables');
    }
  }

  // 用户信息相关
  async saveUserInfo(userInfo: UserInfo): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      userId: userInfo.userId,
      username: userInfo.username,
      email: userInfo.email || '',
      avatar: userInfo.avatar || '',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    return await this.store.insert('users', valueBucket);
  }

  async getUserInfo(userId: string): Promise<UserInfo | null> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('userId', userId);
    
    const resultSet = await this.store.query(predicates);
    
    if (resultSet.goToFirstRow()) {
      const userInfo: UserInfo = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        userId: resultSet.getString(resultSet.getColumnIndex('userId')),
        username: resultSet.getString(resultSet.getColumnIndex('username')),
        email: resultSet.getString(resultSet.getColumnIndex('email')),
        avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
      };
      resultSet.close();
      return userInfo;
    }
    
    resultSet.close();
    return null;
  }

  // 收藏相关
  async addFavorite(favorite: FavoriteRecord): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      userId: favorite.userId,
      itemId: favorite.itemId,
      itemType: favorite.itemType,
      itemTitle: favorite.itemTitle,
      itemDescription: favorite.itemDescription || '',
      itemImageUrl: favorite.itemImageUrl || '',
      createdAt: Date.now()
    };

    return await this.store.insert('favorites', valueBucket);
  }

  async getUserFavorites(userId: string): Promise<FavoriteRecord[]> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('userId', userId);
    predicates.orderByDesc('createdAt');
    
    const resultSet = await this.store.query(predicates);
    const favorites: FavoriteRecord[] = [];
    
    while (resultSet.goToNextRow()) {
      favorites.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        userId: resultSet.getString(resultSet.getColumnIndex('userId')),
        itemId: resultSet.getString(resultSet.getColumnIndex('itemId')),
        itemType: resultSet.getString(resultSet.getColumnIndex('itemType')),
        itemTitle: resultSet.getString(resultSet.getColumnIndex('itemTitle')),
        itemDescription: resultSet.getString(resultSet.getColumnIndex('itemDescription')),
        itemImageUrl: resultSet.getString(resultSet.getColumnIndex('itemImageUrl')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
      });
    }
    
    resultSet.close();
    return favorites;
  }

  async removeFavorite(userId: string, itemId: string, itemType: string): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('userId', userId);
    predicates.equalTo('itemId', itemId);
    predicates.equalTo('itemType', itemType);
    
    return await this.store.delete(predicates);
  }

  // 浏览历史相关
  async addBrowseHistory(history: BrowseHistory): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      userId: history.userId,
      itemId: history.itemId,
      itemType: history.itemType,
      itemTitle: history.itemTitle,
      visitCount: 1,
      lastVisitTime: Date.now(),
      createdAt: Date.now()
    };

    return await this.store.insert('browse_history', valueBucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
  }

  async getUserBrowseHistory(userId: string, limit: number = 50): Promise<BrowseHistory[]> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('browse_history');
    predicates.equalTo('userId', userId);
    predicates.orderByDesc('lastVisitTime');
    predicates.limitAs(limit);
    
    const resultSet = await this.store.query(predicates);
    const histories: BrowseHistory[] = [];
    
    while (resultSet.goToNextRow()) {
      histories.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        userId: resultSet.getString(resultSet.getColumnIndex('userId')),
        itemId: resultSet.getString(resultSet.getColumnIndex('itemId')),
        itemType: resultSet.getString(resultSet.getColumnIndex('itemType')),
        itemTitle: resultSet.getString(resultSet.getColumnIndex('itemTitle')),
        visitCount: resultSet.getLong(resultSet.getColumnIndex('visitCount')),
        lastVisitTime: resultSet.getLong(resultSet.getColumnIndex('lastVisitTime')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
      });
    }
    
    resultSet.close();
    return histories;
  }

  async clearBrowseHistory(userId: string): Promise<number> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates('browse_history');
    predicates.equalTo('userId', userId);
    
    return await this.store.delete(predicates);
  }

  async close(): Promise<void> {
    if (this.store) {
      await relationalStore.deleteRdbStore(globalThis.getContext(), this.dbName);
      this.store = null;
      console.info('[RelationalDB] 数据库已关闭');
    }
  }
}
