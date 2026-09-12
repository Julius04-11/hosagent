/**
 * 数据库使用示例
 * 展示如何在组件中使用数据库服务
 */
import { DatabaseService } from './DatabaseService';
import { UserInfo, FavoriteRecord, BrowseHistory } from './RelationalDatabaseManager';

export class DatabaseUsageExample {
  private dbService: DatabaseService;
  
  constructor() {
    this.dbService = DatabaseService.getInstance();
  }

  /**
   * 示例1：保存和获取用户设置
   */
  async exampleUserSettings() {
    // 保存设置
    await this.dbService.saveUserSetting('theme', 'dark');
    await this.dbService.saveUserSetting('fontSize', 16);
    await this.dbService.saveUserSetting('notificationEnabled', true);

    // 获取设置
    const theme = await this.dbService.getUserSetting('theme', 'light');
    const fontSize = await this.dbService.getUserSetting('fontSize', 14);
    const notificationEnabled = await this.dbService.getUserSetting('notificationEnabled', false);

    console.log('主题:', theme);
    console.log('字体大小:', fontSize);
    console.log('通知开启:', notificationEnabled);
  }

  /**
   * 示例2：保存和获取用户信息
   */
  async exampleUserInfo() {
    const userId = await this.dbService.getCurrentUserId();

    // 保存用户信息
    const userInfo: UserInfo = {
      userId: userId,
      username: '张三',
      email: 'zhangsan@example.com',
      avatar: 'https://example.com/avatar.jpg',
      preferences: JSON.stringify({
        favoriteCategories: ['美食', '景点'],
        budgetRange: '100-500'
      }),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    await this.dbService.saveUserInfo(userInfo);
    console.log('用户信息已保存');

    // 获取用户信息
    const savedUserInfo = await this.dbService.getUserInfo(userId);
    if (savedUserInfo) {
      console.log('用户名:', savedUserInfo.username);
      console.log('邮箱:', savedUserInfo.email);
    }
  }

  /**
   * 示例3：管理收藏
   */
  async exampleFavorites() {
    const userId = await this.dbService.getCurrentUserId();

    // 添加收藏
    const favorite: FavoriteRecord = {
      userId: userId,
      itemId: 'restaurant_001',
      itemType: 'restaurant',
      itemTitle: '川味轩',
      itemDescription: '正宗川菜馆',
      itemImageUrl: 'https://example.com/restaurant.jpg',
      createdAt: Date.now()
    };

    await this.dbService.addFavorite(favorite);
    console.log('已添加收藏');

    // 检查是否已收藏
    const isFavorited = await this.dbService.isFavorited(userId, 'restaurant_001', 'restaurant');
    console.log('是否已收藏:', isFavorited);

    // 获取收藏列表
    const favorites = await this.dbService.getUserFavorites(userId);
    console.log('收藏数量:', favorites.length);
    favorites.forEach(fav => {
      console.log(`- ${fav.itemTitle} (${fav.itemType})`);
    });

    // 删除收藏
    await this.dbService.removeFavorite(userId, 'restaurant_001', 'restaurant');
    console.log('已删除收藏');
  }

  /**
   * 示例4：管理浏览历史
   */
  async exampleBrowseHistory() {
    const userId = await this.dbService.getCurrentUserId();

    // 添加浏览历史
    const history: BrowseHistory = {
      userId: userId,
      itemId: 'attraction_001',
      itemType: 'attraction',
      itemTitle: '世界之窗',
      visitCount: 1,
      lastVisitTime: Date.now(),
      createdAt: Date.now()
    };

    await this.dbService.addBrowseHistory(history);
    console.log('已添加浏览历史');

    // 再次访问同一项目（会更新访问次数）
    await this.dbService.addBrowseHistory(history);
    console.log('已更新浏览历史');

    // 获取浏览历史
    const histories = await this.dbService.getUserBrowseHistory(userId, 10);
    console.log('浏览历史数量:', histories.length);
    histories.forEach(hist => {
      console.log(`- ${hist.itemTitle}: 访问${hist.visitCount}次`);
    });

    // 清空浏览历史
    // await this.dbService.clearBrowseHistory(userId);
    // console.log('已清空浏览历史');
  }

  /**
   * 示例5：在HomePage中使用数据库
   */
  async exampleInHomePage(itemId: string, itemTitle: string) {
    const userId = await this.dbService.getCurrentUserId();

    // 用户点击某个推荐项时，记录浏览历史
    const history: BrowseHistory = {
      userId: userId,
      itemId: itemId,
      itemType: 'recommendation',
      itemTitle: itemTitle,
      visitCount: 1,
      lastVisitTime: Date.now(),
      createdAt: Date.now()
    };

    await this.dbService.addBrowseHistory(history);
  }

  /**
   * 示例6：在详情页中使用数据库
   */
  async exampleInDetailPage(itemId: string, itemTitle: string, itemType: string) {
    const userId = await this.dbService.getCurrentUserId();

    // 检查是否已收藏
    const isFavorited = await this.dbService.isFavorited(userId, itemId, itemType);

    if (!isFavorited) {
      // 添加到收藏
      const favorite: FavoriteRecord = {
        userId: userId,
        itemId: itemId,
        itemType: itemType,
        itemTitle: itemTitle,
        createdAt: Date.now()
      };
      await this.dbService.addFavorite(favorite);
      return true; // 收藏成功
    } else {
      // 取消收藏
      await this.dbService.removeFavorite(userId, itemId, itemType);
      return false; // 取消收藏
    }
  }
}
