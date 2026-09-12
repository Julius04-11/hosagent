import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ImageConstants } from '../../constants/ImageConstants';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface FoodDetailInfo {
  id: string;
  name: string;
  image: string;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  price: string;
  tags: string[];
  description: string;
  openHours: string;
  phone: string;
  address: string;
  specialties: string[];
  reviews: ReviewItem[];
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
export struct FoodDetailPage {
  @State foodDetail: FoodDetailInfo = {} as FoodDetailInfo;
  @State isLoading: boolean = true;
  @State currentImageIndex: number = 0;
  
  private foodId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.foodId = params['id'] as string || '1';
    this.loadFoodDetail();
  }

  private loadFoodDetail() {
    // 模拟加载美食详情数据
    setTimeout(() => {
      this.foodDetail = {
        id: this.foodId,
        name: '深圳湾海鲜大排档',
        image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/292/400/300', 'restaurant'),
        rating: 4.8,
        reviewCount: 1256,
        location: '南山区深圳湾',
        distance: '1.2km',
        price: '人均¥120',
        tags: ['海鲜', '大排档', '夜宵', '聚餐'],
        description: '新鲜海鲜，现点现做，环境优雅，适合聚餐。本店精选优质海鲜，采用传统粤菜烹饪工艺，为您呈现最地道的海鲜美味。',
        openHours: '11:00-23:00',
        phone: '0755-12345678',
        address: '深圳市南山区深圳湾科技生态园',
        specialties: ['白灼虾', '蒜蓉扇贝', '椒盐濑尿虾', '清蒸石斑鱼', '姜葱炒蟹'],
        reviews: [
          {
            userName: '美食达人',
            rating: 5,
            comment: '海鲜很新鲜，味道很棒！环境也不错，服务态度很好。',
            date: '2024-11-10',
            avatar: '👤'
          },
          {
            userName: '吃货小王',
            rating: 4,
            comment: '价格合理，分量足，就是人比较多需要等位。',
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
        title: this.isLoading ? '加载中...' : this.foodDetail.name,
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            this.HeaderImageSection()
            this.BasicInfoSection()
            this.SpecialtiesSection()
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
      Text('🍽️')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在加载美食详情...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder HeaderImageSection() {
    Stack() {
      Image(this.foodDetail.image)
        .width('100%')
        .height(250)
        .objectFit(ImageFit.Cover)

      // 评分标签
      Row() {
        Text('⭐')
          .fontSize(14)
        Text(this.foodDetail.rating.toFixed(1))
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`(${this.foodDetail.reviewCount}条评价)`)
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
        Text(this.foodDetail.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text(this.foodDetail.price)
          .fontSize(20)
          .fontColor('#ef4444')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('📍')
          .fontSize(14)
          .margin({ right: 4 })
        Text(this.foodDetail.location)
          .fontSize(14)
          .fontColor('#6b7280')
          .layoutWeight(1)
        Text(this.foodDetail.distance)
          .fontSize(14)
          .fontColor('#9ca3af')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.foodDetail?.tags ?? [], (tag: string, index: number) => {
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

      Text(this.foodDetail.description)
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

  @Builder SpecialtiesSection() {
    Column() {
      Text('🍴 招牌菜品')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      Column({ space: 8 }) {
        ForEach(this.foodDetail?.specialties ?? [], (dish: string, index: number) => {
          Row() {
            Text('•')
              .fontSize(16)
              .fontColor('#f59e0b')
              .margin({ right: 8 })
            Text(dish)
              .fontSize(14)
              .fontColor('#374151')
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }, (dish: string, index: number) => `dish-${index}-${dish}`)
      }
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
      Text('📞 联系信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })

      Row() {
        Text('营业时间：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.foodDetail.openHours)
          .fontSize(14)
          .fontColor('#374151')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('联系电话：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.foodDetail.phone)
          .fontSize(14)
          .fontColor('#3b82f6')
          .onClick(() => {
            // 拨打电话功能
            console.log('拨打电话:', this.foodDetail.phone);
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text('详细地址：')
          .fontSize(14)
          .fontColor('#6b7280')
        Text(this.foodDetail.address)
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
        Text('💬 用户评价')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#6366f1')
          .onClick(() => {
            // 跳转到评价页面
            console.log('查看全部评价');
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column({ space: 12 }) {
        ForEach((this.foodDetail?.reviews ?? []).slice(0, 2), (review: ReviewItem, index: number) => {
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
                destination: this.foodDetail.name,
                address: this.foodDetail.address
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
          console.log('收藏美食:', this.foodDetail.name);
        })

      Button('分享')
        .backgroundColor('#f59e0b')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          console.log('分享美食:', this.foodDetail.name);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }
}
