import { router, promptAction } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { HotelOrder, OrderStatus, HotelOrderData } from '../../model/HotelOrderModel';
import { DateUtils } from '../../utils/DateUtils';

interface HotelParams {
  hotelId?: string;
  hotelName?: string;
  price?: number;
}

interface DateParams {
  startDate?: string;
  endDate?: string;
  nights?: number;
}

/**
 * 酒店详情和预订页面
 * 集成日期选择和房型选择功能
 */
@Entry
@Component
export struct HotelDetailPage {
  @State hotelId: string = '';
  @State hotelName: string = '';
  @State hotelImage: string = '🏨';
  @State rating: number = 4.8;
  @State reviews: number = 1234;
  @State address: string = '';
  @State facilities: string[] = [];
  
  // 日期选择
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State nights: number = 0;
  
  // 房型选择
  @State selectedRoomType: string = '';
  @State roomPrice: number = 0;
  @State roomCount: number = 1;
  
  // 房型列表
  @State roomTypes: RoomType[] = [];
  
  // 客人信息
  @State guestName: string = '';
  @State guestPhone: string = '';

  aboutToAppear() {
    const params = router.getParams() as HotelParams;
    
    if (params) {
      this.hotelId = params.hotelId || '1';
      this.hotelName = params.hotelName || '豪华酒店';
      this.roomPrice = params.price || 489;
    }
    
    // 初始化房型数据
    this.initializeRoomTypes();
    
    // 初始化默认日期（明天入住，后天离店）
    const tomorrow = DateUtils.addDays(new Date(), 1);
    const dayAfter = DateUtils.addDays(new Date(), 2);
    this.checkInDate = DateUtils.getDateString(tomorrow);
    this.checkOutDate = DateUtils.getDateString(dayAfter);
    this.nights = 1;
  }

  private initializeRoomTypes() {
    this.roomTypes = [
      {
        id: '1',
        name: '豪华大床房',
        price: 489,
        originalPrice: 599,
        size: '35㎡',
        bedType: '大床 2.0m',
        maxGuests: 2,
        features: ['可住2人', '有窗', '免费WiFi', '免费取消'],
        image: '🛏️',
        available: 5
      },
      {
        id: '2',
        name: '行政套房',
        price: 899,
        originalPrice: 1099,
        size: '55㎡',
        bedType: '大床 2.0m + 沙发床',
        maxGuests: 3,
        features: ['可住3人', '客厅+卧室', '行政酒廊', '免费早餐', '延迟退房'],
        image: '🏨',
        available: 3
      },
      {
        id: '3',
        name: '标准双床房',
        price: 356,
        originalPrice: 420,
        size: '30㎡',
        bedType: '2张单人床',
        maxGuests: 2,
        features: ['可住2人', '有窗', '免费WiFi'],
        image: '🛏️',
        available: 8
      },
      {
        id: '4',
        name: '豪华海景房',
        price: 1299,
        size: '45㎡',
        bedType: '大床 2.0m',
        maxGuests: 2,
        features: ['可住2人', '海景阳台', '免费早餐', '迎宾水果', '免费升级'],
        image: '🌊',
        available: 2
      }
    ];
    
    // 默认选择第一个房型
    if (this.roomTypes.length > 0) {
      this.selectedRoomType = this.roomTypes[0].id;
      this.roomPrice = this.roomTypes[0].price;
    }
  }

