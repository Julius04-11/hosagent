/**
 * 行程状态页：定位驱动的动态跟踪（需求文档 §7.6 / §7.7）。
 * - 轮询真实定位，实时上报后端，返回当前阶段 + 具体下一步动作；
 * - 检测到需要重规划（偏离路线/错过出发/天气突变）时自动跳转重规划页；
 * - 提供「模拟位置变化」按钮，方便无真机 GPS 时演示动态规划。
 */
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { ApiService } from '../services/ApiService';
import { LocationService } from '../services/LocationService';
import { getJourneyStore } from '../stores/JourneyStore';
import { JourneyState } from '../models/JourneyState';
import { RoutePlan } from '../models/RoutePlan';
import { LocationData } from '../models/ReplanResult';
import { StatusBadge } from '../components/StatusBadge';
import { ActionBar } from '../components/ActionBar';
import { nowHHMM } from '../utils/TimeUtil';
import { Colors } from '../utils/StyleConstants';

interface DemoLocation {
  label: string;
  loc: LocationData;
}

const DEMO_LOCATIONS: DemoLocation[] = [
  { label: '出发地·杭州东站', loc: { lat: 30.291, lng: 120.211 } },
  { label: '换乘点·上海虹桥站', loc: { lat: 31.197, lng: 121.326 } },
  { label: '偏离路线', loc: { lat: 30.0, lng: 119.0 } },
  { label: '目的地·场馆', loc: { lat: 31.231, lng: 121.475 } }
];

@Entry
@Component
struct JourneyPage {
  @State currentState: JourneyState = '出发准备';
  @State nextAction: string = '准备出发...';
  @State distanceText: string = '';
  @State plan: RoutePlan | null = null;
  @State location: LocationData | null = null;
  @State useDemoLocation: boolean = false;
  private timerId: number = -1;
  private navigating: boolean = false;

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.plan = store.currentPlan ?? store.mainPlan ?? null;
    this.requestLocationPermission();
    this.refresh();
    this.timerId = setInterval(() => { this.refresh(); }, 5000);
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  requestLocationPermission(): void {
    const context = getContext(this) as common.UIAbilityContext;
    LocationService.requestPermission(context).then((granted: boolean) => {
      if (granted) {
        this.refresh();
      }
    });
  }

  async refresh(): Promise<void> {
    // 未使用演示定位时，轮询真实定位做动态跟踪
    if (!this.useDemoLocation) {
      const loc = await LocationService.getCurrentLocation();
      if (loc) {
        this.location = loc;
      }
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
      if (res.needReplan && !this.navigating) {
        this.navigating = true;
        await this.triggerReplan();
      }
    }
  }

  async triggerReplan(): Promise<void> {
    const store = getJourneyStore();
    if (store.goal && this.plan) {
      const result = await ApiService.replan(store.goal, this.plan, {
        location: this.location ?? undefined,
        now: nowHHMM()
      });
      if (result) {
        store.replanResult = result;
        router.pushUrl({ url: 'pages/ReplanPage' });
      }
    }
  }

  async simulateRain(): Promise<void> {
    const store = getJourneyStore();
    if (store.goal && this.plan) {
      const result = await ApiService.replan(store.goal, this.plan,
        { weather: { city: '上海', weather: '暴雨', warning: '暴雨黄色预警' } });
      if (result) {
        store.replanResult = result;
        router.pushUrl({ url: 'pages/ReplanPage' });
      }
    }
  }

  setDemoLocation(entry: DemoLocation): void {
    this.useDemoLocation = true;
    this.location = entry.loc;
    this.refresh();
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

      Text('模拟位置变化（演示动态跟踪）')
        .fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(DEMO_LOCATIONS, (entry: DemoLocation) => {
          Text(entry.label)
            .fontSize(12).fontColor(Colors.PRIMARY)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Colors.PRIMARY + '14')
            .borderRadius(14)
            .margin(4)
            .onClick(() => { this.setDemoLocation(entry); })
        }, (entry: DemoLocation) => entry.label)
      }.width('100%')

      Blank()

      Column({ space: 10 }) {
        Button('模拟暴雨触发重规划')
          .width('100%').height(44)
          .backgroundColor(Colors.ORANGE).fontColor('#FFFFFF')
          .onClick(() => { this.simulateRain(); })

        ActionBar({
          primaryText: '结束行程，查看总结',
          secondaryText: '刷新状态',
          onPrimary: () => { router.pushUrl({ url: 'pages/SummaryPage' }); },
          onSecondary: () => { this.refresh(); }
        })
      }
    }
    .padding(20).width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }
}
