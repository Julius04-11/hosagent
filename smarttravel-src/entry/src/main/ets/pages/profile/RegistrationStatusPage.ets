import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface RegistrationInfo {
  id: string;
  activityName: string;
  activityId: string;
  registrationTime: string;
  status: 'pending' | 'confirmed' | 'cancelled';
  participants: number;
  totalCapacity: number;
  location: string;
  date: string;
  time: string;
}

@Entry
@Component
export struct RegistrationStatusPage {
  @State registrationList: RegistrationInfo[] = [
    {
      id: '1',
      activityName: '端午民俗嘉年华',
      activityId: '1',
      registrationTime: '2024-06-01 10:30',
      status: 'confirmed',
      participants: 1,
      totalCapacity: 50,
      location: '深圳市民中心广场',
      date: '2024-06-10',
      time: '09:00-18:00'
    },
    {
      id: '2',
      activityName: '夜游灯会大赏',
      activityId: '2',
      registrationTime: '2024-06-02 14:20',
      status: 'pending',
      participants: 2,
      totalCapacity: 30,
      location: '深圳湾公园',
      date: '2024-06-15',
      time: '19:00-22:00'
    },
    {
      id: '3',
      activityName: '湖畔音乐露营',
      activityId: '3',
      registrationTime: '2024-06-03 16:45',
      status: 'confirmed',
      participants: 1,
      totalCapacity: 20,
      location: '东湖公园',
      date: '2024-06-20',
      time: '18:00-次日08:00'
    },
    {
      id: '4',
      activityName: '城市马拉松',
      activityId: '4',
      registrationTime: '2024-06-04 09:15',
      status: 'cancelled',
      participants: 1,
      totalCapacity: 1000,
      location: '深圳湾体育中心',
      date: '2024-06-25',
      time: '07:00-12:00'
    }
  ];

  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '待确认', '已确认', '已取消'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '报名情况',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      // 统计卡片
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
          Text('总报名')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('已确认')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('待确认')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ef4444')
          Text('已取消')
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
      ForEach(this.tabs, (tab: string, index: number) => {
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
      })
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
        ForEach(this.getFilteredRegistrations(), (item: RegistrationInfo) => {
          this.RegistrationCard(item)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder RegistrationCard(item: RegistrationInfo) {
    Column() {
      // 活动信息
      Row() {
        Column() {
          Text(item.activityName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .margin({ bottom: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${item.location} · ${item.date} ${item.time}`)
            .fontSize(12)
            .fontColor('#6b7280')
            .margin({ bottom: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 状态标签
        Text(this.getStatusText(item.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(item.status))
          .backgroundColor(this.getStatusBgColor(item.status))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 详细信息
      Row() {
        Column() {
          Text('报名时间')
            .fontSize(10)
            .fontColor('#9ca3af')
            .margin({ bottom: 2 })
          Text(item.registrationTime)
            .fontSize(12)
            .fontColor('#374151')
        }
        .layoutWeight(1)

        Column() {
          Text('参与人数')
            .fontSize(10)
            .fontColor('#9ca3af')
            .margin({ bottom: 2 })
          Text(`${item.participants}/${item.totalCapacity}`)
            .fontSize(12)
            .fontColor('#374151')
        }
        .layoutWeight(1)

        Column() {
          Text('活动ID')
            .fontSize(10)
            .fontColor('#9ca3af')
            .margin({ bottom: 2 })
          Text(item.activityId)
            .fontSize(12)
            .fontColor('#374151')
        }
        .layoutWeight(1)
      }
      .width('100%')

      // 操作按钮
      Row() {
        if (item.status === 'pending') {
          Button('取消报名')
            .fontSize(12)
            .fontColor('#ef4444')
            .backgroundColor('#fef2f2')
            .borderRadius(8)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.cancelRegistration(item.id);
            })
        } else if (item.status === 'confirmed') {
          Button('查看详情')
            .fontSize(12)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .borderRadius(8)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.viewDetails(item.id);
            })
        }

        Blank()

        Button('联系客服')
          .fontSize(12)
          .fontColor('#6b7280')
          .backgroundColor('#f3f4f6')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/customer/CustomerServicePage' });
          })
      }
      .width('100%')
      .margin({ top: 12 })
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

  private getFilteredRegistrations(): RegistrationInfo[] {
    switch (this.selectedTab) {
      case 1: // 待确认
        return this.registrationList.filter(item => item.status === 'pending');
      case 2: // 已确认
        return this.registrationList.filter(item => item.status === 'confirmed');
      case 3: // 已取消
        return this.registrationList.filter(item => item.status === 'cancelled');
      default: // 全部
        return this.registrationList;
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'pending': return '待确认';
      case 'confirmed': return '已确认';
      case 'cancelled': return '已取消';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'pending': return '#f59e0b';
      case 'confirmed': return '#10b981';
      case 'cancelled': return '#ef4444';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'pending': return '#fef3c7';
      case 'confirmed': return '#d1fae5';
      case 'cancelled': return '#fee2e2';
      default: return '#f3f4f6';
    }
  }

  private cancelRegistration(id: string): void {
    const index = this.registrationList.findIndex(item => item.id === id);
    if (index !== -1) {
      this.registrationList[index].status = 'cancelled';
    }
  }

  private viewDetails(id: string): void {
    // 跳转到活动详情页面
    router.pushUrl({ 
      url: 'pages/activity/ActivityDetailPage',
      params: { id: id }
    });
  }
}
