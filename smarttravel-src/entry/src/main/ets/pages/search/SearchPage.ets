import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { RecommendationSection, RecommendationItem } from '../../components/RecommendationSection';
import { RecommendationService } from '../../services/RecommendationService';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface SearchResult {
  id: string;
  title: string;
  type: 'attraction' | 'hotel' | 'restaurant' | 'activity';
  image: string;
  rating: number;
  location: string;
  description: string;
}

interface TrendingItemData {
  rank: number;
  keyword: string;
  heat: string;
  trend: string;
}

@Entry
@Component
struct SearchPage {
  @State searchText: string = '';
  @State searchResults: SearchResult[] = [];
  @State isSearching: boolean = false;
  @State recentSearches: string[] = ['世界之窗', '深圳湾公园', '华强北', '欢乐谷'];
  @State hotRecommendations: RecommendationItem[] = [];
  @State selectedFilter: string = '全部';
  @State showFilters: boolean = false;

  // 模拟搜索数据
  private mockResults: SearchResult[] = [
    {
      id: '1',
      title: '世界之窗',
      type: 'attraction',
      image: 'https://picsum.photos/id/100/300/200',
      rating: 4.8,
      location: '深圳南山区',
      description: '汇聚世界各地著名景点的主题公园'
    },
    {
      id: '2', 
      title: '深圳湾万豪酒店',
      type: 'hotel',
      image: 'https://picsum.photos/id/101/300/200',
      rating: 4.7,
      location: '深圳南山区',
      description: '豪华海景酒店，设施完善'
    },
    {
      id: '3',
      title: '海底捞火锅',
      type: 'restaurant', 
      image: 'https://picsum.photos/id/102/300/200',
      rating: 4.6,
      location: '深圳福田区',
      description: '知名火锅连锁，服务优质'
    },
    {
      id: '4',
      title: '深圳文化节',
      type: 'activity',
      image: 'https://picsum.photos/id/103/300/200', 
      rating: 4.5,
      location: '深圳市民中心',
      description: '年度文化盛典，精彩纷呈'
    }
  ];

  aboutToAppear() {
    this.loadHotRecommendations();
  }

