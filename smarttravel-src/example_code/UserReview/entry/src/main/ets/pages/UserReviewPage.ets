/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { PromptAction } from '@kit.ArkUI'
import { photoSelect } from '../utils/FileUtil';
import { BusinessError } from '@kit.BasicServicesKit';

interface QuickDescItem {
  text: string;
  isSelected: boolean;
}

@ObservedV2
class ReviewScore {
  dim: string;
  label: string;
  @Trace score: number;

  constructor(dim: string, label: string, score: number) {
    this.dim = dim;
    this.label = label;
    this.score = score;
  }
}

@Builder
export function UserReviewPageBuilder(name: string, param: Object) {
  UserReviewPage()
}

/**
 * 酒店入住评价页
 */
@Preview
@ComponentV2
export struct UserReviewPage {
  pageInfos: NavPathStack = new NavPathStack();
  @Local reviewText: string = ''
  @Local uploadedImages: string[] = []
  // 五角星符号
  private starIcon = '★'
  // 评分描述文字
  private scoreDescriptions = ['糟糕', '较差', '一般', '满意', '很棒']
  // 快捷描述选项
  @Local quickItems: QuickDescItem[] = [
    { text: '交通便利', isSelected: false },
    { text: '设施完善', isSelected: false },
    { text: '干净卫生', isSelected: false },
    { text: '安静', isSelected: false }
  ];
  @Local selectedImageUris: Array<string> = [];
  @Local reviewScores: ReviewScore[] = [
    new ReviewScore('overall', '综合评分', 5),
    new ReviewScore('facility', '酒店设施', 5),
    new ReviewScore('service', '服务态度', 5),
    new ReviewScore('environment', '酒店环境', 5),
  ];
  @Local comment: string = '';
  private orderId: string = '';
  @Local handlePopup: boolean = false;
  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  build() {
    NavDestination() {
      Column() {
        Column() {
          // 卡片1: 评分模块
          Column({ space: 12 }) {
            // 评分模块
            ForEach(this.reviewScores, (reviewScore: ReviewScore, index: number) => {
              this.buildRatingSection(reviewScore)
            })
          }
          .padding({
            left: 16,
            right: 16,
            top: 20,
            bottom: 20
          })
          .margin({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(16)

          // 卡片2: 输入区域和图片上传
          Column({ space: 16 }) {
            Column() {
              TextArea({
                text: $$this.comment,
                placeholder: '请输入您真实的入住感受。',
              })
                .width('100%')
                .height(160)
                .fontSize(14)
                .placeholderFont({ size: 14 })
                .lineHeight(19)
                .borderRadius(8)
                .maxLength(120)
                .showCounter(true, { highlightBorder: false })
            }

            // 快捷描述
            Column({ space: 8 }) {
              Text('快捷描述：')
                .fontSize(14)
                .fontColor('#CC000000')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
              Row() {
                Grid() {
                  ForEach(
                    this.quickItems,
                    (item: QuickDescItem) => {
                      GridItem() {
                        this.buildQuickButton(item)
                      }
                    })
                }.columnsGap(2).rowsGap(4)
              }
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 上传图片
            Grid() {
              ForEach(
                this.selectedImageUris,
                (item: string, index: number) => {
                  GridItem() {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(item)
                        .draggable(false)
                        .width(95)
                        .height(90)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                      Image($r('app.media.delete_icon'))
                        .draggable(false)
                        .width(20)
                        .height(20)
                        .margin({ right: 2, top: 2 })
                        .onClick(() => {
                          this.selectedImageUris.splice(index, 1)
                        })
                    }
                  }
                })
              GridItem() {
                if (this.selectedImageUris.length <= 2) {
                  Column() {
                    Image($r('app.media.camera')).draggable(false).width(24)
                    Text('上传图片')
                      .fontColor('#99000000')
                      .fontSize(12)
                      .margin({ top: 8 })
                  }
                  .justifyContent(FlexAlign.Center)
                  .width(90)
                  .height(90)
                  .borderRadius(8)
                  .backgroundColor('#F1F3F5')
                  .onClick(() => {
                    this.selectImage()
                  })
                }
              }
            }
            .width('100%').columnsGap(12).rowsGap(8)
          }
          .padding(16)
          .margin({ top: 8, left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(16)
        }

        // 底部操作栏 (固定在底部)
        Button('发表')
          .width('90%')
          .height(40)
          .margin({ bottom: 10 })
          .onClick(() => {
            // 模拟发起服务器请求
            setTimeout(() => {
              this.submitReview()
            }, 1000)
            // 返回到上一页
            this.pageInfos.pop(this.orderId);
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#F1F3F5')
      .width('100%')
      .height('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .title('酒店点评')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.orderId = context.pathInfo.param as string;
    })
  }

  submitReview() {
    // 提交评论到服务端
    this.submit2Remote();
    // 气泡提示
    try {
      this.promptAction.showToast({
        message: '感谢您的评价',
        alignment: Alignment.Bottom,
        offset: { dx: 0, dy: -64 },
        duration: 800
      })
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`showToast args error code is ${code}, message is ${message}`);
    }
    ;
  }

  submit2Remote() {
  }

  // 选择图片
  async selectImage() {
    // 最多选择三张图片
    let uris = await photoSelect(3 - this.selectedImageUris.length)
    this.selectedImageUris.push(...uris)
  }

  @Builder
  buildQuickButton(quickDescItem: QuickDescItem) {
    Toggle({ type: ToggleType.Button, isOn: quickDescItem.isSelected }) {
      Text(quickDescItem.text)
        .fontColor(quickDescItem.isSelected ? '#0A59F7' : '#B3000000')
        .fontSize(14)
    }
    .onChange((isOn: boolean) => {
      quickDescItem.isSelected = isOn;
      // 更新数组触发响应式重新渲染
      this.quickItems = [...this.quickItems];
    })
  }

  @Builder
  buildRatingSection(reviewScore: ReviewScore) {
    Row() {
      Row() {
        Text(reviewScore.label + '：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#CC000000')

        List({ space: 4 }) {
          ForEach([1, 2, 3, 4, 5], (selectedScore: number) => {
            ListItem() {
              Text(this.starIcon)
                .fontSize(24)
                .fontColor(selectedScore <= reviewScore.score ? '#FFD700' : '#CCCCCC')
                .onClick(() => {
                  reviewScore.score = selectedScore
                })
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .margin({ left: 8 })
        .height(25)
        .width(180)
      }

      // 评分描述文字
      Text(this.getScoreDescription(reviewScore.score))
        .fontSize(14)
        .fontColor('#E6EE6F20')

    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  // 获取评分描述文字
  private getScoreDescription(score: number): string {
    if (score >= 1 && score <= this.scoreDescriptions.length) {
      return this.scoreDescriptions[score - 1]
    }
    return ''
  }
}