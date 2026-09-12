import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface Activity {
  id: number;
  title: string;
  subtitle: string;
  price: string;
  originalPrice?: string;
  rating: number;
  reviewCount: number;
  category: string;
  tags: string[];
  image: string;
  time: string;
  location: string;
  description: string;
}

interface Category {
  name: string;
  color: string;
}

@Entry
@Component
export struct ActivityPageNew {
  @State selectedCategory: string = '热门推荐';
  @State activities: Activity[] = [];
  @State filteredActivities: Activity[] = [];
  @State isLoading: boolean = false;

  private categories: Category[] = [
    { name: '热门推荐', color: '#ff6b6b' },
    { name: '文化体验', color: '#4ecdc4' },
    { name: '自然探索', color: '#45b7d1' },
    { name: '娱乐休闲', color: '#96ceb4' },
    { name: '运动健身', color: '#feca57' },
    { name: '亲子活动', color: '#ff9ff3' }
  ];

  aboutToAppear() {
    console.log('[ActivityPageNew] aboutToAppear - 页面初始化');
    try {
      // 从AppStorage获取选中的分类
      this.selectedCategory = AppStorage.get('selectedCategory') as string || '热门推荐';
      this.loadActivities();
      
      // 监听AppStorage变化
      AppStorage.setAndLink('selectedCategory', this.selectedCategory);
    } catch (error) {
      console.error('[ActivityPageNew] 初始化失败:', error);
    }
  }

  // 监听分类变化，重新过滤活动
  onPageShow() {
    this.filterActivities();
  }

  private loadActivities() {
    this.isLoading = true;
    // 模拟加载数据
    setTimeout(() => {
      this.activities = [
        {
          id: 1,
          title: '世界之窗国际文化节',
          subtitle: '一日游遍世界，感受多元文化魅力',
          price: '¥168',
          originalPrice: '¥220',
          rating: 4.8,
          reviewCount: 1256,
          category: '文化体验',
          tags: ['国际文化', '主题公园', '表演艺术'],
          image: '🏛️',
          time: '2025年10月10日-12日',
          location: '世界之窗主题公园',
          description: '汇聚130个世界著名景观，体验各国文化表演、美食节、手工艺制作等精彩活动。'
        },
        {
          id: 2,
          title: '欢乐谷万圣节狂欢夜',
          subtitle: '惊险刺激的万圣节主题夜场体验',
          price: '¥128',
          originalPrice: '¥180',
          rating: 4.6,
          reviewCount: 892,
          category: '娱乐休闲',
          tags: ['万圣节', '主题乐园', '夜场'],
          image: '🎢',
          time: '2025年10月15日-31日',
          location: '深圳欢乐谷',
          description: '全园恐怖主题装饰，鬼屋探险、万圣节游行、变装大赛等惊险刺激体验。'
        },
        {
          id: 3,
          title: '东部华侨城生态徒步',
          subtitle: '亲近自然，探索生态之美',
          price: '¥88',
          rating: 4.7,
          reviewCount: 634,
          category: '自然探索',
          tags: ['生态徒步', '自然风光', '环保教育'],
          image: '🌿',
          time: '2025年10月18日',
          location: '东部华侨城生态景区',
          description: '专业设计的徒步路线，植物科普、观鸟活动、环保教育等自然体验。'
        },
        {
          id: 4,
          title: '大梅沙海滨音乐节',
          subtitle: '沙滩上的音乐盛宴',
          price: '¥98',
          rating: 4.5,
          reviewCount: 423,
          category: '娱乐休闲',
          tags: ['音乐节', '海滨', '沙滩派对'],
          image: '🎵',
          time: '2025年10月22日',
          location: '大梅沙海滨公园',
          description: '现场音乐表演、沙滩派对、美食市集、互动游戏等海滨音乐体验。'
        },
        {
          id: 5,
          title: '莲花山公园风筝节',
          subtitle: '放飞梦想，享受亲子时光',
          price: '免费',
          rating: 4.4,
          reviewCount: 567,
          category: '亲子活动',
          tags: ['风筝节', '亲子活动', '传统文化'],
          image: '🪁',
          time: '2025年10月28日',
          location: '莲花山公园',
          description: '风筝制作、比赛、展览、亲子活动等传统文化体验。'
        },
        {
          id: 6,
          title: '深圳湾公园观鸟节',
          subtitle: '探索鸟类世界，感受生态之美',
          price: '免费',
          rating: 4.6,
          reviewCount: 312,
          category: '自然探索',
          tags: ['观鸟', '生态保护', '科普教育'],
          image: '🦅',
          time: '2025年10月5日',
          location: '深圳湾公园观鸟台',
          description: '专业观鸟指导、鸟类摄影、知识讲座、生态保护教育等。'
        }
      ];
      this.filterActivities();
      this.isLoading = false;
    }, 500);
  }

  private filterActivities() {
    if (this.selectedCategory === '热门推荐') {
      // 使用展开运算符创建新数组引用，触发UI更新
      this.filteredActivities = [...this.activities];
    } else {
      const filtered = this.activities.filter(activity => 
        activity.category === this.selectedCategory
      );
      // 使用展开运算符创建新数组引用，触发UI更新
      this.filteredActivities = [...filtered];
    }
    console.log('[ActivityPageNew] filterActivities - 过滤后数量:', this.filteredActivities.length);
  }

  private onCategoryChange(category: string) {
    this.selectedCategory = category;
    this.filterActivities();
  }