  private loadHotRecommendations() {
    this.hotRecommendations = RecommendationService.getHotRecommendations();
  }

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '搜索',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      Scroll() {
        Column() {
          // 搜索框区域（带渐变背景）
          this.SearchHeader()

          // 搜索结果或推荐内容
          if (this.searchText.length > 0) {
            this.SearchFilters()
            this.SearchResults()
          } else {
            this.RecentSearches()
            this.HotRecommendations()
            this.TrendingSection()
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#f8fafc')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder SearchHeader() {
    Column() {
      // 搜索框区域
      Row() {
        Row({ space: 12 }) {
          Text('🔍')
            .fontSize(18)
            .fontColor('#999999')
          
          TextInput({ 
            placeholder: '搜索景点、酒店、餐厅...',
            text: this.searchText
          })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('rgba(255, 255, 255, 0)')
            .padding(0)
            .fontSize(15)
            .fontColor('#333333')
            .placeholderColor('#999999')
            .onChange((value: string) => {
              this.searchText = value;
              this.performSearch(value);
            })
        }
        .layoutWeight(1)
        .height(44)
        .backgroundColor('#f5f5f5')
        .borderRadius(22)
        .padding({ left: 16, right: 16 })

        Button('搜索')
          .fontSize(15)
          .fontColor('#ffffff')
          .backgroundColor('#0086f6')
          .borderRadius(22)
          .height(44)
          .padding({ left: 20, right: 20 })
          .margin({ left: 10 })
          .onClick(() => {
            this.performSearch(this.searchText);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder RecentSearches() {
    Column() {
      Row() {
        Text('最近搜索')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('清空')
          .fontSize(13)
          .fontColor('#999999')
          .onClick(() => {
            this.recentSearches = [];
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.recentSearches ?? [], (search: string, index: number) => {
          Text(search)
            .fontSize(13)
            .fontColor('#666666')
            .backgroundColor('#f5f5f5')
            .borderRadius(16)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.searchText = search;
              this.performSearch(search);
            })
        }, (search: string, index: number) => `recent-${index}-${search}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ left: 0, right: 0, top: 10, bottom: 0 })
    .backgroundColor(Color.White)
  }

  @Builder SearchResults() {
    Column() {
      if (this.isSearching) {
        Column() {
          Text('🔍')
            .fontSize(48)
            .margin({ bottom: 16 })
          Text('正在搜索...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .margin({ top: 60 })
      } else if (this.searchResults.length === 0) {
        Column() {
          Text('🔍')
            .fontSize(56)
            .margin({ bottom: 20 })
          
          Text('未找到相关结果')
            .fontSize(17)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          Text('试试其他关键词吧')
            .fontSize(14)
            .fontColor('#9ca3af')
        }
        .margin({ top: 60 })
      } else {
        Row() {
          Text(`找到 `)
            .fontSize(14)
            .fontColor('#999999')
          Text(`${this.searchResults.length}`)
            .fontSize(14)
            .fontColor('#0086f6')
            .fontWeight(FontWeight.Medium)
          Text(` 个结果`)
            .fontSize(14)
            .fontColor('#999999')
        }
        .margin({ left: 16, bottom: 12 })
        .alignSelf(ItemAlign.Start)

        Column({ space: 12 }) {
          ForEach(this.searchResults ?? [], (result: SearchResult, index: number) => {
            this.SearchResultItem(result)
          }, (result: SearchResult, index: number) => `res-${index}-${result.id}`)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
  }

  @Builder SearchResultItem(result: SearchResult) {
    Row() {
      Image(result.image)
        .width(90)
        .height(90)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(result.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .layoutWeight(1)
          
          Text(this.getTypeText(result.type))
            .fontSize(11)
            .fontColor('#ffffff')
            .backgroundColor(this.getTypeColor(result.type))
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        }
        .width('100%')
        .margin({ bottom: 6 })

        Row({ space: 3 }) {
          Text('⭐')
            .fontSize(12)
          
          Text(result.rating.toString())
            .fontSize(13)
            .fontColor('#ff9900')
        }
        .margin({ bottom: 6 })

        Row({ space: 4 }) {
          Text('📍')
            .fontSize(11)
          Text(result.location)
            .fontSize(12)
            .fontColor('#999999')
        }
        .margin({ bottom: 6 })

        Text(result.description)
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(12)
    .onClick(() => {
      this.navigateToDetail(result);
    })
  }

  private performSearch(query: string) {
    if (query.trim().length === 0) {
      this.searchResults = [];
      return;
    }

    this.isSearching = true;
    
    // 模拟搜索延迟
    setTimeout(() => {
      this.searchResults = this.mockResults.filter(result => 
        result.title.toLowerCase().includes(query.toLowerCase()) ||
        result.description.toLowerCase().includes(query.toLowerCase()) ||
        result.location.toLowerCase().includes(query.toLowerCase())
      );
      this.isSearching = false;
      
      // 添加到最近搜索
      if (!this.recentSearches.includes(query)) {
        this.recentSearches.unshift(query);
        if (this.recentSearches.length > 8) {
          this.recentSearches = this.recentSearches.slice(0, 8);
        }
      }
    }, 500);
  }

  private getTypeText(type: string): string {
    const typeMap: Record<string, string> = {
      'attraction': '景点',
      'hotel': '酒店', 
      'restaurant': '餐厅',
      'activity': '活动'
    };
    return typeMap[type] || '其他';
  }

  private getTypeColor(type: string): string {
    const colorMap: Record<string, string> = {
      'attraction': '#52c41a',
      'hotel': '#0086f6',
      'restaurant': '#ff9900', 
      'activity': '#722ed1'
    };
    return colorMap[type] || '#999999';
  }

  private navigateToDetail(result: SearchResult) {
    // 根据类型跳转到不同页面
    let targetUrl = '';
    switch (result.type) {
      case 'attraction':
        targetUrl = 'pages/activity/ActivityDetailPage';
        break;
      case 'hotel':
        targetUrl = 'pages/detail/HotelDetailPage';
        break;
      case 'restaurant':
        targetUrl = 'pages/detail/FoodDetailPage';
        break;
      case 'activity':
        targetUrl = 'pages/activity/ActivityDetailPage';
        break;
      default:
        targetUrl = 'pages/activity/ActivityDetailPage';
    }

    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: targetUrl,
        params: { id: result.id, type: result.type }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '详情页面'));
  }

  @Builder SearchFilters() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(['全部', '景点', '酒店', '餐厅', '活动'], (filter: string, index: number) => {
          if (this.selectedFilter === filter) {
            // 选中态
            Text(filter)
              .fontSize(14)
              .fontColor('#0086f6')
              .backgroundColor('#e6f4ff')
              .padding({ left: 16, right: 16, top: 7, bottom: 7 })
              .borderRadius(16)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.selectedFilter = filter;
              })
          } else {
            // 未选中态
            Text(filter)
              .fontSize(14)
              .fontColor('#666666')
              .backgroundColor('#f5f5f5')
              .padding({ left: 16, right: 16, top: 7, bottom: 7 })
              .borderRadius(16)
              .fontWeight(FontWeight.Normal)
              .onClick(() => {
                this.selectedFilter = filter;
              })
          }
        }, (filter: string, index: number) => `filter-${index}-${filter}`)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ top: 10, bottom: 16 })
    .backgroundColor(Color.White)
  }

  @Builder HotRecommendations() {
    Column() {
      Row() {
        Text('🔥 热门推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('查看更多')
          .fontSize(13)
          .fontColor('#0086f6')
          .onClick(() => {
            console.log('查看更多热门推荐');
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 12 })
      .backgroundColor(Color.White)

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.mockResults ?? [], (result: SearchResult, index: number) => {
            this.HotRecommendationCard(result)
          }, (result: SearchResult, index: number) => `hot-${index}-${result.id}`)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ bottom: 16 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .margin({ top: 10, bottom: 0 })
  }

  @Builder HotRecommendationCard(result: SearchResult) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(result.image)
          .width(180)
          .height(120)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Text(this.getTypeText(result.type))
          .fontSize(10)
          .fontColor('#ffffff')
          .backgroundColor(this.getTypeColor(result.type))
          .borderRadius(8)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .margin({ top: 6, right: 6 })
      }
      .width(180)
      .height(120)

      Column() {
        Text(result.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        Row({ space: 8 }) {
          Row({ space: 3 }) {
            Text('⭐')
              .fontSize(11)
            Text(result.rating.toString())
              .fontSize(12)
              .fontColor('#ff9900')
          }

          Text(result.location)
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .padding(10)
    }
    .width(180)
    .backgroundColor('#fafafa')
    .borderRadius(8)
    .onClick(() => {
      this.navigateToDetail(result);
    })
  }

  @Builder TrendingSection() {
    Column() {
      Row() {
        Text('📊 实时热搜')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Row({ space: 3 }) {
          Text('实时')
            .fontSize(10)
            .fontColor('#52c41a')
          Text('●')
            .fontSize(8)
            .fontColor('#52c41a')
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column({ space: 10 }) {
        ForEach([
          { rank: 1, keyword: '深圳湾公园', heat: '热', trend: 'up' },
          { rank: 2, keyword: '潮汕牛肉火锅', heat: '新', trend: 'new' },
          { rank: 3, keyword: '世界之窗', heat: '', trend: 'up' },
          { rank: 4, keyword: '华强北商圈', heat: '', trend: 'down' }
        ], (item: TrendingItemData, index: number) => {
          this.TrendingItem(item)
        }, (item: TrendingItemData, index: number) => `trend-${index}-${item.keyword}`)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ left: 0, right: 0, top: 10, bottom: 20 })
  }

  @Builder TrendingItem(item: TrendingItemData) {
    Row() {
      Text(item.rank.toString())
        .fontSize(14)
        .fontColor(item.rank <= 3 ? '#ff5722' : '#999999')
        .fontWeight(item.rank <= 3 ? FontWeight.Bold : FontWeight.Normal)
        .width(20)
        .textAlign(TextAlign.Center)

      Text(item.keyword)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 12 })

      if (item.heat) {
        Text(item.heat)
          .fontSize(10)
          .fontColor('#ffffff')
          .backgroundColor(item.heat === '热' ? '#ff5722' : '#52c41a')
          .borderRadius(2)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .margin({ right: 6 })
      }

      if (item.trend === 'up') {
        Text('📈')
          .fontSize(12)
      } else if (item.trend === 'down') {
        Text('📉')
          .fontSize(12)
      } else if (item.trend === 'new') {
        Text('🆕')
          .fontSize(12)
      }
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .onClick(() => {
      this.searchText = item.keyword;
      this.performSearch(item.keyword);
    })
  }
}

