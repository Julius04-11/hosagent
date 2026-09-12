/**
 * 首页ViewModel - 管理首页相关的业务逻辑
 * 负责首页数据加载、用户行为记录、AI推荐管理
 */
import { display } from '@kit.ArkUI';
import { ActivityDetail } from '../model/ActivityModel';
import { UserBehavior, BehaviorType, PreferenceType, BehaviorContext } from '../model/UserBehaviorModel';
import { AIRecommendationEngine } from '../service/AIRecommendationService';

interface ListItemInfo {
  image: Resource;
  title: string;
  description: string;
}

export class HomeViewModel {
  // 首页数据状态
  availableActivities: ActivityDetail[] = [];
  showAIRecommendations: boolean = true;
  swiperIndex: number = 0;
  
  // 设备信息
  deviceWidth: number = 0;
  maxCount: number = 1;
  
  // 用户信息
  userId: string = 'user_' + Date.now();
  
  // UI状态
  isLoading: boolean = false;
  
  private aiEngine: AIRecommendationEngine = AIRecommendationEngine.getInstance();
  
  private recommendedImages: string[] = [
    'https://p3.img.cctvpic.com/photoworkspace/contentimg/2019/05/05/2019050515335593405.jpg',
    'https://askthescientists.com/wp-content/uploads/2018/07/Outdoors-AdobeStock_203673414-835x418.jpg',
    'https://cxfile.advences.com/CFAVOYAGES/photo/shutterstock_638541712.jpg'
  ];
  
  private listInfos: ListItemInfo[] = [
    {
      image: $r('app.string.GreenParkUrl'),
      title: '世界之窗国际文化节',
      description: '2025年10月10日 | 世界之窗 | 体验世界文化魅力'
    },
    {
      image: $r('app.string.LampActivityUrl'),
      title: '欢乐谷万圣节狂欢夜',
      description: '2025年10月15日 | 欢乐谷 | 万圣节主题乐园狂欢'
    },
    {
      image: $r('app.string.WaterStreetUrl'),
      title: '东部华侨城生态徒步',
      description: '2025年10月18日 | 东部华侨城 | 亲近自然生态体验'
    },
    {
      image: $r('app.string.BiFengGorgeUrl'),
      title: '大梅沙海滨音乐节',
      description: '2025年10月22日 | 大梅沙海滨公园 | 海滨音乐盛宴'
    },
    {
      image: $r('app.string.GreenMountainUrl'),
      title: '莲花山公园风筝节',
      description: '2025年10月28日 | 莲花山公园 | 亲子风筝体验活动'
    }
  ];

  /**
   * 初始化首页数据
   */
  async initialize(): Promise<void> {
    this.updateWidth();
    await this.loadMockActivities();
    await this.initializeUserBehavior();
  }

  /**
   * 更新设备宽度
   */
  updateWidth(): void {
    const defaultDisplay = display.getDefaultDisplaySync();
    this.deviceWidth = defaultDisplay.width;
    if (this.deviceWidth >= 4200) {
      this.maxCount = 3;
    } else if (this.deviceWidth >= 2400) {
      this.maxCount = 2;
    } else {
      this.maxCount = 1;
    }
  }

