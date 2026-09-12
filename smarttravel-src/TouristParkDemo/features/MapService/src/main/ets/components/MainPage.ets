/*
 *
 *    Copyright (c) 2025 Huawei Device Co., Ltd.
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 *
 */

import { common, Want } from '@kit.AbilityKit'

@CustomDialog
export struct CustomDialogExample2 {
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  @State distinction: string = '';
  @State distinclat: number = 0;
  @State distinclon: number = 0;
  build() {
    Column() {
      Text('导航去' + this.distinction)
        .fontSize(30)
        .height(100)
      Button('开始导航')
        .onClick(() => {
          let petalMapWant: Want = {
            bundleName: 'com.huawei.hmos.maps.app',
            uri: 'maps://navigation',
            parameters: {
              linkSource: 'com.example.touristparkdemo',
              destinationLatitude: this.distinclat,
              destinationLongitude: this.distinclon,
              destinationName: this.distinction,
              vehicleType: 0
            }
          }
          let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          context.startAbility(petalMapWant);
        })
        .margin(20)
    }
  }
}

@Component
export struct MainPage {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
