/**
 * 图片资源常量配置
 * 统一管理应用中使用的图片资源
 */

// 移除索引签名，ArkTS不支持

// 景点图片接口
interface AttractionImages {
  WORLD_WINDOW: string;
  HAPPY_VALLEY: string;
  SPLENDID_CHINA: string;
  DAMEISHA_BEACH: string;
  XIAOMEISHA_BEACH: string;
}

// 酒店图片接口
interface HotelImages {
  LUXURY_HOTEL: string;
  BOUTIQUE_HOTEL: string;
  BUSINESS_HOTEL: string;
  RESORT_HOTEL: string;
}

// 餐厅图片接口
interface RestaurantImages {
  SEAFOOD: string;
  NOODLES: string;
  HOTPOT: string;
  CANTONESE: string;
}

// 活动图片接口
interface ActivityImages {
  CULTURAL_FESTIVAL: string;
  MUSIC_CONCERT: string;
  ART_EXHIBITION: string;
  SPORTS_EVENT: string;
}

// 本地资源接口
interface LocalResourcesInterface {
  WORLD_WINDOW_LOCAL: string;
  HAPPY_VALLEY_LOCAL: string;
  SPLENDID_CHINA_LOCAL: string;
  DAMEISHA_BEACH_LOCAL: string;
  LUXURY_HOTEL_LOCAL: string;
  BOUTIQUE_HOTEL_LOCAL: string;
  BUSINESS_HOTEL_LOCAL: string;
  RESORT_HOTEL_LOCAL: string;
  SEAFOOD_RESTAURANT_LOCAL: string;
  HOTPOT_RESTAURANT_LOCAL: string;
  CANTONESE_RESTAURANT_LOCAL: string;
  ICON_HOME: string;
  ICON_SEARCH: string;
  ICON_FAVORITE: string;
  ICON_USER: string;
  ICON_MAP: string;
}

export class ImageConstants {
  // 默认占位图片（本地资源）
  static readonly DEFAULT_PLACEHOLDER: string = 'https://picsum.photos/300/200?grayscale';
  
  // 本地资源引用（推荐使用）
  static readonly LOCAL_RESOURCES: LocalResourcesInterface = {
    // 景点图片
    WORLD_WINDOW_LOCAL: 'world_window.jpg',
    HAPPY_VALLEY_LOCAL: 'happy_valley.jpg',
    SPLENDID_CHINA_LOCAL: 'splendid_china.jpg',
    DAMEISHA_BEACH_LOCAL: 'dameisha_beach.jpg',
    
    // 酒店图片
    LUXURY_HOTEL_LOCAL: 'luxury_hotel.jpg',
    BOUTIQUE_HOTEL_LOCAL: 'boutique_hotel.jpg',
    BUSINESS_HOTEL_LOCAL: 'business_hotel.jpg',
    RESORT_HOTEL_LOCAL: 'resort_hotel.jpg',
    
    // 餐厅图片
    SEAFOOD_RESTAURANT_LOCAL: 'seafood_restaurant.jpg',
    HOTPOT_RESTAURANT_LOCAL: 'hotpot_restaurant.jpg',
    CANTONESE_RESTAURANT_LOCAL: 'cantonese_restaurant.jpg',
    
    // UI图标
    ICON_HOME: 'icon_home.png',
    ICON_SEARCH: 'icon_search.png',
    ICON_FAVORITE: 'icon_favorite.png',
    ICON_USER: 'icon_user.png',
    ICON_MAP: 'icon_map.png'
  };
  
  // 景点类别图片
  static readonly ATTRACTION_IMAGES: AttractionImages = {
    WORLD_WINDOW: 'https://picsum.photos/id/100/400/300',
    HAPPY_VALLEY: 'https://picsum.photos/id/101/400/300',
    SPLENDID_CHINA: 'https://picsum.photos/id/102/400/300',
    DAMEISHA_BEACH: 'https://picsum.photos/id/103/400/300',
    XIAOMEISHA_BEACH: 'https://picsum.photos/id/104/400/300'
  };

