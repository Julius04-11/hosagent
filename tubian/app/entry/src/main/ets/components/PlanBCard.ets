/**
 * Plan B 备选方案卡片。
 */
import { RoutePlan } from '../models/RoutePlan';
import { formatCost } from '../utils/FormatUtil';
import { Colors } from '../utils/StyleConstants';

@Component
export struct PlanBCard {
  @Prop plan: RoutePlan;

  build() {
    Column({ space: 6 }) {
      Row() {
        Text('Plan B · 备选')
          .fontSize(12).fontWeight(FontWeight.Medium).fontColor(Colors.GREEN)
        Blank()
        Text(`预计 ${this.plan.eta}`)
          .fontSize(12).fontColor(Colors.TEXT_SUB)
      }.width('100%')

      Text(this.plan.reason)
        .fontSize(13).fontColor(Colors.TEXT).maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')

      Text(`费用 ${formatCost(this.plan.cost)} · 步行 ${this.plan.walkDistanceMeters}米 · 换乘 ${this.plan.transferCount}次`)
        .fontSize(11).fontColor(Colors.TEXT_SUB).width('100%')
    }
    .padding(14)
    .width('100%')
    .backgroundColor(Colors.CARD)
    .borderRadius(8)
    .border({ width: 1, color: Colors.DIVIDER })
  }
}
