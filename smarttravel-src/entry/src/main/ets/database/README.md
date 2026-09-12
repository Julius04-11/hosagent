# 智慧旅行 - 方舟ArkData数据库集成文档

## 概述

本项目已集成华为方舟ArkData数据库，提供键值型和关系型两种数据库存储方案，用于存储用户数据、应用配置、收藏记录、浏览历史等信息。

## 数据库架构

### 1. 键值型数据库（Preferences）

**文件**: `PreferencesManager.ets`

**用途**: 存储简单的键值对数据，如用户设置、应用配置等

**主要功能**:
- 保存/获取字符串、数字、布尔值
- 删除指定键
- 清空所有数据
- 检查键是否存在

**示例**:
```typescript
const prefsManager = PreferencesManager.getInstance();
await prefsManager.initialize(context);

// 保存数据
await prefsManager.putString('theme', 'dark');
await prefsManager.putNumber('fontSize', 16);
await prefsManager.putBoolean('notificationEnabled', true);

// 获取数据
const theme = await prefsManager.getString('theme', 'light');
const fontSize = await prefsManager.getNumber('fontSize', 14);
```

### 2. 关系型数据库（RDB）

**文件**: `RelationalDatabaseManager.ets`

**用途**: 存储复杂的结构化数据

**数据表结构**:

#### 用户信息表 (user_info)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键，自增 |
| userId | TEXT | 用户ID（唯一） |
| username | TEXT | 用户名 |
| email | TEXT | 邮箱 |
| avatar | TEXT | 头像URL |
| preferences | TEXT | 用户偏好（JSON字符串） |
| createdAt | INTEGER | 创建时间（时间戳） |
| updatedAt | INTEGER | 更新时间（时间戳） |

#### 收藏表 (favorites)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键，自增 |
| userId | TEXT | 用户ID |
| itemId | TEXT | 项目ID |
| itemType | TEXT | 项目类型（activity/restaurant/hotel等） |
| itemTitle | TEXT | 项目标题 |
| itemDescription | TEXT | 项目描述 |
| itemImageUrl | TEXT | 项目图片URL |
| createdAt | INTEGER | 创建时间（时间戳） |

#### 浏览历史表 (browse_history)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键，自增 |
| userId | TEXT | 用户ID |
| itemId | TEXT | 项目ID |
| itemType | TEXT | 项目类型 |
| itemTitle | TEXT | 项目标题 |
| visitCount | INTEGER | 访问次数 |
| lastVisitTime | INTEGER | 最后访问时间（时间戳） |
| createdAt | INTEGER | 创建时间（时间戳） |

## 统一服务（DatabaseService）

**文件**: `DatabaseService.ets`

这是一个统一的数据库服务层，封装了键值型和关系型数据库的所有操作，提供简化的API接口。

### 初始化

数据库会在应用启动时（EntryAbility.onCreate）自动初始化：

```typescript
const dbService = DatabaseService.getInstance();
await dbService.initialize(context);
```

### 常用操作

#### 1. 用户设置
```typescript
// 保存设置
await dbService.saveUserSetting('theme', 'dark');
await dbService.saveUserSetting('fontSize', 16);

// 获取设置
const theme = await dbService.getUserSetting('theme', 'light');
```

#### 2. 用户信息
```typescript
// 保存用户信息
const userInfo: UserInfo = {
  userId: 'user_123',
  username: '张三',
  email: 'zhangsan@example.com',
  createdAt: Date.now(),
  updatedAt: Date.now()
};
await dbService.saveUserInfo(userInfo);

// 获取用户信息
const user = await dbService.getUserInfo('user_123');
```

#### 3. 收藏管理
```typescript
// 添加收藏
const favorite: FavoriteRecord = {
  userId: 'user_123',
  itemId: 'restaurant_001',
  itemType: 'restaurant',
  itemTitle: '川味轩',
  createdAt: Date.now()
};
await dbService.addFavorite(favorite);

// 检查是否已收藏
const isFavorited = await dbService.isFavorited('user_123', 'restaurant_001', 'restaurant');

// 获取收藏列表
const favorites = await dbService.getUserFavorites('user_123');

// 删除收藏
await dbService.removeFavorite('user_123', 'restaurant_001', 'restaurant');
```

#### 4. 浏览历史
```typescript
// 添加浏览历史
const history: BrowseHistory = {
  userId: 'user_123',
  itemId: 'attraction_001',
  itemType: 'attraction',
  itemTitle: '世界之窗',
  visitCount: 1,
  lastVisitTime: Date.now(),
  createdAt: Date.now()
};
await dbService.addBrowseHistory(history);

// 获取浏览历史
const histories = await dbService.getUserBrowseHistory('user_123', 10);

// 清空浏览历史
await dbService.clearBrowseHistory('user_123');
```

## 在组件中使用

### 示例：在HomePage中使用

```typescript
import { DatabaseService } from '../database/DatabaseService';
import { BrowseHistory } from '../database/RelationalDatabaseManager';

@Component
export struct HomePage {
  private dbService: DatabaseService = DatabaseService.getInstance();
  
  async aboutToAppear() {
    // 获取当前用户ID
    const userId = await this.dbService.getCurrentUserId();
    
    // 加载用户收藏
    const favorites = await this.dbService.getUserFavorites(userId);
    
    // 加载浏览历史
    const histories = await this.dbService.getUserBrowseHistory(userId, 10);
  }
  
  // 用户点击推荐项时记录浏览历史
  private async handleItemClick(itemId: string, itemTitle: string) {
    const userId = await this.dbService.getCurrentUserId();
    
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
}
```

## 数据库常量

**文件**: `DatabaseService.ets` 中定义了常用的数据库键值常量：

```typescript
export const DB_KEYS = {
  CURRENT_USER_ID: 'current_user_id',
  IS_FIRST_TIME: 'is_first_time',
  LANGUAGE: 'app_language',
  THEME: 'app_theme',
  NOTIFICATION_ENABLED: 'notification_enabled',
  LOCATION_PERMISSION: 'location_permission'
};
```

## 注意事项

1. **异步操作**: 所有数据库操作都是异步的，需要使用 `await` 关键字
2. **错误处理**: 建议在调用数据库操作时添加 try-catch 错误处理
3. **数据同步**: 使用 `@State` 装饰器确保UI能及时更新数据变化
4. **性能优化**: 
   - 避免在循环中频繁调用数据库操作
   - 使用批量操作代替多次单独操作
   - 合理使用数据缓存

## 更多示例

详细的使用示例请参考 `DatabaseUsageExample.ets` 文件。

## 问题排查

如果遇到数据库相关问题：

1. 检查数据库是否正确初始化（在EntryAbility.onCreate中）
2. 查看控制台日志，搜索 `[PreferencesManager]` 和 `[RelationalDB]` 标签
3. 确认Context对象正确传递
4. 检查数据库权限配置

## 技术支持

如有问题，请联系开发团队或查阅华为开发者文档：
- [方舟ArkData官方文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkdata-kit-intro-V5)
