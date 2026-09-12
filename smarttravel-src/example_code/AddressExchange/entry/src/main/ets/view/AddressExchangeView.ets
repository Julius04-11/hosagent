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
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 */

import curves from '@ohos.curves';
import { PromptAction  } from '@kit.ArkUI';
import { HistoryClass, HISTORYLIST } from '../model/HistorySearchModel';

/**
 * 使用交换元素组件样例
 *
 * 核心组件:
 *
 * 实现步骤:
 * 1. 创建左右两边Text组件显示地址。设置初始偏移量以及文本对齐方式
 * 2. 点击中间的图标时，修改是否切换的状态变量值和通过animateTo修改偏移量的值，来实现动态更新左右两边地址的显示，完成动画效果
 */

@Component
export struct AddressExchangeView {
  @State cityNameStart: Resource | undefined = $r('app.string.address_exchange_address_left');
  @State cityNameEnd: Resource | undefined = $r('app.string.nanjing');
  @State weekDay: string = '周日';
  @State monthDay: number = 4;
  @State day: number = 23;
  @State currentIndex: number = -1;
  @State weekDays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  @State selectedDate: Date = new Date('2025-04-23')
  // 旋转角度
  @State rotateAngle: number = 0;
  // 偏移量
  @State translateX: number = 0;
  // 是否已交换
  @State swap: boolean = false;
  // 整体内容区宽度
  private rowWidth: number = 335;
  // 单次偏移距离
  // private distance: number = this.rowWidth * 0.91;
  private distance: number = this.rowWidth * 0.55;
  // 内容相隔距离
  private columnSpace: number = 12;
  // 初始化偏移距离
  private zeroTranslate: number = 0;
  // 单次旋转180°
  private rotateAddAngle: number = 360;
  // toast弹窗时长
  private toastDuration: number = 2000;
  promptAction: PromptAction = this.getUIContext().getPromptAction();

  @Builder
  startCity() {
    Column() {
      Text($r('app.string.start_address'))
        .alignSelf(ItemAlign.Start)
        .fontColor('#80000000')
        .fontSize(14)
        .margin({ bottom: 18 })
        .textAlign(TextAlign.Start)
      Text(this.cityNameStart)
        .translate({ x: this.translateX })
        .fontSize(25)
        .textAlign(this.swap ? TextAlign.End : TextAlign.Start)
        .margin({ bottom: 20 })
        .width('40%')
        .height(40)
    }
  }

  @Builder
  endCity() {
    Column() {
      Text($r('app.string.end_address'))
        .fontColor('#80000000')
        .fontSize(14)
        .alignSelf(ItemAlign.End)
        .margin({ bottom: 18 })
      Text(this.cityNameEnd)
        .translate({ x: -this.translateX })
        .fontSize(25)
        .width('40%')
        .height(40)
        .margin({ bottom: 20 })
        .textAlign(this.swap ? TextAlign.Start : TextAlign.End)
    }
  }

  // 地址交换
  @Builder
  animatedIcons() {
    Stack() {
      Image($r('app.media.change'))
        .size({
          height: $r('app.integer.address_exchange_airplane_size'),
          width: $r('app.integer.address_exchange_airplane_size1')
        })
      Image($r('app.media.circle'))
        .size({
          height: $r('app.integer.address_exchange_recycle_size'),
          width: $r('app.integer.address_exchange_recycle_size')
        })
        .rotate({ angle: this.rotateAngle })
        .animation({
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal,
        })
    }
    .height(100)
    .margin({ top: 30 })
    .width($r('app.string.address_exchange_image_width'))
    .onClick(() => {
      this.swap = !this.swap
      this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
        if (this.swap) {
          this.translateX = this.distance;
        } else {
          this.translateX = this.zeroTranslate;
        }
      })
      this.rotateAngle += this.rotateAddAngle;
    })
  }

  @Builder
  historyRecord() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
      Text($r('app.string.line'))
        .fontSize(14)
        .margin({ bottom: 15 })
        .fontColor('#80000000')
        .margin({
          left: 20,
          top: 20,
        })
      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        if (HISTORYLIST.length > 0) {
          ForEach(HISTORYLIST, (item: HistoryClass, index) => {
            Text() {
              Span(item.startCityName)
              Span($r('app.string.split'))
              Span(item.endCityName)
            }
            .fontSize(16)
            .borderStyle(BorderStyle.Solid)
            .borderRadius(20)
            .backgroundColor('#F1F3F5')
            .fontColor(this.currentIndex === index ? '#0A59F7' : '#cc000000')
            .padding({
              top: '12',
              bottom: '12',
              left: '12',
              right: '12'
            })
            .margin({
              top: '10',
              right: '8'
            })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .onClick(() => {
              this.currentIndex = index
              if (this.swap) {
                this.cityNameStart = item.endCityName
                this.cityNameEnd = item.startCityName
              } else {
                this.cityNameStart = item.startCityName
                this.cityNameEnd = item.endCityName
              }
            })
          }, (item: string) => JSON.stringify(item))
        }
      }
      .padding({
        bottom: 20,
        left: 15,
      })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('90%')
    .height(165)
    .margin({
      top: 14,
    })
  }

  @Builder
  dateShow() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text($r('app.string.start_date'))
          .fontSize(14)
          .margin({ bottom: 12 })
          .fontColor('#80000000')
      }
      .margin({ left: 18 })

      Row() {
        Text() {
          Span(`${this.monthDay}`)
          Span($r('app.string.month'))
          Span(`${this.day}`)
          Span($r('app.string.day'))
        }
        .fontSize(25)
        .fontWeight(FontWeight.Medium)
        .height($r('app.integer.address_exchange_date_height'))
        .onClick(() => {
          CalendarPickerDialog.show({
            selected: this.selectedDate,
            onAccept: (value) => {
              this.weekDay = this.weekDays[value.getDay()];
              this.monthDay = value.getMonth() + 1;
              this.day = value.getDate();
            }
          })
        })
        .margin({ right: 15 })

        Text(this.weekDay)
          .height($r('app.integer.address_exchange_date_height'))
          .fontColor('#80000000')
          .fontSize(14)
      }
      .width(this.rowWidth)
      .margin({ bottom: 15 })
      .onClick(() => {
        this.promptAction.showToast({
          message: $r('app.string.address_exchange_other_function'),
          duration: this.toastDuration
        });
      })
      .margin({ left: 18 })

      Button($r('app.string.address_exchange_search_ticket'))
        .fontColor('#FFFFFF')
        .height($r('app.integer.address_exchange_button_height'))
        .margin({ top: 26 })
        .width('90%')
        .onClick(() => {
          this.promptAction.showToast({
            message: $r('app.string.address_exchange_other_function'),
            duration: this.toastDuration
          });
        })
        .alignSelf(ItemAlign.Center)
    }
    .height(190)
  }

  build() {
    Column() {
      Column({ space: this.columnSpace }) {
        Row() {
          this.startCity()
          this.animatedIcons()
          this.endCity()
        }
        .width(this.rowWidth)
        .height(25)
        .padding({
          top: 2,
          right: 15,
          left: 15
        })

        Image($r('app.media.line'))
          .height(0.8)
          .margin({ top: 40, bottom: 6 })
          .width(340)
        this.dateShow()
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .width('91%')
      .height(265)
      .padding({
        bottom: 20,
        top: 20,
      })
      .margin({
        top: 270
      })

      this.historyRecord()
    }
  }
}