  build() {
    Column() {
      TopNavigationBar({
        title: this.hotelName,
        showBack: true
      })

      Scroll() {
        Column() {
          // 酒店信息卡片
          this.HotelInfoCard()
          
          // 日期选择卡片
          this.DateSelectionCard()
          
          // 房型选择
          this.RoomTypeSelection()
          
          // 客人信息
          this.GuestInfoCard()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#f8fafc')
      
      // 底部预订按钮
      this.BottomBookButton()
    }
    .width('100%')
    .height('100%')
  }

  @Builder HotelInfoCard() {
    Column() {
      Row() {
        Text(this.hotelImage)
          .fontSize(60)
          .width(80)
          .height(80)
          .textAlign(TextAlign.Center)
          .backgroundColor('#f0f0f0')
          .borderRadius(8)
        
        Column({ space: 8 }) {
          Text(this.hotelName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Row({ space: 8 }) {
            Text('⭐')
              .fontSize(14)
            Text(this.rating.toFixed(1))
              .fontSize(14)
              .fontColor('#f59e0b')
            Text(`${this.reviews}条评价`)
              .fontSize(12)
              .fontColor('#999')
          }
          
          if ((this.facilities ?? []).length > 0) {
            Row({ space: 6 }) {
              ForEach((this.facilities ?? []).slice(0, 3), (facility: string, index: number) => {
                Text(facility)
                  .fontSize(11)
                  .fontColor('#666')
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .backgroundColor('#f0f0f0')
                  .borderRadius(4)
              }, (facility: string, index: number) => `fac-${index}-${facility}`)
            }
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  @Builder DateSelectionCard() {
    Column() {
      Row() {
        Text('入住日期')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        
        Text('修改')
          .fontSize(14)
          .fontColor('#007AFF')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        // 入住日期
        Column() {
          Text('入住')
            .fontSize(12)
            .fontColor('#999')
            .margin({ bottom: 4 })
          Text(this.formatDateDisplay(this.checkInDate))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#f8fafc')
        .borderRadius(8)
        
        // 间隔
        Column() {
          Text(`${this.nights}晚`)
            .fontSize(14)
            .fontColor('#666')
        }
        .width(60)
        .justifyContent(FlexAlign.Center)
        
        // 离店日期
        Column() {
          Text('离店')
            .fontSize(12)
            .fontColor('#999')
            .margin({ bottom: 4 })
          Text(this.formatDateDisplay(this.checkOutDate))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#f8fafc')
        .borderRadius(8)
      }
      .width('100%')
      .onClick(() => {
        this.openDatePicker();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder RoomTypeSelection() {
    Column() {
      Text('选择房型')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 12 })
      
      ForEach(this.roomTypes ?? [], (room: RoomType, index: number) => {
        this.RoomTypeCard(room)
      }, (room: RoomType, index: number) => `room-${room.id}-${index}`)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder RoomTypeCard(room: RoomType) {
    Column() {
      Row() {
        Text(room.image)
          .fontSize(40)
          .width(60)
          .height(60)
          .textAlign(TextAlign.Center)
          .backgroundColor('#f8fafc')
          .borderRadius(8)
        
        Column({ space: 6 }) {
          Row() {
            Text(room.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
            
            Column() {
              if (room.originalPrice) {
                Text(`¥${room.originalPrice}`)
                  .fontSize(12)
                  .fontColor('#999')
                  .decoration({ type: TextDecorationType.LineThrough })
              }
              Text(`¥${room.price}`)
                .fontSize(18)
                .fontColor('#FF6B35')
                .fontWeight(FontWeight.Bold)
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          
          Text(`${room.size} · ${room.bedType}`)
            .fontSize(12)
            .fontColor('#666')
          
          Row({ space: 6 }) {
            ForEach((room.features ?? []).slice(0, 3), (feature: string, index: number) => {
              Text(feature)
                .fontSize(11)
                .fontColor('#007AFF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#f0f9ff')
                .borderRadius(4)
            }, (feature: string, index: number) => `rfeat-${room.id}-${index}-${feature}`)
          }
          
          if (room.available < 5) {
            Text(`仅剩${room.available}间`)
              .fontSize(11)
              .fontColor('#FF6B35')
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      
      // 选择按钮
      Row() {
        Text('选择')
          .fontSize(14)
          .fontColor(this.selectedRoomType === room.id ? Color.White : '#007AFF')
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .backgroundColor(this.selectedRoomType === room.id ? '#007AFF' : Color.Transparent)
          .border({
            width: 1,
            color: '#007AFF',
            radius: 16
          })
          .onClick(() => {
            this.selectedRoomType = room.id;
            this.roomPrice = room.price;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.selectedRoomType === room.id ? '#f0f9ff' : '#f8fafc')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .border({
      width: this.selectedRoomType === room.id ? 2 : 1,
      color: this.selectedRoomType === room.id ? '#007AFF' : '#e5e7eb',
      radius: 8
    })
  }

  @Builder GuestInfoCard() {
    Column() {
      Text('客人信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 12 })
      
      TextInput({ placeholder: '入住人姓名' })
        .height(48)
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.guestName = value;
        })
      
      TextInput({ placeholder: '手机号码' })
        .height(48)
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .onChange((value: string) => {
          this.guestPhone = value;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12, bottom: 16 })
  }

  @Builder BottomBookButton() {
    Row() {
      Column({ space: 4 }) {
        Text('总价')
          .fontSize(12)
          .fontColor('#666')
        Text(`¥${this.calculateTotalPrice()}`)
          .fontSize(20)
          .fontColor('#FF6B35')
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)
      
      Button('立即预订')
        .width(140)
        .height(44)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(22)
        .margin({ left: 16 })
        .onClick(() => {
          this.submitBooking();
        })
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetY: -2
    })
  }

  // 打开日期选择器
  private openDatePicker() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/calendar/CalendarPage',
        params: {
          title: '选择入住日期',
          selectRange: true
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '日历页面'));
  }

  // 格式化日期显示
  private formatDateDisplay(dateString: string): string {
    if (!dateString) return '请选择';
    const parts = dateString.split('-');
    if (parts.length !== 3) return dateString;
    return `${parts[1]}月${parts[2]}日`;
  }

  // 计算总价
  private calculateTotalPrice(): number {
    return this.roomPrice * this.nights * this.roomCount;
  }

  // 提交预订
  private submitBooking() {
    // 验证输入
    if (!this.guestName) {
      promptAction.showToast({ message: '请输入入住人姓名' });
      return;
    }
    if (!this.guestPhone || this.guestPhone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号码' });
      return;
    }
    if (!this.checkInDate || !this.checkOutDate) {
      promptAction.showToast({ message: '请选择入住日期' });
      return;
    }
    
    // 创建订单
    const selectedRoom = this.roomTypes.find(r => r.id === this.selectedRoomType);
    const order = new HotelOrder(
      Date.now().toString(),
      this.hotelName,
      this.hotelImage,
      selectedRoom?.name || '标准房',
      this.checkInDate.replace(/-/g, '/'),
      this.checkOutDate.replace(/-/g, '/'),
      this.calculateTotalPrice(),
      OrderStatus.PENDING_PAYMENT,
      DateUtils.getDateString(new Date()),
      this.guestName,
      this.guestPhone,
      this.roomCount,
      this.nights
    );
    
    // 添加到订单列表
    HotelOrderData.addOrder(order);
    
    // 跳转到订单详情页
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.replaceUrl({
        url: 'pages/order/HotelOrderDetailPage',
        params: { orderId: order.id }
      });
      promptAction.showToast({ message: '预订成功' });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '订单详情页面'));
  }

  // 页面返回时处理日期选择结果
  onPageShow() {
    const params = router.getParams() as DateParams;
    
    if (params && params.startDate && params.endDate) {
      this.checkInDate = params.startDate.replace(/\//g, '-');
      this.checkOutDate = params.endDate.replace(/\//g, '-');
      this.nights = params.nights || 1;
    }
  }
}

// 房型接口
interface RoomType {
  id: string;
  name: string;
  price: number;
  originalPrice?: number;
  size: string;
  bedType: string;
  maxGuests: number;
  features: string[];
  image: string;
  available: number;
}
