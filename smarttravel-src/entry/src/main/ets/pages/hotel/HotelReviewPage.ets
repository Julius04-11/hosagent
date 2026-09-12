/**
 * 酒店入住评价页面
 * 参考示例: example_code/UserReview
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

interface QuickDescItem {
  text: string;
  isSelected: boolean;
}

interface ReviewScore {
  dim: string;
  label: string;
  score: number;
}

@Entry
@Component
export struct HotelReviewPage {
  @State reviewText: string = '';
  @State uploadedImages: string[] = [];
  @State selectedImageUris: string[] = [];
  @State comment: string = '';
  
  // 评分数据
  @State reviewScores: ReviewScore[] = [
    { dim: 'overall', label: '综合评分', score: 5 },
    { dim: 'facility', label: '酒店设施', score: 5 },
    { dim: 'service', label: '服务态度', score: 5 },
    { dim: 'environment', label: '酒店环境', score: 5 },
  ];
  
  // 快捷描述选项
  @State quickItems: QuickDescItem[] = [
    { text: '交通便利', isSelected: false },
    { text: '设施完善', isSelected: false },
    { text: '干净卫生', isSelected: false },
    { text: '安静舒适', isSelected: false },
    { text: '服务周到', isSelected: false },
    { text: '性价比高', isSelected: false }
  ];
  
  private starIcon = '★';
  private scoreDescriptions = ['糟糕', '较差', '一般', '满意', '很棒'];
  private hotelId: string = '';
  private orderId: string = '';

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.hotelId = params.hotelId || '';
      this.orderId = params.orderId || '';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()
      
      Scroll() {
        Column() {
          // 评分模块
          this.RatingSection()
          
          // 输入和图片上传模块
          this.CommentSection()
        }
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      
      // 底部提交按钮
      this.SubmitButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // 顶部导航栏
  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text('酒店点评')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text('    ')
        .fontSize(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  // 评分模块
  @Builder RatingSection() {
    Column({ space: 12 }) {
      ForEach(this.reviewScores ?? [], (reviewScore: ReviewScore, index: number) => {
        this.buildRatingItem(reviewScore)
      }, (reviewScore: ReviewScore, index: number) => `score-${reviewScore.dim}-${index}`)
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 12 })
    .backgroundColor('#ffffff')
    .borderRadius(16)
  }

  @Builder buildRatingItem(reviewScore: ReviewScore) {
    Row() {
      Row() {
        Text(reviewScore.label + '：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        // 星星评分
        Row({ space: 4 }) {
          ForEach([1, 2, 3, 4, 5], (selectedScore: number, idx: number) => {
            Text(this.starIcon)
              .fontSize(24)
              .fontColor(selectedScore <= reviewScore.score ? '#FFD700' : '#CCCCCC')
              .onClick(() => {
                reviewScore.score = selectedScore;
                this.reviewScores = [...this.reviewScores];
              })
          }, (selectedScore: number, idx: number) => `star-${reviewScore.dim}-${idx}`)
        }
        .margin({ left: 8 })
      }

      // 评分描述
      Text(this.getScoreDescription(reviewScore.score))
        .fontSize(14)
        .fontColor('#ff9900')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  // 评论和图片模块
  @Builder CommentSection() {
    Column({ space: 16 }) {
      // 评论输入框
      TextArea({
        text: $$this.comment,
        placeholder: '请输入您真实的入住感受（选填）'
      })
        .width('100%')
        .height(160)
        .fontSize(14)
        .placeholderFont({ size: 14 })
        .placeholderColor('#999999')
        .lineHeight(22)
        .borderRadius(8)
        .maxLength(200)
        .showCounter(true)
        .backgroundColor('#f5f5f5')

      // 快捷描述
      Column({ space: 8 }) {
        Text('快捷描述：')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
        
        Grid() {
          ForEach(this.quickItems ?? [], (item: QuickDescItem, index: number) => {
            GridItem() {
              Text(item.text)
                .fontSize(14)
                .fontColor(item.isSelected ? '#0086f6' : '#666666')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(item.isSelected ? '#e6f4ff' : '#f5f5f5')
                .borderRadius(16)
                .onClick(() => {
                  item.isSelected = !item.isSelected;
                  this.quickItems = [...this.quickItems];
                })
            }
          }, (item: QuickDescItem, index: number) => `qdesc-${index}-${item.text}`)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      // 图片上传（占位符）
      Column({ space: 8 }) {
        Text('上传图片：')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
        
        Row() {
          // 上传图片按钮
          Column() {
            Text('📷')
              .fontSize(24)
            Text('上传图片')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .justifyContent(FlexAlign.Center)
          .width(90)
          .height(90)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .onClick(() => {
            promptAction.showToast({
              message: '图片上传功能开发中...',
              duration: 2000
            });
          })
        }
      }
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 10 })
    .backgroundColor('#ffffff')
    .borderRadius(16)
  }

  // 提交按钮
  @Builder SubmitButton() {
    Button('发表评价')
      .width('90%')
      .height(44)
      .margin({ top: 16, bottom: 16 })
      .backgroundColor('#0086f6')
      .fontSize(16)
      .fontColor('#ffffff')
      .onClick(() => {
        this.submitReview();
      })
  }

  // 获取评分描述
  private getScoreDescription(score: number): string {
    if (score >= 1 && score <= this.scoreDescriptions.length) {
      return this.scoreDescriptions[score - 1];
    }
    return '';
  }

  // 提交评价
  private submitReview() {
    // 获取选中的快捷描述
    const selectedQuickDesc = this.quickItems
      .filter(item => item.isSelected)
      .map(item => item.text)
      .join(', ');

    console.log('提交评价:', {
      hotelId: this.hotelId,
      orderId: this.orderId,
      scores: this.reviewScores,
      comment: this.comment,
      quickDesc: selectedQuickDesc,
      images: this.selectedImageUris
    });

    // 显示提交成功提示
    promptAction.showToast({
      message: '感谢您的评价！',
      duration: 2000
    });

    // 返回上一页
    setTimeout(() => {
      router.back();
    }, 1000);
  }
}
