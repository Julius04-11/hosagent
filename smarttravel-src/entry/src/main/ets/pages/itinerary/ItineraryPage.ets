import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface ItineraryItem {
  id: string;
  title: string;
  date: string;
  status: 'upcoming' | 'ongoing' | 'completed';
  location: string;
  image: string;
  participants: number;
}

@Entry
@Component
export struct ItineraryPage {
  @State itineraryList: ItineraryItem[] = [
    {
      id: '1',
      title: '深圳世界之窗一日游',
      date: '2024-10-15',
      status: 'upcoming',
      location: '深圳市南山区',
      image: 'https://p3.img.cctvpic.com/photoworkspace/contentimg/2019/05/05/2019050515335593405.jpg',
      participants: 2
    },
    {
      id: '2',
      title: '欢乐谷主题乐园',
      date: '2024-10-20',
      status: 'upcoming',
      location: '深圳市南山区',
      image: 'https://askthescientists.com/wp-content/uploads/2018/07/Outdoors-AdobeStock_203673414-835x418.jpg',
      participants: 1
    },
    {
      id: '3',
      title: '东部华侨城生态游',
      date: '2024-10-25',
      status: 'upcoming',
      location: '深圳市盐田区',
      image: 'https://cxfile.advences.com/CFAVOYAGES/photo/shutterstock_638541712.jpg',
      participants: 3
    }
  ];

  @State selectedTab: number = 0;

  build() {
    Column() {
      // 统一的顶部导航栏
      TopNavigationBar({
        title: '我的行程',
        showSearch: true,
        showNotification: true
      })
      
      // 标签页
      this.TabBar()
      
      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }


  @Builder TabBar() {
    Row() {
      ForEach(['待出行', '进行中', '已完成'], (tab: string, index: number) => {
        Text(tab)
          .fontSize(16)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#3b82f6' : '#64748b')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = index;
          })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder ContentArea() {
    if (this.selectedTab === 0) {
      this.UpcomingTrips()
    } else if (this.selectedTab === 1) {
      this.OngoingTrips()
    } else {
      this.CompletedTrips()
    }
  }

  @Builder UpcomingTrips() {
    Scroll() {
      Column() {
        // 线路规划卡片
        this.RoutePlanningCard()
        
        // 行程列表
        ForEach(this.itineraryList, (itinerary: ItineraryItem) => {
          this.ItineraryCard(itinerary)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder RoutePlanningCard() {
    Column() {
      Row() {
        Text('线路规划')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)

        Text('我的线路 >')
          .fontSize(14)
          .fontColor('#3b82f6')
          .onClick(() => {
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.pushUrl({
                url: 'pages/category/RoutePage'
              });
            }, (error: Error): void => ErrorHandler.handleRouterError(error, '路线页面'));
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 规划卡片内容
      Column() {
        Row({ space: 12 }) {
          // 景点1
          Column() {
            Text('🏛️')
              .fontSize(24)
              .margin({ bottom: 4 })
            Text('世界之窗')
              .fontSize(12)
              .fontColor('#374151')
          }
          .padding(12)
          .backgroundColor('#f3f4f6')
          .borderRadius(12)
          .onClick(() => {
            console.log('点击了世界之窗景点卡片');
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.pushUrl({
                url: 'pages/activity/ActivityDetailPage',
                params: { id: 'shijiezhichuang', src: 'shijiezhichuang' }
              });
            }, (error: Error): void => {
              console.error('世界之窗跳转失败:', error);
              ErrorHandler.handleRouterError(error, '世界之窗详情');
            });
          })

          // 景点2
          Column() {
            Text('🎢')
              .fontSize(24)
              .margin({ bottom: 4 })
            Text('欢乐谷')
              .fontSize(12)
              .fontColor('#374151')
          }
          .padding(12)
          .backgroundColor('#f3f4f6')
          .borderRadius(12)
          .onClick(() => {
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.pushUrl({
                url: 'pages/activity/ActivityDetailPage',
                params: { id: 'huanlegu', src: 'huanlegu' }
              });
            }, (error: Error): void => ErrorHandler.handleRouterError(error, '欢乐谷详情'));
          })

          // 景点3
          Column() {
            Text('🚉')
              .fontSize(24)
              .margin({ bottom: 4 })
            Text('深圳北站')
              .fontSize(12)
              .fontColor('#374151')
          }
          .padding(12)
          .backgroundColor('#f3f4f6')
          .borderRadius(12)
          .onClick(() => {
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.pushUrl({
                url: 'pages/category/TransportPage'
              });
            }, (error: Error): void => ErrorHandler.handleRouterError(error, '交通页面'));
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 })

        // 开始规划按钮
        Button('开始规划')
          .width('100%')
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#3b82f6')
          .borderRadius(22)
          .onClick(() => {
            console.log('点击了开始规划按钮');
            ErrorHandler.safeExecute(async (): Promise<void> => {
              console.log('准备跳转到地图页面');
              await router.pushUrl({
                url: 'pages/map/MapPage'
              });
              console.log('跳转成功');
            }, (error: Error): void => {
              console.error('跳转失败:', error);
              ErrorHandler.handleRouterError(error, '地图页面');
            });
          })

        Text('支持智能推荐线路')
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#dbeafe')
      .borderRadius(16)
      .margin({ bottom: 16 })
    }
    .width('100%')
  }

  @Builder ItineraryCard(itinerary: ItineraryItem) {
    Row() {
      // 图片
      Image(itinerary.image)
        .width(80)
        .height(80)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      // 内容
      Column() {
        Text(itinerary.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
          .margin({ bottom: 4 })

        Row() {
          Text('📅')
            .fontSize(12)
            .margin({ right: 4 })
          Text(itinerary.date)
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .margin({ bottom: 4 })

        Row() {
          Text('📍')
            .fontSize(12)
            .margin({ right: 4 })
          Text(itinerary.location)
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .margin({ bottom: 8 })

        Row() {
          Text('👥')
            .fontSize(12)
            .margin({ right: 4 })
          Text(`${itinerary.participants}人参与`)
            .fontSize(12)
            .fontColor('#6b7280')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 状态标签
      Text(this.getStatusText(itinerary.status))
        .fontSize(12)
        .fontColor(this.getStatusColor(itinerary.status))
        .backgroundColor(this.getStatusBgColor(itinerary.status))
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(12)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      console.log('点击了行程卡片:', itinerary.title);
      ErrorHandler.safeExecute(async (): Promise<void> => {
        console.log('准备跳转到活动详情页面，参数:', itinerary.id);
        await router.pushUrl({
          url: 'pages/activity/ActivityDetailPage',
          params: { 
            id: itinerary.id,
            src: itinerary.id,
            activityId: itinerary.id
          }
        });
        console.log('行程卡片跳转成功');
      }, (error: Error): void => {
        console.error('行程卡片跳转失败:', error);
        ErrorHandler.handleRouterError(error, '活动详情页面');
      });
    })
  }

  @Builder OngoingTrips() {
    Column() {
      Text('暂无进行中的行程')
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder CompletedTrips() {
    Column() {
      Text('暂无已完成的行程')
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'upcoming': return '待出行';
      case 'ongoing': return '进行中';
      case 'completed': return '已完成';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'upcoming': return '#3b82f6';
      case 'ongoing': return '#f59e0b';
      case 'completed': return '#10b981';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'upcoming': return '#dbeafe';
      case 'ongoing': return '#fef3c7';
      case 'completed': return '#d1fae5';
      default: return '#f3f4f6';
    }
  }
}
