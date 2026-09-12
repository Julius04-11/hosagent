import { TopNavigationBar } from '../../components/TopNavigationBar';
import { router } from '@kit.ArkUI';

interface SocialUser {
  userId: string;
  username: string;
  avatar: string;
  location: string;
}

interface TravelShare {
  id: string;
  userId: string;
  content: string;
  images: string[];
  timestamp: number;
}

interface NearbyUser {
  userId: string;
  username: string;
  avatar: string;
  distance: number;
}

interface TravelChallenge {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  target: number;
  unit: string;
  reward: {
    points: number;
    badge: string;
  };
  startDate: number;
  endDate: number;
  participants: string[];
  isActive: boolean;
}

class SocialTravelService {
  private static instance: SocialTravelService;
  
  static getInstance(): SocialTravelService {
    if (!this.instance) {
      this.instance = new SocialTravelService();
    }
    return this.instance;
  }
  
  async initializeCurrentUser(userId: string): Promise<SocialUser> {
    return {
      userId,
      username: '旅行者',
      avatar: '👤',
      location: '深圳'
    };
  }
  
  async getFeed(userId: string, limit: number, offset: number): Promise<TravelShare[]> {
    return [];
  }
  
  async getNearbyUsers(userId: string, radius: number): Promise<NearbyUser[]> {
    return [];
  }
  
  async publishTravelShare(share: any): Promise<TravelShare> {
    return {
      id: Date.now().toString(),
      userId: share.userId,
      content: share.content,
      images: [],
      timestamp: Date.now()
    };
  }
}

/**
 * 社交旅行页面
 * 提供社交化旅行功能
 */
@Entry
@Component
export struct SocialTravelPage {
  @State currentTab: number = 0;
  @State currentUser: SocialUser | null = null;
  @State feed: TravelShare[] = [];
  @State nearbyUsers: NearbyUser[] = [];
  @State challenges: TravelChallenge[] = [];
  @State isLoading: boolean = false;
  @State newShareContent: string = '';
  @State showShareDialog: boolean = false;

  private socialService: SocialTravelService = SocialTravelService.getInstance();
  private userId: string = 'user_' + Date.now();

  async aboutToAppear() {
    await this.initializePage();
  }

  // 初始化页面
  private async initializePage() {
    this.isLoading = true;
    
    try {
      // 初始化当前用户
      this.currentUser = await this.socialService.initializeCurrentUser(this.userId);
      
      // 加载数据
      await this.loadFeed();
      await this.loadNearbyUsers();
      await this.loadChallenges();
      
    } catch (error) {
      console.error('初始化页面失败:', error);
    }
    
    this.isLoading = false;
  }

  // 加载动态流
  private async loadFeed() {
    if (!this.currentUser) return;
    
    this.feed = await this.socialService.getFeed(this.currentUser.userId, 20, 0);
  }

  // 加载附近用户
  private async loadNearbyUsers() {
    if (!this.currentUser) return;
    
    this.nearbyUsers = await this.socialService.getNearbyUsers(this.currentUser.userId, 5000);
  }

  // 加载挑战
  private async loadChallenges() {
    // 模拟挑战数据
    this.challenges = [
      {
        id: 'challenge_001',
        title: '城市探索者',
        description: '在30天内打卡10个不同的景点',
        icon: '🏙️',
        color: '#1e40af',
        target: 10,
        unit: '个景点',
        reward: {
          points: 500,
          badge: '城市探索者'
        },
        startDate: Date.now(),
        endDate: Date.now() + 30 * 24 * 60 * 60 * 1000,
        participants: [],
        isActive: true
      },
      {
        id: 'challenge_002',
        title: '摄影达人',
        description: '分享20张旅行照片',
        icon: '📸',
        color: '#059669',
        target: 20,
        unit: '张照片',
        reward: {
          points: 300,
          badge: '摄影达人'
        },
        startDate: Date.now(),
        endDate: Date.now() + 15 * 24 * 60 * 60 * 1000,
        participants: [],
        isActive: true
      }
    ];
  }

