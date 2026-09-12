/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import AbilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { bundleManager, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StyleConstant } from '../constant/StyleConstant';

class CommonConstants {
  /**
   * Permissions.
   */
  static readonly LOCATION: Permissions = 'ohos.permission.LOCATION';
  static readonly APPROXIMATELY_LOCATION: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';
}

@Component
export default struct LocationPopup {
  @Prop
  locationText: Resource;
  @State
  handlePopup: boolean = false;

  async aboutToAppear() {
    await this.checkPermissions()
  }

  async checkPermissions(): Promise<void> {
    const permissions: Array<Permissions> = [
      CommonConstants.LOCATION,
      CommonConstants.APPROXIMATELY_LOCATION
    ];
    for (let i = 0; i < 2; i++) {
      let grantStatus: AbilityAccessCtrl.GrantStatus = await this.checkAccessToken(permissions[i]);
      if (grantStatus !== AbilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.handlePopup = true
      } else {
        this.handlePopup = false
      }
    }
  }

  //获取授权TokenID
  async checkAccessToken(permission: Permissions) {
    let atManager = AbilityAccessCtrl.createAtManager();
    let grantStatus: AbilityAccessCtrl.GrantStatus;
    let tokenID: number;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenID = appInfo.accessTokenId;
    } catch (err) {
      hilog.error(0x0000, 'getBundleInfoForSelf failed', `error: ${err}`);
    }

    try {
      grantStatus = await atManager.checkAccessToken(tokenID!, permission);
    } catch (err) {
      hilog.error(0x0000, 'checkAccessToken failed', `error: ${err}`);
    }
    return grantStatus!;
  }

  async requestPermissions() {
    const permissions: Array<Permissions> = [
      CommonConstants.LOCATION,
      CommonConstants.APPROXIMATELY_LOCATION
    ];
    let atManager = AbilityAccessCtrl.createAtManager();
    let context = this.getUIContext().getHostContext() as Context;
    await atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      hilog.info(0x0000, 'succeed', `Request permissions succeed, data is: ${data}`);
      let showResults = data.dialogShownResults as []
      for (let i = 0; i < showResults?.length; i++) {
        if (showResults[i] === false) { // 拒绝授权
          let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          context.startAbility({
            bundleName: 'com.huawei.hmos.settings',
            abilityName: 'com.huawei.hmos.settings.MainAbility', //显示跳转设置内的页面ability统一传这个
            uri: 'location_manager_settings',
            parameters: {
              pushParams: {
                bundleName: context.abilityInfo.bundleName//传要跳转的对应应用的包名
              }
            }
          });
          return;
        }
      }
    }).catch((error: Error) => {
      hilog.error(0x0000, 'failed', `Request permissions failed, error is: ${error}`);
    });
  }

  @Builder
  locationPopupBuilder() {
    Row({ space: StyleConstant.SPACE_TWO }) {
      Text($r('app.string.popup_text'))
        .fontColor(Color.White)
        .height($r('app.float.forty'))
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .width($r('app.string.popup_text_width'))
      Button($r('app.string.pop_button_text'))
        .backgroundColor('#0A59F7')
        .controlSize(ControlSize.SMALL)
        .margin({ left: $r('app.float.vp_five') })
        .onClick(() => {
          this.requestPermissions()
        })
      Image($r('app.media.ic_fork'))
        .width($r('app.float.vp_fifteen'))
        .height($r('app.float.vp_fifteen'))
        .onClick(() => {
          this.handlePopup = false;
        })
    }
    .width($r('app.string.full_width'))
    .padding({ left: $r('app.float.vp_fifteen'), right: $r('app.float.vp_fifteen') })
    .borderRadius(StyleConstant.SEVEN_BORDER_RADIUS)
    .zIndex(StyleConstant.FIVE_HUNDRED)
  }

  build() {
    Column() {
      Text(this.locationText)
        .width($r('app.float.vp_forty'))
        .fontColor(Color.Grey)
        .fontSize($r('app.float.vp_fourteen'))
        .fontWeight(StyleConstant.FOUR_HUNDRED)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width($r('app.float.vp_forty'))
        .maxLines(StyleConstant.TEXT_MAX_LINES)
        .bindPopup(this.handlePopup, {
          builder: this.locationPopupBuilder,
          placement: Placement.Bottom,
          offset: { x: StyleConstant.ZERO, y: StyleConstant.ZERO },
          enableArrow: true,
          showInSubWindow: true,
          autoCancel: true,
          popupColor: 'rgba(56, 55, 54,0.9)',
          backgroundBlurStyle: BlurStyle.NONE,
          width: $r('app.string.popup_width'),
          radius: StyleConstant.THREE,
          onStateChange: (e) => {
            hilog.info(0x0000, 'isVisible', JSON.stringify(e.isVisible))
            if (!e.isVisible) {
              this.handlePopup = false
            }
          }
        })
    }
  }
}


