/**
 * 行程方案页：主方案时间轴 + Plan B 卡片 + 风险提示（需求文档 §6.4）。
 */
import router from '@ohos.router';
import { getJourneyStore } from '../stores/JourneyStore';
import { RoutePlan } from '../models/RoutePlan';
import { RouteCard } from '../components/RouteCard';
import { TimelineView } from '../components/TimelineView';
import { PlanBCard } from '../components/PlanBCard';
import { AlertCard } from '../components/AlertCard';
import { ActionBar } from '../components/ActionBar';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct PlanPage {
  @State mainPlan: RoutePlan | null = null;
  @State backupPlans: RoutePlan[] = [];
  @State riskTips: string[] = [];

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.mainPlan = store.mainPlan ?? null;
    this.backupPlans = store.backupPlans;
    if (store.goal && store.goal.luggage) {
      this.riskTips = ['携带行李，长距离步行体验较差'];
    }
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('行程方案')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
          Blank()
          Text('第 3 步').fontSize(12).fontColor(Colors.TEXT_SUB)
        }.width('100%')

        if (this.mainPlan) {
          RouteCard({ plan: this.mainPlan })
          TimelineView({ segments: this.mainPlan.segments })
        }

        if (this.riskTips.length > 0) {
          ForEach(this.riskTips, (tip: string) => {
            AlertCard({ title: tip, level: 'warning' })
          }, (tip: string) => tip)
        }

        if (this.backupPlans.length > 0) {
          Text('Plan B · 备选方案')
            .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT).width('100%')
          ForEach(this.backupPlans, (p: RoutePlan) => {
            PlanBCard({ plan: p })
          }, (p: RoutePlan) => p.planId)
        }

        ActionBar({
          primaryText: '确认行程，开始出行',
          secondaryText: '修改偏好',
          onPrimary: () => { router.pushUrl({ url: 'pages/JourneyPage' }); },
          onSecondary: () => { router.back(); }
        })
      }
      .padding(20)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }
}
