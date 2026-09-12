import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { HotelOrder, OrderStatus, OrderStatusInfo, HotelOrderData } from '../../model/HotelOrderModel';
import { ErrorHandler } from '../../utils/ErrorHandler';

@Entry
@Component
export struct HotelOrderPage {
  @State allOrders: HotelOrder[] = [];
  @State currentTabIndex: number = 0;
  @State tabTitles: string[] = ['全部', '待支付', '待入住', '待评价'];
  
  private tabsController: TabsController = new TabsController();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const tabIndexParam = params && typeof params['tabIndex'] === 'number' ? params['tabIndex'] as number : undefined;
    if (tabIndexParam !== undefined) {
      this.currentTabIndex = tabIndexParam;
      this.tabsController.changeIndex(tabIndexParam);
    }
    this.loadOrders();
  }

  private loadOrders() {
    // 加载全局订单（首次会用mock填充）
    setTimeout(() => {
      this.allOrders = HotelOrderData.getCurrentOrders();
    }, 100);
  }

  private getOrdersByStatus(status: OrderStatus): HotelOrder[] {
    return HotelOrderData.getOrdersByStatus(this.allOrders, status);
  }

  private onTabChange(index: number) {
    this.currentTabIndex = index;
    this.tabsController.changeIndex(index);
  }

  private onOrderAction(order: HotelOrder) {
    switch (order.status) {
      case OrderStatus.PENDING_PAYMENT:
        this.navigateToPayment(order);
        break;
      case OrderStatus.PENDING_CHECKIN:
        this.rebookOrder(order);
        break;
      case OrderStatus.WAITING_EVALUATE:
        this.navigateToEvaluate(order);
        break;
      default:
        this.viewOrderDetail(order);
        break;
    }
  }

  private navigateToPayment(order: HotelOrder) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/payment/PaymentPage',
        params: {
          orderInfo: {
            orderId: order.id,
            totalPrice: order.totalPrice,
            paymentMethod: 'wechat'
          }
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '支付页面'));
  }

  private rebookOrder(order: HotelOrder) {
    ErrorHandler.showToast('跳转到重新预订页面');
  }

  private navigateToEvaluate(order: HotelOrder) {
    ErrorHandler.showToast('跳转到评价页面');
  }

  private viewOrderDetail(order: HotelOrder) {
    this.navigateToDetail(order);
  }

  private navigateToDetail(order: HotelOrder) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/order/HotelOrderDetailPage',
        params: { orderId: order.id }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '订单详情'));
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '酒店订单',
        showBack: true
      })

      Stack({ alignContent: Alignment.TopStart }) {
        // 自定义Tab栏
        List({ initialIndex: 0, scroller: this.scroller }) {
          ListItem() {
            Row() {
              ForEach(this.tabTitles, (title: string, index: number) => {
                Column() {
                  Text(title)
                    .fontSize(16)
                    .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666666')
                    .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
                    .margin({ bottom: 8 })

                  // 下划线指示器
                  if (this.currentTabIndex === index) {
                    Divider()
                      .width(20)
                      .height(2)
                      .color('#007AFF')
                  }
                }
                .width('25%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .onClick(() => this.onTabChange(index))
              })
            }
            .width('100%')
            .height(44)
            .backgroundColor(Color.White)
          }
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height(44)
        .zIndex(1)

        // Tab内容区域
        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          // 全部订单
          TabContent() {
            this.OrderListContent(OrderStatus.ALL)
          }

          // 待支付订单
          TabContent() {
            this.OrderListContent(OrderStatus.PENDING_PAYMENT)
          }

          // 待入住订单
          TabContent() {
            this.OrderListContent(OrderStatus.PENDING_CHECKIN)
          }

          // 待评价订单
          TabContent() {
            this.OrderListContent(OrderStatus.WAITING_EVALUATE)
          }
        }
        .barHeight(0) // 隐藏默认Tab栏
        .margin({ top: 44 }) // 为自定义Tab栏留出空间
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
        .layoutWeight(1)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder OrderListContent(status: OrderStatus) {
    List() {
      ForEach(this.getOrdersByStatus(status), (order: HotelOrder) => {
        ListItem() {
          this.OrderItemCard(order)
        }
        .margin({ left: 16, right: 16, top: 8, bottom: 8 })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: 8 })
  }

  @Builder OrderItemCard(order: HotelOrder) {
    Column() {
      // 酒店信息头部
      Row() {
        Text(order.hotelImage)
          .fontSize(20)
          .margin({ right: 8 })

        Text(order.hotelName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a1a1a')
          .layoutWeight(1)

        Text(OrderStatusInfo.getStatusText(order.status))
          .fontSize(14)
          .fontColor('#007AFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#E6F3FF')
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 房间信息
      Row() {
        Column() {
          // 房间图片占位
          Text('🛏️')
            .fontSize(40)
            .width(80)
            .height(60)
            .textAlign(TextAlign.Center)
            .backgroundColor('#f0f0f0')
            .borderRadius(8)
        }
        .margin({ right: 12 })

        Column() {
          Text(order.roomType)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a1a1a')
            .margin({ bottom: 4 })

          Text(`${order.checkInDate} - ${order.checkOutDate}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Row() {
            Text('实付款')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ right: 8 })

            Text(`¥ ${order.totalPrice}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B35')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 16 })

      // 操作按钮
      Row() {
        if (order.status !== OrderStatus.PENDING_PAYMENT) {
          Button('更多')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#f0f0f0')
            .borderRadius(4)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ right: 12 })
            .onClick(() => {
              ErrorHandler.showToast('更多操作');
            })

          Button('再次预订')
            .fontSize(14)
            .fontColor('#007AFF')
            .backgroundColor('#E6F3FF')
            .borderRadius(4)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ right: 12 })
            .onClick(() => this.rebookOrder(order))
        }

        Button(OrderStatusInfo.getActionText(order.status))
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(OrderStatusInfo.getActionButtonColor(order.status))
          .borderRadius(4)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => this.onOrderAction(order))
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.navigateToDetail(order))
  }
}
