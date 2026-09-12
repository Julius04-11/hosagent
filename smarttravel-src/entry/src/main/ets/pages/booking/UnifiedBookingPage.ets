import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface ActivityInfo {
  id: string;
  name: string;
  image: string;
  price: number;
  originalPrice?: number;
  description: string;
  validDate: string;
  location: string;
  features: string[];
  notices: string[];
  isFree: boolean;
  type: 'ticket' | 'signup';
}

interface BookingInfo {
  ticketCount: number;
  selectedDate: string;
  contactName: string;
  contactPhone: string;
  idCard: string;
  gender: '男' | '女' | '';
  age: number;
  totalPrice: number;
}

interface PaymentMethod {
  id: string;
  name: string;
  icon: string;
  enabled: boolean;
}

@Entry
@Component
export struct UnifiedBookingPage {
  @State activityInfo: ActivityInfo = {} as ActivityInfo;
  @State bookingInfo: BookingInfo = {
    ticketCount: 1,
    selectedDate: '',
    contactName: '',
    contactPhone: '',
    idCard: '',
    gender: '',
    age: 0,
    totalPrice: 0
  };
  @State isLoading: boolean = true;
  @State showDatePicker: boolean = false;
  @State showPaymentMethods: boolean = false;
  @State selectedPaymentMethod: string = '';
  @State availableDates: string[] = [];
  
