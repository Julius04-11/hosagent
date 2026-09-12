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

import web_webview from '@ohos.web.webview';

@Builder
export function NoticeBuilder() {
  Notice()
}

@Component
export struct Notice {
  @Consume('pageStack') pageStack: NavPathStack;
  controller: web_webview.WebviewController = new web_webview.WebviewController

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
      Column() {
        Divider()
          .strokeWidth(15)
          .color('#fff1ebeb')// 设置顶部绘制延伸到状态栏
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

        Flex() {
          Web({ src: $rawfile("userIndex.html"), controller: this.controller })
            .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }
}