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

import { BreakpointConstants, ILocalData, MemberShipData, StyleConstants } from '@ohos/common';
import { parkVisitingData, swiperImage2 } from '@ohos/home/src/main/ets/viewmodel/HomeData';
import { playItems, relaxingShopping } from '../viewmodel/ParkingVisitingData';

@Entry
@Component
export struct ParkVisiting {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State localLifeList: ILocalData[] = [];
  @State titleIndex: number = 0;
  @State activityTitleIndex: number = 0;
  @State noticeInfo: string = '乐园公告';
  @StorageLink('selectCity') city: string = "";
  @StorageLink('selectParkName') parkName: string = '';
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State localArea: string = ''
  private controller: TabsController = new TabsController()
  @State currentIndex: number = 0
  @State currentYear: number = 0
  @State monthString: string = ''
  @Consume('pageStack') pageStack: NavPathStack;

  aboutToAppear(): void {
    // 获取当前日期
    let currentDate = new Date();

    // 获取当前年份
    this.currentYear = currentDate.getFullYear();

    // 获取当前月份（注意月份是从0开始的，所以需要加1）
    let currentMonth = currentDate.getMonth() + 1;
    // 如果月份小于10，前面添加0
    this.monthString = currentMonth < 10 ? `0${currentMonth}` : `${currentMonth}`;
  }

