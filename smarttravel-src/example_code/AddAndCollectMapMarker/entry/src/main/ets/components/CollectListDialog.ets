/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { promptAction } from '@kit.ArkUI'
import { MarkerType, StyleConstants } from '../constants/StyleConstants'

@Component
export struct CollectListDialog {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Consume showCollectListDialog: boolean
  @Consume collectArr: MarkerType[]
  promptAction = this.getUIContext().getPromptAction()

  aboutToAppear(): void {
    this.bottomRectHeight = this.getUIContext().px2vp(AppStorage.get('bottomRectHeight'))
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.mark_points'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Image($r('app.media.close'))
          .width(43)
          .onClick(() => {
            this.showCollectListDialog = false
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 10 }) {
        Button($r('app.string.location'))
          .backgroundColor('rgb(10, 89, 247)')
          .borderRadius(20)
          .fontSize(14)
          .fontColor('rgb(255, 255, 255)')
          .fontWeight(500)
        Button($r('app.string.trip_plan'))
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .fontColor('rgba(0, 0, 0, 0.9)')
          .fontSize(14)
          .onClick(() => {
            this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
          })
      }
      .width('100%')
      .margin({
        top: 20
      })

      Row() {
        Text($r('app.string.common_address'))
          .fontSize(18)
          .fontWeight(700)

        Row() {
          Text($r('app.string.set_up'))
            .fontSize(16)
            .fontWeight(400)
            .fontColor('rgba(0, 0, 0, 0.6)')
          Image($r('app.media.right'))
            .margin({
              left: 10
            })
            .width(7)
        }
        .onClick(() => {
          this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 30
      })

      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.home'))
            .width(38)
          Column({ space: 6 }) {
            Text($r('app.string.home'))
              .fontSize(15)
              .fontColor(Color.Black)
            Text($r('app.string.click_set_up'))
              .fontSize(13)
              .fontColor('rgba(0, 0, 0, 0.4)')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .onClick(() => {
          this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
        })

        Row({ space: 8 }) {
          Image($r('app.media.company'))
            .width(38)
          Column({ space: 6 }) {
            Text($r('app.string.company'))
              .fontSize(15)
              .fontColor(Color.Black)
            Text($r('app.string.click_set_up'))
              .fontSize(13)
              .fontColor('rgba(0, 0, 0, 0.4)')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .onClick(() => {
          this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
        })
      }
      .width('100%')
      .borderRadius(12)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 25,
        right: 25,
        top: 12,
        bottom: 12
      })
      .margin({
        top: 12
      })

      Row({ space: 6 }) {
        Text($r('app.string.default_collection'))
          .fontSize(18)
          .fontColor('rgb(0, 0, 0)')
          .fontWeight(700)
        Text(`(${this.collectArr.length})`)
          .fontSize(16)
          .fontColor('rgb(0, 0, 0)')
          .fontWeight(700)
      }
      .width('100%')
      .margin({
        top: 28
      })

      List({ space: 10 }) {
        ForEach(this.collectArr, (item: MarkerType) => {
          ListItem() {
            collectItem({ marker: item })
          }
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .margin({
        top: 12
      })

      Button($r('app.string.add_address'))
        .width('100%')
        .backgroundColor('rgb(10, 89, 247)')
        .fontSize(16)
        .fontWeight(500)
        .fontColor(Color.White)
        .padding({
          top: 5,
          bottom: 5
        })
        .margin({
          bottom: this.bottomRectHeight + 12
        })
        .onClick(() => {
          this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
        })
    }
    .width('100%')
    .height('64%')
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: 35,
      topRight: 35
    })
    .padding({
      top: 20,
      left: 16,
      right: 16
    })
  }
}

@Component
struct collectItem {
  @Prop marker: MarkerType
  promptAction = this.getUIContext().getPromptAction()

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.location'))
        .width(38)
      Column({ space: 2 }) {
        Text(this.marker.simpleAddress)
          .fontSize(14)
          .fontColor('rgb(25, 25, 25)')
          .fontWeight(500)
          .margin({
            bottom: 5
          })
        Text(this.marker.detailAddress)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.4)')
          .fontWeight(500)
          .constraintSize({ maxWidth: '85%' })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius(10)
    .padding({
      top: 10,
      bottom: 10,
      left: 10
    })
    .onClick(() => {
      this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
    })
  }
}