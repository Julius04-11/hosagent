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

@Builder
export function CardPageBuilder() {
  CardPage()
}

@Entry
@Component
export struct CardPage {
  @State message: string = 'Hello World';
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  @Consume('pageStack') pageStack: NavPathStack;
  @State selectedFontColor: string = '#0A57F9'
  @State fontColor: string = '#182431'
  @State simpleList: Array<string> = ['1', '2', '3'];
  @State simpleList2: Array<string> = ['6', '7', '8'];
  @StorageLink('selectCity') city: string = "";
  @StorageLink('selectParkName') parkName: string = '';

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : Color.Black)
        .fontSize(17)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color('#0A57F9')
        .opacity(this.currentIndex === index ? 1 : 0)
        .width('16%')
    }.width('100%')
  }

  @Builder
  itemDataStyle(itemData: ESObject, item: ESObject) {
    Column() {
      Row() {
        Text(item === '1' ? '金色年卡' :
          item === '2' ? '银色年卡' : item === '3' ? '铜色年卡' : '' + itemData ? '门票' : '门票')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 17, top: 18 })
        Text('￥999')
          .fontSize(18)
          .fontColor('#ED6F21')
          .fontWeight(FontWeight.Bold)
          .lineHeight(22)
          .margin({ right: 33, top: 18 })
          .visibility(item === '1' ? Visibility.Visible : Visibility.None)
        Text('￥499')
          .fontSize(18)
          .fontColor('#ED6F21')
          .fontWeight(FontWeight.Bold)
          .lineHeight(22)
          .margin({ right: 33, top: 18 })
          .visibility(item === '2' ? Visibility.Visible : Visibility.None)
        Text('￥299')
          .fontSize(18)
          .fontColor('#ED6F21')
          .lineHeight(22)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 33, top: 18 })
          .visibility(item === '3' ? Visibility.Visible : Visibility.None)
        Text('￥299')
          .fontSize(18)
          .fontColor('#ED6F21')
          .lineHeight(22)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 33, top: 18 })
          .visibility(item !== '1' && item !== '2' && item !== '3' ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .margin({ left: 7, right: 7 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('这里是金色年卡的介绍')
          .fontSize(14)
          .fontColor('#ED6F21')
          .visibility(item === '1' ? Visibility.Visible : Visibility.None)
          .margin({ left: 17, top: 18 })
        Text('这里是银色年卡的介绍')
          .fontSize(14)
          .fontColor('#ED6F21')
          .visibility(item === '2' ? Visibility.Visible : Visibility.None)
          .margin({ left: 17, top: 18 })
        Text('这里是铜色年卡的介绍')
          .fontSize(14)
          .fontColor('#ED6F21')
          .visibility(item === '3' ? Visibility.Visible : Visibility.None)
          .margin({ left: 17, top: 18 })
        Text('这里是门票的介绍')
          .fontSize(14)
          .fontColor('#ED6F21')
          .margin({ left: 17, top: 18 })
          .visibility(item !== '1' && item !== '2' && item !== '3' ? Visibility.Visible : Visibility.None)
        Text('原价￥3999')
          .fontSize(10)
          .decoration({
            type: TextDecorationType.LineThrough,
            color: '#ED6F21'
          })
          .fontSize(12)
          .fontColor('#ED6F21')
          .margin({ right: 25, top: 1, bottom: 3 })
      }
      .width('100%')
      .margin({ left: 7, right: 7 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('周六、周日和节假日不可用')
          .fontSize(13)// .lineHeight(22)
          .margin({ left: 17 })
          .fontColor('#9a000000')
          .width('66%')
        Button('预定')
          .width('82')
          .fontSize(16)// .lineHeight(22)
          .height('32')
          .margin({ right: 16, bottom: 17 })
          .align(Alignment.Center)
      }
      .width('100%')
      .margin({ left: 7, right: 7 })
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width('90%')
    .backgroundColor('#F1F3F5')
    .align(Alignment.Center)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius('20')
  }

  @Builder
  scrollBar(name: string, itemData: ESObject) {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text(name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
      }
      .height('75')
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .margin({ left: 20 })

      Scroll() {
        Column({ space: 16 }) {
          ForEach(itemData ? this.simpleList : this.simpleList2, (item: string) => {
            this.itemDataStyle(itemData, item)
          }, (item: string) => item)
        }.width('100%')
      }
      .scrollBar(BarState.Off)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.yearcard'))
          .width('100%')
          .height('35%')
          .objectFit(ImageFit.Fill)

        Flex({ direction: FlexDirection.Column }) {
          Blank()
            .height(256)

          Text(this.city + this.parkName)
            .fontSize(17)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Start)
            .height(30)
            .margin({ top: 30, left: 15 })

          Tabs({ index: this.currentIndex, controller: this.controller }) {
            TabContent() {
              this.scrollBar('年卡', "占位")
            }.tabBar(this.tabBuilder(0, '年卡'))

            TabContent() {
              this.scrollBar('门票', undefined)
            }.tabBar(this.tabBuilder(1, '门票'))
          }
          .width('100%')
          .vertical(false)
          .barMode(BarMode.Fixed)
          .barWidth('100%')
          .barHeight(56)
          .animationDuration(400)
          .margin({ top: 15 })
          .borderRadius(20)
          .backgroundColor(Color.White)
          .onChange((index: number) => {
            this.currentIndex = index
          })
        }
        .height('100%')
        .margin({ top: '15vp' })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.currentIndex = (ctx?.pathInfo?.param as number)
    })

  }
}
