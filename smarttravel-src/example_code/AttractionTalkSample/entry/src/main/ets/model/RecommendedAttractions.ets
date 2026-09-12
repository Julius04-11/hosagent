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

/**
 * 展览推荐接口
 */
export interface RecommendedAttractionItem {
  title: string;
  cover: Resource;
  fontSize: number;
  lineHeight: number;
}

export const RECOMMENDED_ATTRACTIONS: RecommendedAttractionItem[] = [
  {
    title: '徽派建筑',
    cover: $r('app.media.hui_style_architecture'),
    fontSize: 16,
    lineHeight: 19
  },
  {
    title: '欧洲建筑风格',
    cover: $r('app.media.european_architectural_style'),
    fontSize: 12,
    lineHeight: 14
  },
  {
    title: '',
    cover: $r('app.media.colosseum'),
    fontSize: 0,
    lineHeight: 0
  }
];