  // 酒店类别图片
  static readonly HOTEL_IMAGES: HotelImages = {
    LUXURY_HOTEL: 'https://picsum.photos/id/301/400/300',
    BOUTIQUE_HOTEL: 'https://picsum.photos/id/302/400/300',
    BUSINESS_HOTEL: 'https://picsum.photos/id/303/400/300',
    RESORT_HOTEL: 'https://picsum.photos/id/304/400/300'
  };

  // 餐厅类别图片
  static readonly RESTAURANT_IMAGES: RestaurantImages = {
    SEAFOOD: 'https://picsum.photos/id/292/400/300',
    NOODLES: 'https://picsum.photos/id/293/400/300',
    HOTPOT: 'https://picsum.photos/id/294/400/300',
    CANTONESE: 'https://picsum.photos/id/295/400/300'
  };

  // 活动类别图片
  static readonly ACTIVITY_IMAGES: ActivityImages = {
    CULTURAL_FESTIVAL: 'https://picsum.photos/id/103/400/300',
    MUSIC_CONCERT: 'https://picsum.photos/id/104/400/300',
    ART_EXHIBITION: 'https://picsum.photos/id/105/400/300',
    SPORTS_EVENT: 'https://picsum.photos/id/106/400/300'
  };

  // 用户头像默认图片
  static readonly DEFAULT_AVATAR = $r('app.string.AvatarUrl');

  // 推荐图片轮播
  static readonly RECOMMENDED_IMAGES = [
    $r('app.string.GreenParkUrl'),
    $r('app.string.LampActivityUrl'),
    $r('app.string.WaterStreetUrl'),
    $r('app.string.BiFengGorgeUrl'),
    $r('app.string.GreenMountainUrl')
  ];

  /**
   * 获取本地资源路径（推荐）
   * 使用rawfile或media目录中的图片
   */
  static getLocalResource(filename: string): string {
    // 返回rawfile路径，用于Image组件
    return `rawfile/images/${filename}`;
  }
  
  /**
   * 获取media资源引用（推荐用于已添加到media目录的资源）
   */
  static getMediaResource(name: string): Resource | string {
    // 如果图片已添加到resources/base/media/，使用$r引用
    // 否则返回占位符
    try {
      return $r(`app.media.${name}`);
    } catch (e) {
      console.warn(`[ImageConstants] 本地资源不存在: ${name}，使用占位符`);
      return ImageConstants.DEFAULT_PLACEHOLDER;
    }
  }
  
  /**
   * 根据类型获取默认图片
   */
  static getDefaultImageByType(type: string): string {
    switch (type) {
      case 'attraction':
        return ImageConstants.ATTRACTION_IMAGES.WORLD_WINDOW;
      case 'hotel':
        return ImageConstants.HOTEL_IMAGES.LUXURY_HOTEL;
      case 'restaurant':
        return ImageConstants.RESTAURANT_IMAGES.SEAFOOD;
      case 'activity':
        return ImageConstants.ACTIVITY_IMAGES.CULTURAL_FESTIVAL;
      default:
        return ImageConstants.DEFAULT_PLACEHOLDER;
    }
  }

  /**
   * 获取随机图片
   */
  static getRandomImage(category?: string): string {
    const categories = ['attraction', 'hotel', 'restaurant', 'activity'];
    const selectedCategory = category || categories[Math.floor(Math.random() * categories.length)];
    return ImageConstants.getDefaultImageByType(selectedCategory);
  }

  /**
   * 检查图片URL是否有效
   */
  static isValidImageUrl(url: string): boolean {
    return !!url && (url.startsWith('http') || url.startsWith('$r('));
  }

  /**
   * 获取安全的图片URL（如果无效则返回默认图片）
   */
  static getSafeImageUrl(url: string, fallbackType?: string): string {
    if (ImageConstants.isValidImageUrl(url)) {
      return url;
    }
    return fallbackType ? ImageConstants.getDefaultImageByType(fallbackType) : ImageConstants.DEFAULT_PLACEHOLDER;
  }
}
