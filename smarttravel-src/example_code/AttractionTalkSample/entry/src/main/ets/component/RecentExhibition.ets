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

@Component
export struct RecentExhibitionComponent {
  build() {
    Column() {
      Row() {
        Text($r('app.string.recent_exhibitions'))
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
            .fontSize(14)
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
        Image($r('app.media.recent_exhibition'))
          .width(200)
          .height('80%')
          .borderRadius(16)
          .margin({
            left: 15,
            top: -25
          });

        Column() {
          Column() {
            Text($r('app.string.China_National_Ancient_Architecture'))
              .fontWeight(500)
              .fontSize(16)
              .lineHeight(1)
              .fontColor('rgba(0, 0, 0, 0.7)')
              .height('20%')
              .margin({
                bottom: 10,
                right: 26
              });

            Text($r('app.string.exhibition_brief'))
              .fontWeight(500)
              .fontSize(16)
              .lineHeight(1)
              .fontColor('rgba(0, 0, 0, 0.7)')
              .height('20%')
              .margin({
                right: 26
              });
          }
          .width(200)
          .height('30%')
          .justifyContent(FlexAlign.Start)
          .margin({
            bottom: 90
          });

          Text($r('app.string.exhibition_date'))
            .fontWeight(500)
            .fontSize(14)
            .lineHeight(16)
            .fontColor('rgba(0, 0, 0, 0.7)')
            .height('20%')
            .margin({
              top: -40,
              right: 16
            });
        }
        .width(200)
        .height('80%')
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .height('80%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .borderRadius(16)
    .backgroundColor('rgb(255, 255, 255)');
  }
}