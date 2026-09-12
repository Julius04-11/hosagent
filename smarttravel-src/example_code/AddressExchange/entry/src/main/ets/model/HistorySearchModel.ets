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
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 */

export interface HistoryClass {
  startCityName: Resource;
  endCityName: Resource;
}


export const HISTORYLIST: HistoryClass[] = [
  {
    startCityName: $r('app.string.address_exchange_address_left'),
    endCityName: $r('app.string.nanjing')
  },
  {
    startCityName: $r('app.string.address_exchange_address_left'),
    endCityName: $r('app.string.wlmq')
  },
  {
    startCityName: $r('app.string.nanjing'),
    endCityName: $r('app.string.hangzhou')
  },
  {
    startCityName: $r('app.string.address_exchange_address_shenzhen'),
    endCityName: $r('app.string.nanjing')
  },
  {
    startCityName: $r('app.string.nanjing'),
    endCityName: $r('app.string.address_exchange_address_shenzhen')
  }
];