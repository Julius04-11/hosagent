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

import { ShopModel, SHOPS } from '../model/DataModel';

@Component
export struct ShopDetail {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0 //获取状态栏底部区域高度
  @Prop @Watch('onValueChange') clickedShop: number;
  @State currentShop: ShopModel = new ShopModel()
  private context: UIContext = this.getUIContext()

  build() {
    Column() {
      Row() {
        Column() {

          Image(this.currentShop.image)
            .width(124)
            .height(144)
            .borderRadius(8)

        }
        .margin({
          left: 16,
          right: 12,
          bottom: 6,
          top: 16
        })

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
          Column() {
            Text(this.currentShop.name)
              .fontColor('#000000')
              .fontSize(14)
              .margin({
                right: 15,
                bottom: 6,
              })

            Row() {
              Text($r('app.string.comment'))
                .fontColor('#b3000000')
                .fontSize(11)
              Text(this.currentShop.comment.toString())
                .fontColor('#b3000000')
                .fontSize(11)
              Text($r('app.string.unit'))
                .fontColor('#b3000000')
                .fontSize(11)
                .margin({
                  right: 5
                })
              Image($r('app.media.rmb'))
                .width(6.3)
              Text(this.currentShop.money.toString())
                .fontColor('#b3000000')
                .fontSize(11)
              Text($r('app.string.person'))
                .fontColor('#b3000000')
                .fontSize(11)
                .margin({
                  right: 5
                })
              Text(this.currentShop.score.toString())
                .fontColor('#b3000000')
                .fontSize(11)
              Text($r('app.string.score'))
                .fontColor('#b3000000')
                .fontSize(11)
            }
            .margin({
              right: 15,
              bottom: 6,
            })

            Row() {
              Image($r('app.media.star_trophy_fill'))
                .height(11)
                .width(9)
                .margin({
                  right: 10,
                })
              Text(this.currentShop.type)
                .fontColor('#99000000')
                .fontSize(9)
                .fontColor('#EE6F21')
            }
            .backgroundColor('#80f9bc64')
            .borderRadius(4)
            .padding({
              left: 10,
              right: 10,
              bottom: 3,
              top: 4,
            })

            .margin({
              right: 15,
              bottom: 6,
            })

            Row({ space: 5 }) {
              Image($r('app.media.time'))
                .width(12)
                .height(12)
              Text($r('app.string.rest'))
                .fontColor('#99000000')
                .fontSize(11)
              Text($r('app.string.week'))
                .fontColor('#99000000')
                .fontSize(11)
              Text($r('app.string.time'))
                .fontColor('#99000000')
                .fontSize(11)
            }
            .margin({
              right: 15,
              bottom: 6,
            })
          }
          .alignItems(HorizontalAlign.Start)

          Row({ space: 5 }) {
            Row() {
              Image($r('app.media.heart'))
                .width(12)
                .height(12)
                .margin({
                  right: 5,
                })
              Text($r('app.string.heart'))
                .fontColor('#e6000000')
                .fontSize(10)
                .fontWeight(500)
            }
            .justifyContent(FlexAlign.Center)
            .padding({
              left: 9,
              right: 9,
              bottom: 7,
              top: 7,
            })
            .borderRadius(20)
            .backgroundColor('#0d000000')

            Row() {
              Image($r('app.media.search'))
                .width(12)
                .height(12)
                .margin({
                  right: 5,
                })
              Text($r('app.string.around'))
                .fontColor('#e6000000')
                .fontSize(10)
                .fontWeight(500)
            }
            .justifyContent(FlexAlign.Center)
            .padding({
              left: 9,
              right: 9,
              bottom: 7,
              top: 7,
            })
            .borderRadius(20)
            .backgroundColor('#0d000000')

            Row() {
              Image($r('app.media.line'))
                .width(12)
                .height(12)
                .margin({
                  right: 5,
                })
              Text($r('app.string.line'))
                .fontColor('#FFFFFF')
                .fontSize(10)
                .fontWeight(500)
            }
            .justifyContent(FlexAlign.Center)
            .padding({
              left: 9,
              right: 9,
              bottom: 7,
              top: 7,
            })
            .backgroundColor('#0A59F7')
            .borderRadius(20)
          }

        }
        .height(140)
        .margin({
          top: 16,
        })
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .height(176)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(16)
    .margin({
      left: 15,
      right: 15,
      bottom: this.context.px2vp(this.bottomRectHeight) + 18
    })

  }

  onValueChange() {
    this.currentShop = SHOPS.filter((item: ShopModel, index: number) => item.index === this.clickedShop)[0];
  }
}