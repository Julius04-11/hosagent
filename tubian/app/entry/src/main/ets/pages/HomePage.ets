/**
 * 首页：出发地+目的地输入 → 直达约束/偏好页。
 * 支持：真实定位预填出发地、手动修改城市。
 */
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { ApiService } from '../services/ApiService';
import { LocationService } from '../services/LocationService';
import { getJourneyStore } from '../stores/JourneyStore';
import { emptyGoal } from '../models/TravelGoal';
import { Colors } from '../utils/StyleConstants';

@Entry
@Component
struct HomePage {
  @State origin: string = '';
  @State destination: string = '';
  @State city: string = '杭州';
  @State locationText: string = '未定位';
  @State errorText: string = '';

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
      try {
        const address = await ApiService.reverseGeocode(loc);
        const city = address.city.trim();
        if (city.length > 0) {
          this.city = city;
          store.currentCity = city;
          // 定位成功后自动预填出发地为当前城市
          if (this.origin.trim().length === 0) {
            this.origin = city;
          }
          this.locationText = address.formattedAddress ?
            `已定位 ${address.formattedAddress}` : `已定位 ${city}`;
        }
      } catch (e) {
        this.locationText = `已定位坐标，城市反查失败 ${e}`;
      }
    } else {
      store.locationEnabled = false;
      this.locationText = LocationService.lastError.length > 0 ? LocationService.lastError : '定位失败，请点击"重新定位"';
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

      // 定位 + 当前城市
      Row({ space: 8 }) {
        Text('当前城市').fontSize(13).fontColor(Colors.TEXT_SUB)
        TextInput({ placeholder: '例如 桂林', text: this.city })
          .layoutWeight(1).fontSize(14).height(40)
          .onChange((v: string) => { this.city = v; })
        Button('重新定位')
          .fontSize(12).height(36)
          .backgroundColor(Colors.PRIMARY).fontColor('#FFFFFF')
          .onClick(() => { this.detectLocation(); })
      }.width('100%')

      Text('出行规划')
        .fontSize(14).fontColor(Colors.TEXT_SUB).width('100%')
        .margin({ top: 8 })

      // 出发地
      Text('出发地').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 桂林电子科技大学', text: this.origin })
        .fontSize(15).height(44)
        .onChange((v: string) => { this.origin = v; })

      // 目的地
      Text('目的地').fontSize(13).fontColor(Colors.TEXT_SUB).width('100%')
      TextInput({ placeholder: '例如 桂林高兴万达', text: this.destination })
        .fontSize(15).height(44)
        .onChange((v: string) => { this.destination = v; })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(13)
          .fontColor('#B42318')
          .width('100%')
      }

      Blank()

      Button('开始规划')
        .width('100%').height(46)
        .backgroundColor(this.origin.trim().length > 0 && this.destination.trim().length > 0 ? Colors.PRIMARY : '#C7D2FE')
        .fontColor('#FFFFFF')
        .enabled(this.origin.trim().length > 0 && this.destination.trim().length > 0)
        .onClick(() => { this.startPlan(); })
    }
    .padding(20)
    .width('100%').height('100%')
    .backgroundColor(Colors.BG)
  }

  startPlan(): void {
    const store = getJourneyStore();
    store.currentCity = this.city.trim().length > 0 ? this.city.trim() : '杭州';
    // 直接构造 TravelGoal，不再调 parse-goal
    const goal = emptyGoal();
    goal.origin = this.origin.trim();
    goal.destination = this.destination.trim();
    store.goal = goal;
    router.pushUrl({ url: 'pages/ConstraintPage' });
  }
}
