
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
export function MessagePageBuilder(){
  MessagePage()
}
@Entry
@Component
export struct MessagePage {
  private dataSource: number[] = [0,1,2,3,4,5,6,7,8,9]
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  @Consume('pageStack') pageStack: NavPathStack;
  // pageStack: NavPathStack = new NavPathStack();
  aboutToAppear(): void {

  }

  @Builder
  MessageItem() {
    Column() {
      Text('消息消息消息消息消息').align(Alignment.Start)
    }.width('100%')
  }

  @Builder
  MesTab() {
    Tabs({ barPosition: BarPosition.Start, index: this.currentIndex,controller: this.controller  }) {
      TabContent() {
        List() {
          ForEach(this.dataSource, (item: number) => {
            ListItem() {
              this.MessageItem()
            }
          }, (item: number) => JSON.stringify(item)
          )
        }.scrollBar(BarState.Off)
      }
      .tabBar('活动广播')
      .tabIndex(0)

      TabContent() {
        List() {
          ForEach(this.dataSource, (item: number) => {
            ListItem() {
              this.MessageItem()
            }
          }, (item: number) => JSON.stringify(item)
          )
        }.scrollBar(BarState.Off)
      }
      .tabBar('个人消息')
      .tabIndex(1)
      .onClick(()=>{
        this.pageStack.pushPathByName("LoginPage",null)
      })
    }
    .onChange((index: number)=>{
      if ( index == 1 ){
        this.currentIndex = 0
        this.pageStack.pushPathByName("LoginPage",null)
      }
    })
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          this.MesTab()
        }
        .width('100%')
      }
      .height('100%')
    }.title('消息')
    // .onReady((context: NavDestinationContext) => {
    //   this.pageStack = context.pathStack
    // })
  }
}

