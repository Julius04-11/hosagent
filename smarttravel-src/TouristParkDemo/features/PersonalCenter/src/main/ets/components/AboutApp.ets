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
export function AboutAppBuilder(){
  AboutApp()
}

@Component
export struct AboutApp {
  @State message: string = 'Hello World';
  @Consume('pageStack') pageStack: NavPathStack;
  build() {
    NavDestination() {
      Column(){
        Column({space: 10}){
          Image($r('app.media.app_icon'))
            .width('70vp')
          Text('Ver:6.2.2')
        }
        .width('100%')
        .height('30%')
        .justifyContent(FlexAlign.Center)
        List(){
          ListItem(){
            Row(){
              Text('备案号')
              Text('粤ICP备123123号-2A')
                .margin({right: '30vp'})
                .fontColor(Color.Gray)
            }
            .width('100%')
            .height('10%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({left: '10vp'})
          }
          ListItem(){
            Row(){
              Text('官方网站')
            }
            .width('100%')
            .height('10%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({left: '10vp'})
          }
          ListItem(){
            Row(){
              Text('关注微博')
            }
            .width('100%')
            .height('10%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({left: '10vp'})
          }
          ListItem(){
            Row(){
              Text('关注微信')
            }
            .width('100%')
            .height('10%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({left: '10vp'})
          }
        }
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')

    }
    .title('关于')

  }
}