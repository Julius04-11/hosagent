import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface FavoriteItem {
  id: string;
  type: 'activity' | 'place' | 'restaurant' | 'hotel';
  title: string;
  description: string;
  imageUrl: string;
  location: string;
  rating: number;
  price?: string;
  favoriteTime: string;
  tags: string[];
}

@Entry
@Component
export struct MyFavoritesPage {
  @State favoriteList: FavoriteItem[] = [
    {
      id: '1',
      type: 'activity',
      title: '深圳湾公园夜游',
      description: '深圳湾公园是深圳最美的海滨公园，夜晚时分灯光璀璨，是休闲散步的好去处。',
      imageUrl: 'https://picsum.photos/300/200?random=1',
      location: '深圳湾公园',
      rating: 4.8,
      favoriteTime: '2024-06-01',
      tags: ['公园', '夜景', '休闲']
    },
    {
      id: '2',
      type: 'restaurant',
      title: '谭师傅私房菜',
      description: '传统粤菜餐厅，环境优雅，菜品精致，是商务宴请和家庭聚餐的理想选择。',
      imageUrl: 'https://picsum.photos/300/200?random=2',
      location: '福田区',
      rating: 4.6,
      price: '¥200-300/人',
      favoriteTime: '2024-06-02',
      tags: ['粤菜', '私房菜', '商务宴请']
    },
    {
      id: '3',
      type: 'place',
      title: '莲花山公园',
      description: '深圳市中心的大型城市公园，山顶可俯瞰整个深圳市区，是市民休闲健身的热门场所。',
      imageUrl: 'https://picsum.photos/300/200?random=3',
      location: '福田区',
      rating: 4.7,
      favoriteTime: '2024-06-03',
      tags: ['公园', '登山', '城市景观']
    },
    {
      id: '4',
      type: 'hotel',
      title: '深圳湾万豪酒店',
      description: '豪华五星级酒店，位于深圳湾核心区域，拥有无敌海景和顶级服务设施。',
      imageUrl: 'https://picsum.photos/300/200?random=4',
      location: '南山区',
      rating: 4.9,
      price: '¥800-1500/晚',
      favoriteTime: '2024-06-04',
      tags: ['豪华酒店', '海景', '商务']
    },
    {
      id: '5',
      type: 'activity',
      title: '东湖公园荷花节',
      description: '每年夏季举办的荷花节，展示各种珍稀荷花品种，是摄影爱好者的天堂。',
      imageUrl: 'https://picsum.photos/300/200?random=5',
      location: '东湖公园',
      rating: 4.5,
      favoriteTime: '2024-06-05',
      tags: ['荷花', '摄影', '节庆']
    },
    {
      id: '6',
      type: 'restaurant',
      title: '一旬一味',
      description: '创意融合菜餐厅，将传统粤菜与现代烹饪技法完美结合，每道菜都是艺术品。',
      imageUrl: 'https://picsum.photos/300/200?random=6',
      location: '南山区',
      rating: 4.7,
      price: '¥150-250/人',
      favoriteTime: '2024-06-06',
      tags: ['融合菜', '创意', '艺术']
    }
  ];

  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '活动', '景点', '餐厅', '酒店'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '我的收藏',
        showBack: true,
        showSearch: true,
        showNotification: false
      })

      // 统计信息
      this.StatisticsCard()

      // 标签页
      this.TabBar()

      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder StatisticsCard() {
    Column() {
      Row() {
        Column() {
          Text('6')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('收藏总数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('活动')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3b82f6')
          Text('餐厅')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('其他')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder TabBar() {
    Row() {
      ForEach(this.tabs ?? [], (tab: string, index: number) => {
        Text(tab)
          .fontSize(14)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#3b82f6' : '#6b7280')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(16)
          .onClick(() => {
            this.selectedTab = index;
          })
      }, (tab: string, index: number) => `tab-${index}-${tab}`)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ContentArea() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredFavorites() ?? [], (item: FavoriteItem, index: number) => {
          this.FavoriteCard(item)
        }, (item: FavoriteItem, index: number) => `fav-${item.id}-${index}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder FavoriteCard(item: FavoriteItem) {
    Column() {
      Row() {
        // 图片
        Image(item.imageUrl)
          .width(100)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .margin({ right: 12 })

        // 内容信息
        Column() {
          // 标题和类型标签
          Row() {
            Text(item.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getTypeText(item.type))
              .fontSize(10)
              .fontColor(this.getTypeColor(item.type))
              .backgroundColor(this.getTypeBgColor(item.type))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 描述
          Text(item.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          // 位置和评分
          Row() {
            Text('📍')
              .fontSize(12)
              .margin({ right: 4 })
            Text(item.location)
              .fontSize(12)
              .fontColor('#6b7280')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text('⭐')
              .fontSize(12)
              .margin({ right: 2 })
            Text(item.rating.toString())
              .fontSize(12)
              .fontColor('#f59e0b')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 价格和收藏时间
          Row() {
            if (item.price) {
              Text(item.price)
                .fontSize(12)
                .fontColor('#10b981')
                .fontWeight(FontWeight.Bold)
            }

            Blank()

            Text(`收藏于 ${item.favoriteTime}`)
              .fontSize(10)
              .fontColor('#9ca3af')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(item.tags ?? [], (tag: string, index: number) => {
          Text(`#${tag}`)
            .fontSize(10)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ right: 6, bottom: 4 })
        }, (tag: string, index: number) => `tag-${item.id}-${index}-${tag}`)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 操作按钮
      Row() {
        Button('查看详情')
          .fontSize(12)
          .fontColor('#3b82f6')
          .backgroundColor('#dbeafe')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.viewDetail(item.id, item.type);
          })

        Blank()

        Button('取消收藏')
          .fontSize(12)
          .fontColor('#ef4444')
          .backgroundColor('#fef2f2')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.removeFavorite(item.id);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getFilteredFavorites(): FavoriteItem[] {
    switch (this.selectedTab) {
      case 1: // 活动
        return this.favoriteList.filter(item => item.type === 'activity');
      case 2: // 景点
        return this.favoriteList.filter(item => item.type === 'place');
      case 3: // 餐厅
        return this.favoriteList.filter(item => item.type === 'restaurant');
      case 4: // 酒店
        return this.favoriteList.filter(item => item.type === 'hotel');
      default: // 全部
        return this.favoriteList;
    }
  }

  private getTypeText(type: string): string {
    switch (type) {
      case 'activity': return '活动';
      case 'place': return '景点';
      case 'restaurant': return '餐厅';
      case 'hotel': return '酒店';
      default: return '其他';
    }
  }

  private getTypeColor(type: string): string {
    switch (type) {
      case 'activity': return '#10b981';
      case 'place': return '#3b82f6';
      case 'restaurant': return '#f59e0b';
      case 'hotel': return '#8b5cf6';
      default: return '#6b7280';
    }
  }

  private getTypeBgColor(type: string): string {
    switch (type) {
      case 'activity': return '#d1fae5';
      case 'place': return '#dbeafe';
      case 'restaurant': return '#fef3c7';
      case 'hotel': return '#ede9fe';
      default: return '#f3f4f6';
    }
  }

  private viewDetail(id: string, type: string): void {
    // 根据类型跳转到不同的详情页面
    const routeMap: Record<string, string> = {
      'activity': 'pages/activity/ActivityDetailPage',
      'place': 'pages/place/PlaceDetailPage',
      'restaurant': 'pages/restaurant/RestaurantDetailPage',
      'hotel': 'pages/hotel/HotelDetailPage'
    };

    const url = routeMap[type];
    if (url) {
      router.pushUrl({
        url: url,
        params: { id: id }
      }).catch((error: Error) => {
        console.error('跳转详情页失败:', error.message);
      });
    } else {
      console.error('未知的详情页类型:', type);
    }
  }

  private removeFavorite(id: string): void {
    const index = this.favoriteList.findIndex(item => item.id === id);
    if (index !== -1) {
      this.favoriteList.splice(index, 1);
    }
  }
}
