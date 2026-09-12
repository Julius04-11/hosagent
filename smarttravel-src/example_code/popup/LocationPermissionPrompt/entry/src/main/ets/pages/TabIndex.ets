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
import HomePageView from '../view/HomePageView';


@Entry
@Component
struct TabIndex {
  @State currentIndex: number = 0
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;

  @Builder
  tabBuilder(title: string | Resource, targetIndex: number, selectedImg: Resource, img: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : img)
        .size({ width: $r('app.float.vp_twenty_eight'), height: $r('app.float.vp_twenty_eight') })
        .objectFit(ImageFit.Contain)

      Text(title)
        .fontSize($r('app.float.vp_fourteen'))
        .margin({ top: $r('app.float.margin_top_three') })
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.tab_selected_color') : Color.Black)
    }
    .padding({ top: $r('app.float.margin_top_ten') })
    .width($r('app.string.full_width'))
    .height($r('app.string.full_height'))
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Column() {
            HomePageView()
          }
          .width($r('app.string.full_width'))
          .height($r('app.string.full_height'))
          .backgroundColor($r('app.color.tab_background_color'))
        }
        .tabBar(this.tabBuilder($r('app.string.home'), 0, $r('app.media.mainPage_selected'),
          $r('app.media.mainPage')
        ))

        TabContent() {
          Column() {
            Text($r('app.string.travel'))
          }
          .width($r('app.string.full_width'))
          .height($r('app.string.full_height'))
          .backgroundColor($r('app.color.tab_background_color'))
        }
        .tabBar(this.tabBuilder($r('app.string.travel'), 1, $r('app.media.travel_selected'),
          $r('app.media.travel')))

        TabContent() {
          Column() {
            Text($r('app.string.strategy'))
          }
          .width($r('app.string.full_width'))
          .height($r('app.string.full_height'))
          .backgroundColor($r('app.color.tab_background_color'))
        }
        .tabBar(this.tabBuilder($r('app.string.strategy'), 2, $r('app.media.strategy_selected'),
          $r('app.media.strategy')))

        TabContent() {
          Column() {
            Text($r('app.string.personal'))
          }
          .width($r('app.string.full_width'))
          .height($r('app.string.full_height'))
          .backgroundColor($r('app.color.tab_background_color'))
        }
        .tabBar(this.tabBuilder($r('app.string.personal'), 3, $r('app.media.personal_selected'),
          $r('app.media.personal')))
      }.onChange((index: number) => {
        this.currentIndex = index
      })
      .onContentWillChange(() => {
        return false
      })
    }
    .width($r('app.string.full_width'))
    .height($r('app.string.full_height'))
    .backgroundColor($r('app.color.home_background_color'))
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })

  }
}