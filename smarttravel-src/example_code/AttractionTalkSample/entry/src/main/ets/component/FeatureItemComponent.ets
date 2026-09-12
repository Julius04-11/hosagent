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
export struct FeatureItemComponent {
  @Prop featureImage: Resource;
  @Prop featureName: Resource;

  build() {
    Column() {
      Image(this.featureImage)
        .borderRadius(12)
        .padding({
          top: 3,
          right: 3,
          bottom: 3,
          left: 3
        });

      Text(this.featureName)
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(18)
        .textAlign(TextAlign.Center);
    };
  }
}