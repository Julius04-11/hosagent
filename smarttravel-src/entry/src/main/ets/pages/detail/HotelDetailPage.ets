import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ImageConstants } from '../../constants/ImageConstants';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface HotelDetailInfo {
  id: string;
  name: string;
  images: string[];
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  price: string;
  originalPrice: string;
  tags: string[];
  description: string;
  facilities: string[];
  checkIn: string;
  checkOut: string;
  phone: string;
  address: string;
  roomTypes: RoomType[];
  reviews: ReviewItem[];
}

interface RoomType {
  name: string;
  price: string;
  originalPrice: string;
  image: string;
  facilities: string[];
  available: boolean;
}

interface ReviewItem {
  userName: string;
  rating: number;
  comment: string;
  date: string;
  avatar: string;
}

@Entry
@Component
export struct HotelDetailPage {
  @State hotelDetail: HotelDetailInfo = {} as HotelDetailInfo;
  @State isLoading: boolean = true;
  @State currentImageIndex: number = 0;
  @State selectedRoomIndex: number = 0;
  
  private hotelId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.hotelId = params['id'] as string || '1';
    this.loadHotelDetail();
  }

  private loadHotelDetail() {
    // 模拟加载酒店详情数据
    setTimeout(() => {
      this.hotelDetail = {
        id: this.hotelId,
        name: '深圳湾万豪酒店',
        images: [
          ImageConstants.getSafeImageUrl('https://picsum.photos/id/301/400/300', 'hotel'),
          ImageConstants.getSafeImageUrl('https://picsum.photos/id/302/400/300', 'hotel'),
          ImageConstants.getSafeImageUrl('https://picsum.photos/id/303/400/300', 'hotel')
        ],
        rating: 4.8,
        reviewCount: 1256,
        location: '南山区深圳湾',
        distance: '1.2km',
        price: '¥680',
        originalPrice: '¥880',
        tags: ['五星级', '海景', '商务', '豪华'],
        description: '豪华海景酒店，设施完善，服务一流。酒店位于深圳湾核心地段，享有无敌海景，是商务出行和休闲度假的理想选择。',
        facilities: ['WiFi', '停车场', '健身房', '游泳池', '餐厅', 'SPA', '会议室', '商务中心'],
        checkIn: '14:00',
        checkOut: '12:00',
        phone: '0755-88888888',
        address: '深圳市南山区深圳湾科技生态园A区',
        roomTypes: [
          {
            name: '豪华海景房',
            price: '¥680',
            originalPrice: '¥880',
            image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/304/300/200', 'hotel'),
            facilities: ['海景', '大床', '浴缸', '阳台'],
            available: true
          },
          {
            name: '商务套房',
            price: '¥980',
            originalPrice: '¥1280',
            image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/305/300/200', 'hotel'),
            facilities: ['客厅', '办公区', '会议桌', '迷你吧'],
            available: true
          }
        ],
        reviews: [
          {
            userName: '商务达人',
            rating: 5,
            comment: '酒店位置很好，房间宽敞舒适，服务很棒！海景房的景色真的很美。',
            date: '2024-11-10',
            avatar: '👤'
          },
          {
            userName: '度假爱好者',
            rating: 4,
            comment: '设施很完善，早餐丰富，就是价格稍微有点贵。',
            date: '2024-11-08',
            avatar: '👤'
          }
        ]
      };
      this.isLoading = false;
    }, 800);
  }

  build() {
    Column() {
      TopNavigationBar({
        title: this.isLoading ? '加载中...' : this.hotelDetail.name,
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            this.HeaderImageSection()
            this.BasicInfoSection()
            this.FacilitiesSection()
            this.RoomTypesSection()
            this.ContactInfoSection()
            this.ReviewsSection()
            this.ActionButtonsSection()
          }
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('🏨')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在加载酒店详情...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder HeaderImageSection() {
    Stack() {
      Swiper() {
        ForEach(this.hotelDetail?.images ?? [], (image: string, index: number) => {
          Image(image)
            .width('100%')
            .height(250)
            .objectFit(ImageFit.Cover)
        }, (image: string, index: number) => `img-${index}-${image}`)
      }
      .width('100%')
      .height(250)
      .indicator(true)
      .loop(true)
      .autoPlay(true)
      .interval(3000)

      // 评分标签
      Row() {
        Text('⭐')
          .fontSize(14)
        Text(this.hotelDetail.rating.toFixed(1))
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`(${this.hotelDetail.reviewCount}条评价)`)
          .fontSize(12)
          .fontColor(Color.White)
      }
      .backgroundColor('rgba(0,0,0,0.6)')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ bottom: 16, right: 16 })
    }
    .alignContent(Alignment.BottomEnd)
  }

  @Builder BasicInfoSection() {
    Column() {
      Row() {
        Text(this.hotelDetail.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Column() {
          Row() {
            Text(this.hotelDetail.originalPrice)
              .fontSize(14)
              .fontColor('#9ca3af')
              .decoration({ type: TextDecorationType.LineThrough })
            Text(this.hotelDetail.price)
              .fontSize(20)
              .fontColor('#ef4444')
              .fontWeight(FontWeight.Bold)
              .margin({ left: 8 })
          }
          Text('/晚')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('📍')
          .fontSize(14)
          .margin({ right: 4 })
        Text(this.hotelDetail.location)
          .fontSize(14)
          .fontColor('#6b7280')
          .layoutWeight(1)
        Text(this.hotelDetail.distance)
          .fontSize(14)
          .fontColor('#9ca3af')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.hotelDetail?.tags ?? [], (tag: string, index: number) => {
          Text(tag)
            .fontSize(12)
            .fontColor('#6366f1')
            .backgroundColor('#eef2ff')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
        }, (tag: string, index: number) => `tag-${index}-${tag}`)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(this.hotelDetail.description)
        .fontSize(14)
        .fontColor('#4b5563')
        .lineHeight(22)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
  }

  @Builder FacilitiesSection() {
    Column() {
      Text('🏊 酒店设施')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.hotelDetail?.facilities ?? [], (facility: string, index: number) => {
          Row() {
            Text(this.getFacilityIcon(facility))
              .fontSize(16)
              .margin({ right: 6 })
            Text(facility)
              .fontSize(14)
              .fontColor('#374151')
          }
          .backgroundColor('#f3f4f6')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .borderRadius(8)
          .margin({ right: 8, bottom: 8 })
        }, (facility: string, index: number) => `facility-${index}-${facility}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoomTypesSection() {
    Column() {
      Text('🛏️ 房型选择')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      Column({ space: 12 }) {
        ForEach(this.hotelDetail?.roomTypes ?? [], (room: RoomType, index: number) => {
          this.RoomTypeItem(room, index)
        }, (room: RoomType, index: number) => `room-${index}-${room.name ?? ''}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoomTypeItem(room: RoomType, index: number) {
    Row() {
      Image(room.image)
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(room.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .layoutWeight(1)
          
          Column() {
            Row() {
              Text(room.originalPrice)
                .fontSize(12)
                .fontColor('#9ca3af')
                .decoration({ type: TextDecorationType.LineThrough })
              Text(room.price)
                .fontSize(16)
                .fontColor('#ef4444')
                .fontWeight(FontWeight.Bold)
                .margin({ left: 4 })
            }
            Text('/晚')
              .fontSize(10)
              .fontColor('#6b7280')
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(room.facilities ?? [], (facility: string, index: number) => {
            Text(facility)
              .fontSize(11)
              .fontColor('#059669')
              .backgroundColor('#d1fae5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .margin({ right: 6, bottom: 4 })
          }, (facility: string, index: number) => `room-fac-${index}-${facility}`)
        }

        Row() {
          Text(room.available ? '✅ 有房' : '❌ 满房')
            .fontSize(12)
            .fontColor(room.available ? '#059669' : '#dc2626')
            .layoutWeight(1)
          
          if (room.available) {
            Button('预订')
              .backgroundColor('#3b82f6')
              .fontColor(Color.White)
              .fontSize(12)
              .height(28)
              .borderRadius(14)
              .onClick(() => {
                console.log('预订房间:', room.name);
              })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.selectedRoomIndex === index ? '#f0f9ff' : '#f9fafb')
    .padding(12)
    .borderRadius(8)
    .border({
      width: this.selectedRoomIndex === index ? 2 : 1,
      color: this.selectedRoomIndex === index ? '#3b82f6' : '#e5e7eb'
    })
    .onClick(() => {
      this.selectedRoomIndex = index;
    })
  }

  @Builder ContactInfoSection() {
    Column() {
      Text('📞 酒店信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      Row() {
        Text('入住时间：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.hotelDetail.checkIn)
          .fontSize(14)
          .fontColor('#374151')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('退房时间：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.hotelDetail.checkOut)
          .fontSize(14)
          .fontColor('#374151')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('联系电话：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.hotelDetail.phone)
          .fontSize(14)
          .fontColor('#3b82f6')
          .onClick(() => {
            console.log('拨打电话:', this.hotelDetail.phone);
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('详细地址：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.hotelDetail.address)
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)
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

  @Builder ReviewsSection() {
    Column() {
      Row() {
        Text('💬 住客评价')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#6366f1')
          .onClick(() => {
            console.log('查看全部评价');
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column({ space: 12 }) {
        ForEach((this.hotelDetail?.reviews ?? []).slice(0, 2), (review: ReviewItem, index: number) => {
          this.ReviewItem(review)
        }, (review: ReviewItem, index: number) => `review-${index}-${review.userName}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ReviewItem(review: ReviewItem) {
    Column() {
      Row() {
        Image(review.avatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .margin({ right: 8 })
        
        Column() {
          Text(review.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
          
          Row() {
            ForEach(Array.from({length: 5}), (item: undefined, index: number) => {
              Text(index < review.rating ? '⭐' : '☆')
                .fontSize(12)
            }, (_: undefined, index: number) => `star-${review.userName}-${index}`)
            Text(review.date)
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ left: 8 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(review.comment)
        .fontSize(14)
        .fontColor('#4b5563')
        .lineHeight(20)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActionButtonsSection() {
    Row({ space: 12 }) {
      Button('导航')
        .backgroundColor('#10b981')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          ErrorHandler.safeExecute(async () => {
            await router.pushUrl({
              url: 'pages/ar/ARNavigationPage',
              params: { 
                destination: this.hotelDetail.name,
                address: this.hotelDetail.address
              }
            });
          }, (error: Error): void => ErrorHandler.handleRouterError(error, 'AR导航页面'));
        })

      Button('收藏')
        .backgroundColor('#6366f1')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          console.log('收藏酒店:', this.hotelDetail.name);
        })

      Button('立即预订')
        .backgroundColor('#ef4444')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          console.log('预订酒店:', this.hotelDetail.name);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  private getFacilityIcon(facility: string): string {
    const iconMap: Record<string, string> = {
      'WiFi': '📶',
      '停车场': '🅿️',
      '健身房': '🏋️',
      '游泳池': '🏊',
      '餐厅': '🍽️',
      'SPA': '💆',
      '会议室': '🏢',
      '商务中心': '💼'
    };
    return iconMap[facility] || '✅';
  }
}
