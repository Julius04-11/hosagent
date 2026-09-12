/*
 *
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 */

import { TAB_INFO } from '../model/TabBarData';
import { TabBarDataType } from '../model/DataType';

@Entry
@Component
struct MainPage {
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State startDate: string = '';
  @State endDate: string = '';

  build() {
    Navigation(this.pathStack) {
      Column({ space: 12 }) {
        this.titleBuilder();
        this.roomDetail();
        this.roomReservation();
      }
      .height('100%')
      .width('100%')
      .padding({ left: 16, right: 16 })
      .safeAreaPadding({ top: this.getUIContext().px2vp(this.topRectHeight) })
      .layoutWeight(1);

      // tab栏
      this.tabBuilder();
    }
    .height('100%')
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'));
  }

  @Builder
  titleBuilder() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Image($r('app.media.back'))
          .width(40)
          .height(40);
        Text($r('app.string.room_detail'))
          .fontWeight(700)
          .fontSize(20)
          .fontColor('rgba(0, 0, 0, 0.9)');
      };

      Image($r('app.media.room'))
        .width('100%')
        .height(155)
        .borderRadius(16);
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 8 });
  }

  // 房间详情
  @Builder
  roomDetail() {
    Column() {
      Text($r('app.string.room_description'))
        .fontSize(18)
        .fontWeight(700);
      Text($r('app.string.location'))
        .fontSize(12)
        .fontWeight(400)
        .opacity(0.4)
        .margin({ top: 6 });
      Text($r('app.string.price'))
        .fontSize(24)
        .fontWeight(700)
        .fontColor($r('app.color.price_font_color'))
        .margin({ top: 12 });
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height(122)
    .borderRadius(16)
    .padding(16)
    .backgroundColor(Color.White);
  }

  // 房间预订
  @Builder
  roomReservation() {
    Column() {
      Row({ space: 6 }) {
        Image($r('app.media.house'))
          .width(18)
          .height(18);
        Text($r('app.string.room_description1'))
          .fontWeight(400)
          .fontSize(14);
      }
      .width('100%');

      Row() {
        Text($r('app.string.room_name'))
          .fontWeight(500)
          .fontSize(16);
        Text($r('app.string.price'))
          .fontWeight(700)
          .fontSize(20);
      }
      .width('100%')
      .margin({ top: 13 })
      .justifyContent(FlexAlign.SpaceBetween);

      Column({ space: 8 }) {
        Row() {
          Text($r('app.string.check_in_data'))
            .fontWeight(400)
            .fontSize(12)
            .opacity(0.5);
          Text($r('app.string.check_out_data'))
            .fontWeight(400)
            .fontSize(12)
            .opacity(0.5);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text(this.startDate ? this.startDate : $r('app.string.line'))
            .fontWeight(500)
            .fontSize(16)
            .fontColor(this.startDate ? 'rgba(0, 0, 0, 0.9)' : '#18181A')
            .width(119)
            .textAlign(TextAlign.Start);
          Text(this.endDate ? this.endDate : $r('app.string.line'))
            .fontWeight(500)
            .fontSize(16)
            .fontColor(this.endDate ? 'rgba(0, 0, 0, 0.9)' : '#18181A')
            .width(119)
            .textAlign(TextAlign.End);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .margin({ top: 16 });
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height(150)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding(16)
    .onClick(() => {
      this.pathStack.pushPathByName('calendarPage', null, (info: PopInfo) => {
        let date = info.result as string[];
        this.startDate = date[0];
        this.endDate = date[1];
      });
    });
  }

  @Builder
  tabBuilder() {
    Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      ForEach(TAB_INFO, (item: TabBarDataType, index: number) => {
        Column({ space: 4 }) {
          Image(item.icon)
            .width(21)
            .height(21)
            .margin({ top: 5 });
          Text(item.title)
            .fontSize(10)
            .fontWeight(500)
            .fontColor(index === 0 ? '#0A59F7' : 'rgba(0, 0, 0, 0.6)')
            .opacity(0.6);
        };
      });
    }
    .safeAreaPadding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
    .height(70)
    .backgroundColor('#F1F3F5');
  }
}