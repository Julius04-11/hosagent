/**
 * 本地图片资源常量配置
 * 统一管理media目录中的图片资源
 */
export class LocalImageConstants {
  // 海景图片
  static readonly DAMEISHA_BEACH = $r('app.media.dameisha_beach');
  
  // 酒店图片
  static readonly BOUTIQUE_HOTEL = $r('app.media.boutique_hotel');
  static readonly BUSINESS_HOTEL = $r('app.media.business_hotel');
  static readonly LUXURY_HOTEL = $r('app.media.luxury_hotel');
  static readonly RESORT_HOTEL = $r('app.media.resort_hotel');
  
  // 餐饮图片
  static readonly CANTONESE_RESTAURANT = $r('app.media.cantonese_restaurant');
  static readonly HOTPOT_RESTAURANT = $r('app.media.hotpot_restaurant');
  static readonly SEAFOOD_RESTAURANT = $r('app.media.seafood_restaurant');
  static readonly WESTERN_RESTAURANT = $r('app.media.western_restaurant');
  
  // 景点图片
  static readonly HAPPY_VALLEY = $r('app.media.happy_valley');
  static readonly LIANHUA_MOUNTAIN = $r('app.media.lianhua_mountain');
  static readonly SHENZHEN_BAY_PARK = $r('app.media.shenzhen_bay_park');
  static readonly SPLENDID_CHINA = $r('app.media.splendid_china');
  static readonly WORLD_WINDOW = $r('app.media.world_window');
  
  // 默认图片
  static readonly PLACEHOLDER = $r('app.media.placeholder');
  static readonly DEFAULT_AVATAR = $r('app.media.default_avatar');
  static readonly BACKGROUND = $r('app.media.background');
  static readonly FOREGROUND = $r('app.media.foreground');
  static readonly START_ICON = $r('app.media.startIcon');
  
  /**
   * 根据类别获取默认图片
   */
  static getDefaultImageByCategory(category: string): Resource {
    switch (category) {
      case 'beach':
      case 'sea':
        return LocalImageConstants.DAMEISHA_BEACH;
      case 'hotel':
      case 'accommodation':
        return LocalImageConstants.BOUTIQUE_HOTEL;
      case 'food':
      case 'restaurant':
        return LocalImageConstants.CANTONESE_RESTAURANT;
      case 'attraction':
      case 'scenic':
        return LocalImageConstants.WORLD_WINDOW;
      case 'nature':
        return LocalImageConstants.LIANHUA_MOUNTAIN;
      case 'park':
        return LocalImageConstants.SHENZHEN_BAY_PARK;
      default:
        return LocalImageConstants.PLACEHOLDER;
    }
  }
  
  /**
   * 获取所有酒店图片（用于轮播）
   */
  static getAllHotelImages(): Resource[] {
    return [
      LocalImageConstants.BOUTIQUE_HOTEL,
      LocalImageConstants.BUSINESS_HOTEL,
      LocalImageConstants.LUXURY_HOTEL,
      LocalImageConstants.RESORT_HOTEL
    ];
  }
  
  /**
   * 获取所有餐饮图片（用于轮播）
   */
  static getAllFoodImages(): Resource[] {
    return [
      LocalImageConstants.CANTONESE_RESTAURANT,
      LocalImageConstants.HOTPOT_RESTAURANT,
      LocalImageConstants.SEAFOOD_RESTAURANT,
      LocalImageConstants.WESTERN_RESTAURANT
    ];
  }
  
  /**
   * 获取所有景点图片（用于轮播）
   */
  static getAllAttractionImages(): Resource[] {
    return [
      LocalImageConstants.HAPPY_VALLEY,
      LocalImageConstants.LIANHUA_MOUNTAIN,
      LocalImageConstants.SHENZHEN_BAY_PARK,
      LocalImageConstants.SPLENDID_CHINA,
      LocalImageConstants.WORLD_WINDOW
    ];
  }
}
