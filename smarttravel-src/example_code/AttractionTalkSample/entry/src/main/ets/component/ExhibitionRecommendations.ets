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

import { RecommendedAttractionItem, RECOMMENDED_ATTRACTIONS } from '../model/RecommendedAttractions';
import { RecommendedAttractionsComponent } from './RecommendedAttractions';

@Component
export struct ExhibitionRecommendationsComponent {
  build() {
    Column() {
      Row() {
        Text($r('app.string.exhibition_recommendation'))
          .fontSize(18)
          .fontWeight(700)
          .lineHeight(24)
          .align(Alignment.Start)
          .margin({
            top: 10,
            left: 15
          });

        Row() {
          Text($r('app.string.all'))
            .fontWeight(400)
            .fontSize(16)
            .lineHeight(16)
            .align(Alignment.Start)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .margin({
              right: 10
            });

          Image($r('app.media.chevron_right'))
            .width(10)
            .height(23);
        }
        .margin({
          top: 10,
          right: 15
        });
      }
      .width('100%')
      .height('20%')
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        ForEach(RECOMMENDED_ATTRACTIONS, (item: RecommendedAttractionItem) => {
          RecommendedAttractionsComponent({
            title: item.title,
            cover: item.cover,
            fontSize: item.fontSize,
            lineHeight: item.lineHeight
          })
            .width('33%')
            .margin({
              left: 10
            });
        });
      }
      .margin({
        top: 10,
        left: 10
      })
      .width('100%')
      .height('80%');
    }
    .backgroundColor('rgb(255, 255, 255)')
    .borderRadius(16);
  }
}