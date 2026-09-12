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

import { ILocalData } from '../viewmodel/LocalDataModel';
import { StyleConstants } from '../constants/StyleConstants';
import { CommonDataSource } from '../utils/CommonDataSource';
import Logger from '../utils/Logger';

@Component
export struct LocalList {
  @Link localList: ILocalData[];
  @Prop column: number = 0;
  private onClickItem? = (Commodity: ILocalData) => {
  };

  aboutToAppear(): void {
  }

  @Builder
  LocalListItem(info: ILocalData) {
    Column() {
      Image(info.advImg)
        .width('100%')
        .layoutWeight(1)
        .borderRadius('10vp')
        .onError((message) => {
          Logger.info('image error ' + JSON.stringify(message));
        })
    }
    .padding('6vp')
    .width(StyleConstants.FULL_WIDTH)
    .height(info.height)
    .borderRadius('8vp')
  }

  build() {
    if (this.localList.length > 0) {

      WaterFlow() {
        LazyForEach(new CommonDataSource<ILocalData>(this.localList), (item: ILocalData) => {
          FlowItem() {
            this.LocalListItem(item)
          }
          .margin({ left: '6vp', right: '6vp' })
          .onClick(() => {
            if (this.onClickItem !== undefined) {
              this.onClickItem(item);
            }
          })
          .width('100%')
        }, (item: ILocalData) => JSON.stringify(item))
      }
      .columnsTemplate("1fr 1fr")
      .width('100%')
    }
  }
}