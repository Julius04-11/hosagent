/**
 * 订单管理页面
 * 参考: example_code/TravelCheckinOrder
 * v5.0: 支持Tab导航和订单状态筛选
 */

import { router } from '@kit.ArkUI';

interface OrderItem {
  id: string;
  title: string;
  subtitle: string;
  price: number;
  status: 'all' | 'pending' | 'confirmed' | 'completed';
  statusText: string;
  date: string;
}

@Entry
@Component
export struct OrderPage {
  @State currentTabIndex: number = 0;
  @State orders: OrderItem[] = [];

  private tabNames: string[] = ['全部', '待支付', '待入住', '已完成'];

  aboutToAppear() {
    this.loadOrders();
  }

  build() {
    Column() {
      this.TopBar()
      this.TabNavigation()
      this.OrderList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#1e40af')
        .onClick(() => router.back())

      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('    ')
        .fontSize(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder TabNavigation() {
    Tabs({ index: this.currentTabIndex }) {
      ForEach(this.tabNames, (name: string, index: number) => {
        TabContent() {
        }
        .tabBar(this.TabBuilder(name, index))
      })
    }
    .width('100%')
    .height(48)
    .backgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
  }

  @Builder TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontColor(this.currentTabIndex === index ? '#1e40af' : '#64748b')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
  }

  @Builder OrderList() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredOrders(), (order: OrderItem) => {
          this.OrderCard(order)
        })

        if (this.getFilteredOrders().length === 0) {
          Column() {
            Text('📦')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('暂无订单')
              .fontSize(16)
              .fontColor('#94a3b8')
          }
          .width('100%')
          .height(300)
          .justifyContent(FlexAlign.Center)
        }
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder OrderCard(order: OrderItem) {
    Column() {
      Row() {
        Text(order.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')
          .layoutWeight(1)

        Text(order.statusText)
          .fontSize(14)
          .fontColor(this.getStatusColor(order.status))
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(order.subtitle)
        .fontSize(14)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 8 })

      Text(order.date)
        .fontSize(12)
        .fontColor('#94a3b8')
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        Text(`¥${order.price}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#f43f5e')
          .layoutWeight(1)

        Button('查看详情')
          .fontSize(14)
          .height(36)
          .backgroundColor('#1e40af')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/order/HotelOrderDetailPage',
              params: { orderId: order.id }
            });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  private loadOrders() {
    this.orders = [
      {
        id: '001',
        title: '深圳大梅沙海景酒店',
        subtitle: '豪华海景房 × 1',
        price: 888,
        status: 'completed',
        statusText: '已完成',
        date: '2024-11-15 至 2024-11-17'
      },
      {
        id: '002',
        title: '深圳世界之窗门票',
        subtitle: '成人票 × 2',
        price: 400,
        status: 'pending',
        statusText: '待支付',
        date: '预订日期: 2024-11-20'
      }
    ];
  }

  private getFilteredOrders(): OrderItem[] {
    if (this.currentTabIndex === 0) {
      return this.orders;
    }

    const statusMap = ['all', 'pending', 'confirmed', 'completed'];
    const targetStatus = statusMap[this.currentTabIndex];

    return this.orders.filter(order => order.status === targetStatus);
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'pending':
        return '#f59e0b';
      case 'confirmed':
        return '#3b82f6';
      case 'completed':
        return '#10b981';
      default:
        return '#64748b';
    }
  }
}
