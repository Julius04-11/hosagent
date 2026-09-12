import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface ItineraryItem {
  id: string;
  title: string;
  description: string;
  startDate: string;
  endDate: string;
  status: 'planning' | 'ongoing' | 'completed' | 'cancelled';
  activities: ActivityItem[];
  totalCost: number;
  participants: number;
  coverImage: string;
  tags: string[];
}

interface ActivityItem {
  id: string;
  name: string;
  time: string;
  location: string;
  cost: number;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  type: 'activity' | 'transport' | 'accommodation' | 'meal';
}

@Entry
@Component
export struct MyItineraryPage {
  @State itineraryList: ItineraryItem[] = [
    {
      id: '1',
      title: '深圳周末游',
      description: '探索深圳最精华的景点，体验现代化都市的魅力',
      startDate: '2024-06-15',
      endDate: '2024-06-16',
      status: 'planning',
      activities: [
        { id: '1', name: '深圳湾公园', time: '09:00-11:00', location: '深圳湾公园', cost: 0, status: 'confirmed', type: 'activity' },
        { id: '2', name: '谭师傅私房菜', time: '12:00-13:30', location: '福田区', cost: 200, status: 'confirmed', type: 'meal' },
        { id: '3', name: '莲花山公园', time: '15:00-17:00', location: '莲花山公园', cost: 0, status: 'pending', type: 'activity' },
        { id: '4', name: '东门老街', time: '18:00-20:00', location: '东门老街', cost: 150, status: 'pending', type: 'activity' }
      ],
      totalCost: 350,
      participants: 2,
      coverImage: 'https://picsum.photos/300/200?random=1',
      tags: ['周末游', '深圳', '2天1夜']
    },
    {
      id: '2',
      title: '端午民俗体验',
      description: '感受传统端午文化，参与民俗活动',
      startDate: '2024-06-10',
      endDate: '2024-06-10',
      status: 'ongoing',
      activities: [
        { id: '5', name: '端午民俗嘉年华', time: '09:00-18:00', location: '市民中心广场', cost: 50, status: 'completed', type: 'activity' },
        { id: '6', name: '粽子制作体验', time: '14:00-16:00', location: '市民中心广场', cost: 30, status: 'confirmed', type: 'activity' },
        { id: '7', name: '龙舟比赛观看', time: '16:30-18:00', location: '深圳湾', cost: 0, status: 'pending', type: 'activity' }
      ],
      totalCost: 80,
      participants: 1,
      coverImage: 'https://picsum.photos/300/200?random=2',
      tags: ['端午', '民俗', '传统文化']
    },
    {
      id: '3',
      title: '深圳美食之旅',
      description: '品尝深圳最地道的粤菜和特色小吃',
      startDate: '2024-06-08',
      endDate: '2024-06-08',
      status: 'completed',
      activities: [
        { id: '8', name: '早茶体验', time: '08:00-10:00', location: '一旬一味', cost: 120, status: 'completed', type: 'meal' },
        { id: '9', name: '东门小吃街', time: '12:00-14:00', location: '东门老街', cost: 80, status: 'completed', type: 'meal' },
        { id: '10', name: '谭师傅私房菜', time: '18:00-20:00', location: '福田区', cost: 300, status: 'completed', type: 'meal' }
      ],
      totalCost: 500,
      participants: 2,
      coverImage: 'https://picsum.photos/300/200?random=3',
      tags: ['美食', '粤菜', '探店']
    },
    {
      id: '4',
      title: '深圳夜景摄影',
      description: '拍摄深圳最美的夜景，记录城市风光',
      startDate: '2024-06-20',
      endDate: '2024-06-20',
      status: 'planning',
      activities: [
        { id: '11', name: '深圳湾夜景', time: '19:00-21:00', location: '深圳湾公园', cost: 0, status: 'pending', type: 'activity' },
        { id: '12', name: '平安金融中心', time: '21:30-23:00', location: '平安金融中心', cost: 100, status: 'pending', type: 'activity' }
      ],
      totalCost: 100,
      participants: 1,
      coverImage: 'https://picsum.photos/300/200?random=4',
      tags: ['摄影', '夜景', '城市风光']
    }
  ];

  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '规划中', '进行中', '已完成'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '我的行程',
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
          Text('4')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('行程总数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('规划中')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3b82f6')
          Text('进行中')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('已完成')
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
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(20)
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
        ForEach(this.getFilteredItineraries() ?? [], (itinerary: ItineraryItem, index: number) => {
          this.ItineraryCard(itinerary)
        }, (itinerary: ItineraryItem, index: number) => `iti-${itinerary.id}-${index}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder ItineraryCard(itinerary: ItineraryItem) {
    Column() {
      // 封面图片和基本信息
      Row() {
        Image(itinerary.coverImage)
          .width(100)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .margin({ right: 12 })

        Column() {
          // 标题和状态
          Row() {
            Text(itinerary.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getStatusText(itinerary.status))
              .fontSize(10)
              .fontColor(this.getStatusColor(itinerary.status))
              .backgroundColor(this.getStatusBgColor(itinerary.status))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 描述
          Text(itinerary.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          // 日期和费用
          Row() {
            Text('📅')
              .fontSize(12)
              .margin({ right: 4 })
            Text(`${itinerary.startDate} - ${itinerary.endDate}`)
              .fontSize(12)
              .fontColor('#6b7280')

            Text('💰')
              .fontSize(12)
              .margin({ left: 12, right: 4 })
            Text(`¥${itinerary.totalCost}`)
              .fontSize(12)
              .fontColor('#10b981')
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 参与人数
          Row() {
            Text('👥')
              .fontSize(12)
              .margin({ right: 4 })
            Text(`${itinerary.participants} 人`)
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 活动列表预览
      Column() {
        Text('行程安排')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        ForEach((itinerary.activities ?? []).slice(0, 3), (activity: ActivityItem, idx: number) => {
          this.ActivityItem(activity)
        }, (activity: ActivityItem, idx: number) => `act-${itinerary.id}-${idx}-${activity.id}`)

        if (itinerary.activities.length > 3) {
          Text(`还有 ${itinerary.activities.length - 3} 个活动...`)
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#f9fafb')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(itinerary.tags ?? [], (tag: string, idx: number) => {
          Text(`#${tag}`)
            .fontSize(10)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ right: 6, bottom: 4 })
        }, (tag: string, idx: number) => `tag-${itinerary.id}-${idx}-${tag}`)
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
            this.viewItineraryDetail(itinerary.id);
          })

        if (itinerary.status === 'planning') {
          Button('编辑行程')
            .fontSize(12)
            .fontColor('#f59e0b')
            .backgroundColor('#fef3c7')
            .borderRadius(8)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ left: 8 })
            .onClick(() => {
              this.editItinerary(itinerary.id);
            })
        }

        Blank()

        Button('分享')
          .fontSize(12)
          .fontColor('#10b981')
          .backgroundColor('#d1fae5')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.shareItinerary(itinerary.id);
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

  @Builder ActivityItem(activity: ActivityItem) {
    Row() {
      Text(this.getActivityTypeIcon(activity.type))
        .fontSize(12)
        .margin({ right: 8 })

      Text(activity.name)
        .fontSize(12)
        .fontColor('#374151')
        .layoutWeight(1)

      Text(activity.time)
        .fontSize(10)
        .fontColor('#6b7280')
        .margin({ right: 8 })

      Text(this.getActivityStatusText(activity.status))
        .fontSize(10)
        .fontColor(this.getActivityStatusColor(activity.status))
        .backgroundColor(this.getActivityStatusBgColor(activity.status))
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(4)
    }
    .width('100%')
    .margin({ bottom: 4 })
  }

  private getFilteredItineraries(): ItineraryItem[] {
    switch (this.selectedTab) {
      case 1: // 规划中
        return this.itineraryList.filter(itinerary => itinerary.status === 'planning');
      case 2: // 进行中
        return this.itineraryList.filter(itinerary => itinerary.status === 'ongoing');
      case 3: // 已完成
        return this.itineraryList.filter(itinerary => itinerary.status === 'completed');
      default: // 全部
        return this.itineraryList;
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'planning': return '规划中';
      case 'ongoing': return '进行中';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'planning': return '#f59e0b';
      case 'ongoing': return '#3b82f6';
      case 'completed': return '#10b981';
      case 'cancelled': return '#ef4444';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'planning': return '#fef3c7';
      case 'ongoing': return '#dbeafe';
      case 'completed': return '#d1fae5';
      case 'cancelled': return '#fee2e2';
      default: return '#f3f4f6';
    }
  }

  private getActivityTypeIcon(type: string): string {
    switch (type) {
      case 'activity': return '🎯';
      case 'transport': return '🚗';
      case 'accommodation': return '🏨';
      case 'meal': return '🍽️';
      default: return '📍';
    }
  }

  private getActivityStatusText(status: string): string {
    switch (status) {
      case 'pending': return '待定';
      case 'confirmed': return '已确认';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      default: return '未知';
    }
  }

  private getActivityStatusColor(status: string): string {
    switch (status) {
      case 'pending': return '#f59e0b';
      case 'confirmed': return '#10b981';
      case 'completed': return '#3b82f6';
      case 'cancelled': return '#ef4444';
      default: return '#6b7280';
    }
  }

  private getActivityStatusBgColor(status: string): string {
    switch (status) {
      case 'pending': return '#fef3c7';
      case 'confirmed': return '#d1fae5';
      case 'completed': return '#dbeafe';
      case 'cancelled': return '#fee2e2';
      default: return '#f3f4f6';
    }
  }

  private viewItineraryDetail(id: string): void {
    router.pushUrl({ 
      url: 'pages/itinerary/ItineraryDetailPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转行程详情页失败:', error.message);
    });
  }

  private editItinerary(id: string): void {
    router.pushUrl({ 
      url: 'pages/itinerary/ItineraryEditPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转行程编辑页失败:', error.message);
    });
  }

  private shareItinerary(id: string): void {
    console.log(`分享行程: ${id}`);
  }
}
