/**
 * 权限与设置页（需求文档 §12 / §6.4）。
 */
import router from '@ohos.router';
import { getJourneyStore } from '../stores/JourneyStore';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct SettingsPage {
  @State locationOn: boolean = false;
  @State notificationOn: boolean = false;

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('权限与设置')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
          Blank()
          Text('返回').fontSize(13).fontColor(Colors.PRIMARY)
            .onClick(() => { router.back(); })
        }.width('100%')

        this.permissionCard('定位权限', '用于判断你是否已经出发、是否接近换乘点或目的地。', this.locationOn,
          (v: boolean) => { this.locationOn = v; })
        this.permissionCard('通知权限', '用于在出发、换乘、天气突变或计划失效时提醒你。', this.notificationOn,
          (v: boolean) => { this.notificationOn = v; })

        Column({ space: 10 }) {
          Text('隐私说明')
            .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT).width('100%')
          Text('只保存当前行程和用户偏好，不保存长期定位轨迹，不上传无关个人信息。')
            .fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
        }
        .padding(16).width('100%')
        .backgroundColor(Colors.CARD).borderRadius(8)

        Button('清除本地行程数据')
          .width('100%').height(44)
          .backgroundColor('#FEF2F2').fontColor(Colors.RED)
          .onClick(() => { this.clearData(); })
      }
      .padding(20)
    }
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  @Builder
  permissionCard(title: string, desc: string, on: boolean, onChange: (v: boolean) => void) {
    Column({ space: 8 }) {
      Row() {
        Text(title).fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: on }).onChange((v: boolean) => { onChange(v); })
      }.width('100%')
      Text(desc).fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
    }
    .padding(16).width('100%')
    .backgroundColor(Colors.CARD).borderRadius(8)
  }

  clearData(): void {
    const store = getJourneyStore();
    store.goal = undefined;
    store.mainPlan = undefined;
    store.backupPlans = [];
    store.currentPlan = undefined;
    store.replanResult = undefined;
    store.currentState = '出发准备';
  }
}
