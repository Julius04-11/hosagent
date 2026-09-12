import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { HotelOrder, OrderStatus, HotelOrderData } from '../../model/HotelOrderModel';

interface Hotel {
  id: string;
  name: string;
  image: string;
  rating: number;
  price: number;
  originalPrice?: number;
  address: string;
  distance: string;
  facilities: string[];
  reviews: number;
}

@Entry
@Component
export struct HotelSearchPage {
  @State searchText: string = '';
  @State hotels: Hotel[] = [
    {
      id: '1',
      name: '豪华酒店',
      image: '🏨',
      rating: 4.8,
      price: 489,
      originalPrice: 599,
      address: '深圳市南山区深南大道',
      distance: '距离市中心2.1km',
      facilities: ['WiFi', '停车场', '健身房', '游泳池'],
      reviews: 1234
    },
    {
      id: '2',
      name: '海景度假村',
      image: '🏖️',
      rating: 4.6,
      price: 1299,
      address: '深圳市盐田区海滨路',
      distance: '距离海边0.2km',
      facilities: ['海景房', '私人海滩', 'SPA', '餐厅'],
      reviews: 856
    },
    {
      id: '3',
      name: '商务酒店',
      image: '🏢',
      rating: 4.5,
      price: 356,
      originalPrice: 420,
      address: '深圳市福田区中心区',
      distance: '距离地铁站0.5km',
      facilities: ['会议室', '商务中心', '24小时前台'],
      reviews: 2341
    }
  ];
  @State isLoading: boolean = false;
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State showDatePicker: boolean = false;
  @State dateType: 'checkin' | 'checkout' = 'checkin';

  aboutToAppear() {
    this.loadHotels();
  }

  private loadHotels() {
    this.isLoading = true;
    setTimeout(() => {
      this.hotels = [
        {
          id: '1',
          name: '豪华酒店',
          image: '🏨',
          rating: 4.8,
          price: 489,
          originalPrice: 599,
          address: '深圳市南山区深南大道',
          distance: '距离市中心2.1km',
          facilities: ['WiFi', '停车场', '健身房', '游泳池'],
          reviews: 1234
        },
        {
          id: '2',
          name: '海景度假村',
          image: '🏖️',
          rating: 4.6,
          price: 1299,
          address: '深圳市盐田区海滨路',
          distance: '距离海边0.2km',
          facilities: ['海景房', '私人海滩', 'SPA', '餐厅'],
          reviews: 856
        },
        {
          id: '3',
          name: '商务酒店',
          image: '🏢',
          rating: 4.5,
          price: 356,
          originalPrice: 420,
          address: '深圳市福田区中心区',
          distance: '距离地铁站0.5km',
          facilities: ['会议室', '商务中心', '24小时前台'],
          reviews: 2341
        }
      ];
      this.isLoading = false;
    }, 500);
  }

