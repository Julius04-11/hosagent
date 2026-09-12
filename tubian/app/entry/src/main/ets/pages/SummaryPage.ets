/**
 * 到达总结页：总耗时、总花费、关键决策（需求文档 §6.4）。
 */
import router from '@ohos.router';
import { getJourneyStore } from '../stores/JourneyStore';
import { RoutePlan } from '../models/RoutePlan';
import { ReplanResult } from '../models/ReplanResult';
import { formatCost, formatDuration } from '../utils/FormatUtil';
import { ActionBar } from '../components/ActionBar';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct SummaryPage {
  @State plan: RoutePlan | null = null;
  @State replan: ReplanResult | null = null;

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.plan = store.currentPlan ?? store.mainPlan ?? null;
    this.replan = store.replanResult ?? null;
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('行程总结')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT).width('100%')

        if (this.plan) {
          Column({ space: 12 }) {
            Text('已抵达')
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Colors.GREEN).width('100%')
            Row({ space: 20 }) {
              this.summaryItem('总耗时', formatDuration(this.plan.durationMinutes))
              this.summaryItem('总花费', formatCost(this.plan.cost))
              this.summaryItem('到达时间', this.plan.eta)
            }.width('100%')
          }
          .padding(20).width('100%')
          .backgroundColor(Colors.CARD).borderRadius(8)
        }

        if (this.replan) {
          Column({ space: 8 }) {
            Text('关键决策')
              .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT).width('100%')
            Text(`触发原因：${this.replan.trigger}`)
              .fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
            Text(this.replan.explanation)
              .fontSize(13).fontColor(Colors.TEXT).width('100%')
          }
          .padding(16).width('100%')
          .backgroundColor(Colors.CARD).borderRadius(8)
        }

        ActionBar({
          primaryText: '再次规划',
          onPrimary: () => { this.restart(); }
        })
      }
      .padding(20)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  @Builder
  summaryItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(16).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT)
      Text(label).fontSize(12).fontColor(Colors.TEXT_SUB)
    }.alignItems(HorizontalAlign.Start)
  }

  restart(): void {
    const store = getJourneyStore();
    store.goal = undefined;
    store.mainPlan = undefined;
    store.backupPlans = [];
    store.currentPlan = undefined;
    store.replanResult = undefined;
    router.clear();
    router.pushUrl({ url: 'pages/HomePage' });
  }
}
