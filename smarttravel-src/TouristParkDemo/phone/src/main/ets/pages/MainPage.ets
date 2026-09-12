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

import { BreakpointConstants, BreakpointSystem, StyleConstants } from '@ohos/common';
import { buttonInfo, ButtonInfoModel } from '../viewmodel/MainPageData';
import { Home } from '@ohos/home';
import { ParkVisiting } from '@ohos/parkService';
import { MapPage } from '@ohos/mapService';
import { Personal } from '@ohos/personalCenter';

@Entry
@Component
struct MainPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @StorageLink('IndexPage') currentPageIndex: number = 0;
  private breakpointSystem = new BreakpointSystem();
  @State tabArray: Array<number> = [0, 1, 2];
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  aboutToAppear() {
    this.breakpointSystem.register(this.getUIContext());
  }

  @Builder
  buildTab(button: ButtonInfoModel, tabIndex: number) {
    Column() {
      Image(this.currentPageIndex === tabIndex ? button.selectImg : button.img)
        .objectFit(ImageFit.Contain)
        .width('28vp')
        .height('28vp')
      Text(button.title)
        .fontColor(this.currentPageIndex === tabIndex ? '#0A57F9' : Color.Black)
        .opacity(this.currentPageIndex === tabIndex ? 1 : 0.6)
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .fontSize(12)
    }
    .width('20%')
    .height(StyleConstants.FULL_HEIGHT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentPageIndex = tabIndex;
    })
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Tabs({
            barPosition: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? BarPosition.Start :
            BarPosition.End,
            index: this.currentPageIndex
          }) {
            TabContent() {
              Home({})
            }

            TabContent() {
              ParkVisiting({})
            }

            TabContent() {
              MapPage({})
            }

            TabContent() {
              Personal()
            }
          }
          .barHeight(0)
          .scrollable(false)
          .animationDuration(0)
          .onChange((index: number) => {
            this.currentPageIndex = index;
          })

          // 页签
          Row() {
            Scroll() {
              Row() {
                ForEach(buttonInfo, (item: ButtonInfoModel, index: number) => {
                  this.buildTab(item, index)
                })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height('50vp')
          .backgroundColor(Color.White)
          .backgroundImageSize({ width: '100%', height: '100%' })
        }
        .backgroundColor($r('app.color.page_background'))
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}