  // 发布分享
  private async publishShare() {
    if (!this.newShareContent.trim() || !this.currentUser) return;
    
    try {
      const share = await this.socialService.publishTravelShare({
        userId: this.currentUser.userId,
        shareType: 'text' as 'text' | 'image' | 'video',
        title: '新的分享',
        content: this.newShareContent,
        images: [],
        tags: ['分享'],
        isPublic: true
      });
      
      this.newShareContent = '';
      this.showShareDialog = false;
      await this.loadFeed();
      
      console.log('分享发布成功');
    } catch (error) {
      console.error('发布分享失败:', error);
    }
  }

  // 切换标签页
  private switchTab(tabIndex: number) {
    this.currentTab = tabIndex;
  }

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '社交旅行',
        showBack: true,
        showSearch: false,
        showNotification: true,
        showProfile: true
      })

      // 标签页切换
      Row() {
        Button() {
          Text('动态')
            .fontSize(14)
            .fontColor(this.currentTab === 0 ? Color.White : '#6b7280')
        }
        .layoutWeight(1)
        .height(40)
        .backgroundColor(this.currentTab === 0 ? '#1e40af' : '#f1f5f9')
        .borderRadius(20)
        .onClick(() => {
          this.switchTab(0);
        })
        
        Button() {
          Text('附近')
            .fontSize(14)
            .fontColor(this.currentTab === 1 ? Color.White : '#6b7280')
        }
        .layoutWeight(1)
        .height(40)
        .backgroundColor(this.currentTab === 1 ? '#1e40af' : '#f1f5f9')
        .borderRadius(20)
        .margin({ left: 8 })
        .onClick(() => {
          this.switchTab(1);
        })
        
        Button() {
          Text('挑战')
            .fontSize(14)
            .fontColor(this.currentTab === 2 ? Color.White : '#6b7280')
        }
        .layoutWeight(1)
        .height(40)
        .backgroundColor(this.currentTab === 2 ? '#1e40af' : '#f1f5f9')
        .borderRadius(20)
        .margin({ left: 8 })
        .onClick(() => {
          this.switchTab(2);
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#1e40af')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#6b7280')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 动态流
        if (this.currentTab === 0) {
          this.FeedTab()
        }
        // 附近用户
        else if (this.currentTab === 1) {
          this.NearbyTab()
        }
        // 挑战
        else if (this.currentTab === 2) {
          this.ChallengesTab()
        }
      }

      // 发布按钮
      Button() {
        Text('✏️')
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width(56)
      .height(56)
      .backgroundColor('#1e40af')
      .borderRadius(28)
      .position({ x: '100%', y: '100%' })
      .translate({ x: -72, y: -72 })
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.2)',
        offsetX: 0,
        offsetY: 4
      })
      .onClick(() => {
        this.showShareDialog = true;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder FeedTab() {
    Scroll() {
      Column() {
        ForEach(this.feed ?? [], (share: TravelShare, index: number) => {
          TravelShareCard({
            share: share,
            currentUserId: this.userId
          })
        }, (share: TravelShare, index: number) => `feed-${share.id}-${index}`)
      }
      .padding({ left: 16, right: 16, bottom: 80 })
    }
    .scrollBar(BarState.Auto)
    .layoutWeight(1)
  }

  @Builder NearbyTab() {
    Scroll() {
      Column() {
        ForEach(this.nearbyUsers ?? [], (nearbyUser: NearbyUser, index: number) => {
          NearbyUserCard({
            nearbyUser: nearbyUser,
            currentUserId: this.userId
          })
        }, (nearbyUser: NearbyUser, index: number) => `nearby-${nearbyUser.userId}-${index}`)
      }
      .padding({ left: 16, right: 16, bottom: 80 })
    }
    .scrollBar(BarState.Auto)
    .layoutWeight(1)
  }

  @Builder ChallengesTab() {
    Scroll() {
      Column() {
        ForEach(this.challenges ?? [], (challenge: TravelChallenge, index: number) => {
          TravelChallengeCard({
            challenge: challenge,
            currentUserId: this.userId
          })
        }, (challenge: TravelChallenge, index: number) => `challenge-${challenge.id}-${index}`)
      }
      .padding({ left: 16, right: 16, bottom: 80 })
    }
    .scrollBar(BarState.Auto)
    .layoutWeight(1)
  }
}
