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

export class tabContent {
  title: string = ''
  desc: string = ''
}

export class TextCascadeContent {
  text: string = ''
  children: tabContent[] = []
}

@CustomDialog
struct CustomDialogExample {
  @State typeIndex: number = 0
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  @State city: string = '';
  controller?: CustomDialogController
  cancel: () => void = () => {}
  @State tabContentData: Array<tabContent> = [
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    },
    {
      title: '主题乐园',
      desc: '北京市朝阳区xxxxxxxxxxxxxxxxxxx'
    }
  ]
  cascade: TextCascadeContent[] = [
    {
      text: '北京市',
      children: this.tabContentData
    },
    {
      text: '广州市',
      children: this.tabContentData
    },
    {
      text: '上海市',
      children: this.tabContentData
    },
    {
      text: '天津市',
      children: this.tabContentData
    },
    {
      text: '重庆市',
      children: this.tabContentData
    },
    {
      text: '沈阳市',
      children: this.tabContentData
    },
    {
      text: '南京市',
      children: this.tabContentData
    },
    {
      text: '武汉市',
      children: this.tabContentData
    },
    {
      text: '成都市',
      children: this.tabContentData
    },
    {
      text: '西安市',
      children: this.tabContentData
    },
  ]

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('sys.media.ohos_ic_public_close'))
          .width(24)
          .height(24)
          .margin({ left: 20, top: 15 })
          .fillColor($r('sys.color.ohos_id_color_fourth'))
          .onClick(() => {
            this.controller?.close();
            // this.cancel()
          })

        Column() {
          Text("选择城市乐园")
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
        }
        .width('100%')
        .margin({top: 15})
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(60)

      Divider()
        .height('2px')
        .strokeWidth('2')
        .width('100%')
        .color($r('sys.color.ohos_id_color_list_separator'))
      Column() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
          List({ scroller: this.classifyScroller, initialIndex: 0 }) {
            ForEach(this.cascade, (item: TextCascadeContent, index) => {
              ListItem() {
                Column() {
                  Column() {
                    Text(item.text)
                      .fontSize(20)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.typeIndex == index ? Color.Orange : $r('sys.color.ohos_id_color_text_primary'))
                  }
                  .width('100%')
                  .height(55)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.typeIndex == index ? $r('sys.color.ohos_id_color_background') :
                  $r('sys.color.ohos_id_color_sub_background'))
                  .onClick(() => {
                    this.typeIndex = index

                  })

                  if (this.cascade.length != (index + 1)) {
                    Divider()
                      .width('100%')
                      .height('1px')
                      .color($r('sys.color.ohos_id_color_list_separator'))
                  }
                }
              }
            })
          }
          .width(140)
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)

          List({ scroller: this.scroller }) {
            ForEach(this.cascade[this.typeIndex].children, (item: tabContent, index) => {
              ListItem() {
                Column() {
                  Column() {
                    Image($r('app.media.home_loves'))
                      .objectFit(ImageFit.Cover)
                      .width('100%')
                      .borderRadius('5vp')
                      .height('90%')
                    Text(this.cascade[this.typeIndex].text + item.title)
                      .fontSize(20)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  }
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Center)
                  .padding({ top: 24, bottom: 24, right: 16 })
                  .height(180)
                  .onClick(() => {
                    AppStorage.setOrCreate('selectCity', this.cascade[this.typeIndex].text);
                    AppStorage.setOrCreate('selectParkName', item.title)
                    this.controller?.close();
                  })

                  if (this.cascade[this.typeIndex].children.length != (index + 1)) {
                    Divider()
                      .width('100%')
                      .height('2px')
                      .strokeWidth('2')
                      .color($r('sys.color.ohos_id_color_list_separator'))
                  }
                }
                .padding({ left: 24 })
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
              }
            })
          }
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
      }
      .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .transition(
      TransitionEffect.asymmetric(
        TransitionEffect.translate({ y: 40 }).animation({ duration: 500, curve: Curve.Sharp }),
        TransitionEffect.IDENTITY
      ))
  }
}

export { CustomDialogExample }
