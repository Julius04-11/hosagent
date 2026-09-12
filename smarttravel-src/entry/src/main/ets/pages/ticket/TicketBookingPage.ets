import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface TicketInfo {
  id: string;
  name: string;
  image: string;
  price: number;
  originalPrice: number;
  description: string;
  validDate: string;
  location: string;
  features: string[];
  notices: string[];
}

interface BookingInfo {
  ticketCount: number;
  selectedDate: string;
  contactName: string;
  contactPhone: string;
  totalPrice: number;
}

@Entry
@Component
export struct TicketBookingPage {
  @State ticketInfo: TicketInfo = {} as TicketInfo;
  @State bookingInfo: BookingInfo = {
    ticketCount: 1,
    selectedDate: '',
    contactName: '',
    contactPhone: '',
    totalPrice: 0
  };
  @State isLoading: boolean = true;
  @State showDatePicker: boolean = false;
  @State availableDates: string[] = [];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const ticketId = params['id'] as string || '1';
    this.loadTicketInfo(ticketId);
    this.generateAvailableDates();
  }

  private loadTicketInfo(ticketId: string) {
    // 模拟加载门票信息
    setTimeout(() => {
      this.ticketInfo = {
        id: ticketId,
        name: '深圳欢乐谷门票',
        image: 'https://picsum.photos/id/400/400/300',
        price: 230,
        originalPrice: 280,
        description: '深圳欢乐谷是华侨城集团新一代大型主题乐园，首批国家AAAAA级旅游景区',
        validDate: '购买后30天内有效',
        location: '深圳市南山区侨城西街18号',
        features: ['刺激游乐设施', '精彩演出', '主题餐厅', '纪念品商店'],
        notices: [
          '门票当日有效，过期作废',
          '1.2米以下儿童免票',
          '1.2-1.5米儿童半价',
          '请携带有效身份证件',
          '禁止携带食物和饮料入园'
        ]
      };
      this.bookingInfo.totalPrice = this.ticketInfo.price * this.bookingInfo.ticketCount;
      this.isLoading = false;
    }, 800);
  }

  private generateAvailableDates() {
    const dates: string[] = [];
    const today = new Date();
    for (let i = 0; i < 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const dateStr = date.toISOString().split('T')[0];
      dates.push(dateStr);
    }
    this.availableDates = dates;
    this.bookingInfo.selectedDate = dates[0];
  }

  private updateTicketCount(count: number) {
    if (count < 1) count = 1;
    if (count > 10) count = 10;
    this.bookingInfo.ticketCount = count;
    this.bookingInfo.totalPrice = this.ticketInfo.price * count;
  }

  private submitBooking() {
    if (!this.bookingInfo.contactName.trim()) {
      ErrorHandler.showToast('请填写联系人姓名');
      return;
    }
    if (!this.bookingInfo.contactPhone.trim()) {
      ErrorHandler.showToast('请填写联系电话');
      return;
    }
    if (!/^1[3-9]\d{9}$/.test(this.bookingInfo.contactPhone)) {
      ErrorHandler.showToast('请填写正确的手机号码');
      return;
    }

    ErrorHandler.safeExecute(async (): Promise<void> => {
      // 模拟提交订单
      ErrorHandler.showToast('正在提交订单...');
      
      setTimeout(async () => {
        await router.pushUrl({
          url: 'pages/order/OrderConfirmPage',
          params: {
            ticketInfo: this.ticketInfo,
            bookingInfo: this.bookingInfo
          }
        });
      }, 1500);
    }, (error: Error): void => ErrorHandler.handleGenericError(error, '提交订单'));
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
            this.TicketInfoSection()
            this.BookingFormSection()
            this.PriceSection()
            this.NoticesSection()
          }
        }
        .layoutWeight(1)

        this.BottomActionSection()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('🎫')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在加载门票信息...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder TicketInfoSection() {
    Column() {
      Row() {
        Image(this.ticketInfo.image)
          .width(100)
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.ticketInfo.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .margin({ bottom: 8 })

          Text(this.ticketInfo.description)
            .fontSize(14)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row() {
            Text(`¥${this.ticketInfo.originalPrice}`)
              .fontSize(14)
              .fontColor('#9ca3af')
              .decoration({ type: TextDecorationType.LineThrough })
            Text(`¥${this.ticketInfo.price}`)
              .fontSize(20)
              .fontColor('#ef4444')
              .fontWeight(FontWeight.Bold)
              .margin({ left: 8 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }

      Text(`📍 ${this.ticketInfo.location}`)
        .fontSize(14)
        .fontColor('#6b7280')
        .width('100%')
        .margin({ top: 12 })

      Text(`⏰ ${this.ticketInfo.validDate}`)
        .fontSize(14)
        .fontColor('#6b7280')
        .width('100%')
        .margin({ top: 4 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
  }

  @Builder BookingFormSection() {
    Column() {
      Text('📝 预订信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      // 游玩日期
      Row() {
        Text('游玩日期')
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)

        Text(this.bookingInfo.selectedDate)
          .fontSize(16)
          .fontColor('#3b82f6')
          .onClick(() => {
            this.showDatePicker = true;
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#f9fafb')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 门票数量
      Row() {
        Text('门票数量')
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)

        Row() {
          Button('-')
            .width(32)
            .height(32)
            .backgroundColor('#f3f4f6')
            .fontColor('#374151')
            .fontSize(18)
            .onClick(() => {
              this.updateTicketCount(this.bookingInfo.ticketCount - 1);
            })

          Text(this.bookingInfo.ticketCount.toString())
            .fontSize(16)
            .fontColor('#374151')
            .width(40)
            .textAlign(TextAlign.Center)

          Button('+')
            .width(32)
            .height(32)
            .backgroundColor('#f3f4f6')
            .fontColor('#374151')
            .fontSize(18)
            .onClick(() => {
              this.updateTicketCount(this.bookingInfo.ticketCount + 1);
            })
        }
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#f9fafb')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 联系人姓名
      TextInput({ placeholder: '请输入联系人姓名' })
        .width('100%')
        .height(48)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .fontSize(16)
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.bookingInfo.contactName = value;
        })

      // 联系电话
      TextInput({ placeholder: '请输入联系电话' })
        .width('100%')
        .height(48)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .fontSize(16)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.bookingInfo.contactPhone = value;
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PriceSection() {
    Column() {
      Text('💰 费用明细')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Text(`门票 x ${this.bookingInfo.ticketCount}`)
          .fontSize(16)
          .fontColor('#374151')
          .layoutWeight(1)
        Text(`¥${this.ticketInfo.price * this.bookingInfo.ticketCount}`)
          .fontSize(16)
          .fontColor('#374151')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Divider()
        .color('#e5e7eb')
        .margin({ top: 8, bottom: 8 })

      Row() {
        Text('总计')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        Text(`¥${this.bookingInfo.totalPrice}`)
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

  @Builder NoticesSection() {
    Column() {
      Text('⚠️ 购票须知')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 12 })

      Column({ space: 8 }) {
        ForEach(this.ticketInfo.notices, (notice: string) => {
          Row() {
            Text('•')
              .fontSize(16)
              .fontColor('#f59e0b')
              .margin({ right: 8 })
            Text(notice)
              .fontSize(14)
              .fontColor('#6b7280')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BottomActionSection() {
    Row() {
      Column() {
        Text('总计')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(`¥${this.bookingInfo.totalPrice}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .alignItems(HorizontalAlign.Start)

      Button('立即预订')
        .backgroundColor('#ef4444')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .layoutWeight(1)
        .margin({ left: 16 })
        .onClick(() => {
          this.submitBooking();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }
}
