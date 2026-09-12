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

export interface FeatureItem {
  id: string;
  image: Resource; // 图片资源
  title: Resource; // 标题文本
}

export const FEATURE_ITEMS: FeatureItem[] = [
  {
    id: 'selfGuided',
    image: $r('app.media.self_guided'),
    title: $r('app.string.self_guided')
  },
  {
    id: 'introduction',
    image: $r('app.media.Introduction'),
    title: $r('app.string.introduction')
  },
  {
    id: 'ticket',
    image: $r('app.media.ticket'),
    title: $r('app.string.ticket')
  },
  {
    id: 'culture_creative',
    image: $r('app.media.culture_creative'),
    title: $r('app.string.culture_creative')
  },
  {
    id: 'catering',
    image: $r('app.media.catering'),
    title: $r('app.string.catering')
  }
];