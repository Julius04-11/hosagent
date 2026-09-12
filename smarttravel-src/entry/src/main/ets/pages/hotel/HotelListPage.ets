/**
 * 酒店列表页面
 * 展示深圳酒店，已入住的可以评价
 */

import { router } from '@kit.ArkUI';
import { shenzhenHotels, HotelData } from '../../viewmodel/ShenzhenData';

@Entry
@Component
export struct HotelListPage {
  @State hotels: HotelData[] = [];

  aboutToAppear() {
    console.log('[HotelListPage] aboutToAppear - 页面初始化');
    try {
      this.hotels = [...shenzhenHotels];
      console.log('[HotelListPage] 酒店数据加载完成:', this.hotels.length);
    } catch (error) {
      console.error('[HotelListPage] 初始化失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()
      
      // 酒店列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.hotels, (hotel: HotelData) => {
            this.HotelCard(hotel)
          }, (hotel: HotelData) => hotel.id) // 添加keyGenerator
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // 顶部导航栏
  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text('深圳酒店')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text('🔍')
        .fontSize(20)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  // 酒店卡片
  @Builder HotelCard(hotel: HotelData) {
    Column() {
      Row({ space: 12 }) {
        // 酒店图片
        Image(hotel.image)
          .width(120)
          .height(90)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
        
        // 酒店信息
        Column() {
          Text(hotel.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(hotel.subtitle)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 4 })
          
          Row() {
            Text(`⭐${hotel.rating}`)
              .fontSize(12)
              .fontColor('#ff9900')
            Text(`  ${hotel.category}`)
              .fontSize(12)
              .fontColor('#999999')
          }
          .margin({ top: 4 })
          
          Text(hotel.price)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ff6b6b')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      
      // 特色标签
      Row({ space: 6 }) {
        ForEach((hotel.features ?? []).slice(0, 3), (feature: string, index: number) => {
          Text(feature)
            .fontSize(11)
            .fontColor('#666666')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#f5f5f5')
            .borderRadius(4)
        }, (feature: string, index: number) => `feat-${hotel.id}-${index}-${feature}`)
      }
      .width('100%')
      .margin({ top: 12 })
      
      // 操作按钮
      if (hotel.hasOrder) {
        Row({ space: 10 }) {
          Text('已入住')
            .fontSize(12)
            .fontColor('#52c41a')
          
          if (hotel.canReview) {
            Button('立即评价')
              .fontSize(14)
              .height(32)
              .backgroundColor('#0086f6')
              .onClick(() => {
                // 跳转到评价页面
                router.pushUrl({
                  url: 'pages/hotel/HotelReviewPage',
                  params: {
                    hotelId: hotel.id,
                    orderId: `order_${hotel.id}_${Date.now()}`
                  }
                });
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 12 })
      } else {
        Row() {
          Button('查看详情')
            .fontSize(14)
            .height(32)
            .backgroundColor('#0086f6')
            .onClick(() => {
              console.log('查看酒店详情:', hotel.name);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(12)
  }
}