  private onActivityClick(activity: Activity) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/activity/ActivityDetailPage',
        params: {
          activityId: activity.id,
          src: activity.id
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '活动详情页面'));
  }

  private onBookingClick(activity: Activity) {
    const price = activity.price === '免费' ? 0 : parseInt(activity.price.replace('¥', '')) || 0;
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/booking/UnifiedBookingPage',
        params: {
          id: activity.id.toString(),
          name: activity.title,
          price: price
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '购票报名页面'));
  }

  private getActivityColor(category: string): string {
    switch (category) {
      case '文化体验': return '#ff6b6b';
      case '娱乐休闲': return '#4ecdc4';
      case '自然探索': return '#45b7d1';
      case '亲子活动': return '#96ceb4';
      case '运动健身': return '#feca57';
      default: return '#74b9ff';
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      this.HeaderSection()
      
      // 分类标签栏
      this.CategoryTabs()
      
      // 活动列表
      this.ActivityList()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder HeaderSection() {
    Row() {
      // 返回按钮
      Text('←')
        .fontSize(24)
        .fontColor('#1e40af')
        .fontWeight(FontWeight.Bold)
        .margin({ right: 12 })
        .onClick(() => {
          ErrorHandler.safeExecute(async (): Promise<void> => {
            await router.back();
          }, (error: Error): void => ErrorHandler.handleGenericError(error, '返回上页'));
        })
      
      Text('社区活动')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1e40af')
      
      Blank()
      
      // 搜索按钮
      Button() {
        Text('🔍')
          .fontSize(20)
          .fontColor('#64748b')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .borderRadius(20)
      .onClick(() => {
        // 搜索功能
      })
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder CategoryTabs() {
    Scroll() {
      Row() {
        ForEach(this.categories ?? [], (category: Category, index: number) => {
          Button() {
            Text(category.name)
              .fontSize(14)
              .fontWeight(this.selectedCategory === category.name ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.selectedCategory === category.name ? Color.White : '#64748b')
          }
          .width(80)
          .height(36)
          .backgroundColor(this.selectedCategory === category.name ? category.color : '#f1f5f9')
          .borderRadius(18)
          .margin({ right: 12 })
          .onClick(() => {
            this.onCategoryChange(category.name);
          })
        }, (category: Category, index: number) => `cat-${index}-${category.name}`)
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder ActivityList() {
    if (this.isLoading) {
      this.LoadingView()
    } else {
      Scroll() {
        Column() {
          ForEach(this.filteredActivities ?? [], (activity: Activity, index: number) => {
            this.ActivityCard(activity, index)
          }, (activity: Activity, index: number) => `act-${activity.id}-${index}`)
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .scrollBar(BarState.Auto)
    }
  }

  @Builder LoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#1e40af')
      
      Text('加载中...')
        .fontSize(16)
        .fontColor('#64748b')
        .margin({ top: 16 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder ActivityCard(activity: Activity, index: number) {
    Column() {
      // 活动图片
      Stack() {
        // 背景色块
        Column() {
          Text(activity.image)
            .fontSize(80)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(200)
        .backgroundColor(this.getActivityColor(activity.category))
        .borderRadius({ topLeft: 12, topRight: 12 })
        .justifyContent(FlexAlign.Center)
        
        // 价格标签
        Row() {
          Text(activity.price)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          
          if (activity.originalPrice) {
            Text(activity.originalPrice)
              .fontSize(12)
              .fontColor(Color.White)
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('rgba(0,0,0,0.6)')
        .borderRadius(20)
        .position({ x: 12, y: 12 })
        
        // 评分标签
        Row() {
          Text('⭐')
            .fontSize(14)
            .fontColor('#ffd700')
          
          Text(activity.rating.toString())
            .fontSize(12)
            .fontColor('#1e40af')
            .margin({ left: 4 })
          
          Text(`(${activity.reviewCount})`)
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ left: 4 })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(Color.White)
        .borderRadius(12)
        .position({ x: 12, y: 50 })
      }
      .width('100%')
      .height(200)
      .borderRadius({ topLeft: 12, topRight: 12 })
      
      // 活动信息
      Column() {
        // 标题和副标题
        Column() {
          Text(activity.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(activity.subtitle)
            .fontSize(14)
            .fontColor('#64748b')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        
        // 活动描述
        Text(activity.description)
          .fontSize(13)
          .fontColor('#475569')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)
          .margin({ top: 8 })
          .width('100%')
        
        // 标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(activity.tags ?? [], (tag: string, tagIndex: number) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#1e40af')
              .backgroundColor('#dbeafe')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })
          }, (tag: string, tagIndex: number) => `atag-${activity.id}-${tagIndex}-${tag}`)
        }
        .margin({ top: 12 })
        
        // 时间和地点
        Row() {
          Row() {
            Text('🕒')
              .fontSize(16)
              .fontColor('#64748b')
            
            Text(activity.time)
              .fontSize(12)
              .fontColor('#64748b')
              .margin({ left: 4 })
          }
          
          Blank()
          
          Row() {
            Text('📍')
              .fontSize(16)
              .fontColor('#64748b')
            
            Text(activity.location)
              .fontSize(12)
              .fontColor('#64748b')
              .margin({ left: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 立即报名按钮
        Button() {
          Text(activity.price === '免费' ? '免费参与' : '立即购票')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(44)
        .backgroundColor('#1e40af')
        .borderRadius(22)
        .margin({ top: 16 })
        .onClick(() => {
          this.onBookingClick(activity);
        })
      }
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 20 })
    .onClick(() => {
      this.onActivityClick(activity);
    })
  }
}