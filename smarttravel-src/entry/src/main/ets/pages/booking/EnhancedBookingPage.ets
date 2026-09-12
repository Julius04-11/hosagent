import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface TicketType {
  id: string;
  name: string;
  price: number;
  originalPrice?: number;
  description: string;
  ageRange: string;
}

interface PaymentMethod {
  id: string;
  name: string;
  icon: string;
  color: string;
}

interface OrderTicket {
  ticketId: string;
  ticketName: string;
  price: number;
  count: number;
}

interface OrderInfo {
  orderId: string;
  activityName: string;
  selectedTickets: OrderTicket[];
  selectedDate: string;
  contactName: string;
  contactPhone: string;
  totalPrice: number;
  createTime: string;
}

interface ActivityInfo {
  id: string;
  name: string;
  image: string;
  ticketTypes: TicketType[];
  description: string;
  validDate: string;
  location: string;
  features: string[];
  notices: string[];
  category: 'scenic' | 'cultural' | 'entertainment';
}

interface BookingInfo {
  selectedTickets: Map<string, number>;
  selectedDate: string;
  contactName: string;
  contactPhone: string;
  totalPrice: number;
}

@Entry
@Component
export struct EnhancedBookingPage {
  @State activityInfo: ActivityInfo = {} as ActivityInfo;
  @State bookingInfo: BookingInfo = {
    selectedTickets: new Map(),
    selectedDate: '',
    contactName: '',
    contactPhone: '',
    totalPrice: 0
  };
  @State isLoading: boolean = true;
  @State showDatePicker: boolean = false;
  @State showPaymentMethods: boolean = false;
  @State selectedPaymentMethod: string = '';
  @State availableDates: string[] = [];
  @State selectedDateIndex: number = 0;

