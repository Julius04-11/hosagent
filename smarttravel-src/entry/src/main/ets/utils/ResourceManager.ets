/**
 * 资源管理器 - 统一管理图片、音频等媒体资源
 * 解决Base64性能问题，支持本地资源和缓存
 */

export class ResourceManager {
  private static instance: ResourceManager;
  private imageCache: Map<string, Resource> = new Map();

  private constructor() {}

  static getInstance(): ResourceManager {
    if (!ResourceManager.instance) {
      ResourceManager.instance = new ResourceManager();
    }
    return ResourceManager.instance;
  }

  /**
   * 获取景点图片
   */
  getAttractionImage(name: string): Resource {
    const key = `attraction_${name}`;
    if (this.imageCache.has(key)) {
      return this.imageCache.get(key)!;
    }

    // 使用本地资源
    const images: Record<string, Resource> = {
      'world_window': $r('app.media.world_window'),
      'happy_valley': $r('app.media.happy_valley'),
      'splendid_china': $r('app.media.splendid_china'),
      'dameisha_beach': $r('app.media.dameisha_beach'),
      'lianhua_mountain': $r('app.media.lianhua_mountain'),
      'shenzhen_bay_park': $r('app.media.shenzhen_bay_park'),
      'default': $r('app.media.placeholder')
    };

    const resource = images[name] || images['default'];
    this.imageCache.set(key, resource);
    return resource;
  }

  /**
   * 获取餐厅图片
   */
  getRestaurantImage(type: string): Resource {
    const images: Record<string, Resource> = {
      'seafood': $r('app.media.seafood_restaurant'),
      'hotpot': $r('app.media.hotpot_restaurant'),
      'cantonese': $r('app.media.cantonese_restaurant'),
      'western': $r('app.media.western_restaurant'),
      'default': $r('app.media.placeholder')
    };
    return images[type] || images['default'];
  }

  /**
   * 获取酒店图片
   */
  getHotelImage(type: string): Resource {
    const images: Record<string, Resource> = {
      'luxury': $r('app.media.luxury_hotel'),
      'boutique': $r('app.media.boutique_hotel'),
      'business': $r('app.media.business_hotel'),
      'resort': $r('app.media.resort_hotel'),
      'default': $r('app.media.placeholder')
    };
    return images[type] || images['default'];
  }

  /**
   * 获取UI图标
   */
  getIcon(name: string): Resource {
    const icons: Record<string, Resource> = {
      'home': $r('app.media.startIcon'),
      'search': $r('app.media.startIcon'),
      'favorite': $r('app.media.startIcon'),
      'user': $r('app.media.default_avatar'),
      'map': $r('app.media.startIcon'),
      'calendar': $r('app.media.startIcon'),
      'settings': $r('app.media.startIcon')
    };
    return icons[name] || $r('app.media.startIcon');
  }

  /**
   * 获取占位图片（加载失败时使用）
   */
  getPlaceholder(type?: string): Resource {
    return $r('app.media.placeholder');
  }

  /**
   * 清除缓存
   */
  clearCache(): void {
    this.imageCache.clear();
  }

  /**
   * 获取缓存大小
   */
  getCacheSize(): number {
    return this.imageCache.size;
  }
}

/**
 * 音频资源管理
 */
export class AudioManager {
  private static instance: AudioManager;

  private constructor() {}

  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  /**
   * 获取景点导览音频
   */
  getAttractionAudio(name: string): string {
    return `rawfile/audio/attractions/${name}_guide.mp3`;
  }

  /**
   * 获取UI提示音
   */
  getUISound(type: string): string {
    const sounds: Record<string, string> = {
      'click': 'rawfile/audio/ui/button_click.mp3',
      'success': 'rawfile/audio/ui/success.mp3',
      'error': 'rawfile/audio/ui/error.mp3',
      'notification': 'rawfile/audio/ui/notification.mp3'
    };
    return sounds[type] || sounds['click'];
  }
}

/**
 * 使用示例
 * 
 * // 获取图片
 * const rm = ResourceManager.getInstance();
 * const image = rm.getAttractionImage('world_window');
 * 
 * // 在组件中使用
 * Image(image)
 *   .width(200)
 *   .height(150)
 * 
 * // 获取音频
 * const am = AudioManager.getInstance();
 * const audioPath = am.getAttractionAudio('world_window');
 */
