import { AIRecommendationEngine } from '../service/AIRecommendationService';
import { Recommendation, RecommendationContext, UserBehavior, BehaviorType, BehaviorContext } from '../model/UserBehaviorModel';
import { ActivityDetail } from '../model/ActivityModel';
import { LocationService } from '../utils/LocationUtils';
import { AnimationUtils } from '../utils/AnimationUtils';

/**
 * 智能推荐卡片组件
 * 显示个性化推荐内容
 */
@Component
export struct SmartRecommendationCard {
  @Prop recommendation: Recommendation;
  @Prop userId: string;
  @State isAnimating: boolean = false;
  @State isFavorited: boolean = false;

  private aiEngine: AIRecommendationEngine = AIRecommendationEngine.getInstance();

  // 处理推荐点击
  private async handleRecommendationClick() {
    if (this.isAnimating) return;
    
    this.isAnimating = true;
    
    // 记录用户行为
    await this.recordUserBehavior(BehaviorType.CLICK);
    
    // 添加点击动画
    await AnimationUtils.favoriteToggleAnimation(
      this.getUIContext(),
      { scale: (value) => {} },
      true,
      200
    );
    
    this.isAnimating = false;
    
    // 跳转到活动详情页面
    // router.pushUrl({
    //   url: 'pages/activity/ActivityDetailPage',
    //   params: { id: this.recommendation.targetId }
    // });
  }

  // 处理收藏操作
  private async handleFavoriteToggle() {
    if (this.isAnimating) return;
    
    this.isAnimating = true;
    this.isFavorited = !this.isFavorited;
    
    // 记录用户行为
    await this.recordUserBehavior(
      this.isFavorited ? BehaviorType.FAVORITE : BehaviorType.VIEW
    );
    
    // 添加收藏动画
    await AnimationUtils.favoriteToggleAnimation(
      this.getUIContext(),
      { scale: (value) => {} },
      this.isFavorited,
      300
    );
    
    this.isAnimating = false;
  }

  // 记录用户行为
  private async recordUserBehavior(behaviorType: BehaviorType) {
    const context: BehaviorContext = {
      timeOfDay: this.getTimeOfDay(),
      dayOfWeek: this.getDayOfWeek(),
      season: this.getCurrentSeason()
    };
    
    const behavior: UserBehavior = {
      id: `behavior_${Date.now()}`,
      userId: this.userId,
      behaviorType: behaviorType,
      targetId: this.recommendation.targetId,
      targetType: this.recommendation.targetType,
      timestamp: Date.now(),
      context: context
    };
    
    await this.aiEngine.recordUserBehavior(behavior);
  }

