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
export struct AddressDialog {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Consume currmarker: MarkerType
  @Consume showCollectListDialog: boolean
  @Consume showAddressDialog: boolean
  @Consume collectArr: MarkerType[]
  private customDialogComponentId: number = 0
  promptAction = this.getUIContext().getPromptAction()

  aboutToAppear(): void {
    this.bottomRectHeight = this.getUIContext().px2vp(AppStorage.get('bottomRectHeight'))
  }

  @Builder
  customDialogComponent() {
    Row() {
      Image($r('app.media.star'))
        .width(21)

      Text($r('app.string.custom_dialog_content'))
        .fontSize(14)
        .fontWeight(400)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .margin({
          left: 15
        })

      Blank()

      Text($r('app.string.click_view'))
        .fontSize(14)
        .fontWeight(400)
        .fontColor('rgb(10, 89, 247)')
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
          this.showCollectListDialog = true
        })

      Image($r('app.media.close_dialog'))
        .width(10)
        .margin({
          left: 15
        })
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
        })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16
    })
  }

  add() {
    let temp = new MarkerType(
      this.currmarker.markerId,
      this.currmarker.simpleAddress,
      this.currmarker.detailAddress,
      this.currmarker.location,
      this.currmarker.isCollect,
      this.currmarker.drivingTime,
      this.currmarker.walkingTime,
      this.currmarker.currDisance
    )
    this.collectArr.push(temp)
  }

  delete(id: string) {
    for (let i = 0; i < this.collectArr.length; i++) {
      if (this.collectArr[i].markerId === id) {
        this.collectArr.splice(i, 1)
        break
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.mark_points'))
          .fontSize(22)
          .fontWeight(700)

        Image($r('app.media.close'))
          .width(43)
          .onClick(() => {
            this.showAddressDialog = false
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.currmarker.simpleAddress)
          .fontSize(16)
          .fontWeight(500)
          .fontColor(Color.Black)
      }
      .width('100%')
      .margin({
        top: 15
      })

      Row() {
        Text(this.currmarker.currDisance)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(400)

        Text(`步行${this.currmarker.walkingTime}`)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(400)
          .margin({
            left: 5
          })
      }
      .width('100%')
      .margin({
        top: 5
      })

      Blank()

      Row() {
        Button($r('app.string.route'))
          .width('45%')
          .fontSize(16)
          .fontWeight(500)
          .fontColor(Color.White)
          .backgroundColor('rgb(10, 89, 247)')
          .padding({
            top: 11,
            bottom: 11
          })
          .onClick(() => {
            this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
          })
        Image($r('app.media.search'))
          .width(43)
          .onClick(() => {
            this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
          })
        Image(this.currmarker.isCollect ? $r('app.media.collect') : $r('app.media.uncollect'))
          .width(43)
          .onClick(() => {
            if (this.currmarker.isCollect) {
              this.delete(this.currmarker.markerId)
              this.currmarker.isCollect = false
            } else {
              this.add()
              this.currmarker.isCollect = true
              this.getUIContext().getPromptAction().openCustomDialog({
                builder: () => {
                  this.customDialogComponent()
                },
                isModal: false,
                showInSubWindow: false,
                offset: { dx: 0, dy: '40%' },
                height: 50,
                width: '90%',
                cornerRadius: {
                  topLeft: 18,
                  topRight: 18,
                  bottomLeft: 18,
                  bottomRight: 18
                },
                autoCancel: true,
                backgroundColor: '#e6ffffff'
              }).then((dialogId: number) => {
                this.customDialogComponentId = dialogId;
              })
            }
          })
        Image($r('app.media.share'))
          .width(43)
          .onClick(() => {
            this.promptAction.showToast({ message: StyleConstants.ONLY_DISPLAY })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: this.bottomRectHeight + 12
      })
    }
    .width('100%')
    .height(197 + this.bottomRectHeight)
    .padding({
      top: 20,
      left: 16,
      right: 16,
    })
    .borderRadius({
      topLeft: 35,
      topRight: 35
    })
    .backgroundColor(Color.White)
  }
}