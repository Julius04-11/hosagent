/**
 * 行程状态页：定位驱动的动态跟踪（需求文档 §7.6 / §7.7）。
 * - 轮询真实定位，实时上报后端，返回当前阶段 + 具体下一步动作；
 * - 检测到需要重规划时展示 Agent 建议卡片（采纳/忽略），不直接跳转。
 */
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { ApiService } from '../services/ApiService';
import { LocationService } from '../services/LocationService';
import { getJourneyStore } from '../stores/JourneyStore';
import { JourneyState } from '../models/JourneyState';
import { RoutePlan } from '../models/RoutePlan';
import { LocationData, ReplanResult } from '../models/ReplanResult';
import { StatusBadge } from '../components/StatusBadge';
import { ActionBar } from '../components/ActionBar';
import { nowHHMM } from '../utils/TimeUtil';
import { openMapNavigation, openRideHail } from '../utils/AppLinkUtil';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct JourneyPage {
  @State currentState: JourneyState = '出发准备';
  @State nextAction: string = '准备出发...';
  @State distanceText: string = '';
  @State plan: RoutePlan | null = null;
  @State location: LocationData | null = null;
  @State errorText: string = '';
  // Agent 建议卡片
  @State agentSuggestion: string = '';
  @State agentReason: string = '';
  @State replanResult: ReplanResult | null = null;
  @State showSuggestion: boolean = false;
  private timerId: number = -1;
  private refreshing: boolean = false;
  private lastReason: string = '';  // 防止同一原因重复弹卡片

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.plan = store.currentPlan ?? store.mainPlan ?? null;
    this.requestLocationPermission().then((granted: boolean) => {
      if (granted) {
        this.refresh();
        this.timerId = setInterval(() => { this.refresh(); }, 5000);
      } else {
        this.nextAction = '未授权定位，无法动态跟踪行程';
      }
    });
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  onPageShow(): void {
    if (this.timerId < 0) {
      this.timerId = setInterval(() => { this.refresh(); }, 5000);
    }
  }

  private async requestLocationPermission(): Promise<boolean> {
    const context = getContext(this) as common.UIAbilityContext;
    return await LocationService.requestPermission(context);
  }

  async refresh(): Promise<void> {
    if (this.refreshing) {
      return;
    }
    this.refreshing = true;
    try {
      const loc = await LocationService.getCurrentLocation();
      if (loc) {
        this.location = loc;
      }

      const store = getJourneyStore();
      if (store.goal && this.plan) {
        const res = await ApiService.updateStatus(store.goal, this.plan,
          this.location ?? undefined, nowHHMM());
        this.currentState = res.currentState;
        this.nextAction = res.nextAction;
        store.currentState = res.currentState;
        if (res.distanceToDestination !== undefined) {
          this.distanceText = res.distanceToDestination >= 1000 ?
            `距目的地 ${(res.distanceToDestination / 1000).toFixed(1)} 公里` :
            `距目的地 ${res.distanceToDestination} 米`;
        }
        // Agent 主动建议：needReplan=true 且 reason 与上次不同时弹卡片
        if (res.needReplan && res.reason && res.reason !== this.lastReason && !this.showSuggestion) {
          this.lastReason = res.reason;
          await this.fetchReplanSuggestion(res.reason);
        }
        this.errorText = '';
      }
    } catch (e) {
      this.errorText = `状态更新失败：${e}`;
      console.error(`JourneyPage refresh 失败: ${e}`);
    } finally {
      this.refreshing = false;
    }
  }

  /** 调后端 replan 获取建议方案，展示卡片。 */
  private async fetchReplanSuggestion(reason: string): Promise<void> {
    const store = getJourneyStore();
    if (!store.goal || !this.plan) {
      return;
    }
    try {
      const result = await ApiService.replan(store.goal, this.plan, {
        location: this.location ?? undefined,
        now: nowHHMM()
      });
      if (result) {
        this.replanResult = result;
        this.agentReason = reason;
        this.agentSuggestion = result.explanation || result.action || '检测到行程异常，建议切换方案';
        this.showSuggestion = true;
      }
    } catch (e) {
      console.error(`获取重规划建议失败: ${e}`);
    }
  }

  /** 用户采纳建议：切换方案并关闭卡片。 */
  private acceptSuggestion(): void {
    if (this.replanResult) {
      const store = getJourneyStore();
      store.currentPlan = this.replanResult.newPlan;
      this.plan = this.replanResult.newPlan;
    }
    this.showSuggestion = false;
    this.replanResult = null;
  }

  /** 用户忽略建议：关闭卡片，本次行程不再重复弹同一原因。 */
  private dismissSuggestion(): void {
    this.showSuggestion = false;
    this.replanResult = null;
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('行程状态')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
        Blank()
        Text('动态跟踪中').fontSize(12).fontColor(Colors.TEXT_SUB)
      }.width('100%')

      Column({ space: 10 }) {
        StatusBadge({ state: this.currentState })
        Text(this.nextAction)
          .fontSize(15).fontColor(Colors.TEXT).textAlign(TextAlign.Center).width('100%')
        if (this.distanceText.length > 0) {
          Text(this.distanceText).fontSize(12).fontColor(Colors.TEXT_SUB)
        }
      }
      .padding(20).width('100%')
      .backgroundColor(Colors.CARD).borderRadius(8)

      // Agent 建议卡片
      if (this.showSuggestion && this.replanResult) {
        Column({ space: 10 }) {
          Row() {
            Text('Agent 建议').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#B45309')
            Blank()
            Text(this.agentReason).fontSize(12).fontColor('#B45309')
          }.width('100%')
          Text(this.agentSuggestion)
            .fontSize(13).fontColor(Colors.TEXT).width('100%')
          if (this.replanResult.newPlan) {
            Text(`新方案：${this.replanResult.newPlan.durationMinutes}分钟 · ${this.replanResult.newPlan.cost}元 · ${this.replanResult.newPlan.riskLevel}风险`)
              .fontSize(12).fontColor(Colors.TEXT_SUB).width('100%')
          }
          if (this.replanResult.extraCost > 0) {
            Text(`额外费用 +${this.replanResult.extraCost}元`)
              .fontSize(12).fontColor('#B42318').width('100%')
          }
          Row({ space: 12 }) {
            Button('采纳')
              .layoutWeight(1).height(38).fontSize(14)
              .backgroundColor('#B45309').fontColor('#FFFFFF')
              .onClick(() => { this.acceptSuggestion(); })
            Button('忽略')
              .layoutWeight(1).height(38).fontSize(14)
              .backgroundColor(Colors.CARD).fontColor(Colors.TEXT_SUB)
              .border({ width: 1, color: Colors.TEXT_SUB })
              .onClick(() => { this.dismissSuggestion(); })
          }.width('100%')
        }
        .padding(16).width('100%')
        .backgroundColor('#FEF3C7').borderRadius(8)
        .border({ width: 1, color: '#FCD34D' })
      }

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(12).fontColor(Colors.RED).width('100%')
      }

      // 一键跳转外部应用
      if (this.plan) {
        Row({ space: 10 }) {
          Button('地图导航')
            .layoutWeight(1).height(40).fontSize(13)
            .backgroundColor(Colors.PRIMARY).fontColor('#FFFFFF')
            .onClick(() => {
              const store = getJourneyStore();
              const ctx = getContext(this) as common.UIAbilityContext;
              openMapNavigation(ctx, store.goal?.destination ?? '');
            })
          Button('一键打车')
            .layoutWeight(1).height(40).fontSize(13)
            .backgroundColor('#16A34A').fontColor('#FFFFFF')
            .onClick(() => {
              const store = getJourneyStore();
              const ctx = getContext(this) as common.UIAbilityContext;
              openRideHail(ctx, store.goal?.destination ?? '');
            })
        }.width('100%')
      }

      Blank()

      ActionBar({
        primaryText: '结束行程，查看总结',
        secondaryText: '刷新状态',
        onPrimary: () => { router.pushUrl({ url: 'pages/SummaryPage' }); },
        onSecondary: () => { this.refresh(); }
      })
    }
    .padding(20).width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }
}
