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

@CustomDialog
export  struct QuitLoginDialog {
  controller?: CustomDialogController
  cancel?: () => void
  confirm?: () => void

  build() {
    Column() {
      Text('是否退出登录?')
        .fontSize(16)
        .fontColor('#E6000000')
        .margin({bottom: 8, top: 24, left: 24, right: 24})
      Row() {
        Text('取消')
          .fontColor('#007DFF')
          .fontSize(16)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            if(this.controller){
              this.controller.close()
            }
            this.cancel!()
          })
        Line().width(1).height(24).backgroundColor('#33000000').margin({left: 4, right: 4})
        Text('确定')
          .fontColor('#FA2A2D')
          .fontSize(16)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            if(this.controller){
              this.controller.close()
            }
            this.confirm!()
          })
      }.height(40)
      .margin({left: 24, right: 24, bottom: 16})
    }.borderRadius(24)
  }
}