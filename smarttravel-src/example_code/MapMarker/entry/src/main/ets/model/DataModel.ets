/*
 *
 *     Copyright (c) 2025 Huawei Device Co., Ltd.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *
 */

export class ShopModel {
  index: number = 1;
  type: Resource = $r('app.string.type1');
  image: Resource = $r('app.media.sushi_food');
  name: Resource = $r('app.string.shop1');
  comment: number = 280;
  money: number = 59;
  score: number = 4.3;
}


export const SHOPS: ShopModel[] = [
  {
    index: 0,
    image: $r('app.media.hum_food'),
    type: $r('app.string.type2'),
    name: $r('app.string.shop2'),
    comment: 80,
    money: 49,
    score: 4.1,
  },
  {
    index: 1,
    image: $r('app.media.sushi_food'),
    type: $r('app.string.type1'),
    name: $r('app.string.shop1'),
    comment: 80,
    money: 59,
    score: 4.3,

  },
  {
    index: 2,
    image: $r('app.media.fish_food'),
    type: $r('app.string.type3'),
    name: $r('app.string.shop3'),
    comment: 1250,
    money: 150,
    score: 4.1,
  }
]
