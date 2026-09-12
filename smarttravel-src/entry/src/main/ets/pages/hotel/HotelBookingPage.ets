import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { HotelOrder, OrderStatus, HotelOrderData } from '../../model/HotelOrderModel';

@Entry
@Component
export struct HotelBookingPage {
  @State hotelName: string = '豪华酒店';
  @State roomType: string = '豪华大床房';
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State price: number = 489;
  @State nights: number = 1;
  @State guestName: string = '';
  @State guestPhone: string = '';
  @State totalPrice: number = 489;
  @State showDatePicker: boolean = false;
  @State dateType: 'checkin' | 'checkout' = 'checkin';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.hotelName = params['hotelName'] as string || '豪华酒店';
      this.price = params['price'] as number || 489;
      this.checkInDate = params['checkInDate'] as string || '';
      this.checkOutDate = params['checkOutDate'] as string || '';
      this.calculateTotal();
    }
  }

  private calculateTotal() {
    if (this.checkInDate && this.checkOutDate) {
      // 简单计算天数（实际应该用日期库）
      this.nights = 2; // 默认2晚
      this.totalPrice = this.price * this.nights;
    }
  }

  private generateAvailableDates(): string[] {
    const dates: string[] = [];
    const today = new Date();
    for (let i = 0; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      dates.push(dateStr);
    }
    return dates;
  }

  private onBooking() {
    if (!this.validateForm()) {
      return;
    }

    // 创建订单并跳转到订单页面
    const order = new HotelOrder(
      'HT' + Date.now().toString(),
      this.hotelName,
      '🏨',
      this.roomType,
      this.checkInDate,
      this.checkOutDate,
      this.totalPrice,
      OrderStatus.PENDING_PAYMENT,
      new Date().toLocaleString(),
      this.guestName,
      this.guestPhone,
      1,
      this.nights
    );

    // 写入全局订单并跳转到支付页
    HotelOrderData.addOrder(order);

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

  private validateForm(): boolean {
    if (!this.checkInDate) {
      ErrorHandler.showToast('请选择入住日期');
      return false;
    }
    if (!this.checkOutDate) {
      ErrorHandler.showToast('请选择退房日期');
      return false;
    }
    if (!this.guestName.trim()) {
      ErrorHandler.showToast('请输入客人姓名');
      return false;
    }
    if (!this.guestPhone.trim()) {
      ErrorHandler.showToast('请输入联系电话');
      return false;
    }
    return true;
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '酒店预订',
        showBack: true
      })

      Scroll() {
        Column() {
          // 酒店信息
          Row() {
            Text('🏨').fontSize(40).margin({ right: 16 })
            Column() {
              Text(this.hotelName).fontSize(18).fontWeight(FontWeight.Bold)
              Text(this.roomType).fontSize(14).fontColor('#666').margin({ top: 4 })
              Text(`¥${this.price}/晚`).fontSize(16).fontColor('#FF6B35').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12).margin({ bottom: 16 })

          // 日期选择
          Column() {
            Text('入住信息').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
            
            Row() {
              Column() {
                Text('入住日期')
                  .fontSize(12)
                  .fontColor('#666')
                Text(this.checkInDate || '选择日期')
                  .fontSize(14)
                  .fontColor(this.checkInDate ? '#1a1a1a' : '#999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                this.dateType = 'checkin';
                this.showDatePicker = true;
              })

              Text('|')
                .fontSize(16)
                .fontColor('#e0e0e0')
                .margin({ left: 16, right: 16 })

              Column() {
                Text('退房日期')
                  .fontSize(12)
                  .fontColor('#666')
                Text(this.checkOutDate || '选择日期')
                  .fontSize(14)
                  .fontColor(this.checkOutDate ? '#1a1a1a' : '#999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                this.dateType = 'checkout';
                this.showDatePicker = true;
              })
            }
            .width('100%')
            .height(50)
            .padding(12)
            .backgroundColor('#f9f9f9')
            .borderRadius(8)

            if (this.checkInDate && this.checkOutDate) {
              Text(`共${this.nights}晚`)
                .fontSize(12)
                .fontColor('#666')
                .margin({ top: 8 })
            }
          }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12).margin({ bottom: 16 }).alignItems(HorizontalAlign.Start)

          // 日期选择器
          if (this.showDatePicker) {
            Column() {
              Text(this.dateType === 'checkin' ? '选择入住日期' : '选择退房日期')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 })

              Grid() {
                ForEach(this.generateAvailableDates() ?? [], (date: string, index: number) => {
                  GridItem() {
                    Text(date)
                      .fontSize(14)
                      .fontColor('#1a1a1a')
                      .backgroundColor(Color.White)
                      .width(60)
                      .height(40)
                      .textAlign(TextAlign.Center)
                      .borderRadius(8)
                      .border({ width: 1, color: '#e0e0e0' })
                      .onClick(() => {
                        if (this.dateType === 'checkin') {
                          this.checkInDate = date;
                        } else {
                          this.checkOutDate = date;
                        }
                        this.calculateTotal();
                        this.showDatePicker = false;
                      })
                  }
                }, (date: string, index: number) => `date-${index}-${date}`)
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .height(200)

              Button('取消')
                .width('100%')
                .margin({ top: 16 })
                .onClick(() => {
                  this.showDatePicker = false;
                })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 8, color: '#00000020' })
            .margin({ bottom: 16 })
          }

          // 客人信息
          Column() {
            Text('客人信息').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
            TextInput({ placeholder: '请输入客人姓名' })
              .fontSize(14)
              .height(44)
              .backgroundColor('#f9f9f9')
              .borderRadius(8)
              .onChange((value: string) => { this.guestName = value; })
              .margin({ bottom: 12 })
            TextInput({ placeholder: '请输入联系电话' })
              .fontSize(14)
              .height(44)
              .backgroundColor('#f9f9f9')
              .borderRadius(8)
              .type(InputType.PhoneNumber)
              .onChange((value: string) => { this.guestPhone = value; })
          }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12).alignItems(HorizontalAlign.Start)

          // 价格明细
          if (this.checkInDate && this.checkOutDate) {
            Column() {
              Text('价格明细').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
              
              Row() {
                Text(`${this.roomType} × ${this.nights}晚`)
                  .fontSize(14)
                  .fontColor('#666')
                  .layoutWeight(1)
                Text(`¥${this.price * this.nights}`)
                  .fontSize(14)
                  .fontColor('#1a1a1a')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Divider()
                .color('#e0e0e0')
                .margin({ top: 8, bottom: 8 })

              Row() {
                Text('总计')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
                  .layoutWeight(1)
                Text(`¥${this.totalPrice}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ top: 16 })
            .alignItems(HorizontalAlign.Start)
          }
        }.padding(16)
      }.layoutWeight(1)

      // 底部预订按钮
      Row() {
        Column() {
          Text('总计')
            .fontSize(12)
            .fontColor('#666')
          Text(`¥${this.totalPrice}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 16 })

        Button('立即预订')
          .layoutWeight(1)
          .height(48)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .borderRadius(24)
          .onClick(() => this.onBooking())
      }.width('100%').padding(16).backgroundColor(Color.White).border({ width: { top: 1 }, color: '#e0e0e0' })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
