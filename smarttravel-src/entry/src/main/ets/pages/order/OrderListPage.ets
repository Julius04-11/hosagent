/**
 * 订单列表页面 - 显示待评价订单
 * 支持按预订日期分组显示订单
 * 使用Tabs组件和@Observed/@ObjectLink实现响应式状态管理
 */

import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { OrderViewModel, OrderStatus, OrderType } from '../../viewmodel/OrderViewModel';
import { GroupedOrder, HotelOrder, ObservableOrder } from '../../model/OrderModel';

// Tab配置
interface TabConfig {
  index: number;
  title: string;
}

// 分组订单接口
interface GroupedOrderEntry {
  date: string;
  orders: HotelOrder[];
}

const TAB_CONFIGS: TabConfig[] = [
  { index: 0, title: '全部' },
  { index: 1, title: '待评价' },
  { index: 2, title: '已完成' }
];

@Entry
@Component
export struct OrderListPage {
  private viewModel: OrderViewModel = new OrderViewModel();
  
  @State groupedOrders: GroupedOrder[] = [];
  @State observableOrders: ObservableOrder[] = [];
  @State isLoading: boolean = false;
  @State selectedTab: number = 0; // 0: 全部, 1: 待评价, 2: 已完成
  
  // Tabs相关
  private tabsController: TabsController = new TabsController();
  private scroller: Scroller = new Scroller();
  private indicatorLeftMargin: number = 0;
  private tabPosWidthMap: Map<string, Record<string, number>> = new Map();
  private uiContext: UIContext = this.getUIContext();
  private readonly STACK_PADDING: number = 16;
  private readonly UNDERLINE_WIDTH: number = 56;
  private readonly ANIMATE_DURATION: number = 300;
  private underlineDistance: number = 0;

  async aboutToAppear() {
    await this.loadOrders();
  }

  // 页面显示时刷新订单（从评价页面返回时）
  onPageShow() {
    // 重新加载订单以更新评价状态
    this.loadOrders();
  }

  // 更新ObservableOrder的评价状态
  private updateOrderReviewStatus(orderId: string, hasReview: boolean) {
    const observableOrder = this.observableOrders.find(o => o.orderId === orderId);
    if (observableOrder) {
      if (hasReview) {
        observableOrder.markAsReviewed();
      }
    }
  }

  // 加载订单并分组
  private async loadOrders() {
    this.isLoading = true;
    await this.viewModel.initialize();
    this.groupOrders();
    this.isLoading = false;
  }

  // 将订单按日期分组
  private groupOrders() {
    const orders = this.viewModel.orders.filter(order => 
      order.type === OrderType.HOTEL && 
      (this.selectedTab === 0 || 
       (this.selectedTab === 1 && order.status === OrderStatus.COMPLETED && !this.viewModel.getReviewByOrderId(order.orderId)) ||
       (this.selectedTab === 2 && order.status === OrderStatus.COMPLETED))
    );

    // 转换为ObservableOrder（响应式订单）
    // 如果已存在相同的订单，保留原有实例以保持响应式连接
    const newObservableOrders: ObservableOrder[] = [];
    orders.forEach(order => {
      const hasReview = !!this.viewModel.getReviewByOrderId(order.orderId);
      const existingOrder = this.observableOrders.find(o => o.orderId === order.orderId);
      if (existingOrder) {
        // 更新现有订单的状态
        if (hasReview && !existingOrder.hasReview) {
          existingOrder.markAsReviewed();
        }
        existingOrder.status = order.status;
        existingOrder.updateTime = order.updateTime;
        newObservableOrders.push(existingOrder);
      } else {
        // 创建新订单
        newObservableOrders.push(new ObservableOrder(
          order,
          order.title,
          order.description,
          hasReview
        ));
      }
    });
    this.observableOrders = newObservableOrders;

    // 转换为HotelOrder（用于分组显示）
    const hotelOrders: HotelOrder[] = orders.map(order => {
      const hotelOrder: HotelOrder = {
        orderId: order.orderId,
        type: order.type,
        title: order.title,
        description: order.description,
        image: order.image,
        status: order.status,
        price: order.price,
        quantity: order.quantity,
        totalAmount: order.totalAmount,
        createTime: order.createTime,
        updateTime: order.updateTime,
        checkInDate: order.checkInDate || '',
        checkOutDate: order.checkOutDate || '',
        travelDate: order.travelDate,
        contactInfo: order.contactInfo,
        location: order.location,
        hotelName: order.title,
        roomType: order.description,
        guestCount: order.quantity,
        hasReview: !!this.viewModel.getReviewByOrderId(order.orderId)
      };
      return hotelOrder;
    });

    // 按预订日期分组
    const groupedMap = new Map<string, HotelOrder[]>();
    hotelOrders.forEach(order => {
      const date = order.checkInDate || this.formatDate(order.createTime);
      if (!groupedMap.has(date)) {
        groupedMap.set(date, []);
      }
      groupedMap.get(date)!.push(order);
    });

    // 转换为数组并排序
    this.groupedOrders = Array.from(groupedMap.entries())
      .map((entry): GroupedOrderEntry => ({
        date: entry[0],
        orders: entry[1].sort((a, b) => b.createTime - a.createTime)
      }))
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  }

