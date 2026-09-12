/**
 * 路线卡片：展示方案类型、ETA、费用、耗时、步行、换乘、风险与理由。
 */
import { RoutePlan } from '../models/RoutePlan';
import { formatCost, formatDistance } from '../utils/FormatUtil';
import { riskColor } from '../utils/RiskUtil';
import { Colors } from '../utils/StyleConstants';

@Component
export struct RouteCard {
  @Prop plan: RoutePlan;

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.plan.type)
          .fontSize(14).fontWeight(FontWeight.Bold).fontColor(Colors.PRIMARY)
        Blank()
        Text(`预计 ${this.plan.eta} 到达`)
          .fontSize(13).fontColor(Colors.TEXT_SUB)
      }.width('100%')

      Row({ space: 16 }) {
        this.stat('费用', formatCost(this.plan.cost))
        this.stat('耗时', `${this.plan.durationMinutes}分钟`)
        this.stat('步行', formatDistance(this.plan.walkDistanceMeters))
        this.stat('换乘', `${this.plan.transferCount}次`)
      }.width('100%')

      Row() {
        Text(`准时率 ${Math.round(this.plan.onTimeProbability * 100)}%`)
          .fontSize(12).fontColor(riskColor(this.plan.riskLevel))
          .backgroundColor(riskColor(this.plan.riskLevel) + '1A')
          .borderRadius(4).padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }.width('100%')

      Text(this.plan.reason)
        .fontSize(12).fontColor(Colors.TEXT_SUB).maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
    }
    .padding(16)
    .backgroundColor(Colors.CARD)
    .borderRadius(8)
    .width('100%')
  }

  @Builder
  stat(label: string, value: string) {
    Column({ space: 2 }) {
      Text(value).fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT)
      Text(label).fontSize(11).fontColor(Colors.TEXT_SUB)
    }.alignItems(HorizontalAlign.Start)
  }
}
