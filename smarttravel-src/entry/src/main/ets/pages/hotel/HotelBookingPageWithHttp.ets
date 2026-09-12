import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { SmartTravelApi } from '../../api/SmartTravelApi';
import { NetworkService } from '../../services/NetworkService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HotelBookingPageWithHttp';
const DOMAIN = 0xFF00;

/**
 * 酒店预订页面（集成 HTTP 请求）
 * 演示如何在实际业务中使用 HTTP 服务
 */
@Entry
@Component
export struct HotelBookingPageWithHttp {
  // 页面参数
  @State hotelId: string = 'hotel_001';
  @State hotelName: string = '';
  @State roomType: string = '';
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State price: number = 0;
  @State nights: number = 1;
  @State guestName: string = '';
  @State guestPhone: string = '';
  @State totalPrice: number = 0;
  
  // UI 状态
  @State isLoading: boolean = false;
  @State isCheckingAvailability: boolean = false;
  @State isBooking: boolean = false;
  @State showDatePicker: boolean = false;
  @State dateType: 'checkin' | 'checkout' = 'checkin';
  @State isAvailable: boolean = true;
  @State availabilityMessage: string = '';

  // 服务实例
  private api: SmartTravelApi = SmartTravelApi.getInstance();
  private networkService: NetworkService = NetworkService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.hotelId = params['hotelId'] as string || 'hotel_001';
      this.hotelName = params['hotelName'] as string || '';
      this.roomType = params['roomType'] as string || '豪华大床房';
      this.price = params['price'] as number || 489;
      this.checkInDate = params['checkInDate'] as string || '';
      this.checkOutDate = params['checkOutDate'] as string || '';
    }

    // 加载酒店详情
    this.loadHotelDetail();
  }

  /**
   * 从服务器加载酒店详情
   */
  private async loadHotelDetail(): Promise<void> {
    // 检查网络状态
    if (!this.networkService.isInternetAvailable()) {
      ErrorHandler.showToast('网络不可用，请检查网络连接');
      return;
    }

    this.isLoading = true;
    try {
      hilog.info(DOMAIN, TAG, `Loading hotel detail: ${this.hotelId}`);
      const hotel = await this.api.getHotelDetail(this.hotelId);
      
      // 更新页面数据
      this.hotelName = hotel.name;
      this.price = hotel.price;
      
      hilog.info(DOMAIN, TAG, 'Hotel detail loaded successfully');
      
      // 如果已选择日期，检查可用性
      if (this.checkInDate && this.checkOutDate) {
        this.checkAvailability();
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load hotel: ${JSON.stringify(error)}`);
      ErrorHandler.showToast('加载酒店信息失败，请重试');
      
      // 降级处理：使用传入的参数
      if (!this.hotelName) {
        this.hotelName = '豪华酒店';
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查房间可用性
   */
  private async checkAvailability(): Promise<void> {
    if (!this.checkInDate || !this.checkOutDate) {
      return;
    }

    // 检查网络状态
    if (!this.networkService.isInternetAvailable()) {
      this.isAvailable = false;
      this.availabilityMessage = '网络不可用，无法检查可用性';
      return;
    }

    this.isCheckingAvailability = true;
    this.availabilityMessage = '正在检查可用性...';

    try {
      hilog.info(DOMAIN, TAG, `Checking availability for ${this.hotelId}`);
      
      const result = await this.api.checkHotelAvailability(
        this.hotelId,
        this.checkInDate,
        this.checkOutDate,
        this.roomType
      );

      this.isAvailable = result.available;
      
      if (result.available) {
        this.availabilityMessage = '✅ 房间可预订';
        hilog.info(DOMAIN, TAG, 'Room is available');
      } else {
        this.availabilityMessage = '❌ 该时段已售罄';
        hilog.warn(DOMAIN, TAG, 'Room is not available');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to check availability: ${JSON.stringify(error)}`);
      
      // 降级处理：假设可用
      this.isAvailable = true;
      this.availabilityMessage = '⚠️ 检查失败，请稍后重试';
    } finally {
      this.isCheckingAvailability = false;
    }
  }

  /**
   * 计算总价
   */
  private calculateTotal(): void {
    if (this.checkInDate && this.checkOutDate) {
      // 简单计算天数（实际应该用日期库）
      this.nights = 2; // 默认2晚
      this.totalPrice = this.price * this.nights;
      
      // 检查可用性
      this.checkAvailability();
    }
  }

  /**
   * 生成可选日期列表
   */
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

  /**
   * 提交预订（发送到服务器）
   */
  private async onBooking(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    // 检查可用性
    if (!this.isAvailable) {
      ErrorHandler.showToast('该时段已售罄，请选择其他日期');
      return;
    }

    // 检查网络状态
    if (!this.networkService.isInternetAvailable()) {
      ErrorHandler.showToast('网络不可用，请检查网络连接');
      return;
    }

    this.isBooking = true;

    try {
      hilog.info(DOMAIN, TAG, 'Creating booking...');

      // 发送预订请求到服务器
      const result = await this.api.createHotelBooking({
        hotelId: this.hotelId,
        hotelName: this.hotelName,
        roomType: this.roomType,
        checkInDate: this.checkInDate,
        checkOutDate: this.checkOutDate,
        guestName: this.guestName,
        guestPhone: this.guestPhone,
        nights: this.nights,
        totalPrice: this.totalPrice
      });

      hilog.info(DOMAIN, TAG, `Booking created: ${result.orderId}`);
      ErrorHandler.showToast('预订成功！');

      // 跳转到订单详情页
      await router.pushUrl({
        url: 'pages/order/OrderDetailPage',
        params: {
          orderId: result.orderId,
          orderNo: result.orderNo
        }
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Booking failed: ${JSON.stringify(error)}`);
      
      const err = error as Error;
      const errorMessage = err.message || '预订失败';
      
      // 根据错误类型显示不同提示
      if (errorMessage.includes('401')) {
        ErrorHandler.showToast('请先登录');
      } else if (errorMessage.includes('timeout')) {
        ErrorHandler.showToast('网络超时，请重试');
      } else if (errorMessage.includes('network')) {
        ErrorHandler.showToast('网络错误，请检查网络连接');
      } else {
        ErrorHandler.showToast(`预订失败: ${errorMessage}`);
      }
    } finally {
      this.isBooking = false;
    }
  }

  /**
   * 表单验证
   */
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
    if (this.guestPhone.length !== 11) {
      ErrorHandler.showToast('请输入正确的手机号码');
      return false;
    }
    return true;
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '酒店预订（HTTP版）',
        showBack: true
      })

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007AFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
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
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 可用性提示
            if (this.availabilityMessage) {
              Row() {
                Text(this.availabilityMessage)
                  .fontSize(14)
                  .fontColor(this.isAvailable ? '#52c41a' : '#f5222d')
                if (this.isCheckingAvailability) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .margin({ left: 8 })
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.isAvailable ? '#f6ffed' : '#fff1f0')
              .borderRadius(8)
              .margin({ bottom: 16 })
            }

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
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })
            .alignItems(HorizontalAlign.Start)

            // 日期选择器
            if (this.showDatePicker) {
              Column() {
                Text(this.dateType === 'checkin' ? '选择入住日期' : '选择退房日期')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 16 })

                Grid() {
                  ForEach(this.generateAvailableDates(), (date: string, index: number) => {
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
                .onChange((value: string) => {
                  this.guestName = value;
                })
                .margin({ bottom: 12 })
              TextInput({ placeholder: '请输入联系电话' })
                .fontSize(14)
                .height(44)
                .backgroundColor('#f9f9f9')
                .borderRadius(8)
                .type(InputType.PhoneNumber)
                .onChange((value: string) => {
                  this.guestPhone = value;
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)

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
          }
          .padding(16)
        }
        .layoutWeight(1)
      }

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

        Button(this.isBooking ? '提交中...' : '立即预订')
          .layoutWeight(1)
          .height(48)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isBooking || !this.isAvailable ? '#cccccc' : '#007AFF')
          .borderRadius(24)
          .enabled(!this.isBooking && this.isAvailable)
          .onClick(() => this.onBooking())

        if (this.isBooking) {
          LoadingProgress()
            .width(24)
            .height(24)
            .margin({ left: 8 })
            .color(Color.White)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#e0e0e0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
