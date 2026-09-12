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
import { StyleConstant } from '../constant/StyleConstant'

@Entry
@Component
export default struct TabMainView {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  private controller: TabsController = new TabsController()

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize($r('app.float.vp_sixteen'))
        .fontWeight(this.selectedIndex === index ? StyleConstant.FIVE_HUNDRED : StyleConstant.FOUR_HUNDRED)
        .lineHeight($r('app.float.vp_twenty_two'))
        .margin({ top: $r('app.float.seventeen'), bottom: $r('app.float.seven') })
      Divider()
        .strokeWidth(StyleConstant.DIVIDER_WIDTH)
        .width($r('app.float.vp_twenty'))
        .color(this.selectedFontColor)
        .opacity(this.selectedIndex === index ? 1 : 0)
    }.width($r('app.string.full_width'))
  }

  @Builder
  exploreArea(topTitle: string | Resource, mainTitle: string | Resource, expresion: string | Resource,
    buttonText: string | Resource, backgroundImage: Resource) {
    Column() {
      Text(topTitle)
        .fontSize($r('app.float.vp_ten'))
        .fontWeight(StyleConstant.FOUR_HUNDRED)
        .fontColor($r('app.color.font_color'))
        .lineHeight($r('app.float.thirteen'))
        .margin({ top: $r('app.float.vp_two'), left: $r('app.float.vp_minus_five') })

      Text(mainTitle)
        .fontSize($r('app.float.vp_sixteen'))
        .fontWeight(StyleConstant.SEVEN_HUNDRED)
        .margin({ top: $r('app.float.vp_twenty') })
        .fontColor($r('app.color.font_color'))
        .lineHeight($r('app.float.vp_twenty_one'))

      Text(expresion)
        .fontSize($r('app.float.twelve'))
        .fontWeight(StyleConstant.FOUR_HUNDRED)
        .fontColor($r('app.color.font_color'))
        .lineHeight($r('app.float.vp_sixteen'))
        .margin({ top: $r('app.float.vp_six') })
      Button(buttonText)
        .height($r('app.float.vp_twenty_eight'))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .width($r('app.float.vp_seventy_two'))
        .fontColor($r('app.color.font_color'))
        .margin({ top: $r('app.float.eighty'), bottom: $r('app.float.vp_thirty_one') })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({message:$r('app.string.function_only_displayed')})
        })
    }
    .width($r('app.string.full_width'))
    .height($r('app.string.full_height'))
    .borderRadius($r('app.float.vp_sixteen'))
    .padding({ left: $r('app.float.twelve') })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundImage(backgroundImage)
    .backgroundImageSize(ImageSize.Cover)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          // 附近景点
          Column() {
            Column() {
              Text($r('app.string.title_level_1'))
                .fontSize($r('app.float.vp_twenty'))
                .fontWeight(StyleConstant.SEVEN_HUNDRED)
                .margin({ top: $r('app.float.vp_twenty') })
                .fontColor($r('app.color.font_color'))
                .lineHeight($r('app.float.vp_twenty_seven'))

              Text($r('app.string.title_level_2'))
                .fontSize($r('app.float.vp_sixteen'))
                .fontWeight(StyleConstant.FOUR_HUNDRED)
                .fontColor($r('app.color.font_color'))
                .lineHeight($r('app.float.vp_twenty_one'))
                .margin({ top: $r('app.float.vp_six') })
              Button($r('app.string.title_level_3'))
                .height($r('app.float.vp_twenty_eight'))
                .width($r('app.float.vp_seventy_two'))
                .margin({ top: $r('app.float.vp_sixteen'), bottom: $r('app.float.vp_thirty_one') })
                .onClick(() => {
                  this.getUIContext().getPromptAction().showToast({message:$r('app.string.function_only_displayed')})
                })
            }
            .width($r('app.string.full_width'))
            .borderRadius($r('app.float.vp_sixteen'))
            .padding({ left: $r('app.float.twenty_four') })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .backgroundImage($r('app.media.top_image'))
            .backgroundImageSize(ImageSize.FILL)

            // 探索周边美景
            Text($r('app.string.title_middle_1'))
              .fontSize($r('app.float.eighteen'))
              .fontWeight(StyleConstant.SIX_HUNDRED)
              .height($r('app.float.twenty_four'))
              .margin({ top: $r('app.float.vp_ten'), bottom: $r('app.float.vp_ten') })
              .width($r('app.string.full_width'))
              .fontColor('#191919')

            // 网格布局2
            Grid() {
              GridItem() {
                this.exploreArea($r('app.string.grid_1_level_1'), $r('app.string.grid_1_level_2'),
                  $r('app.string.grid_1_level_3'), $r('app.string.grid_1_level_4'), $r('app.media.vouchers'))
              }

              GridItem() {
                this.exploreArea($r('app.string.grid_2_level_1'), $r('app.string.grid_2_level_2'),
                  $r('app.string.grid_2_level_3'), $r('app.string.grid_2_level_4'), $r('app.media.vouchers'))
              }
            }
            .columnsGap($r('app.float.vp_twenty'))
            .height($r('app.float.two_hundred'))
            .rowsTemplate('1fr')
            .columnsTemplate('1fr 1fr')

            // 热门景点
            Row() {
              Text($r('app.string.popular'))
                .fontSize($r('app.float.eighteen'))
                .fontWeight(StyleConstant.SIX_HUNDRED)
                .height($r('app.float.twenty_four'))
                .margin({ top: $r('app.float.vp_ten'), bottom: $r('app.float.vp_ten') })
                .fontColor('#191919')
              Row() {
                Text($r('app.string.check_more'))
                  .fontSize($r('app.float.twelve'))
                  .lineHeight($r('app.float.vp_fourteen'))
                  .fontWeight(StyleConstant.FOUR_HUNDRED)
                Image($r('app.media.ic_right_arrow'))
                  .height($r('app.float.twelve'))
                  .margin({ left: $r('app.float.vp_five') })
                  .objectFit(ImageFit.Contain)
              }
              .onClick(() => {
                this.getUIContext().getPromptAction().showToast({message:$r('app.string.function_only_displayed')})
              })
            }.height($r('app.float.fifty'))
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .width($r('app.string.full_width'))

            // 世界之窗
            Column() {
              Row() {
                Text($r('app.string.location_title'))
                  .fontSize($r('app.float.eighteen'))
                  .fontWeight(StyleConstant.SEVEN_HUNDRED)
                  .lineHeight($r('app.float.twenty_four'))
                Column() {
                  Image($r('app.media.location_north_up_right_fill'))
                    .objectFit(ImageFit.Contain)
                    .height($r('app.float.vp_ten'))
                    .rotate({ angle: StyleConstant.ROTATE_ANGLE })
                }
                .width($r('app.float.vp_twenty'))
                .height($r('app.float.vp_twenty'))
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .borderRadius($r('app.float.vp_ten'))
                .backgroundColor('#EDEDED')
              }
              .width($r('app.string.full_width'))
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Row() {
                  Text($r('app.string.location_title_desc1'))
                    .fontSize($r('app.float.twelve'))
                    .fontWeight(StyleConstant.EIGHT_HUNDRED)
                    .lineHeight($r('app.float.vp_sixteen'))
                    .fontColor('rgba(0, 0, 0, 0.6)')
                  Text($r('app.string.location_title_desc2'))
                    .fontSize($r('app.float.twelve'))
                    .fontWeight(StyleConstant.EIGHT_HUNDRED)
                    .maxLines(StyleConstant.TEXT_MAX_LINES)
                    .width($r("app.string.location_width"))
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                    .lineHeight($r('app.float.vp_sixteen'))
                    .fontColor('rgba(0, 0, 0, 0.6)')
                }

                Text($r('app.string.location_title_desc3'))
                  .fontSize($r('app.float.twelve'))
                  .fontWeight(StyleConstant.EIGHT_HUNDRED)
                  .fontColor('rgba(0, 0, 0, 0.6)')
                  .lineHeight($r('app.float.vp_sixteen'))
              }.justifyContent(FlexAlign.SpaceBetween)
              .width($r('app.string.full_width'))
              .margin({ top: $r('app.float.vp_four') })

              Row() {
                Text($r('app.string.location_title_cost1'))
                  .fontSize($r('app.float.eighteen'))
                  .fontWeight(StyleConstant.SEVEN_HUNDRED)
                  .lineHeight($r('app.float.twenty_four'))
                  .fontColor('rgb(232, 64, 38)')

                Text($r('app.string.location_title_cost2'))
                  .fontSize($r('app.float.vp_ten'))
                  .fontWeight(StyleConstant.EIGHT_HUNDRED)
                  .lineHeight($r('app.float.thirteen'))
                  .padding({ bottom: $r('app.float.vp_four') })
                  .fontColor(Color.Grey)
                  .margin({ left: $r('app.float.vp_five') })

                Text($r('app.string.location_title_cost3'))
                  .fontSize($r('app.float.vp_eight'))
                  .fontWeight(StyleConstant.FOUR_HUNDRED)
                  .padding($r('app.float.vp_three'))
                  .borderRadius($r('app.float.vp_five'))
                  .margin({ left: $r('app.float.vp_five') })
                  .border({ width: $r('app.float.border_width'), color: Color.Grey })

              }.justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Bottom)
              .width($r('app.string.full_width'))
            }
            .height($r('app.float.vp_hundred'))
            .padding({
              top: $r('app.float.vp_ten'),
              left: $r('app.float.vp_twenty'),
              right: $r('app.float.vp_twenty'),
              bottom: $r('app.float.vp_ten')
            })
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.vp_twenty'))
            .width($r('app.string.full_width'))

          }
          .width($r('app.string.full_width'))
          .height($r('app.string.full_height'))
          .padding({ left: $r('app.float.vp_twenty'), right: $r('app.float.vp_twenty') })
          .backgroundColor('#F1F3F5')
        }.tabBar(this.tabBuilder(0, $r('app.string.discover')))

        TabContent() {
          Column() {
            Text($r('app.string.navigation'))
          }.width($r('app.string.full_width')).height($r('app.string.full_height'))
        }.tabBar(this.tabBuilder(1, $r('app.string.navigation')))

        TabContent() {
          Column() {
            Text($r('app.string.Attraction'))
          }.width($r('app.string.full_width')).height($r('app.string.full_height'))
        }.tabBar(this.tabBuilder(2, $r('app.string.Attraction')))

        TabContent() {
          Column() {
            Text($r('app.string.strategy'))
          }.width($r('app.string.full_width')).height($r('app.string.full_height'))
        }.tabBar(this.tabBuilder(3, $r('app.string.strategy')))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barHeight($r('app.float.vp_fifty_six'))
      .animationDuration(StyleConstant.FOUR_HUNDRED)
      .onChange((index: number) => {
        // currentIndex控制TabContent显示页签
        this.currentIndex = index
        this.selectedIndex = index
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if (index === targetIndex) {
          return
        }
        this.selectedIndex = targetIndex
      })
      .backgroundColor('#F1F3F5')
    }.width($r('app.string.full_width'))
  }
}