  /**
   * 加载模拟活动数据
   */
  async loadMockActivities(): Promise<ActivityDetail[]> {
    this.isLoading = true;
    try {
      // 模拟活动数据，实际应从API获取
      const activities: ActivityDetail[] = [
        {
          activityId: 1,
          title: '世界之窗国际文化节',
          carouselImages: ['https://p3.img.cctvpic.com/photoworkspace/contentimg/2019/05/05/2019050515335593405.jpg'],
          sections: [],
          enrollmentAvailable: true,
          enrollmentText: '立即报名',
          enrollmentLink: ''
        } as ActivityDetail,
        {
          activityId: 2,
          title: '欢乐谷万圣节狂欢夜',
          carouselImages: ['https://askthescientists.com/wp-content/uploads/2018/07/Outdoors-AdobeStock_203673414-835x418.jpg'],
          sections: [],
          enrollmentAvailable: true,
          enrollmentText: '立即报名',
          enrollmentLink: ''
        } as ActivityDetail,
        {
          activityId: 3,
          title: '东部华侨城生态徒步',
          carouselImages: ['https://cxfile.advences.com/CFAVOYAGES/photo/shutterstock_638541712.jpg'],
          sections: [],
          enrollmentAvailable: true,
          enrollmentText: '立即报名',
          enrollmentLink: ''
        } as ActivityDetail
      ];
      
      this.availableActivities = activities;
      return activities;
    } catch (error) {
      console.error('加载活动数据失败:', error);
      return [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 初始化用户行为数据
   */
  async initializeUserBehavior(): Promise<void> {
    // 模拟一些初始用户行为，帮助AI学习用户偏好
    const context1: BehaviorContext = {
      timeOfDay: 'morning',
      dayOfWeek: 'saturday',
      season: 'autumn'
    };
    
    const context2: BehaviorContext = {
      timeOfDay: 'evening',
      dayOfWeek: 'friday',
      season: 'autumn'
    };
    
    const initialBehaviors: UserBehavior[] = [
      {
        id: 'init_1',
        userId: this.userId,
        behaviorType: BehaviorType.VIEW,
        targetId: '1',
        targetType: PreferenceType.CULTURAL_EXPERIENCE,
        timestamp: Date.now() - 86400000, // 1天前
        context: context1
      },
      {
        id: 'init_2',
        userId: this.userId,
        behaviorType: BehaviorType.CLICK,
        targetId: '2',
        targetType: PreferenceType.ENTERTAINMENT,
        timestamp: Date.now() - 172800000, // 2天前
        context: context2
      }
    ];

    // 记录初始行为
    for (const behavior of initialBehaviors) {
      await this.aiEngine.recordUserBehavior(behavior);
    }
  }

  /**
   * 记录用户行为
   */
  async recordUserBehavior(
    behaviorType: BehaviorType,
    targetId: string,
    targetType: PreferenceType
  ): Promise<void> {
    const context: BehaviorContext = {
      timeOfDay: this.getTimeOfDay(),
      dayOfWeek: this.getDayOfWeek(),
      season: this.getCurrentSeason()
    };
    
    const behavior: UserBehavior = {
      id: `behavior_${Date.now()}`,
      userId: this.userId,
      behaviorType: behaviorType,
      targetId: targetId,
      targetType: targetType,
      timestamp: Date.now(),
      context: context
    };
    
    await this.aiEngine.recordUserBehavior(behavior);
  }

  /**
   * 导航到活动页面
   */
  async navigateToActivity(category: string): Promise<void> {
    console.log(`导航到活动页面，分类：${category}`);
    
    // 记录用户行为
    await this.recordUserBehavior(
      BehaviorType.CLICK,
      category,
      PreferenceType.SCENIC_SPOTS
    );
  }

  /**
   * 获取时间段
   */
  private getTimeOfDay(): string {
    const hour = new Date().getHours();
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  /**
   * 获取星期几
   */
  private getDayOfWeek(): string {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[new Date().getDay()];
  }

  /**
   * 获取当前季节
   */
  private getCurrentSeason(): string {
    const month = new Date().getMonth() + 1;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  /**
   * 获取推荐图片列表
   */
  getRecommendedImages(): string[] {
    return this.recommendedImages;
  }

  /**
   * 获取列表信息
   */
  getListInfos(): ListItemInfo[] {
    return this.listInfos;
  }

  /**
   * 更新轮播图索引
   */
  updateSwiperIndex(index: number): void {
    this.swiperIndex = index;
  }

  /**
   * 切换AI推荐显示状态
   */
  toggleAIRecommendations(): void {
    this.showAIRecommendations = !this.showAIRecommendations;
  }
}

