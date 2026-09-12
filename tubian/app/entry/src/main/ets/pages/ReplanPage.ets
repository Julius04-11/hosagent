/**
 * 重规划提醒页：风险提示 + 原/新方案对比 + 原因解释（需求文档 §6.4）。
 */
import router from '@ohos.router';
import { getJourneyStore } from '../stores/JourneyStore';
import { ReplanResult } from '../models/ReplanResult';
import { RoutePlan } from '../models/RoutePlan';
import { RouteCard } from '../components/RouteCard';
import { AlertCard } from '../components/AlertCard';
import { ActionBar } from '../components/ActionBar';
import { formatCostDelta } from '../utils/FormatUtil';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct ReplanPage {
  @State result: ReplanResult | null = null;
  @State oldPlan: RoutePlan | null = null;

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.result = store.replanResult ?? null;
    this.oldPlan = store.currentPlan ?? store.mainPlan ?? null;
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('行程变化提醒')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT).width('100%')

        if (this.result) {
          AlertCard({ title: this.result.trigger, level: 'danger' })
        }

        if (this.oldPlan && this.result) {
          Column({ space: 6 }) {
            Text(`原方案：预计 ${this.oldPlan.eta} 到达 · 费用 ${this.oldPlan.cost} 元`)
              .fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
          }
          .padding(12).width('100%')
          .backgroundColor('#F3F4F6').borderRadius(8)

          Text('推荐新方案')
            .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT).width('100%')
          RouteCard({ plan: this.result.newPlan })

          Column({ space: 6 }) {
            Text(`额外费用 ${formatCostDelta(this.result.extraCost)}`)
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.ORANGE).width('100%')
            Text(this.result.explanation)
              .fontSize(13).fontColor(Colors.TEXT).width('100%')
          }
          .padding(14).width('100%')
          .backgroundColor(Colors.CARD).borderRadius(8)
        }

        ActionBar({
          primaryText: '切换方案',
          secondaryText: '暂不切换',
          onPrimary: () => { this.switchPlan(); },
          onSecondary: () => { router.back(); }
        })
      }
      .padding(20)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  switchPlan(): void {
    const store = getJourneyStore();
    if (this.result) {
      store.currentPlan = this.result.newPlan;
      store.replanResult = undefined;
    }
    router.pushUrl({ url: 'pages/JourneyPage' });
  }
}