  private paymentMethods: PaymentMethod[] = [
    { id: 'wechat', name: '微信支付', icon: '🟢', color: '#07C160' },
    { id: 'alipay', name: '支付宝', icon: '🔵', color: '#1677FF' },
    { id: 'unionpay', name: '银联支付', icon: '🔴', color: '#E21F27' }
  ];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const activityId = params['id'] as string || '1';
    this.loadActivityInfo(activityId);
    this.generateAvailableDates();
  }

  private loadActivityInfo(activityId: string) {
    setTimeout(() => {
      // 模拟真实景区定价
      this.activityInfo = {
        id: activityId,
        name: '深圳世界之窗',
        image: '🏛️',
        category: 'scenic',
        ticketTypes: [
          {
            id: 'adult',
            name: '成人票',
            price: 220,
            originalPrice: 260,
            description: '适用于18-59周岁成人',
            ageRange: '18-59岁'
          },
          {
            id: 'child',
            name: '儿童票',
            price: 110,
            description: '适用于3-17周岁儿童',
            ageRange: '3-17岁'
          },
          {
            id: 'senior',
            name: '长者票',
            price: 110,
            description: '适用于60周岁以上长者',
            ageRange: '60岁以上'
          },
          {
            id: 'student',
            name: '学生票',
            price: 165,
            description: '全日制在校学生凭学生证',
            ageRange: '学生证'
          }
        ],
        description: '世界文化精粹，一日游遍全球',
        validDate: '当日有效，过期作废',
        location: '深圳市南山区深南大道9037号',
        features: ['电子票', '随买随用', '无需换票'],
        notices: ['请携带有效身份证件', '门票当日有效', '一经售出概不退换']
      };
      this.isLoading = false;
    }, 500);
  }

  private generateAvailableDates() {
    const dates: string[] = [];
    const today = new Date();
    for (let i = 0; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const dateStr = date.toLocaleDateString('zh-CN', {
        month: '2-digit',
        day: '2-digit',
        weekday: 'short'
      });
      dates.push(dateStr);
    }
    this.availableDates = dates;
  }

  private updateTicketCount(ticketId: string, delta: number) {
    const currentCount = this.bookingInfo.selectedTickets.get(ticketId) || 0;
    const newCount = Math.max(0, Math.min(9, currentCount + delta));
    
    if (newCount === 0) {
      this.bookingInfo.selectedTickets.delete(ticketId);
    } else {
      this.bookingInfo.selectedTickets.set(ticketId, newCount);
    }
    
    this.calculateTotalPrice();
  }

  private calculateTotalPrice() {
    let total = 0;
    this.bookingInfo.selectedTickets.forEach((count, ticketId) => {
      const ticket = this.activityInfo.ticketTypes.find(t => t.id === ticketId);
      if (ticket) {
        total += ticket.price * count;
      }
    });
    this.bookingInfo.totalPrice = total;
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '门票预订',
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            this.ActivityHeader()
            this.TicketSelection()
            this.DateSelection()
            this.ContactInfo()
            this.PaymentMethodSelection()
            this.OrderSummary()
          }
          .padding(16)
        }
        .layoutWeight(1)

        this.BottomBar()
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
        .fontColor('#999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder ActivityHeader() {
    Column() {
      Row() {
        Text(this.activityInfo.image)
          .fontSize(48)
          .margin({ right: 16 })

        Column() {
          Text(this.activityInfo.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')

          Text(this.activityInfo.description)
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 4 })

          Text(this.activityInfo.location)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder TicketSelection() {
    Column() {
      Text('选择门票')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1a1a1a')
        .margin({ bottom: 16 })

      ForEach(this.activityInfo.ticketTypes, (ticket: TicketType) => {
        Column() {
          Row() {
            Column() {
              Text(ticket.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1a1a1a')

              Text(ticket.description)
                .fontSize(12)
                .fontColor('#666')
                .margin({ top: 2 })

              Row() {
                Text(`¥${ticket.price}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ff4444')

                if (ticket.originalPrice && ticket.originalPrice > ticket.price) {
                  Text(`¥${ticket.originalPrice}`)
                    .fontSize(14)
                    .fontColor('#999')
                    .decoration({ type: TextDecorationType.LineThrough })
                    .margin({ left: 8 })
                }
              }
              .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Row() {
              Button('-')
                .width(32)
                .height(32)
                .fontSize(18)
                .backgroundColor('#f0f0f0')
                .fontColor('#666')
                .onClick(() => this.updateTicketCount(ticket.id, -1))

              Text((this.bookingInfo.selectedTickets.get(ticket.id) || 0).toString())
                .fontSize(16)
                .fontColor('#1a1a1a')
                .width(40)
                .textAlign(TextAlign.Center)

              Button('+')
                .width(32)
                .height(32)
                .fontSize(18)
                .backgroundColor('#007AFF')
                .fontColor(Color.White)
                .onClick(() => this.updateTicketCount(ticket.id, 1))
            }
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ bottom: 8 })
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder DateSelection() {
    Column() {
      Row() {
        Text('选择日期')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        // Date text container with flex: 1 to take remaining space
        Column() {
          if (this.bookingInfo.selectedDate) {
            Text(this.bookingInfo.selectedDate)
              .fontSize(16)
              .fontColor('#1677FF')
          } else {
            Text('请选择日期')
              .fontSize(16)
              .fontColor('#999')
          }
        }
        .margin({ left: 12 })
        .width('100%')

        // Calendar icon
        Text('📅')
          .fontSize(20)
      }
      .width('100%')
      .height(48)
        .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .borderRadius(8)
      .onClick(() => {
        this.showDatePicker = true;
      })

      // 日期选择器弹窗
      if (this.showDatePicker) {
        Column() {
          Text('选择日期')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 16 })

          Grid() {
            ForEach(this.availableDates, (date: string, index: number) => {
              GridItem() {
                Text(date)
                  .fontSize(14)
                  .fontColor(this.bookingInfo.selectedDate === date ? Color.White : '#1a1a1a')
                  .backgroundColor(this.bookingInfo.selectedDate === date ? '#007AFF' : Color.White)
                  .width(60)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .borderRadius(8)
                  .border({ width: 1, color: '#e0e0e0' })
                  .onClick(() => {
                    this.bookingInfo.selectedDate = date;
                    this.showDatePicker = false;
                  })
              }
            })
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
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder ContactInfo() {
    Column() {
      Text('联系人信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '请输入联系人姓名' })
        .fontSize(16)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.bookingInfo.contactName = value;
        })

      TextInput({ placeholder: '请输入联系人手机号' })
        .fontSize(16)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.bookingInfo.contactPhone = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder PaymentMethodSelection() {
    Column() {
      Text('支付方式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Start)

      ForEach(this.paymentMethods, (method: PaymentMethod) => (
        Row() {
          Text(method.icon)
            .fontSize(24)
            .margin({ right: 12 })
          
          Text(method.name)
            .fontSize(16)
            .fontColor('#1a1a1a')
            .layoutWeight(1)
          
          if (this.selectedPaymentMethod === method.id) {
            Text('✓')
              .fontSize(16)
              .fontColor('#1677FF')
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onClick(() => {
          this.selectedPaymentMethod = method.id;
        })
      ))
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder OrderSummary() {
    Column() {
      Text('订单明细')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1a1a1a')
        .margin({ bottom: 16 })

      ForEach(Array.from(this.bookingInfo.selectedTickets.entries()).filter(entry => {
        const ticketId = entry[0];
        return this.activityInfo.ticketTypes.find(t => t.id === ticketId) !== undefined;
      }), (entry: [string, number]) => {
        Row() {
          Text(`${this.activityInfo.ticketTypes.find(t => t.id === entry[0])?.name || ''} × ${entry[1]}`)
            .fontSize(14)
            .fontColor('#666')
            .layoutWeight(1)

          Text(`¥${(this.activityInfo.ticketTypes.find(t => t.id === entry[0])?.price || 0) * entry[1]}`)
            .fontSize(14)
            .fontColor('#1a1a1a')
        }
        .width('100%')
        .margin({ bottom: 8 })
      })

      Divider()
        .color('#eee')
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('总计')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
          .layoutWeight(1)

        Text(`¥${this.bookingInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff4444')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  private validateForm(): boolean {
    if (this.bookingInfo.selectedTickets.size === 0) {
      // Show error: Please select at least one ticket
      return false;
    }
    
    if (!this.bookingInfo.selectedDate) {
      // Show error: Please select a date
      return false;
    }
    
    if (!this.bookingInfo.contactName.trim()) {
      // Show error: Please enter contact name
      return false;
    }
    
    if (!/^1[3-9]\d{9}$/.test(this.bookingInfo.contactPhone)) {
      // Show error: Please enter a valid phone number
      return false;
    }
    
    if (!this.selectedPaymentMethod) {
      // Show error: Please select a payment method
      return false;
    }
    
    return true;
  }

  private async processPayment() {
    if (!this.validateForm()) {
      // Show appropriate error message
      return;
    }

    try {
      // Simulate payment processing with explicit void generic type
      await new Promise<void>(resolve => setTimeout(resolve, 1500));
      
      // Navigate to payment result page
      router.pushUrl({
        url: 'pages/order/PaymentResultPage',
        params: {
          success: true,
          orderId: `ORD${Date.now()}`,
          amount: this.bookingInfo.totalPrice,
          paymentMethod: this.selectedPaymentMethod
        }
      });
    } catch (error) {
      console.error('Payment failed:', error);
      // Show error message
    }
  }

  @Builder BottomBar() {
    Row() {
      Column() {
        Text('总计')
          .fontSize(12)
          .fontColor('#999')
        
        Text(`¥${this.bookingInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff4444')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      Button('提交订单')
        .width(180)
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.bookingInfo.totalPrice > 0 ? '#007AFF' : '#CCCCCC')
        .fontColor(Color.White)
        .onClick(() => this.processPayment())
        .enabled(this.bookingInfo.totalPrice > 0)
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#f0f0f0' })
  }

  private validateOrder(): boolean {
    if (this.bookingInfo.selectedTickets.size === 0) {
      ErrorHandler.showToast('请选择门票');
      return false;
    }
    if (!this.bookingInfo.selectedDate) {
      ErrorHandler.showToast('请选择游玩日期');
      return false;
    }
    if (!this.bookingInfo.contactName.trim()) {
      ErrorHandler.showToast('请输入联系人姓名');
      return false;
    }
    if (!this.bookingInfo.contactPhone.trim()) {
      ErrorHandler.showToast('请输入联系人手机号');
      return false;
    }
    return true;
  }

  private proceedToPayment() {
    // 创建订单信息
    const orderInfo: OrderInfo = {
      orderId: 'ST' + Date.now().toString(),
      activityName: this.activityInfo.name,
      selectedTickets: Array.from(this.bookingInfo.selectedTickets.entries()).map((entry: [string, number]) => {
        const ticketId = entry[0];
        const count = entry[1];
        const ticket = this.activityInfo.ticketTypes.find(t => t.id === ticketId);
        const orderTicket: OrderTicket = {
          ticketId: ticketId,
          ticketName: ticket?.name || '',
          price: ticket?.price || 0,
          count: count
        };
        return orderTicket;
      }),
      selectedDate: this.bookingInfo.selectedDate,
      contactName: this.bookingInfo.contactName,
      contactPhone: this.bookingInfo.contactPhone,
      totalPrice: this.bookingInfo.totalPrice,
      createTime: new Date().toLocaleString()
    };

    // 跳转到支付页面
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/payment/PaymentPage',
        params: {
          orderInfo: orderInfo
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '支付页面'));
  }
}
