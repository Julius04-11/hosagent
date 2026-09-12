import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';

@Entry
@Component
export struct PlaceDetailPage {
  @State placeId: string = '';
  @State placeName: string = '深圳湾公园';
  @State rating: number = 4.8;
  @State reviewCount: number = 1256;
  @State location: string = '南山区深圳湾';
  @State openTime: string = '全天开放';
  @State ticketPrice: string = '免费';
  @State description: string = '深圳湾公园是深圳市最美的海滨公园之一，拥有13公里的海滨栈道。';
  @State tags: string[] = ['公园', '海景', '免费', '适合散步'];
  @State isFavorite: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.placeId = params.id;
    }
  }

  build() {
    Column() {
      TopNavigationBar({ title: '地点详情', showBack: true })

      Scroll() {
        Column() {
          Text('🏞️').fontSize(80).margin(20)
          
          Text(this.placeName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 16 })

          Row({ space: 8 }) {
            Text(`⭐ ${this.rating}`)
            Text(`(${this.reviewCount}条评价)`)
              .fontSize(14)
              .fontColor('#6b7280')
          }
          .margin({ bottom: 16 })

          Column() {
            Row() {
              Text('📍 位置：').fontColor('#6b7280')
              Text(this.location)
            }.width('100%').margin({ bottom: 8 })

            Row() {
              Text('⏰ 开放时间：').fontColor('#6b7280')
              Text(this.openTime)
            }.width('100%').margin({ bottom: 8 })

            Row() {
              Text('💰 门票：').fontColor('#6b7280')
              Text(this.ticketPrice).fontColor('#10b981')
            }.width('100%')
          }
          .width('90%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 16 })

          Text(this.description)
            .fontSize(14)
            .lineHeight(22)
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
