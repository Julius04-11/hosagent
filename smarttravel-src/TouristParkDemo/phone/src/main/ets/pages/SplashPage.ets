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

import { StyleConstants, BreakpointSystem ,PageConstants } from '@ohos/common';
import Logger from '@ohos/common/src/main/ets/utils/Logger';

@Entry
@Component
struct SplashPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  private breakpointSystem = new BreakpointSystem();
  private timeOutId: number = 3000;

  build() {
    Flex({direction: FlexDirection.Column, alignItems: ItemAlign.Center}){
      Column() {
        Image($r('app.media.backgroundImage'))
          .height(StyleConstants.FULL_HEIGHT)
          .width(StyleConstants.FULL_WIDTH)
          .objectFit(ImageFit.Fill)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .flexGrow(1)
    }
    .height(StyleConstants.FULL_HEIGHT)
    .width(StyleConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.page_background'))
  }

  aboutToAppear() {
    this.breakpointSystem.register(this.getUIContext());
    //自动跳转MainPage
    this.timeOutId = setTimeout( ()=>{
      this.getUIContext().getRouter().replaceUrl({
        url:PageConstants.MAIN_PAGE_URL
      })
        .catch((err: Error) =>{
          Logger.info(JSON.stringify(err));
        })
    }, this.timeOutId);
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }
}