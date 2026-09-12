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

import { map, MapComponent } from '@kit.MapKit';
import { CommonConstants } from '../constants/CommonConstants';
import { SearchNearby } from '../components/SearchNearby';
import { MetroInfo } from '../model/MetroStationModel';
import { MarkerViewModel } from '../viewmodel/MarkerViewModel';

@Component
export struct MapPage {
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State metros: MetroInfo[] = [];
  @State searchMarkers: map.Marker[] = [];
  @Consume('pageInfos') pathStack: NavPathStack;
  private markerVM: MarkerViewModel = MarkerViewModel.instance

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        MapComponent({ mapOptions: this.markerVM.mapOptions, mapCallback: this.markerVM.mapCallback })
          .height(CommonConstants.MAPCOMPONENT_HEIGHT)

        this.titleBuilder()

        SearchNearby({ metros: this.metros }).position({ bottom: 0 })
      }
      .height(CommonConstants.FULL_SIZE)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.metros = ctx.pathInfo.param as MetroInfo[]
    })
  }

  @Builder
  titleBuilder() {
    RelativeContainer() {
      Column() {
        Image($r('app.media.ic_public_back'))
          .width(CommonConstants.IC_BACK_WIDTH)
          .height(CommonConstants.IC_BACK_HEIGHT)
      }
      .height(CommonConstants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .onClick(() => {
        this.pathStack.pop()
      })

      Text($r('app.string.address_name'))
        .fontSize(CommonConstants.FONT_SIZE_LARGE)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.markerVM.moveToCenter();
        })
    }
    .width(CommonConstants.TITLE_WIDTH)
    .height(CommonConstants.TITLE_HEIGHT)
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .padding({ left: CommonConstants.PADDING, right: CommonConstants.PADDING })
    .margin({
      left: CommonConstants.PADDING_LARGE,
      right: CommonConstants.PADDING_LARGE,
      top: this.topRectHeight
    })
  }
}

@Builder
export function MapPageBuilder() {
  MapPage()
}