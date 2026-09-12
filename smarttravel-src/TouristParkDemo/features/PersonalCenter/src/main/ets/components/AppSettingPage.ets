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

import Logger from '@ohos/common/src/main/ets/utils/Logger'

@Builder
export function GlobalTitle(tex: string,pageStack:NavPathStack) {
  Column() {
    Flex({ direction: FlexDirection.Row }) {
      Image($r('app.media.ic_back'))
        .height('10%')
        .aspectRatio(1)
        .width('10%')
        .onClick(() => {
          pageStack.pop()
        })

      Flex({ justifyContent: FlexAlign.Center }) {
        Text(tex)
          .fontSize(25)
      }

    }
    .height('24vp')
    .width('100%')
    .margin({ bottom: '18vp' })
  }
  .width('100%')
  .padding({ top: '12vp', bottom: '12vp', left: '8' })
}


@Builder
export function AppSettingPageBuilder(){
  AppSettingPage()
}

const LIST_SPACE: number = 16; // 列表默认间隔
const LAYOUT_WEIGHT: number = 1; // 自动分配剩余空间
@Observed
class SettingMenu {
  public text: string; // 菜单文本
  public content: string;
  public pushUrl: string;
  public obj: ESObject;
  constructor(text: string, content: string,pushUrl: string,obj: ESObject) {
    this.text = text;
    this.content = content;
    this.pushUrl = pushUrl;
    this.obj = obj;
  }
}
@Component
export struct SettingItemView {
  private text: string | Resource = ''; // 功能菜单文本
  private content: string = '';
  build() {

    Row() {
      Row() {
        Text(this.text)
          .fontSize(16)
          .fontColor("#99182431")
          .margin({ left: 12 })
          .layoutWeight(LAYOUT_WEIGHT)
          .lineHeight(22)
          .width('50%')
        Text(this.content)
          .fontSize(14)
          .fontColor("#99182431")
          .layoutWeight(LAYOUT_WEIGHT)
          .margin({ left: 70 })
          .lineHeight(22)
          .textAlign(TextAlign.Center)
        Image($r('app.media.icon_right_arrow'))
          .height(20)
          .width(10)
          .align(Alignment.End)
          .opacity(0.38)
          .objectFit(ImageFit.Contain)
      }
      .width("100%")
      .height(48)
      .padding({
        left: 12,
        right: 12
      })
      .alignItems(VerticalAlign.Center)
    }
    .width("100%")
    .height(48)
    .alignSelf(ItemAlign.Center)
  }
}
// @Entry
@Component
struct AppSettingPage {
  @State basicMenuGroup: SettingMenu[] = [
    new SettingMenu('智能推荐', '','',null),
    new SettingMenu( '消息设置', '','',null),
    new SettingMenu( '关于应用', 'V6.2.2','AboutApp',null),
  ]; // 基础功能分组
  @State otherMenuGroup: SettingMenu[] = [
    new SettingMenu('账号与安全', '','',null),
    new SettingMenu('隐私政策', '','',null),
    new SettingMenu( '清除缓存(11.99M)', '','',null)
  ]; // 其他功能分组

  @Consume('pageStack') pageStack: NavPathStack;
  // pageStack: NavPathStack = new NavPathStack();
  build() {
    NavDestination(){
      Column() {
        Column() {
          List() {
            ListItem() {
              // 创建基础功能分组
              Row() {
                List() {
                  ForEach(this.basicMenuGroup,
                    (item: SettingMenu) => {
                      ListItem() {
                        SettingItemView({ text: item.text, content: item.content })
                          .onClick(()=>{
                            if(item.pushUrl != null && item.pushUrl != undefined && item.pushUrl != '') {
                              this.pageStack.pushPathByName(item.pushUrl, item.obj)
                            }
                          })
                      }
                    },
                    (item: SettingMenu) => item.text.toString())
                }
                .height(150)
                .divider({
                  strokeWidth: 1,
                  color: "#0c000000",
                  startMargin: 46,
                  endMargin: 24
                })
              }
              .height(155)
              .alignItems(VerticalAlign.Center)
              .margin({ bottom: 12 })
              .borderRadius(24)
              .backgroundColor("#FFFFFF")
            }
            ListItem() {
              // 创建其他功能分组
              List({ space: LIST_SPACE }) {
                ForEach(this.otherMenuGroup,
                  (item: SettingMenu) => {
                    ListItem() {
                      SettingItemView({ text: item.text, content: item.content })
                        .onClick(()=>{
                          if(item.pushUrl != null && item.pushUrl != undefined && item.pushUrl != ''){
                            this.pageStack.pushPathByName(item.pushUrl,item.obj)
                          }
                        })
                    }
                    .height(56)
                    .borderRadius(24)
                    .backgroundColor("#FFFFFF")
                  },
                  (item: SettingMenu) => item.text.toString())
              }
            }
          }
          .layoutWeight(LAYOUT_WEIGHT)
          .margin({ top: 10 })
          Button("退出登录").width('100%').backgroundColor(Color.Blue)
            .onClick(()=>{
              AppStorage.setOrCreate("userAccount",null);
              Logger.error("----------------------> "+ AppStorage.has('userAccount'))
              Logger.error("----------------------> "+ AppStorage.get('userAccount'))
              this.pageStack.clear();
            })
        }
        .backgroundColor('#F1F3F5')
        .width("100%")
        .height("100%")
        .padding({
          left: 12,
          right: 12
        })
        .alignItems(HorizontalAlign.Center)
        .height('90%')
      }
      .width('100%').height('100%')
    }
    .title('设置')
  }
}
