/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 房屋信息
export class HouseInfo {
  content: string;
  title: string;

  constructor(content: string, title: string) {
    this.content = content;
    this.title = title;
  }
}

// 租房信息
export class RentalInfo {
  rental: HouseInfo;
  houseInfo: HouseInfo[];
  label: string[];

  constructor(rental: HouseInfo, houseInfo: HouseInfo[], label: string[]) {
    this.rental = rental;
    this.houseInfo = houseInfo;
    this.label = label;
  }
}

export const HOUSE: RentalInfo = new RentalInfo(
  new HouseInfo('1200', '元/月(月付)'),
  [new HouseInfo('2室1厅', '整租'),
    new HouseInfo('75m²', '建筑面积'),
    new HouseInfo('南|北', '朝向'),
    new HouseInfo('18/19层', '楼层')],
  ['有电梯', '近地铁', '民水民电'])
