import { CollectedMarker } from '../model/CollectMarkerModel'
import { StyleConstants } from '../constants/StyleConstants'

@Component
export struct AddressDialog {
  @Link visible: boolean
  @Prop marker: CollectedMarker | undefined
  @Prop onCollect: () => void
  @Prop onClose: () => void

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.visible && this.marker) {
        Blank()
          .width('100%')
          .height('100%')
          .backgroundColor(StyleConstants.BACKDROP_COLOR)
          .onClick(() => {
            this.onClose()
          })

        Column() {
          Text('已添加标记')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 12 })

          Text(this.marker.simpleAddress || '未获取到简要地址')
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          Text(this.marker.detailAddress || '未获取到详细地址')
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 24 })

          Row() {
            Button('取消')
              .height(StyleConstants.DIALOG_BUTTON_HEIGHT)
              .width('45%')
              .borderRadius(StyleConstants.DIALOG_BUTTON_RADIUS)
              .backgroundColor(Color.White)
              .border({ width: 1, color: StyleConstants.DIALOG_BUTTON_OUTLINE_COLOR })
              .fontColor(StyleConstants.DIALOG_BUTTON_TEXT_COLOR)
              .onClick(() => {
                this.onClose()
              })

            Button('收藏')
              .height(StyleConstants.DIALOG_BUTTON_HEIGHT)
              .width('45%')
              .borderRadius(StyleConstants.DIALOG_BUTTON_RADIUS)
              .backgroundColor('#0A59F7')
              .fontColor(Color.White)
              .onClick(() => {
                this.onCollect()
              })
              .margin({ left: StyleConstants.DIALOG_BUTTON_GAP })
          }
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(StyleConstants.DIALOG_WIDTH)
        .padding(StyleConstants.DIALOG_PADDING)
        .backgroundColor(Color.White)
        .borderRadius(StyleConstants.DIALOG_BORDER_RADIUS)
      } else {
        Blank()
      }
    }
    .width('100%')
    .height('100%')
  }
}


