import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface OrderInfo {
  orderId: string;
  ticketName: string;
  ticketCount: number;
  totalPrice: number;
  contactName: string;
  contactPhone: string;
  selectedDate: string;
  status: 'pending' | 'paid' | 'completed';
  createTime: string;
  paymentMethod: string;
}

@Entry
@Component
export struct OrderConfirmPage {
  @State orderInfo: OrderInfo = {} as OrderInfo;
  @State isLoading: boolean = true;
  @State countdown: number = 900; // 15分钟倒计时
  @State countdownTimer: number = -1;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.generateOrderInfo(params);
    this.startCountdown();
  }

  aboutToDisappear() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
    }
  }

  private generateOrderInfo(params: Record<string, Object>) {
    setTimeout(() => {
      const ticketInfo = params['ticketInfo'] as Record<string, Object>;
      const bookingInfo = params['bookingInfo'] as Record<string, Object>;
      
      this.orderInfo = {
        orderId: 'ST' + Date.now().toString(),
        ticketName: (ticketInfo?.name as string) || '门票',
        ticketCount: (bookingInfo?.ticketCount as number) || 1,
        totalPrice: (bookingInfo?.totalPrice as number) || 0,
        contactName: (bookingInfo?.contactName as string) || '',
        contactPhone: (bookingInfo?.contactPhone as string) || '',
        selectedDate: (bookingInfo?.selectedDate as string) || '',
        status: 'pending',
        createTime: new Date().toLocaleString(),
        paymentMethod: '微信支付'
      };
      this.isLoading = false;
    }, 500);
  }

  private startCountdown() {
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.countdownTimer);
        ErrorHandler.showToast('订单已超时，请重新下单');
        router.back();
      }
    }, 1000);
  }

  private formatCountdown(): string {
    const minutes = Math.floor(this.countdown / 60);
    const seconds = this.countdown % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  private payOrder() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      ErrorHandler.showToast('正在跳转支付...');
      
      // 模拟支付流程
      setTimeout(async () => {
        await router.pushUrl({
          url: 'pages/payment/PaymentPage',
          params: {
            orderInfo: this.orderInfo
          }
        });
      }, 1000);
    }, (error: Error): void => ErrorHandler.handleGenericError(error, '支付跳转'));
  }

  private cancelOrder() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      ErrorHandler.showToast('订单已取消');
      await router.back();
    }, (error: Error): void => ErrorHandler.handleGenericError(error, '取消订单'));
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '订单确认',
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Column() {
          this.CountdownSection()
          
          Scroll() {
            Column() {
              this.OrderInfoSection()
              this.ContactInfoSection()
              this.PriceDetailSection()
              this.PaymentMethodSection()
            }
          }
          .layoutWeight(1)

          this.BottomActionSection()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('📋')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在生成订单...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder CountdownSection() {
    Row() {
      Text('⏰ 请在')
        .fontSize(16)
        .fontColor('#f59e0b')
      Text(this.formatCountdown())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ef4444')
      Text('内完成支付')
        .fontSize(16)
        .fontColor('#f59e0b')
    }
    .width('100%')
    .height(48)
    .backgroundColor('#fef3c7')
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: 1, bottom: 1 }, color: '#f59e0b' })
  }

  @Builder OrderInfoSection() {
    Column() {
      Row() {
        Text('📋 订单信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text(`订单号: ${this.orderInfo.orderId}`)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(this.orderInfo.ticketName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .width('100%')
            .margin({ bottom: 8 })

          Text(`游玩日期: ${this.orderInfo.selectedDate}`)
            .fontSize(14)
            .fontColor('#6b7280')
            .width('100%')
            .margin({ bottom: 4 })

          Text(`数量: ${this.orderInfo.ticketCount}张`)
            .fontSize(14)
            .fontColor('#6b7280')
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(`¥${this.orderInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ContactInfoSection() {
    Column() {
      Text('👤 联系信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Text('联系人:')
          .fontSize(16)
          .fontColor('#6b7280')
          .width(80)
        Text(this.orderInfo.contactName)
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('手机号:')
          .fontSize(16)
          .fontColor('#6b7280')
          .width(80)
        Text(this.orderInfo.contactPhone)
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PriceDetailSection() {
    Column() {
      Text('💰 费用明细')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Text(`${this.orderInfo.ticketName} x ${this.orderInfo.ticketCount}`)
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)
        Text(`¥${this.orderInfo.totalPrice}`)
          .fontSize(16)
          .fontColor('#374151')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Divider()
        .color('#e5e7eb')
        .margin({ top: 8, bottom: 8 })

      Row() {
        Text('应付金额')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        Text(`¥${this.orderInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PaymentMethodSection() {
    Column() {
      Text('💳 支付方式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Text('💚')
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text('微信支付')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .width('100%')
          Text('推荐使用微信支付，安全便捷')
            .fontSize(14)
            .fontColor('#6b7280')
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('✓')
          .fontSize(20)
          .fontColor('#10b981')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#f0fdf4')
      .borderRadius(8)
      .border({ width: 2, color: '#10b981' })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BottomActionSection() {
    Column() {
      Row() {
        Text('应付金额: ')
          .fontSize(16)
          .fontColor('#6b7280')
        Text(`¥${this.orderInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Row({ space: 12 }) {
        Button('取消订单')
          .backgroundColor('#f3f4f6')
          .fontColor('#6b7280')
          .fontSize(16)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.cancelOrder();
          })

        Button('立即支付')
          .backgroundColor('#ef4444')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(8)
          .layoutWeight(2)
          .onClick(() => {
            this.payOrder();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }
}
