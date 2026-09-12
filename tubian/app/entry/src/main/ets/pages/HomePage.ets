/**
 * 首页 / 目标输入页（需求文档 §6.4）。
 * 支持：真实定位 + 可手动更改当前城市；目标缺出发地时默认使用当前城市。
 */
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { ApiService } from '../services/ApiService';
import { LocationService } from '../services/LocationService';
import { getJourneyStore } from '../stores/JourneyStore';
import { Colors } from '../utils/StyleConstants';

const QUICK_TAGS: string[] = ['赶高铁', '看演唱会', '去机场', '酒店入住', '带行李', '少步行'];

@Entry
@Component
struct HomePage {
  @State input: string = '';
  @State city: string = '杭州';
  @State locationText: string = '未定位';

  aboutToAppear(): void {
    const store = getJourneyStore();
    this.city = store.currentCity;
    this.detectLocation();
  }

  async detectLocation(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const granted = await LocationService.requestPermission(context);
    if (!granted) {
      this.locationText = '未授权定位，请允许权限后重新定位';
      return;
    }
    const loc = await LocationService.getCurrentLocation();
    const store = getJourneyStore();
    if (loc) {
      store.location = loc;
      store.locationEnabled = true;
      this.locationText = `已定位 (${loc.lat.toFixed(2)}, ${loc.lng.toFixed(2)})`;
    } else {
      store.locationEnabled = false;
      this.locationText = `定位失败 ${LocationService.lastError}`;
    }
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('途变')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT)
        Blank()
        Column({ space: 2 }) {
          Text(`📍 ${this.city}`)
            .fontSize(14).fontColor(Colors.PRIMARY)
          Text(this.locationText)
            .fontSize(10).fontColor(Colors.TEXT_SUB)
        }.alignItems(HorizontalAlign.End)
      }.width('100%').margin({ top: 8 })

      // 可更改的当前城市 + 定位
      Row({ space: 8 }) {
        Text('当前城市').fontSize(13).fontColor(Colors.TEXT_SUB)
        TextInput({ placeholder: '例如 上海', text: this.city })
          .layoutWeight(1).fontSize(14).height(40)
          .onChange((v: string) => { this.city = v; })
        Button('重新定位')
          .fontSize(12).height(36)
          .backgroundColor(Colors.PRIMARY).fontColor('#FFFFFF')
          .onClick(() => { this.detectLocation(); })
      }.width('100%')

      Text('一句话说出你的出行目标')
        .fontSize(14).fontColor(Colors.TEXT_SUB).width('100%')

      TextArea({
        placeholder: '例如：我明天去上海看演唱会，晚上7点前必须入场',
        text: this.input
      })
        .height(120).fontSize(15)
        .onChange((v: string) => { this.input = v; })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(QUICK_TAGS, (tag: string) => {
          Text(tag)
            .fontSize(13).fontColor(Colors.PRIMARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(Colors.PRIMARY + '14')
            .borderRadius(16)
            .margin(4)
            .onClick(() => {
              this.input = this.input.length > 0 ? `${this.input}，${tag}` : tag;
            })
        }, (tag: string) => tag)
      }.width('100%')

      Blank()

      Button('开始规划')
        .width('100%').height(46)
        .backgroundColor(this.input.trim().length > 0 ? Colors.PRIMARY : '#C7D2FE')
        .fontColor('#FFFFFF')
        .enabled(this.input.trim().length > 0)
        .onClick(() => { this.startPlan(); })
    }
    .padding(20)
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  async startPlan(): Promise<void> {
    const store = getJourneyStore();
    store.currentCity = this.city.trim().length > 0 ? this.city.trim() : '杭州';
    store.loading = true;
    const res = await ApiService.parseGoal(this.input);
    // 目标未指定出发地时，默认用当前城市
    if (!res.goal.origin || res.goal.origin.trim().length === 0) {
      res.goal.origin = store.currentCity;
    }
    store.goal = res.goal;
    store.loading = false;
    router.pushUrl({ url: 'pages/ConstraintPage', params: { missingFields: res.missingFields } });
  }
}