  // 获取时间段
  private getTimeOfDay(): string {
    const hour = new Date().getHours();
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  // 获取星期几
  private getDayOfWeek(): string {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[new Date().getDay()];
  }

  // 获取当前季节
  private getCurrentSeason(): string {
    const month = new Date().getMonth() + 1;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  build() {
    Column() {
      // 推荐标签
      Row() {
        Text('🤖 AI推荐')
          .fontSize(12)
          .fontColor('#1e40af')
          .backgroundColor('#f0f8ff')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
        
        Blank()
        
        // 推荐分数
        Text(`${Math.round(this.recommendation.score * 100)}%`)
          .fontSize(12)
          .fontColor('#059669')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 推荐图片
      Stack() {
        Image(this.recommendation.imageUrl)
          .width('100%')
          .height(120)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
        
        // 推荐理由标签
        Text(this.recommendation.reason)
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .position({ x: 8, y: 8 })
      }
      .width('100%')
      .height(120)
      .margin({ bottom: 12 })

      // 推荐内容
      Column() {
        Text(this.recommendation.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
        
        Text(this.recommendation.description)
          .fontSize(14)
          .fontColor('#6b7280')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        // 标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.recommendation?.tags ?? [], (tag: string, index: number) => {
            Text(`#${tag}`)
              .fontSize(10)
              .fontColor('#1e40af')
              .backgroundColor('#f0f8ff')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 4, bottom: 4 })
          }, (tag: string, index: number) => `srec-tag-${index}-${tag}`)
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 操作按钮
        Row() {
          Button() {
            Text('查看详情')
              .fontSize(14)
              .fontColor(Color.White)
          }
          .layoutWeight(1)
          .height(36)
          .backgroundColor('#1e40af')
          .borderRadius(18)
          .onClick(() => {
            this.handleRecommendationClick();
          })
          
          Button() {
            Text(this.isFavorited ? '❤️' : '🤍')
              .fontSize(16)
          }
          .width(36)
          .height(36)
          .backgroundColor(Color.Transparent)
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => {
            this.handleFavoriteToggle();
          })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .scale({ x: this.isAnimating ? 0.95 : 1, y: this.isAnimating ? 0.95 : 1 })
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }
}

/**
 * 智能推荐列表组件
 * 显示个性化推荐列表
 */
@Component
export struct SmartRecommendationList {
  @Prop userId: string;
  @Prop availableActivities: ActivityDetail[];
  @State recommendations: Recommendation[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private aiEngine: AIRecommendationEngine = AIRecommendationEngine.getInstance();
  private locationService: LocationService = LocationService.getInstance();

  async aboutToAppear() {
    await this.loadRecommendations();
  }

  // 加载推荐
  private async loadRecommendations() {
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      // 获取当前上下文
      const context = await this.getRecommendationContext();
      
      // 获取个性化推荐
      this.recommendations = await this.aiEngine.getPersonalizedRecommendations(
        this.userId,
        context,
        this.availableActivities
      );
      
      console.log(`获取到 ${this.recommendations.length} 个个性化推荐`);
    } catch (error) {
      console.error('加载推荐失败:', error);
      this.errorMessage = '推荐加载失败，请稍后重试';
    }
    
    this.isLoading = false;
  }

  // 获取推荐上下文
  private async getRecommendationContext(): Promise<RecommendationContext> {
    const currentLocation = await this.locationService.getCurrentLocation();
    
    const context: RecommendationContext = {
      currentLocation: currentLocation ? {
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude
      } : undefined,
      timeOfDay: this.getTimeOfDay(),
      weather: 'sunny', // 模拟天气，实际应从天气API获取
      season: this.getCurrentSeason(),
      budget: 500, // 模拟预算
      timeAvailable: 4, // 模拟可用时间
      companions: 2 // 模拟同行人数
    };
    
    return context;
  }

  // 刷新推荐
  private async refreshRecommendations() {
    await this.loadRecommendations();
  }

  // 获取时间段
  private getTimeOfDay(): string {
    const hour = new Date().getHours();
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  // 获取当前季节
  private getCurrentSeason(): string {
    const month = new Date().getMonth() + 1;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('🤖 智能推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
        
        Blank()
        
        Button() {
          Text('🔄')
            .fontSize(16)
            .fontColor('#6b7280')
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.refreshRecommendations();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 推荐内容
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#1e40af')
          
          Text('AI正在为您分析...')
            .fontSize(14)
            .fontColor('#6b7280')
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.errorMessage) {
        Column() {
          Text('⚠️')
            .fontSize(32)
            .fontColor('#f59e0b')
            .margin({ bottom: 8 })
          
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#6b7280')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 12 })
          
          Button() {
            Text('重试')
              .fontSize(14)
              .fontColor(Color.White)
          }
          .height(32)
          .backgroundColor('#1e40af')
          .borderRadius(16)
          .onClick(() => {
            this.refreshRecommendations();
          })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.recommendations.length === 0) {
        Column() {
          Text('🎯')
            .fontSize(32)
            .fontColor('#6b7280')
            .margin({ bottom: 8 })
          
          Text('暂无个性化推荐')
            .fontSize(14)
            .fontColor('#6b7280')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.recommendations ?? [], (recommendation: Recommendation, index: number) => {
              SmartRecommendationCard({
                recommendation: recommendation,
                userId: this.userId
              })
              .margin({ bottom: 16 })
            }, (recommendation: Recommendation, index: number) => `srec-${index}-${recommendation.targetId}`)
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