  private paymentMethods: PaymentMethod[] = [
    { id: 'wechat', name: '微信支付', icon: '💚', enabled: true },
    { id: 'alipay', name: '支付宝', icon: '🔵', enabled: true },
    { id: 'bankcard', name: '银行卡', icon: '💳', enabled: true },
    { id: 'creditcard', name: '信用卡', icon: '💎', enabled: true }
  ];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const activityId = params['id'] as string || '1';
    const activityName = params['name'] as string || '活动';
    const price = params['price'] as number || 0;
    this.loadActivityInfo(activityId, activityName, price);
    this.generateAvailableDates();
  }

  private loadActivityInfo(activityId: string, activityName: string, price: number) {
    setTimeout(() => {
      this.activityInfo = {
        id: activityId,
        name: activityName,
        image: '🎫',
        price: price,
        originalPrice: price > 0 ? price + 20 : 0,
        description: price === 0 ? '免费参与活动，需要提前报名' : '精彩活动，立即购票参与',
        validDate: '2025年10月10日 - 2025年10月12日',
        location: '深圳市南山区',
        features: price === 0 ? ['免费参与', '提前报名', '身份验证'] : ['电子票', '快速入场', '退改保障'],
        notices: price === 0 ? ['请携带身份证件', '提前30分钟到场', '活动当天签到'] : ['请在有效期内使用', '一经售出概不退换', '请妥善保管票据'],
        isFree: price === 0,
        type: price === 0 ? 'signup' : 'ticket'
      };
      this.updateTotalPrice();
      this.isLoading = false;
    }, 500);
  }

  private generateAvailableDates() {
    const dates: string[] = [];
    const today = new Date();
    for (let i = 1; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      dates.push(date.toLocaleDateString('zh-CN'));
    }
    this.availableDates = dates;
  }

  private updateTotalPrice() {
    this.bookingInfo.totalPrice = this.activityInfo.price * this.bookingInfo.ticketCount;
  }

  private onTicketCountChange(delta: number) {
    const newCount = this.bookingInfo.ticketCount + delta;
    if (newCount >= 1 && newCount <= 10) {
      this.bookingInfo.ticketCount = newCount;
      this.updateTotalPrice();
    }
  }

  private onConfirmBooking() {
    if (!this.validateBookingInfo()) {
      return;
    }

    if (this.activityInfo.isFree) {
      // 免费报名，直接跳转到确认页面
      this.navigateToConfirmPage();
    } else {
      // 付费购票，显示支付方式选择
      this.showPaymentMethods = true;
    }
  }

  private validateBookingInfo(): boolean {
    if (!this.bookingInfo.contactName.trim()) {
      ErrorHandler.showToast('请输入联系人姓名');
      return false;
    }
    if (!this.bookingInfo.contactPhone.trim()) {
      ErrorHandler.showToast('请输入联系人电话');
      return false;
    }
    if (!this.bookingInfo.selectedDate) {
      ErrorHandler.showToast('请选择活动日期');
      return false;
    }
    if (this.activityInfo.type === 'signup') {
      if (!this.bookingInfo.idCard.trim()) {
        ErrorHandler.showToast('请输入身份证号');
        return false;
      }
      if (!this.bookingInfo.gender) {
        ErrorHandler.showToast('请选择性别');
        return false;
      }
      if (this.bookingInfo.age <= 0) {
        ErrorHandler.showToast('请输入正确的年龄');
        return false;
      }
    }
    return true;
  }

  private onPaymentMethodSelected(methodId: string) {
    this.selectedPaymentMethod = methodId;
    this.showPaymentMethods = false;
    this.processPayment(methodId);
  }

  private processPayment(methodId: string) {
    const method = this.paymentMethods.find(m => m.id === methodId);
    if (!method) return;

    ErrorHandler.showToast(`正在跳转到${method.name}...`);
    
    // 模拟支付处理
    setTimeout(() => {
      this.navigateToPaymentPage(methodId);
    }, 1000);
  }

  private navigateToConfirmPage() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/order/OrderConfirmPage',
        params: {
          activityInfo: this.activityInfo,
          bookingInfo: this.bookingInfo
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '确认页面'));
  }

  private navigateToPaymentPage(paymentMethod: string) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/payment/PaymentPage',
        params: {
          orderInfo: {
            orderId: 'ST' + Date.now().toString(),
            activityName: this.activityInfo.name,
            totalPrice: this.bookingInfo.totalPrice,
            paymentMethod: paymentMethod
          },
          bookingInfo: this.bookingInfo
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '支付页面'));
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '统一预订',
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            this.ActivityInfoCard()
            this.BookingFormSection()
            if (!this.activityInfo.isFree) {
              this.PriceSection()
            }
            this.NoticesSection()
          }
          .padding(16)
        }
        .layoutWeight(1)

        this.BottomActionBar()
      }

      if (this.showPaymentMethods) {
        this.PaymentMethodsDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder LoadingView() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder ActivityInfoCard() {
    Column() {
      Row() {
        Text(this.activityInfo.image)
          .fontSize(40)
          .margin({ right: 12 })

        Column() {
          Text(this.activityInfo.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.activityInfo.description)
            .fontSize(14)
            .fontColor('#6b7280')
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.activityInfo.isFree) {
            Text('免费活动')
              .fontSize(16)
              .fontColor('#22c55e')
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8 })
          } else {
            Row() {
              Text(`¥${this.activityInfo.price}`)
                .fontSize(20)
                .fontColor('#ef4444')
                .fontWeight(FontWeight.Bold)
              
              if (this.activityInfo.originalPrice && this.activityInfo.originalPrice > this.activityInfo.price) {
                Text(`¥${this.activityInfo.originalPrice}`)
                  .fontSize(14)
                  .fontColor('#9ca3af')
                  .decoration({ type: TextDecorationType.LineThrough })
                  .margin({ left: 8 })
              }
            }
            .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder BookingFormSection() {
    Column() {
      Text(this.activityInfo.isFree ? '报名信息' : '预订信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 16 })

      // 数量选择（付费活动）
      if (!this.activityInfo.isFree) {
        Row() {
          Text('购买数量')
            .fontSize(14)
            .fontColor('#374151')
            .layoutWeight(1)

          Row() {
            Button('-')
              .width(32)
              .height(32)
              .fontSize(16)
              .backgroundColor('#f3f4f6')
              .fontColor('#374151')
              .onClick(() => this.onTicketCountChange(-1))

            Text(this.bookingInfo.ticketCount.toString())
              .fontSize(16)
              .fontColor('#1f2937')
              .width(40)
              .textAlign(TextAlign.Center)

            Button('+')
              .width(32)
              .height(32)
              .fontSize(16)
              .backgroundColor('#f3f4f6')
              .fontColor('#374151')
              .onClick(() => this.onTicketCountChange(1))
          }
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      // 日期选择
      Row() {
        Text('活动日期')
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)

        Text(this.bookingInfo.selectedDate || '请选择日期')
          .fontSize(14)
          .fontColor(this.bookingInfo.selectedDate ? '#1f2937' : '#9ca3af')
          .onClick(() => {
            this.showDatePicker = true;
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 联系人信息
      Column() {
        TextInput({ placeholder: '请输入联系人姓名' })
          .fontSize(14)
          .height(44)
          .backgroundColor('#f9fafb')
          .onChange((value: string) => {
            this.bookingInfo.contactName = value;
          })
          .margin({ bottom: 12 })

        TextInput({ placeholder: '请输入联系人电话' })
          .fontSize(14)
          .height(44)
          .backgroundColor('#f9fafb')
          .type(InputType.PhoneNumber)
          .onChange((value: string) => {
            this.bookingInfo.contactPhone = value;
          })
          .margin({ bottom: 12 })

        // 报名活动需要额外信息
        if (this.activityInfo.type === 'signup') {
          TextInput({ placeholder: '请输入身份证号' })
            .fontSize(14)
            .height(44)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.bookingInfo.idCard = value;
            })
            .margin({ bottom: 12 })

          Row() {
            Text('性别')
              .fontSize(14)
              .fontColor('#374151')
              .margin({ right: 16 })

            Radio({ value: '男', group: 'gender' })
              .checked(this.bookingInfo.gender === '男')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.bookingInfo.gender = '男';
              })
            Text('男')
              .fontSize(14)
              .margin({ right: 16 })

            Radio({ value: '女', group: 'gender' })
              .checked(this.bookingInfo.gender === '女')
              .onChange((isChecked: boolean) => {
                if (isChecked) this.bookingInfo.gender = '女';
              })
            Text('女')
              .fontSize(14)
          }
          .width('100%')
          .margin({ bottom: 12 })

          TextInput({ placeholder: '请输入年龄' })
            .fontSize(14)
            .height(44)
            .backgroundColor('#f9fafb')
            .type(InputType.Number)
            .onChange((value: string) => {
              this.bookingInfo.age = parseInt(value) || 0;
            })
            .margin({ bottom: 12 })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PriceSection() {
    Column() {
      Text('费用明细')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 16 })

      Row() {
        Text(`${this.activityInfo.name} × ${this.bookingInfo.ticketCount}`)
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)

        Text(`¥${this.activityInfo.price * this.bookingInfo.ticketCount}`)
          .fontSize(14)
          .fontColor('#1f2937')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Divider()
        .color('#e5e7eb')
        .margin({ top: 8, bottom: 8 })

      Row() {
        Text('总计')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)

        Text(`¥${this.bookingInfo.totalPrice}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NoticesSection() {
    Column() {
      Text('注意事项')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      ForEach(this.activityInfo.notices, (notice: string, index: number) => {
        Text(`${index + 1}. ${notice}`)
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ bottom: 4 })
          .width('100%')
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BottomActionBar() {
    Row() {
      if (!this.activityInfo.isFree) {
        Column() {
          Text('总计')
            .fontSize(12)
            .fontColor('#6b7280')
          Text(`¥${this.bookingInfo.totalPrice}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ef4444')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 16 })
      }

      Button(this.activityInfo.isFree ? '立即报名' : '立即购票')
        .layoutWeight(1)
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(this.activityInfo.isFree ? '#22c55e' : '#ef4444')
        .borderRadius(24)
        .onClick(() => this.onConfirmBooking())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }

  @Builder PaymentMethodsDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showPaymentMethods = false;
        })

      // 支付方式选择面板
      Column() {
        Row() {
          Text('选择支付方式')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .layoutWeight(1)

          Text('✕')
            .fontSize(20)
            .fontColor('#6b7280')
            .onClick(() => {
              this.showPaymentMethods = false;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: '#e5e7eb' })

        Column() {
          ForEach(this.paymentMethods, (method: PaymentMethod) => {
            if (method.enabled) {
              Row() {
                Text(method.icon)
                  .fontSize(24)
                  .margin({ right: 12 })

                Text(method.name)
                  .fontSize(16)
                  .fontColor('#1f2937')
                  .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor('#9ca3af')
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .onClick(() => this.onPaymentMethodSelected(method.id))
              .border({ width: { bottom: 1 }, color: '#f3f4f6' })
            }
          })

          Text('支持刷脸支付和密码支付')
            .fontSize(12)
            .fontColor('#9ca3af')
            .margin({ top: 16, bottom: 20 })
        }
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ x: 0, y: -300 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(999)
  }
}
