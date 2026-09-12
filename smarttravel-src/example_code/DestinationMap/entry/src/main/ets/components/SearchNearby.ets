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

import { map } from '@kit.MapKit';
import { CommonConstants } from '../constants/CommonConstants';
import { MetroInfo } from '../model/MetroStationModel';
import { MarkerViewModel } from '../viewmodel/MarkerViewModel';

@Component
export struct SearchNearby {
  // 列表高度
  @State curHeight: string = CommonConstants.LIST_HEIGHT_FOLD;
  // 当前索引
  @State curIndex: number = -1;
  @Prop metros: MetroInfo[];
  private scroller: ListScroller = new ListScroller();
  private markerVM: MarkerViewModel = MarkerViewModel.instance

  aboutToAppear(): void {
    this.markerVM.markerClickCallback = (marker: map.Marker) => {
      this.curIndex = this.markerVM.searchMarkers.indexOf(marker)
      this.curHeight = CommonConstants.LIST_HEIGHT_FOLD
      this.scroller.scrollToIndex(this.curIndex)
      this.markerVM.moveCamera(marker);
    }
  }

  // 修改列表高度
  expanding(offset: number) {
    if (offset > 0 && this.curHeight !== CommonConstants.LIST_HEIGHT_FOLD) {
      this.curHeight = CommonConstants.LIST_HEIGHT_FOLD;
    } else if (offset < 0 && this.curHeight !== CommonConstants.LIST_HEIGHT_EXPAND) {
      this.curHeight = CommonConstants.LIST_HEIGHT_EXPAND;
    }
  }

  build() {
    Column({ space: CommonConstants.PUBLIC_SPACE_MD }) {

      this.barBuilder()

      this.nearbyBuilder()

      this.listBuilder()
    }
    .height(this.curHeight)
    .width(CommonConstants.FULL_SIZE)
    .backgroundColor(Color.White)
    .border({
      width: { bottom: 1 },
      color: Color.Gray,
      radius: { topLeft: CommonConstants.BORDER_RADIUS_LARGE, topRight: CommonConstants.BORDER_RADIUS_LARGE }
    })
    .padding({
      left: CommonConstants.PADDING,
      right: CommonConstants.PADDING,
      bottom: CommonConstants.PADDING
    })
    .clip(true)
    .animation({ duration: CommonConstants.EXPANDING_DURATION })
    .gesture(
      PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          this.expanding(event.offsetY);
        })
    )
  }

  @Builder
  barBuilder() {
    Row() {
      Row()
        .width(CommonConstants.LIST_BAR_WIDTH)
        .height(CommonConstants.LIST_BAR_HEIGHT)
        .borderRadius(CommonConstants.BORDER_RADIUS_BAR)
        .backgroundColor($r('sys.color.icon_fourth'))
    }
    .width(CommonConstants.FULL_SIZE)
    .height(CommonConstants.IC_BACK_WIDTH)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
    .padding({ top: CommonConstants.PADDING_LARGE / 2 })
  }

  @Builder
  nearbyBuilder() {
    Text($r('app.string.nearby_list_title'))
      .fontSize(CommonConstants.FONT_SIZE_LARGE)
      .fontWeight(FontWeight.Medium)
      .width(CommonConstants.FULL_SIZE)
  }

  @Builder
  listBuilder() {
    List({ space: CommonConstants.PUBLIC_SPACE, scroller: this.scroller }) {
      ForEach(this.metros, (item: MetroInfo, index) => {
        ListItem() {
          Row() {
            Column() {
              Text(item.name).fontWeight(CommonConstants.FONT_WEIGHT)
              Text(item.address)
                .fontSize(CommonConstants.FONT_SIZE_SMALL)
                .fontColor(Color.Gray)
            }.alignItems(HorizontalAlign.Start)

            Text(`${item.distance.toFixed(0)}m`).fontSize(CommonConstants.FONT_SIZE_MD)
          }
          .width(CommonConstants.FULL_SIZE)
          .backgroundColor(this.curIndex === index ? $r('app.color.list_background_select') : $r('sys.color.white'))
          .borderRadius(CommonConstants.BORDER_RADIUS)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(CommonConstants.PADDING)
          .onClick(() => {
            this.curIndex = index
            let marker = this.markerVM.searchMarkers[index]
            this.markerVM.moveCamera(marker);
          })
        }
      }, (item: MetroInfo, index) => JSON.stringify(item) + '_' + index)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}

