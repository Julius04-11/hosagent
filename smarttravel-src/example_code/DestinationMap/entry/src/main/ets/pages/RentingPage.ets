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

import { mapCommon, site } from '@kit.MapKit';
import { CommonConstants } from '../constants/CommonConstants';
import { MarkerViewModel } from '../viewmodel/MarkerViewModel';
import { MetroInfo } from '../model/MetroStationModel';
import { HOUSE, HouseInfo, RentalInfo } from '../model/HouseInfoModel';


@Entry
@Component
struct RentingPage {
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @State detail?: RentalInfo = undefined;
  @State center: mapCommon.LatLng = {
    latitude: 32.02065982629459,
    longitude: 118.788899213002
  };
  @State metros: MetroInfo[] = [];
  @State closestOne?: MetroInfo = undefined;
  @Provide('pageInfos') pathStack: NavPathStack = new NavPathStack()
  private markerVM: MarkerViewModel = MarkerViewModel.instance

  async aboutToAppear() {
    this.markerVM.center = this.center;
    this.detail = HOUSE;
    // 搜索附近
    let params: site.SearchByTextParams = {
      query: '地铁站',
      location: this.center,
      poiTypes: ['SUBWAY'],
      isChildren: true,
      language: 'zh_CN',
      radius: 2000
    }
    let result = await site.searchByText(params);
    if (result.sites) {
      this.metros.length = 0
      for (let site of result.sites) {
        if (site.distance! <= CommonConstants.DISTANCE && !site.name!.endsWith('(规划中)')) {
          let metro: MetroInfo = {
            siteId: site.siteId,
            name: site.name,
            address: site.formatAddress,
            location: site.location,
            distance: site.distance
          } as MetroInfo
          this.metros.push(metro);
        }
      }
      this.metros.sort((a, b) => a.distance - b.distance);
      this.markerVM.metros = this.metros;
    }
    this.closestOne = this.metros[0]
  }

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Scroll() {
            Column() {
              Image($r('app.media.pic_house'))
                .width(CommonConstants.FULL_SIZE)
                .height(CommonConstants.HOUSE_PIC_HEIGHT)
              Column({ space: CommonConstants.PUBLIC_SPACE }) {
                this.houseProfile()

                this.rentalDetail()
              }
              .width(CommonConstants.FULL_SIZE)
              .backgroundColor($r('app.color.default_background'))
              .borderRadius({
                topLeft: CommonConstants.BORDER_RADIUS_LARGE,
                topRight: CommonConstants.BORDER_RADIUS_LARGE
              })
              .offset({ y: CommonConstants.PIC_COVER_OFFSET })
              .padding(CommonConstants.PADDING_LARGE)
            }
          }
          .width(CommonConstants.FULL_SIZE)
          .layoutWeight(1)
          .position({ y: 0 })
          .scrollBar(BarState.Off)
        }
        .tabBar(this.tabBarBuilder)
        .backgroundColor($r('app.color.default_background'))
      }
      .scrollable(false)
      .padding({ bottom: this.bottomRectHeight })
    }
    .hideToolBar(true)
  }

  @Builder
  tabBarBuilder() {
    Row({ space: CommonConstants.PUBLIC_SPACE_TABBAR }) {
      Column({ space: CommonConstants.PUBLIC_SPACE_MD / 2 }) {
        Image($r('app.media.ic_collection'))
          .width(CommonConstants.IC_TABBAR_SIZE)
          .height(CommonConstants.IC_TABBAR_SIZE)
        Text($r('app.string.tabbar_icon_Collection'))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.icon_secondary'))
      }
      .justifyContent(FlexAlign.Start)

      Button($r('app.string.tabbar_button_Contacts'))
        .padding({
          top: CommonConstants.PADDING_BUTTON,
          bottom: CommonConstants.PADDING_BUTTON
        }).layoutWeight(1)
    }
    .width(CommonConstants.FULL_SIZE)
    .padding({
      left: CommonConstants.PADDING_LARGE,
      right: CommonConstants.PADDING_LARGE,
    })
  }

  @Builder
  houseProfile() {
    Column({ space: CommonConstants.PUBLIC_SPACE }) {
      Row({ space: 2 }) {
        Text(this.detail?.rental.content)
          .fontSize(CommonConstants.FONT_SIZE_LARGER)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Red)
        Text(this.detail?.rental.title)
          .fontSize(CommonConstants.FONT_SIZE_SMALL)
          .lineHeight(CommonConstants.FONT_LINEHEIGHT)
          .fontColor($r('sys.color.mask_secondary'))
      }.width(CommonConstants.FULL_SIZE).alignItems(VerticalAlign.Bottom)

      Row() {
        ForEach(this.detail?.houseInfo, (item: HouseInfo) => {
          Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
            Text(item.content).fontSize(CommonConstants.FONT_SIZE_MD)
            Text(item.title)
              .fontSize(CommonConstants.FONT_SIZE_SMALL)
              .fontColor($r('sys.color.mask_secondary'))
          }
        })
      }.width(CommonConstants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

      Row({ space: CommonConstants.PUBLIC_SPACE_MD }) {
        ForEach(this.detail?.label, (item: string) => {
          Text(item)
            .fontSize(CommonConstants.FONT_SIZE_SMALLER)
            .lineHeight(CommonConstants.FONT_LABEL_LINEHEIGHT)
            .fontColor($r('sys.color.ohos_id_color_floating_button_start'))
            .backgroundColor($r('app.color.label_background'))
            .borderRadius(CommonConstants.BORDER_RADIUS)
            .padding({
              top: CommonConstants.PADDING_LABEL_VERTICAL,
              bottom: CommonConstants.PADDING_LABEL_VERTICAL,
              left: CommonConstants.PADDING_LABEL_HORIZONTAL,
              right: CommonConstants.PADDING_LABEL_HORIZONTAL
            })
        })
      }.width(CommonConstants.FULL_SIZE)

      this.mapBuilder()
    }
    .padding(CommonConstants.PADDING)
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
  }

  // 跳转地图
  @Builder
  mapBuilder() {
    Column() {
      Row() {
        Column({ space: CommonConstants.PUBLIC_SPACE_MD }) {
          Row({ space: CommonConstants.PUBLIC_SPACE_MD / 2 }) {
            Text($r('app.string.address_name'))
            Image($r('app.media.ic_public_arrow_right'))
              .width(CommonConstants.IC_ARROW_SIZE)
              .height(CommonConstants.IC_ARROW_SIZE)
              .padding(CommonConstants.PADDING / 4)
              .borderRadius('50%')
              .backgroundColor($r('app.color.arrow_background'))
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)

          Text(this.closestOne ? `近${this.closestOne.name}·相距${this.closestOne.distance.toFixed(0)}m` : ' ')
            .fontSize(CommonConstants.FONT_SIZE_SMALL)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_location'))
          .size({
            width: CommonConstants.IC_LOCATION_SIZE,
            height: CommonConstants.IC_LOCATION_SIZE
          })
      }
      .width(CommonConstants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: CommonConstants.PADDING,
        right: CommonConstants.PADDING,
        top: CommonConstants.PADDING_MAP_TOP
      })

      Row() {
        Text($r('app.string.commuting_text_placeholder'))
          .fontSize(CommonConstants.FONT_SIZE_MD)
          .fontColor($r('sys.color.mask_secondary'))
        Text() {
          Span($r('app.string.commuting_text_add'))
          ImageSpan($r('app.media.ic_public_arrow_right'))
            .width(CommonConstants.IC_COMMUTING_ARROW_SIZE)
            .height(CommonConstants.IC_COMMUTING_ARROW_SIZE)
            .margin({ bottom: CommonConstants.PUBLIC_SPACE_MD / 2 })
        }
        .fontSize(CommonConstants.FONT_SIZE_MD)
        .fontColor($r('sys.color.mask_secondary'))
      }
      .width(CommonConstants.COMMUTING_WIDTH)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius({
        bottomLeft: CommonConstants.BORDER_RADIUS,
        bottomRight: CommonConstants.BORDER_RADIUS
      })
      .padding(CommonConstants.PADDING)
      .margin({ bottom: 2 })
    }
    .height(CommonConstants.MAP_HEIGHT)
    .backgroundImage($r('app.media.map'))
    .backgroundImageSize({ width: CommonConstants.FULL_SIZE, height: CommonConstants.FULL_HEIGHT })
    .backdropBlur(CommonConstants.BACK_BLUR)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .justifyContent(FlexAlign.SpaceBetween)
    .clip(true)
    .onClick(() => {
      this.pathStack.pushPathByName('mapPage', this.metros)
    })
  }

  @Builder
  rentalDetail() {
    Column({ space: CommonConstants.PUBLIC_SPACE }) {
      Text($r('app.string.rental_title'))
        .fontSize(CommonConstants.FONT_SIZE_LARGE)
        .fontWeight(CommonConstants.FONT_WEIGHT_TITLE)
        .width(CommonConstants.FULL_SIZE)
      Column() {
        Column({ space: 2 }) {
          Text($r('app.string.rental_detail_subtitle1')).fontWeight(CommonConstants.FONT_WEIGHT)
          Text($r('app.string.rental_detail_content1'))
            .fontSize(CommonConstants.FONT_SIZE_MD)
            .fontColor($r('sys.color.mask_secondary'))
        }.width(CommonConstants.FULL_SIZE).alignItems(HorizontalAlign.Start)

        Divider()
          .strokeWidth(1)
          .padding({ top: CommonConstants.PADDING, bottom: CommonConstants.PADDING })

        Column({ space: 2 }) {
          Text($r('app.string.rental_detail_subtitle2')).fontWeight(CommonConstants.FONT_WEIGHT)
          Text($r('app.string.rental_detail_content2'))
            .fontSize(CommonConstants.FONT_SIZE_MD)
            .fontColor($r('sys.color.mask_secondary'))
        }.width(CommonConstants.FULL_SIZE).alignItems(HorizontalAlign.Start)
      }
      .backgroundColor(Color.White)
      .padding(CommonConstants.PADDING)
      .borderRadius(CommonConstants.BORDER_RADIUS)
    }
  }
}