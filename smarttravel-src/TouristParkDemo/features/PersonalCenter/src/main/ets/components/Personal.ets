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

import { MemberShipData, StyleConstants } from '@ohos/common';
import { memberShip, memberShipInter, memberShipPaper, moreFunction } from '../viewmodel/PersonalData';

@Entry
@Component
export struct Personal {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'md';
  @StorageProp('userAccount') userAccount: string = '';
  @Consume('pageStack') pageStack: NavPathStack;
  @State showUserImg: boolean = false;
  scroller: Scroller = new Scroller()

  @Styles
  cardStyle(){
    .width(StyleConstants.FULL_WIDTH)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.vp_sixteen'))
  }

  @Styles
  imgStyle(){
    .width('25vp')
    .height('25vp')
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.vp_sixteen'))
  }

  @Styles
  imgStyle2(){
    .width('30vp')
    .height('30vp')
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.vp_sixteen'))
  }

  @Builder
  Avatar() {
    Column() {
      Row() {
        Column() {
          Image($r('app.media.my_ava'))
            .width(70)
            .height(70)
            .borderRadius($r('app.float.vp_twenty_four'))
            .onClick(() => {
              this.pageStack.pushPathByName("PersonalCenter", null)
            })
        }

        Column() {
          Row() {
            Text(this.userAccount || '登录/注册')
              .fontSize(18)
              .fontColor(Color.Black)
              .margin({ top: '10', bottom: '10vp' })
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                if (!this.userAccount) {
                  this.pageStack.pushPathByName("LoginPage", null)
                }
              })
          }
          .alignItems(VerticalAlign.Top)

          Row() {
            Image($r('app.media.my_vip'))
              .width(16)
              .height(16)
              .margin({ right: '6' })
              .visibility(this.userAccount ? Visibility.Visible : Visibility.None)
            Text(this.userAccount ? '蓝卡会员' : $r('app.string.entry_sys'))
              .fontColor(Color.Black)
              .fontSize(13)
              .textAlign(TextAlign.Start)
              .padding({
                right: $r('app.float.vp_four'),
                top: $r('app.float.vp_one'),
                bottom: $r('app.float.vp_one')
              })
          }
          .alignItems(VerticalAlign.Top)
          .margin({ top: '6' })
        }
        .alignItems(HorizontalAlign.Start)
        .alignSelf(ItemAlign.Center)
        .margin({ left: '20' })
      }
      .height(36)
      .width(StyleConstants.FULL_WIDTH)
    }
    .height(94)
    .width('90%')
  }

  @Builder
  buildTab(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .size({ width: 43, height: 43 })
      Text(button.title)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .height(30)
    }
    .height(80)
    .onClick(() => {
      this.pageStack.pushPathByName(button.action, button.index)
    })
  }

  @Builder
  buildTabOrder(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .width('43vp')
        .height('43vp')
      Text(button.title)
        .fontSize(15)
        .textAlign(TextAlign.Center)
        .margin({ top: '5' })
    }
    .height(66)
  }

  @Builder
  buildTab2(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .width('38vp')
        .height('38vp')
        .objectFit(ImageFit.Fill)
      Text(button.title)
        .fontSize(15)
        .textAlign(TextAlign.Center)
        .margin({ top: '5' })
    }
    .margin({ top: '15' })
    .height(80)
  }

  @Builder
  buildTabMore(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .width('22vp')
        .height('22vp')
        .objectFit(ImageFit.Fill)
        .margin({ bottom: '8', top: '5' })
      Text(button.title)
        .fontSize(15)
        .textAlign(TextAlign.Center)
        .margin({ top: '5' })
    }
    .height(64)
    .margin({ top: '15', left: '5', right: '5' })
  }

  @Builder
  buildTabNew(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Image(button.img)
          .objectFit(ImageFit.Fill)
          .width('40vp')
          .height('40vp')
          .margin({ right: '5' })
        Text(button.title)
      }
      .height('100%')
      .width('100%')
      .linearGradient({
        colors: button.title === '优惠券' ? [[0xC3F4EE, 0.0], [0xB9EFEF, 1.0]] : [[0xFDEECD, 0.0], [0xFDD091, 1.0]]
      })
      .backgroundColor(Color.Gray)
      .padding({
        left: 10,
        right: 10,
        top: 10,
        bottom: 10
      })
      .borderRadius(12)
      .onClick(() => {
      })
    }
    .height(52)
  }

  @Builder
  buildTab3(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Image(button.img)
          .objectFit(ImageFit.Fill)
          .imgStyle()
        Text(button.title)
      }
      .height('100%')
      .width('100%')
      .padding({
        left: 10,
        right: 10,
        top: 10,
        bottom: 10
      })
      .backgroundColor('#fff5f6f6')
      .borderRadius('6')
      .onClick(() => {
      })
    }
    .height(50)
  }

  @Builder
  MoreFunctionService() {
    Flex({ alignContent: FlexAlign.Center, justifyContent: FlexAlign.Center }) {
      List() {
        ForEach(moreFunction, (item: MemberShipData, index: number) => {
          ListItem() {
            this.buildTab3(item)
          }
        }, (index: string) => index)
      }
      .divider({
        strokeWidth: 1,
        color: '#ffe9e9e9',
        startMargin: '8vp',
        endMargin: '8vp'
      })
      .width('90%')
      .margin({ top: 10 })
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {

        Flex({ direction: FlexDirection.Column }) {
          Row() {
            if (this.showUserImg) {
              Image($r('app.media.my_ava'))
                .width(70)
                .height(70)
            } else {
              Image('')
                .width($r('app.float.vp_twenty_four'))
                .height($r('app.float.vp_twenty_four'))
            }

            Row({ space: 18 }) {
              Image($r('app.media.my_message'))
                .width(26)
                .height(26)
                .margin({ left: $r('app.float.vp_twenty_four') })
                .onClick(() => {
                  this.pageStack.pushPathByName("MessagePage", null)
                })

              Image($r('app.media.my_setting'))
                .width(26)
                .height(26)
                .onClick(() => {
                  this.pageStack.pushPathByName("AppSettingPage", null, false)
                })
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('95%')
          .alignSelf(ItemAlign.Center)
          .height(30)
          .margin({ right: 20 })

          Scroll() {
            Column() {
              this.Avatar()

              Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Center
              }) {
                Row({ space: 5 }) {
                  Image($r('app.media.vip_icon'))
                    .width('35')
                  Text('我的年卡')
                    .fontSize(17)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .margin({ right: '5vp', left: '5vp' })
                }
                .margin({ left: '15vp' })

                Row({ space: 5 }) {
                  Text(this.userAccount ? "点击查看" : '立即登录查看')
                    .fontColor(Color.White)
                    .fontSize(14)
                  Image($r('app.media.arrow_right'))
                    .width('8')
                }
                .margin({ right: '15vp' })
              }
              .borderRadius(20)
              .width('90%')
              .height(62)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [[0x4C88FF, 0.0], [0xA6A9FA, 1.0]]
              })

              Column() {
                Row() {
                  Grid() {
                    ForEach(memberShip, (item: MemberShipData, index: number) => {
                      GridItem() {
                        this.buildTabOrder(item)
                      }
                    }, (index: string) => index)
                  }
                  .columnsTemplate('1fr 1fr 1fr 1fr')
                  .columnsGap(10)
                  .rowsGap(10)
                  .width('90%')
                  .height(78)
                  .margin({ top: 16 })
                }

                Row() {
                  Grid() {
                    ForEach(memberShipPaper, (item: MemberShipData, index: number) => {
                      GridItem() {
                        this.buildTabNew(item)
                      }
                    }, (index: string) => index)
                  }
                  .columnsTemplate('1fr 1fr')
                  .columnsGap(10)
                  .rowsGap(10)
                  .width('90%')
                  .height(108)
                  .margin({ top: 10 })
                }

                // this.CommonFunctions()
              }
              .borderRadius(16)
              .height(174)
              .width('90%')
              .margin({ top: 12 })
              .linearGradient({
                colors: [[0xEDEDFE, 0.0], [0xFFFFFF, 1.0]]
              })
              .border({ color: Color.White, width: '2', style: BorderStyle.Solid })

              Flex({ direction: FlexDirection.Column }) {
                Grid() {
                  ForEach(memberShipInter, (item: MemberShipData, index: number) => {
                    GridItem() {
                      this.buildTab2(item)
                    }
                  }, (index: string) => index)
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(10)
                .rowsGap(10)
                .height(96)
                .backgroundColor(Color.White)
                .borderRadius(16)
                .width('90%')
                .margin({ top: 25 })

                Grid() {
                  ForEach(moreFunction, (item: MemberShipData, index: number) => {
                    GridItem() {
                      this.buildTabMore(item)
                    }
                  }, (index: string) => index)
                }
                .columnsTemplate('1fr 1fr 1fr 1fr')
                .columnsGap(6)
                .rowsGap(6)
                .width('90%')
                .backgroundColor(Color.White)
                .borderRadius(16)
                .height(170)
                .width('90%')
                .margin({ top: 25 })
              }

              // this.MoreFunctionService()
            }
            .width('100%')
            .margin({ top: 12 })
          }
          .scrollBar(BarState.Off)

        }
        .width('100%')
        .height("100%")
        .margin({ top: 10 })
      }
    }
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
  }
}