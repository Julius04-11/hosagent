/**
 * 风险提醒卡片：橙色/红色突出，文案克制。
 */
import { Colors } from '../utils/StyleConstants';

@Component
export struct AlertCard {
  @Prop title: string;
  @Prop level: string = 'warning'; // 'warning' | 'danger'

  build() {
    Row({ space: 8 }) {
      Text('!')
        .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .width(20).height(20).textAlign(TextAlign.Center)
        .backgroundColor(this.level === 'danger' ? Colors.RED : Colors.ORANGE)
        .borderRadius(10)
      Text(this.title)
        .fontSize(13).fontColor(this.level === 'danger' ? Colors.RED : Colors.ORANGE)
        .layoutWeight(1)
    }
    .padding(12)
    .width('100%')
    .backgroundColor(this.level === 'danger' ? '#FEF2F2' : '#FFF7ED')
    .borderRadius(8)
  }
}
