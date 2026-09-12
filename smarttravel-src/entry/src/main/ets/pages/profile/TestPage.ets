import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

@Entry
@Component
export struct TestPage {
  build() {
    Column() {
      TopNavigationBar({
        title: '测试页面',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      Column() {
        Text('这是一个测试页面')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 20 })

        Text('如果你能看到这个页面，说明路由跳转正常工作！')
          .fontSize(16)
          .fontColor('#6b7280')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 30 })

        Button('返回')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#3b82f6')
          .borderRadius(8)
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