  @Builder
  builderTab3(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .size({ width: 35, height: 35 })
      Text(button.title)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontSize(14)
    }
    .height(StyleConstants.FULL_HEIGHT)
    .onClick(() => {
    })
  }

  @Builder
  customSwiper2() {
    Swiper() {
      ForEach(swiperImage2, (item: Resource) => {
        Image(item)
          .width(StyleConstants.FULL_WIDTH)
          .objectFit(ImageFit.Fill)
          .borderRadius('16vp')
          .backgroundColor(Color.White)
          .height('100%')
      }, (item: Resource) => JSON.stringify(item))
    }
    .autoPlay(true)
    .itemSpace(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 : '14vp')
    .indicator(false)
    .displayCount(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 3 :
      (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? 2 : 1))
    .margin({ bottom: '8vp', top: '4vp' })
    .width('354vp')
    .height('220vp')
  }

  @Builder
  customSwiper3() {
    Swiper() {
      ForEach(parkVisitingData, (item: MemberShipData) => {
        this.builderTab3(item)
      }, (item: Resource) => JSON.stringify(item))
    }
    .itemSpace(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 : '14vp')
    .indicator(false)
    .displayCount(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 3 :
      (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? 2 : 1))
    .margin({ bottom: '12vp', top: '12vp' })
    .displayCount(5)
    .width('350vp')
    .height('80')
  }

  @Builder
  tabContentFix() {
    Column() {

      Text(this.monthString + '/' + this.currentYear + '  ' + '今日演出')
        .fontColor(Color.Black)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ right: '10vp', bottom: '10vp' })
        .height('30')
      Image($r('app.media.today'))
        .borderRadius('7')
        .objectFit(ImageFit.Fill)
        .height('180vp')
        .width('100%')

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
        Text('xxxxxxxxxxxxxx演出')
          .fontColor(Color.Black)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .margin({ left: '7vp', top: '7vp', bottom: '7vp' })
          .alignSelf(ItemAlign.Start)
          .height(25)
        Text('场次时间：09：30 | 19：30')
          .fontColor(Color.Black)
          .fontSize(12)
          .height(25)
          .margin({ left: '7vp', bottom: '7vp' })
          .alignSelf(ItemAlign.Start)
      }
      .height('50vp')
      .borderRadius('20vp')

    }
    .height('250vp')
    .margin({ top: '15vp', left: '17vp', right: '17vp' })
  }

  @Builder
  tabSwiper() {
    Flex({ direction: FlexDirection.Column, }) {

      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          this.tabContentFix();
        }.tabBar(this.ImageTabBuilder(0))


        TabContent() {
          this.tabContentFix();
        }.tabBar(this.ImageTabBuilder(1))

        TabContent() {
          this.tabContentFix();
        }.tabBar(this.ImageTabBuilder(2))

        TabContent() {
          this.tabContentFix();
        }.tabBar(this.ImageTabBuilder(3))

        TabContent() {
          this.tabContentFix();
        }.tabBar(this.ImageTabBuilder(4))
      }
      .borderRadius('20')
      .width('350vp')
      .animationDuration(300)
      .margin({ top: '25vp' })

      .height('350')
      .backgroundColor(0xf1f3f5)
      .onTabBarClick((index: number) => {
        this.currentIndex = index
      })
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }.width('350vp')
  }

  @Builder
  ImageTabBuilder(index: number) {
    if (this.currentIndex === index) {
      Image($r('app.media.today'))
        .width(60)
        .height(40)
        .objectFit(ImageFit.Fill)
        .border({ color: Color.Blue, width: '2', style: BorderStyle.Solid })
        .borderRadius('5')
    } else {
      Image($r('app.media.today'))
        .width(60)
        .height(40)
        .objectFit(ImageFit.Fill)
        .borderRadius('5')
    }
  }

  @Builder
  GridItemWithTitle(gridTitle: string, buildItems: Array<MemberShipData>, columnsTmp: string, rowTmp: string,
    num: number) {
    Flex({ direction: FlexDirection.Column }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 5 }) {
          Text(gridTitle)
            .fontColor(Color.Black)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .margin({ left: '20vp' })
        }

        Row({ space: 5 }) {
          Text('全部')
            .fontColor(Color.Black)
          Image($r('app.media.ic_right_arrow'))
            .width('14')
        }
      }
      .width('95%')

      Grid() {
        ForEach(buildItems, (item: MemberShipData, index: number) => {
          GridItem() {
            Column({ space: '5vp' }) {
              Image(item.img)
                .width('150vp')
                .height('150vp')
                .backgroundColor('#ff32d0e7')
                .borderColor('#fffc7a7a')
                .borderRadius(22)

              Text(item.title)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Start)
                .fontSize('16fp')
                .height('20vp')
                .margin({ top: '10vp' })
              Text(item.title)
                .textAlign(TextAlign.Start)
                .fontSize('14fp')
                .height('20vp')
            }
            .alignItems(HorizontalAlign.Start)
            .height('200vp')
            .onClick(() => {
              //this.currentPageIndex = tabIndex;
            })
          }
        }, (index: string) => index)
      }
      .columnsTemplate(columnsTmp)
      .rowsTemplate(rowTmp)
      .columnsGap(2)
      .rowsGap(2)
      .width('100%')
      .height(250 * num)
    }
    .margin({ top: '20vp' })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.play_bg'))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .height(280)
          .width('100%')
        Scroll() {
          Column() {
            Column() {
              Text(this.city + this.parkName)
                .fontSize(18)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ left: 20 })
            }
            .width('100%')
            .height('30vp')
            .alignItems(HorizontalAlign.Start)

            this.customSwiper2()
            this.customSwiper3()

            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
              Row({ space: 5 }) {
                Text('开启地图游玩模式')
                  .fontSize(17)
                  .fontColor(Color.Black)
                  .fontWeight(FontWeight.Bold)
                Image($r('app.media.ic_right_arrow'))
                  .width('16')
                  .margin({ bottom: '2vp' })
              }
              .margin({ bottom: '10vp' })

              Row({ space: 5 }) {
                Text('今日开放时间：09:30-21:00')
                  .fontColor('#99000000')
                  .fontSize(16)
              }
            }
            .backgroundColor('#F1F3F5')
            .borderRadius('20vp')
            .width('350vp')
            .padding({ left: '25vp' })
            .height(86)
            .onClick(() => {
              this.pageStack.pushPathByName("MapPage", null)
            })

            this.tabSwiper();

            this.GridItemWithTitle("玩乐项目", playItems, '1fr 1fr', '1fr 1fr 1fr 1fr', 4)
            this.GridItemWithTitle("休闲购物", relaxingShopping, '1fr 1fr', '1fr 1fr', 2)

          }

        }
        .scrollBar(BarState.Off)
        .margin({ top: 20, bottom: '60vp' })

      }
      .height('100%')
    }
    .hideTitleBar(true)
  }
}