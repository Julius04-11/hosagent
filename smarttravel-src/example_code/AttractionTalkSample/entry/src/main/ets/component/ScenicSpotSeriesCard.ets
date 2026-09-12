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
import { common } from '@kit.AbilityKit';

@Component
export struct ScenicSpotSeriesCardComponent {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Prop cover: Resource;
  @Prop title: Resource;
  @Prop description: Resource;
  showDescription: string = this.context.resourceManager.getStringSync(this.description.id);

  build() {
    Row() {
      Image(this.cover)
        .width('40%')
        .height('80%')
        .borderRadius(16)
        .margin({
          top: 5,
          right: 10,
          bottom: 5,
          left: 10
        });

      Column() {
        Text(this.title)
          .fontWeight(500)
          .fontSize(18)
          .lineHeight(22)
          .align(Alignment.Start)
          .fontColor('rgba(0, 0, 0, 0.9)')
          .width('100%');

        Text(this.description)
          .fontWeight(400)
          .fontSize(12)
          .lineHeight(20)
          .width('95%')
          .align(Alignment.Start)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .margin({
            top: 10
          })
          .maxLines(3);
      }
      .height('70%')
      .width('50%')
      .justifyContent(FlexAlign.Start);
    }
    .height('100%')
    .width('100%')
    .borderRadius(16)
    .backgroundColor('rgb(255, 255, 255)');
  }

  aboutToAppear(): void {
    this.showDescription = this.context.resourceManager.getStringSync(this.description.id);
  }
}