  // 格式化日期
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 切换标签
  private onTabChange(index: number) {
    this.selectedTab = index;
    this.tabsController.changeIndex(index);
    this.groupOrders();
  }

  // 获取Tab位置信息
  private getTabInfo(keyId: string): Record<string, number> {
    const posWidth = this.tabPosWidthMap.get(keyId);
    if (posWidth) {
      return posWidth;
    }
    return { 'left': 0, 'width': 0 };
  }

  // 启动动画
  private startAnimateTo(duration: number, leftMargin: number) {
    this.uiContext.animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
      this.indicatorLeftMargin = leftMargin + this.underlineDistance;
    });
  }

  // 跳转到评价页面
  private navigateToReview(orderId: string) {
    router.pushUrl({
      url: 'pages/order/UserReviewPage',
      params: { orderId: orderId }
    }).catch((error: Error) => {
      console.error('跳转失败:', error.message);
    });
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '我的订单',
        showBack: true
      })

      // 自定义Tab栏（参考官方示例）
      Stack({ alignContent: Alignment.TopStart }) {
        List({ initialIndex: 0, scroller: this.scroller }) {
          ForEach(TAB_CONFIGS, (tab: TabConfig, index: number) => {
            ListItem() {
              Row() {
                Text(tab.title)
                  .fontSize(14)
                  .lineHeight(20)
                  .fontColor(this.selectedTab === tab.index ? '#1890ff' : '#666666')
                  .fontWeight(this.selectedTab === tab.index ? FontWeight.Bold : FontWeight.Normal)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.onTabChange(tab.index);
              })
              .id(tab.index.toString())
              .onAreaChange((oldValue: Area, newValue: Area) => {
                if (newValue.globalPosition.x !== undefined) {
                  const width = Number.parseFloat(newValue.width.toString());
                  const globalX = Number.parseFloat(newValue.globalPosition.x.toString());
                  if (newValue.position.x !== undefined && this.selectedTab === tab.index &&
                    this.indicatorLeftMargin === 0) {
                    const positionX = Number.parseFloat(newValue.position.x.toString());
                    this.underlineDistance = (width - this.UNDERLINE_WIDTH) / 2;
                    this.indicatorLeftMargin = Number.isNaN(positionX) ? 0 : positionX + this.underlineDistance;
                  }
                  this.tabPosWidthMap.set(tab.index.toString(), { 'left': globalX, 'width': width });
                }
              })
            }
          }, (tab: TabConfig) => tab.index.toString())
        }
        .width('100%')
        .height(48)
        .listDirection(Axis.Horizontal)
        .onScrollFrameBegin((offset: number, state: ScrollState) => {
          this.indicatorLeftMargin -= offset;
          return { offsetRemain: offset };
        })

        // Tab指示器
        Column()
          .width(this.UNDERLINE_WIDTH)
          .height(2)
          .backgroundColor('#1890ff')
          .margin({ left: this.indicatorLeftMargin, top: 48 })

        // Tabs内容区域
        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          ForEach(TAB_CONFIGS, (tab: TabConfig, index: number) => {
            TabContent() {
              this.OrderListContent()
            }
          }, (tab: TabConfig) => tab.index.toString())
        }
        .tabIndex(0)
        .barHeight(0)
        .width('100%')
        .margin({ top: 50 })
        .scrollable(false)
        .backgroundColor(Color.Transparent)
        .animationDuration(this.ANIMATE_DURATION)
        .onChange((index: number) => {
          this.selectedTab = index;
          this.scroller.scrollToIndex(index - 1, true);
          this.groupOrders();
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          this.selectedTab = targetIndex;
          const targetIndexInfo = this.getTabInfo(targetIndex.toString());
          this.startAnimateTo(this.ANIMATE_DURATION, targetIndexInfo.left - this.STACK_PADDING);
        })
        .onAnimationEnd((index: number, event: TabsAnimationEvent) => {
          const targetIndexInfo = this.getTabInfo(index.toString());
          this.startAnimateTo(0, targetIndexInfo.left - this.STACK_PADDING);
        })
      }
      .width('100%')
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  // 订单列表内容
  @Builder
  OrderListContent() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#1890ff')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.groupedOrders.length === 0) {
      Column() {
        Text('暂无订单')
          .fontSize(16)
          .fontColor('#9ca3af')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.groupedOrders ?? [], (groupedOrder: GroupedOrder, gIdx: number) => {
            Column({ space: 12 }) {
              // 日期标题
              Text('预订日期：' + groupedOrder.date)
                .fontSize(14)
                .fontColor('#B3000000')
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ left: 16, top: 8, bottom: 4 })

              // 订单列表
              Column({ space: 8 }) {
                ForEach(groupedOrder.orders ?? [], (hotelOrder: HotelOrder, oIdx: number) => {
                  this.OrderCardSelector(hotelOrder)
                }, (hotelOrder: HotelOrder, oIdx: number) => `ord-${groupedOrder.date}-${hotelOrder.orderId}-${oIdx}`)
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }, (groupedOrder: GroupedOrder, gIdx: number) => `group-${groupedOrder.date}-${gIdx}`)
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
    }
  }

  // 订单卡片选择器
  @Builder
  OrderCardSelector(hotelOrder: HotelOrder) {
    if (this.hasObservableOrder(hotelOrder.orderId)) {
      this.OrderCardWithObjectLink(this.getObservableOrder(hotelOrder.orderId)!)
    } else {
      this.OrderCard(hotelOrder)
    }
  }

  // 检查是否有对应的ObservableOrder
  private hasObservableOrder(orderId: string): boolean {
    return this.observableOrders.some(o => o.orderId === orderId);
  }

  // 获取对应的ObservableOrder
  private getObservableOrder(orderId: string): ObservableOrder | undefined {
    return this.observableOrders.find(o => o.orderId === orderId);
  }

  // 使用@ObjectLink的响应式订单卡片
  @Builder
  OrderCardWithObjectLink(order: ObservableOrder) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        // 酒店图片
        Image(order.image || 'https://picsum.photos/id/301/200/150')
          .width(100)
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // 订单信息
        Column({ space: 6 }) {
          Text(order.hotelName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(order.roomType)
            .fontSize(13)
            .fontColor('#6b7280')

          Row({ space: 8 }) {
            Text(`入住：${order.checkInDate || ''}`)
              .fontSize(12)
              .fontColor('#9ca3af')
            Text(`退房：${order.checkOutDate || ''}`)
              .fontSize(12)
              .fontColor('#9ca3af')
          }

          Row() {
            Text(`¥${order.totalAmount}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ef4444')

            Blank()

            // 状态标签（响应式更新）
            Text(this.getStatusText(order.status))
              .fontSize(12)
              .fontColor(this.getStatusColor(order.status))
              .backgroundColor(this.getStatusBgColor(order.status))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      // 操作按钮（响应式更新）
      this.OrderActionButtons(order)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 订单操作按钮
  @Builder
  OrderActionButtons(order: ObservableOrder) {
    Row() {
      Blank()
      
      if (order.status === OrderStatus.COMPLETED && !order.hasReview) {
        Button('去评价')
          .type(ButtonType.Normal)
          .backgroundColor('#1890ff')
          .fontColor(Color.White)
          .fontSize(14)
          .width(100)
          .height(36)
          .onClick(() => {
            this.navigateToReview(order.orderId);
          })
      } else if (order.hasReview) {
        Text('已评价')
          .fontSize(14)
          .fontColor('#9ca3af')
      } else if (order.status === OrderStatus.PENDING) {
        Button('立即支付')
          .type(ButtonType.Normal)
          .backgroundColor('#1890ff')
          .fontColor(Color.White)
          .fontSize(14)
          .width(100)
          .height(36)
          .onClick(() => {
            order.updateStatus(OrderStatus.PAID);
            this.viewModel.updateOrderStatus(order.orderId, OrderStatus.PAID);
          })
        Button('取消订单', { type: ButtonType.Capsule })
          .fontColor('#666666')
          .backgroundColor('#f5f5f5')
          .fontSize(14)
          .width(80)
          .height(36)
          .margin({ left: 8 })
          .onClick(() => {
            order.updateStatus(OrderStatus.CANCELLED);
            this.viewModel.updateOrderStatus(order.orderId, OrderStatus.CANCELLED);
            this.groupOrders();
          })
      } else if (order.status === OrderStatus.PAID) {
        Button('查看详情')
          .type(ButtonType.Normal)
          .backgroundColor('#f5f5f5')
          .fontColor('#666666')
          .fontSize(14)
          .width(100)
          .height(36)
      }
    }
    .width('100%')
    .margin({ top: 8 })
  }

  @Builder
  OrderCard(order: HotelOrder) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        // 酒店图片
        Image(order.image || 'https://picsum.photos/id/301/200/150')
          .width(100)
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        // 订单信息
        Column({ space: 6 }) {
          Text(order.hotelName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(order.roomType)
            .fontSize(13)
            .fontColor('#6b7280')

          Row({ space: 8 }) {
            Text(`入住：${order.checkInDate}`)
              .fontSize(12)
              .fontColor('#9ca3af')
            Text(`退房：${order.checkOutDate}`)
              .fontSize(12)
              .fontColor('#9ca3af')
          }

          Row() {
            Text(`¥${order.totalAmount}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ef4444')

            Blank()

            // 状态标签
            Text(this.getStatusText(order.status))
              .fontSize(12)
              .fontColor(this.getStatusColor(order.status))
              .backgroundColor(this.getStatusBgColor(order.status))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      // 操作按钮
      if (order.status === OrderStatus.COMPLETED && !order.hasReview) {
        Row() {
          Blank()
          Button('去评价')
            .type(ButtonType.Normal)
            .backgroundColor('#1890ff')
            .fontColor(Color.White)
            .fontSize(14)
            .width(100)
            .height(36)
            .onClick(() => {
              this.navigateToReview(order.orderId);
            })
        }
        .width('100%')
        .margin({ top: 8 })
      } else if (order.hasReview) {
        Row() {
          Blank()
          Text('已评价')
            .fontSize(14)
            .fontColor('#9ca3af')
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getStatusText(status: OrderStatus): string {
    const statusMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '待支付',
      [OrderStatus.PAID]: '已支付',
      [OrderStatus.CONFIRMED]: '已确认',
      [OrderStatus.COMPLETED]: '已完成',
      [OrderStatus.CANCELLED]: '已取消',
      [OrderStatus.REFUNDED]: '已退款'
    };
    return statusMap[status] || '未知';
  }

  private getStatusColor(status: OrderStatus): string {
    const colorMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '#f59e0b',
      [OrderStatus.PAID]: '#3b82f6',
      [OrderStatus.CONFIRMED]: '#10b981',
      [OrderStatus.COMPLETED]: '#10b981',
      [OrderStatus.CANCELLED]: '#ef4444',
      [OrderStatus.REFUNDED]: '#9ca3af'
    };
    return colorMap[status] || '#666666';
  }

  private getStatusBgColor(status: OrderStatus): string {
    const bgColorMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '#fef3c7',
      [OrderStatus.PAID]: '#dbeafe',
      [OrderStatus.CONFIRMED]: '#d1fae5',
      [OrderStatus.COMPLETED]: '#d1fae5',
      [OrderStatus.CANCELLED]: '#fee2e2',
      [OrderStatus.REFUNDED]: '#f3f4f6'
    };
    return bgColorMap[status] || '#f3f4f6';
  }
}

