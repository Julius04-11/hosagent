import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { HotelOrderData, OrderStatus } from '../../model/HotelOrderModel';

interface PaymentInfo {
  orderId: string;
  amount: number;
  paymentMethod: string;
  status: 'pending' | 'processing' | 'success' | 'failed';
}

interface PaymentMethod {
  id: string;
  name: string;
  icon: string;
  color: string;
}

@Entry
@Component
export struct PaymentPage {
  @State paymentInfo: PaymentInfo = {} as PaymentInfo;
  @State isProcessing: boolean = false;
  @State paymentStatus: 'pending' | 'processing' | 'success' | 'failed' = 'pending';
  @State countdown: number = 3;
  @State showPaymentOptions: boolean = false;
  @State selectedAuthMethod: 'face' | 'password' = 'face';
  @State selectedPaymentId: string = 'wechat';

  private paymentMethods: PaymentMethod[] = [
    { id: 'wechat', name: '微信支付', icon: '💚', color: '#10b981' },
    { id: 'alipay', name: '支付宝', icon: '🔵', color: '#1677FF' },
    { id: 'unionpay', name: '银联支付', icon: '🔴', color: '#E21F27' }
  ];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.initPaymentInfo(params);
  }

  private initPaymentInfo(params: Record<string, Object>) {
    const orderInfo = params['orderInfo'] as Record<string, Object>;
    this.paymentInfo = {
      orderId: (orderInfo?.orderId as string) || '',
      amount: (orderInfo?.totalPrice as number) || 0,
      paymentMethod: '微信支付',
      status: 'pending'
    };
    this.selectedPaymentId = 'wechat';
  }

  private processPayment() {
    this.isProcessing = true;
    this.paymentStatus = 'processing';
    // 同步所选支付方式到 paymentInfo 文案
    const selected = this.paymentMethods.find(m => m.id === this.selectedPaymentId);
    if (selected) {
      this.paymentInfo.paymentMethod = selected.name;
    }
    
    // 模拟支付处理
    setTimeout(() => {
      // 90%概率成功支付
      const success = Math.random() > 0.1;
      this.paymentStatus = success ? 'success' : 'failed';
      this.isProcessing = false;
      
      if (success) {
        this.startSuccessCountdown();
      }
    }, 3000);
  }

  private startSuccessCountdown() {
    const timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(timer);
        this.navigateToOrderList();
      }
    }, 1000);
  }

  private navigateToOrderList() {
    // 成功则将订单状态置为“待入住”
    if (this.paymentStatus === 'success' && this.paymentInfo.orderId) {
      HotelOrderData.updateOrderStatus(this.paymentInfo.orderId, OrderStatus.PENDING_CHECKIN);
    }
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.replaceUrl({
        url: 'pages/order/HotelOrderPage',
        params: { tabIndex: 2 }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '订单列表页面'));
  }

  private retryPayment() {
    this.paymentStatus = 'pending';
    this.countdown = 3;
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '支付',
        showBack: this.paymentStatus !== 'success'
      })

      Column() {
        if (this.paymentStatus === 'pending') {
          this.PendingView()
        } else if (this.paymentStatus === 'processing') {
          this.ProcessingView()
        } else if (this.paymentStatus === 'success') {
          this.SuccessView()
        } else {
          this.FailedView()
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder PendingView() {
    Column() {
      // 支付金额
      Column() {
        Text('支付金额')
          .fontSize(16)
          .fontColor('#6b7280')
          .margin({ bottom: 8 })
        
        Text(`¥${this.paymentInfo.amount}`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 32 })
      }
      .margin({ bottom: 48 })

      // 支付方式
      Column() {
        Text('支付方式')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .width('100%')
          .margin({ bottom: 16 })

        ForEach(this.paymentMethods, (method: PaymentMethod) => {
          Row() {
            Text(method.icon)
              .fontSize(28)
              .margin({ right: 12 })

            Column() {
              Text(method.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1f2937')
                .width('100%')
              Text(this.selectedPaymentId === method.id ? '已选择' : '点击选择')
                .fontSize(12)
                .fontColor('#6b7280')
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            if (this.selectedPaymentId === method.id) {
              Text('✓')
                .fontSize(16)
                .fontColor(method.color)
            }
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 2, color: this.selectedPaymentId === method.id ? method.color : '#e5e7eb' })
          .margin({ bottom: 12 })
          .onClick(() => {
            this.selectedPaymentId = method.id;
            this.paymentInfo.paymentMethod = method.name;
          })
        })
      }
      .width('100%')
      .padding(16)
      .margin({ bottom: 48 })

      // 支付按钮
      Button('确认支付')
        .width('80%')
        .height(48)
        .backgroundColor('#10b981')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .borderRadius(24)
        .onClick(() => {
          this.processPayment();
        })
    }
    .width('100%')
    .padding(24)
  }

  @Builder ProcessingView() {
    Column() {
      // 加载动画
      LoadingProgress()
        .width(80)
        .height(80)
        .color('#10b981')
        .margin({ bottom: 32 })

      Text('正在处理支付...')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1f2937')
        .margin({ bottom: 16 })

      Text('请稍候，不要关闭页面')
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ bottom: 32 })

      Text(`订单号: ${this.paymentInfo.orderId}`)
        .fontSize(14)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(24)
  }

  @Builder SuccessView() {
    Column() {
      // 成功图标
      Text('✅')
        .fontSize(80)
        .margin({ bottom: 24 })

      Text('支付成功!')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#10b981')
        .margin({ bottom: 16 })

      Text(`支付金额: ¥${this.paymentInfo.amount}`)
        .fontSize(18)
        .fontColor('#1f2937')
        .margin({ bottom: 8 })

      Text(`订单号: ${this.paymentInfo.orderId}`)
        .fontSize(14)
        .fontColor('#6b7280')
        .margin({ bottom: 32 })

      Text(`${this.countdown}秒后自动跳转到订单列表`)
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ bottom: 24 })

      Row({ space: 16 }) {
        Button('查看订单')
          .backgroundColor('#f3f4f6')
          .fontColor('#6b7280')
          .fontSize(16)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.navigateToOrderList();
          })

        Button('继续购票')
          .backgroundColor('#10b981')
          .fontColor(Color.White)
          .fontSize(16)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.replaceUrl({
                url: 'pages/home/HomePage'
              });
            }, (error: Error): void => ErrorHandler.handleRouterError(error, '首页'));
          })
      }
      .width('80%')
    }
    .width('100%')
    .padding(24)
  }

  @Builder FailedView() {
    Column() {
      // 失败图标
      Text('❌')
        .fontSize(80)
        .margin({ bottom: 24 })

      Text('支付失败')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ef4444')
        .margin({ bottom: 16 })

      Text('支付过程中出现问题，请重试')
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ bottom: 8 })

      Text(`订单号: ${this.paymentInfo.orderId}`)
        .fontSize(14)
        .fontColor('#6b7280')
        .margin({ bottom: 32 })

      Row({ space: 16 }) {
        Button('取消订单')
          .backgroundColor('#f3f4f6')
          .fontColor('#6b7280')
          .fontSize(16)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            ErrorHandler.safeExecute(async (): Promise<void> => {
              await router.back();
            }, (error: Error): void => ErrorHandler.handleGenericError(error, '返回上页'));
          })

        Button('重新支付')
          .backgroundColor('#ef4444')
          .fontColor(Color.White)
          .fontSize(16)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.retryPayment();
          })
      }
      .width('80%')
    }
    .width('100%')
    .padding(24)
  }
}
