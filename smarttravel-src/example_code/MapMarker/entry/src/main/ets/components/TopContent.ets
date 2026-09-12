/*
 *
 *     Copyright (c) 2025 Huawei Device Co., Ltd.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *
 */

@Component
export struct TopContent {
  @StorageProp('topRectHeight') topRectHeight: number = 0 //获取状态栏顶部区域高度
  private context: UIContext = this.getUIContext()

  build() {
    Stack() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Image($r('app.media.back'))
          .width(42)
          .margin({
            right: 12,
          })
        Text($r('app.string.food_map'))
          .fontColor('#e6000000')
          .fontSize(20)
          .fontWeight(700)
      }
      .margin({
        top: 10,
        left: 16,
      })
    }
    .padding({ top: this.context.px2vp(this.topRectHeight) })
    .width('100%')
    .align(Alignment.Top)
    .alignSelf(ItemAlign.Start)
  }
}