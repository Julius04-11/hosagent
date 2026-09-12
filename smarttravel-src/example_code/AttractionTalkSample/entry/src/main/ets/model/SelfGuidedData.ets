/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

export interface SelfGuidedItem {
  id: string,
  cover: Resource;
  title: Resource;
  description: Resource;
}

export const SELF_GUIDED_DATA: SelfGuidedItem[] = [
  {
    id: '0',
    cover: $r('app.media.ancient_chinese_architecture1'),
    title: $r('app.string.ancient_chinese_architecture1'),
    description: $r('app.string.ancient_chinese_architecture_description')
  },
  {
    id: '1',
    cover: $r('app.media.ancient_chinese_architecture2'),
    title: $r('app.string.ancient_chinese_architecture2'),
    description: $r('app.string.ancient_chinese_architecture_description')
  },
  {
    id: '2',
    cover: $r('app.media.ancient_chinese_architecture3'),
    title: $r('app.string.ancient_chinese_architecture3'),
    description: $r('app.string.ancient_chinese_architecture_description')
  },
  {
    id: '3',
    cover: $r('app.media.ancient_chinese_architecture4'),
    title: $r('app.string.ancient_chinese_architecture4'),
    description: $r('app.string.ancient_chinese_architecture_description')
  },
  {
    id: '4',
    cover: $r('app.media.ancient_chinese_architecture5'),
    title: $r('app.string.ancient_chinese_architecture5'),
    description: $r('app.string.ancient_chinese_architecture_description')
  }
];