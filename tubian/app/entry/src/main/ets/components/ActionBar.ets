/**
 * 底部操作栏：一个主按钮 + 可选次按钮。
 */
import { Colors } from '../utils/StyleConstants';

@Component
export struct ActionBar {
  @Prop primaryText: string = '确认';
  @Prop secondaryText: string = '';
  onPrimary: () => void = () => {};
  onSecondary: () => void = () => {};

  build() {
    Row({ space: 12 }) {
      if (this.secondaryText.length > 0) {
        Button(this.secondaryText)
          .layoutWeight(1).height(44)
          .backgroundColor('#F3F4F6').fontColor(Colors.TEXT)
          .onClick(() => this.onSecondary())
      }
      Button(this.primaryText)
        .layoutWeight(1).height(44)
        .backgroundColor(Colors.PRIMARY).fontColor('#FFFFFF')
        .onClick(() => this.onPrimary())
    }
    .width('100%')
  }
}
