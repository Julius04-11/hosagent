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

export class ButtonInfoModel {
  index: number = 0;
  img: Resource | string = $r('app.media.ic_home_normal');
  selectImg: Resource | string  = $r('app.media.ic_home_focus');
  title: Resource | string = $r('app.string.home');
}

const buttonInfo: ButtonInfoModel[] = [
  {
    index: 0,
    img: $r('app.media.home'),
    selectImg: $r('app.media.home_choose'),
    title: $r('app.string.home')
  },
  {
    index: 1,
    img: $r('app.media.play'),
    selectImg: $r('app.media.play_choose'),
    title: '游园'
  },
  {
    index: 2,
    img: $r('app.media.map'),
    selectImg: $r('app.media.map_choose'),
    title: '地图'
  },
  {
    index: 3,
    img: $r('app.media.mine'),
    selectImg: $r('app.media.mine_choose'),
    title: $r('app.string.mine')
  }
]

export { buttonInfo }