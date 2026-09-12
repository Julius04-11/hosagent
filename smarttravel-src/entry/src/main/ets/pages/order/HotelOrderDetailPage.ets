import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { HotelOrderData, HotelOrder, OrderStatusInfo, OrderStatus } from '../../model/HotelOrderModel';

@Entry
@Component
export struct HotelOrderDetailPage {
  @State order: HotelOrder = new HotelOrder('', '', '', '', '', '', 0, OrderStatus.ALL, '', '', '', 0, 0);

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const orderId: string = params && (params['orderId'] as string);
    const list: HotelOrder[] = HotelOrderData.getCurrentOrders();
    const found: HotelOrder | undefined = orderId ? list.find(o => o.id === orderId) : undefined;
    if (found) {
      this.order = found;
    } else if (list.length > 0) {
      this.order = list[0];
    }
  }

  private goPay() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/payment/PaymentPage',
        params: {
          orderInfo: {
            orderId: this.order.id,
            totalPrice: this.order.totalPrice,
            paymentMethod: 'wechat'
          }
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '支付页面'));
  }

  build() {
    Column() {
      TopNavigationBar({ title: '订单详情', showBack: true })

      Column() {
        // 酒店信息
        Column() {
          Row() {
            Text(this.order.hotelImage || '🏨').fontSize(32).margin({ right: 12 })
            Column() {
              Text(this.order.hotelName || '').fontSize(18).fontWeight(FontWeight.Bold)
              Text(this.order.roomType || '').fontSize(14).fontColor('#666').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)

            Text(OrderStatusInfo.getStatusText(this.order.status))
              .fontSize(14)
              .fontColor('#007AFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#E6F3FF')
              .borderRadius(4)
          }.width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 12 })

        // 日期与住客
        Column() {
          Row() {
            Text('入住/离店').fontSize(14).fontColor('#666').layoutWeight(1)
            Text(`${this.order.checkInDate || ''} - ${this.order.checkOutDate || ''}`).fontSize(14)
          }.width('100%').margin({ bottom: 8 })

          Row() {
            Text('住客信息').fontSize(14).fontColor('#666').layoutWeight(1)
            Text(`${this.order.guestName || ''}  ${this.order.guestPhone || ''}`).fontSize(14)
          }.width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 12 })
        .alignItems(HorizontalAlign.Start)

        // 金额
        Column() {
          Row() {
            Text('实付金额').fontSize(14).fontColor('#666').layoutWeight(1)
            Text(`¥ ${this.order.totalPrice || 0}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FF6B35')
          }.width('100%')

          Row() {
            Text('订单号').fontSize(12).fontColor('#999').layoutWeight(1)
            Text(this.order.id || '').fontSize(12).fontColor('#999')
          }.width('100%').margin({ top: 8 })

          Row() {
            Text('下单时间').fontSize(12).fontColor('#999').layoutWeight(1)
            Text(this.order.orderTime || '').fontSize(12).fontColor('#999')
          }.width('100%').margin({ top: 4 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      }
      .padding(16)
      .layoutWeight(1)

      // 底部操作
      Row() {
        if (this.order.status === OrderStatus.PENDING_PAYMENT) {
          Button('去支付')
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(24)
            .onClick(() => this.goPay())
        } else {
          Button('返回订单列表')
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .backgroundColor('#007AFF')
            .fontColor(Color.White)
            .borderRadius(24)
            .onClick(() => {
              ErrorHandler.safeExecute(async (): Promise<void> => {
                await router.back();
              }, (error: Error): void => ErrorHandler.handleGenericError(error, '返回'));
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#f0f0f0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
