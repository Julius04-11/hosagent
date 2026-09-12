import { TopNavigationBar } from '../../components/TopNavigationBar';
import { router } from '@kit.ArkUI';

/**
 * 环保旅行页面 - 简化版
 */
@Entry
@Component
export struct EcoTravelPage {
  @State currentTab: number = 0;
  @State isLoading: boolean = false;

  build() {
    Column() {
      TopNavigationBar({
        title: '环保旅行',
        showBack: true
      })

      // 环保统计卡片
      Column() {
        Text('🌱 环保旅行统计')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        Row() {
          Column() {
            Text('0')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#059669')
            Text('碳足迹 (kg)')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)

          Column() {
            Text('0')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#059669')
            Text('环保行为')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)

          Column() {
            Text('0')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#059669')
            Text('绿色积分')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ horizontal: 16, top: 16 })

      // 环保建议
      Column() {
        Text('🌿 环保建议')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })

        Column() {
          Text('🚶‍♂️ 步行或骑行短途出行')
            .fontSize(14)
            .margin({ bottom: 8 })
          Text('🚌 选择公共交通工具')
            .fontSize(14)
            .margin({ bottom: 8 })
          Text('♻️ 减少一次性用品使用')
            .fontSize(14)
            .margin({ bottom: 8 })
          Text('🏨 选择环保认证酒店')
            .fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ horizontal: 16, top: 16 })
      .alignItems(HorizontalAlign.Start)

      Spacer()

      // 返回按钮
      Button('返回首页')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#059669')
        .borderRadius(24)
        .margin({ bottom: 32 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
