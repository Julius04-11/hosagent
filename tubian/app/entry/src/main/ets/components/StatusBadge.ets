/**
 * 阶段状态标签。
 */
import { JourneyState } from '../models/JourneyState';
import { Colors } from '../utils/StyleConstants';

@Component
export struct StatusBadge {
  @Prop state: JourneyState;

  build() {
    Text(this.state)
      .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.PRIMARY)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(Colors.PRIMARY + '1A')
      .borderRadius(14)
  }
}
