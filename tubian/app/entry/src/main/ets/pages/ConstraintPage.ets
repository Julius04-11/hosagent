/**
 * 约束补充页：预算、行李、偏好、是否接受网约车（需求文档 §7.2）。
 */
import router from '@ohos.router';
import { ApiService } from '../services/ApiService';
import { getJourneyStore } from '../stores/JourneyStore';
import { TravelPreference, PREFERENCE_OPTIONS } from '../models/TravelGoal';
import { ActionBar } from '../components/ActionBar';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct ConstraintPage {
  @State budget: string = '';
  @State luggage: boolean = false;
  @State preference: TravelPreference = '准时优先';
  @State acceptRideHail: boolean = true;

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('补充出行偏好')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
        Blank()
        Text('第 2 步').fontSize(12).fontColor(Colors.TEXT_SUB)
      }.width('100%')

      Text('预算上限（元，可不填）').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 300', text: this.budget })
        .type(InputType.Number).fontSize(15)
        .onChange((v: string) => { this.budget = v; })

      Row() {
        Text('携带行李').fontSize(15).fontColor(Colors.TEXT).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.luggage })
          .onChange((isOn: boolean) => { this.luggage = isOn; })
      }.width('100%')

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

      Row() {
        Text('接受网约车').fontSize(15).fontColor(Colors.TEXT).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.acceptRideHail })
          .onChange((isOn: boolean) => { this.acceptRideHail = isOn; })
      }.width('100%')

      Blank()

      ActionBar({
        primaryText: '生成方案',
        onPrimary: () => { this.plan(); }
      })
    }
    .padding(20)
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  async plan(): Promise<void> {
    const store = getJourneyStore();
    if (store.goal) {
      store.goal.budget = this.budget.length > 0 ? Number(this.budget) : undefined;
      store.goal.luggage = this.luggage;
      store.goal.preference = this.preference;
    }
    if (store.goal) {
      const res = await ApiService.planRoute(store.goal);
      store.mainPlan = res.mainPlan;
      store.backupPlans = res.backupPlans;
      store.currentPlan = res.mainPlan;
      router.pushUrl({ url: 'pages/PlanPage' });
    }
  }
}
