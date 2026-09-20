/**
 * 偏好设置页：时间/预算/交通方式/出行习惯/行李（需求文档 §7.2）。
 */
import router from '@ohos.router';
import { ApiService } from '../services/ApiService';
import { getJourneyStore } from '../stores/JourneyStore';
import {
  TravelPreference, PREFERENCE_OPTIONS,
  TransportMode, TRANSPORT_MODES,
  TravelProfile
} from '../models/TravelGoal';
import { ActionBar } from '../components/ActionBar';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct ConstraintPage {
  @State origin: string = '';
  @State destination: string = '';
  @State departureTime: string = '';
  @State deadline: string = '23:00';
  @State budget: string = '';
  @State luggage: boolean = false;
  @State preference: TravelPreference = '准时优先';
  @State acceptRideHail: boolean = true;
  @State selectedModes: TransportMode[] = [];
  @State profile: TravelProfile = {
    motionSick: false,
    heavyLuggage: false,
    withElderly: false,
    budgetSensitive: false,
    timeSensitive: false
  };
  @State errorText: string = '';

  aboutToAppear(): void {
    const store = getJourneyStore();
    if (store.goal) {
      this.origin = store.goal.origin;
      this.destination = store.goal.destination;
      this.departureTime = store.goal.departureTime ?? '';
      this.deadline = store.goal.deadline;
      this.budget = store.goal.budget === undefined ? '' : `${store.goal.budget}`;
      this.luggage = store.goal.luggage;
      this.preference = store.goal.preference;
      this.acceptRideHail = store.goal.acceptRideHail ?? true;
      this.selectedModes = store.goal.transportModes ?? [];
      this.profile = store.goal.travelProfile ?? this.profile;
    }
  }

  private toggleMode(mode: TransportMode): void {
    const idx = this.selectedModes.indexOf(mode);
    if (idx >= 0) {
      this.selectedModes.splice(idx, 1);
    } else {
      this.selectedModes.push(mode);
    }
    // ArkTS 不支持展开运算符，用 slice 触发数组引用变更
    this.selectedModes = this.selectedModes.slice();
  }

  build() {
    Scroll() {
    Column({ space: 14 }) {
      Row() {
        Text('出行偏好')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
        Blank()
        Text('第 2 步').fontSize(12).fontColor(Colors.TEXT_SUB)
      }.width('100%')

      // 时间设置
      Text('计划出发时间（可不填）').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 16:30', text: this.departureTime })
        .fontSize(15).height(40)
        .onChange((v: string) => { this.departureTime = v; })

      Text('最晚到达时间').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 23:00', text: this.deadline })
        .fontSize(15).height(40)
        .onChange((v: string) => { this.deadline = v; })

      Text('预算上限（元，可不填）').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 300', text: this.budget })
        .type(InputType.Number).fontSize(15).height(40)
        .onChange((v: string) => { this.budget = v; })

      // 交通方式偏好
      Text('偏好交通方式（可多选，不选则不限）').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(TRANSPORT_MODES, (mode: TransportMode) => {
          Text(mode)
            .fontSize(13)
            .fontColor(this.selectedModes.includes(mode) ? '#FFFFFF' : Colors.PRIMARY)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedModes.includes(mode) ? Colors.PRIMARY : Colors.PRIMARY + '14')
            .borderRadius(18)
            .margin(4)
            .onClick(() => { this.toggleMode(mode); })
        }, (mode: TransportMode) => mode)
      }.width('100%')

      // 出行偏好
      Text('出行偏好').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(PREFERENCE_OPTIONS, (opt: TravelPreference) => {
          Text(opt)
            .fontSize(13)
            .fontColor(this.preference === opt ? '#FFFFFF' : Colors.PRIMARY)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.preference === opt ? Colors.PRIMARY : Colors.PRIMARY + '14')
            .borderRadius(18)
            .margin(4)
            .onClick(() => { this.preference = opt; })
        }, (opt: TravelPreference) => opt)
      }.width('100%')

      // 出行习惯画像
      Text('出行习惯').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      Column({ space: 0 }) {
        this.profileRow('晕车', this.profile.motionSick, (v: boolean) => { this.profile.motionSick = v; })
        this.profileRow('大件行李', this.profile.heavyLuggage, (v: boolean) => { this.profile.heavyLuggage = v; })
        this.profileRow('带老人/小孩', this.profile.withElderly, (v: boolean) => { this.profile.withElderly = v; })
        this.profileRow('预算敏感', this.profile.budgetSensitive, (v: boolean) => { this.profile.budgetSensitive = v; })
        this.profileRow('时间敏感', this.profile.timeSensitive, (v: boolean) => { this.profile.timeSensitive = v; })
      }.width('100%').backgroundColor(Colors.CARD).borderRadius(8).padding({ left: 16, right: 16 })

      // 其他选项
      Row() {
        Text('携带行李').fontSize(15).fontColor(Colors.TEXT).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.luggage })
          .onChange((isOn: boolean) => { this.luggage = isOn; })
      }.width('100%')

      Row() {
        Text('接受网约车').fontSize(15).fontColor(Colors.TEXT).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.acceptRideHail })
          .onChange((isOn: boolean) => { this.acceptRideHail = isOn; })
      }.width('100%')

      Blank()

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(13)
          .fontColor('#B42318')
          .width('100%')
      }

      ActionBar({
        primaryText: '生成方案',
        onPrimary: () => { this.plan(); }
      })
    }
    .padding(20)
    .width('100%')
    .backgroundColor(Colors.BG)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  @Builder
  profileRow(label: string, isOn: boolean, onChange: (v: boolean) => void) {
    Row() {
      Text(label).fontSize(15).fontColor(Colors.TEXT).layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .onChange((v: boolean) => { onChange(v); })
    }.width('100%').height(44)
  }

  async plan(): Promise<void> {
    const store = getJourneyStore();
    if (store.goal) {
      store.goal.origin = this.origin.trim();
      store.goal.destination = this.destination.trim();
      store.goal.departureTime = this.departureTime.trim().length > 0 ? this.departureTime.trim() : undefined;
      store.goal.deadline = this.deadline.trim().length > 0 ? this.deadline.trim() : '23:59';
      store.goal.budget = this.budget.length > 0 ? Number(this.budget) : undefined;
      store.goal.luggage = this.luggage;
      store.goal.preference = this.preference;
      store.goal.acceptRideHail = this.acceptRideHail;
      store.goal.transportModes = this.selectedModes.slice();
      store.goal.travelProfile = {
        motionSick: this.profile.motionSick,
        heavyLuggage: this.profile.heavyLuggage,
        withElderly: this.profile.withElderly,
        budgetSensitive: this.profile.budgetSensitive,
        timeSensitive: this.profile.timeSensitive
      };
    }
    if (store.goal) {
      if (store.goal.origin.length === 0 || store.goal.destination.length === 0) {
        this.errorText = '请先补全出发地和目的地';
        return;
      }
      try {
        this.errorText = '';
        const res = await ApiService.planRoute(store.goal);
        store.mainPlan = res.mainPlan;
        store.backupPlans = res.backupPlans;
        store.currentPlan = res.mainPlan;
        store.riskTips = res.riskTips ?? [];
        router.pushUrl({ url: 'pages/PlanPage' });
      } catch (e) {
        this.errorText = `${e}`;
      }
    }
  }
}