  private onHotelClick(hotel: Hotel) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/hotel/HotelBookingPage',
        params: {
          hotelId: hotel.id,
          hotelName: hotel.name,
          price: hotel.price,
          checkInDate: this.checkInDate,
          checkOutDate: this.checkOutDate
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '酒店预订页面'));
  }

  private createPendingOrderAndGo(hotel: Hotel) {
    // 构造订单基础信息
    const id = `H${Date.now()}`;
    const now = new Date();
    const orderTime = `${now.getFullYear()}-${(now.getMonth()+1).toString().padStart(2,'0')}-${now.getDate().toString().padStart(2,'0')} ${now.getHours().toString().padStart(2,'0')}:${now.getMinutes().toString().padStart(2,'0')}`;

    // 入离店日期：若未选，则默认今天/明天
    const checkIn = this.checkInDate || `${now.getMonth() + 1}/${now.getDate()}`;
    const checkOutDateObj = new Date(now);
    checkOutDateObj.setDate(now.getDate() + 1);
    const checkOut = this.checkOutDate || `${checkOutDateObj.getMonth() + 1}/${checkOutDateObj.getDate()}`;

    const order = new HotelOrder(
      id,
      hotel.name,
      hotel.image,
      '标准间',
      checkIn,
      checkOut,
      hotel.price,
      OrderStatus.PENDING_PAYMENT,
      orderTime,
      '游客',
      '13800000000',
      1,
      1
    );

    HotelOrderData.addOrder(order);

    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/order/HotelOrderPage',
        params: { tabIndex: 1 }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '酒店订单'));
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

  private gotoOrders() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/order/HotelOrderPage',
        params: { tabIndex: 0 }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '酒店订单页面'));
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '住宿',
        showBack: true
      })

      // 订单入口
      Row() {
        Button('查看订单')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.gotoOrders())
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, top: 8 })

      Column() {
        // 搜索框
        TextInput({ placeholder: '搜索酒店...', text: this.searchText })
          .fontSize(16)
          .height(44)
          .backgroundColor('#f0f0f0')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .margin({ left: 16, right: 16, top: 12, bottom: 12 })
          .onChange((value: string) => {
            this.searchText = value;
          })

        // 日期选择
        Row() {
          Column() {
            Text('入住')
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
            Text('离店')
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
        .height(60)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .margin({ left: 16, right: 16, bottom: 16 })
        .borderRadius(8)

        // 日期选择器
        if (this.showDatePicker) {
          Column() {
            Text(this.dateType === 'checkin' ? '选择入住日期' : '选择离店日期')
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
          .margin({ left: 16, right: 16, bottom: 16 })
        }

        // 酒店列表
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.hotels ?? [], (hotel: Hotel, index: number) => {
              ListItem() {
                this.HotelCard(hotel)
              }
              .margin({ left: 16, right: 16, top: 8, bottom: 8 })
            }, (hotel: Hotel, index: number) => `hotel-${hotel.id}-${index}`)
          }
          .layoutWeight(1)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder HotelCard(hotel: Hotel) {
    Column() {
      Row() {
        // 酒店图片
        Text(hotel.image)
          .fontSize(40)
          .width(80)
          .height(80)
          .textAlign(TextAlign.Center)
          .backgroundColor('#f0f0f0')
          .borderRadius(8)
          .margin({ right: 12 })

        Column() {
          // 酒店名称和评分
          Row() {
            Text(hotel.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .layoutWeight(1)

            Row() {
              Text('⭐')
                .fontSize(12)
              Text(hotel.rating.toString())
                .fontSize(12)
                .fontColor('#ff6b35')
                .margin({ left: 2 })
            }
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 地址和距离
          Text(hotel.address)
            .fontSize(12)
            .fontColor('#666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 2 })

          Text(hotel.distance)
            .fontSize(12)
            .fontColor('#999')
            .margin({ bottom: 8 })

          // 设施
          Row() {
            ForEach((hotel.facilities ?? []).slice(0, 3), (facility: string, index: number) => {
              Text(facility)
                .fontSize(10)
                .fontColor('#666')
                .backgroundColor('#f0f0f0')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 4 })
            }, (facility: string, index: number) => `fac-${hotel.id}-${index}-${facility}`)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })

      // 价格和预订按钮
      Row() {
        Column() {
          if (hotel.originalPrice && hotel.originalPrice > hotel.price) {
            Text(`¥${hotel.originalPrice}`)
              .fontSize(12)
              .fontColor('#999')
              .decoration({ type: TextDecorationType.LineThrough })
          }
          
          Row() {
            Text(`¥${hotel.price}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff6b35')
            Text('/晚')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 2 })
          }

          Text(`${hotel.reviews}条评价`)
            .fontSize(10)
            .fontColor('#999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('预订')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .borderRadius(6)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => this.createPendingOrderAndGo(hotel))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => this.onHotelClick(hotel))
  }
}
