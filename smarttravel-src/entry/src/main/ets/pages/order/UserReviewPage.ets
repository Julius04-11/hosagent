/**
 * 酒店入住评价页面
 * 支持星级评分、文字评价、图片上传、标签选择
 */

import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { OrderViewModel } from '../../viewmodel/OrderViewModel';
import { ReviewScore, REVIEW_TAGS } from '../../model/OrderModel';
import { Prompt } from '@kit.ArkUI';

// 路由参数接口
interface RouteParams {
  orderId?: string;
}

// NavDestination上下文接口
interface NavDestinationContext {
  pathStack: NavPathStack;
}

@Entry
@Component
export struct UserReviewPage {
  private viewModel: OrderViewModel = new OrderViewModel();
  private pageInfos?: NavPathStack;
  
  @State orderId: string = '';
  @State hotelName: string = '';
  @State roomType: string = '';
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  
  // 评价数据
  @State reviewScore: ReviewScore = { score: 5 };
  @State reviewContent: string = '';
  @State selectedTags: string[] = [];
  @State reviewImages: string[] = [];
  
  @State isSubmitting: boolean = false;

  aboutToAppear() {
    // 从路由参数获取订单ID
    const params = router.getParams() as RouteParams;
    if (params && params.orderId) {
      this.orderId = params.orderId;
      this.loadOrderInfo();
    }
  }

  // 在NavDestination的onReady中调用（备用方法）
  onReady(context: NavDestinationContext) {
    this.pageInfos = context.pathStack;
    // 如果aboutToAppear中未获取到参数，尝试从这里获取
    if (!this.orderId) {
      const params = router.getParams() as RouteParams;
      if (params && params.orderId) {
        this.orderId = params.orderId;
        this.loadOrderInfo();
      }
    }
  }

  // 加载订单信息
  private async loadOrderInfo() {
    await this.viewModel.initialize();
    const order = this.viewModel.getOrderById(this.orderId);
    if (order) {
      this.hotelName = order.title;
      this.roomType = order.description;
      this.checkInDate = order.checkInDate || '';
      this.checkOutDate = order.checkOutDate || '';
    }
  }

  // 选择星级
  private selectScore(score: number) {
    this.reviewScore.score = score;
  }

  // 切换标签选择
  private toggleTag(tag: string) {
    const index = this.selectedTags.indexOf(tag);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      if (this.selectedTags.length < 3) {
        this.selectedTags.push(tag);
      } else {
        Prompt.showToast({ message: '最多选择3个标签' });
      }
    }
  }

  // 添加图片（模拟）
  private addImage() {
    // 实际应该调用图片选择器
    // 这里使用模拟数据
    if (this.reviewImages.length < 9) {
      this.reviewImages.push(`https://picsum.photos/id/${100 + this.reviewImages.length}/200/200`);
      Prompt.showToast({ message: '图片已添加' });
    } else {
      Prompt.showToast({ message: '最多上传9张图片' });
    }
  }

  // 删除图片
  private removeImage(index: number) {
    this.reviewImages.splice(index, 1);
  }

  // 提交评价
  private async submitReview() {
    if (!this.reviewContent.trim()) {
      Prompt.showToast({ message: '请输入评价内容' });
      return;
    }

    if (this.reviewScore.score < 1 || this.reviewScore.score > 5) {
      Prompt.showToast({ message: '请选择评分' });
      return;
    }

    this.isSubmitting = true;
    try {
      const review = await this.viewModel.submitReview({
        orderId: this.orderId,
        userId: 'user_' + Date.now(), // 实际应该从用户信息获取
        rating: this.reviewScore.score,
        content: this.reviewContent,
        images: this.reviewImages,
        tags: this.selectedTags
      });

      if (review) {
        Prompt.showToast({ message: '评价提交成功！' });
        // 更新订单的评价状态
        const order = this.viewModel.getOrderById(this.orderId);
        if (order) {
          // 标记订单已评价（通过ViewModel更新）
          await this.viewModel.loadReviews(); // 重新加载评价列表
        }
        // 延迟返回，让用户看到成功提示
        setTimeout(() => {
          router.back();
        }, 1500);
      } else {
        Prompt.showToast({ message: '评价提交失败，请重试' });
      }
    } catch (error) {
      console.error('提交评价失败:', error);
      Prompt.showToast({ message: '评价提交失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationBar({
          title: '酒店评价',
          showBack: true
        })

        Scroll() {
          Column({ space: 20 }) {
            // 订单信息卡片
            this.OrderInfoCard()

            // 星级评分
            this.RatingSection()

            // 评价内容
            this.ContentSection()

            // 标签选择
            this.TagsSection()

            // 图片上传
            this.ImagesSection()

            // 提交按钮
            Button('提交评价')
              .width('90%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#1890ff')
              .fontColor(Color.White)
              .enabled(!this.isSubmitting)
              .onClick(() => {
                this.submitReview();
              })
              .margin({ top: 20, bottom: 30 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
  }

  @Builder
  OrderInfoCard() {
    Column({ space: 12 }) {
      Row() {
        Text('订单信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
      }
      .width('100%')

      Divider()
        .color('#e5e7eb')

      Column({ space: 8 }) {
        Row() {
          Text('酒店名称：')
            .fontSize(14)
            .fontColor('#6b7280')
          Text(this.hotelName)
            .fontSize(14)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Row() {
          Text('房型：')
            .fontSize(14)
            .fontColor('#6b7280')
          Text(this.roomType)
            .fontSize(14)
            .fontColor('#1f2937')
        }
        .width('100%')

        Row() {
          Text('入住日期：')
            .fontSize(14)
            .fontColor('#6b7280')
          Text(`${this.checkInDate} 至 ${this.checkOutDate}`)
            .fontSize(14)
            .fontColor('#1f2937')
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  RatingSection() {
    Column({ space: 12 }) {
      Row() {
        Text('整体评分')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
      }
      .width('100%')

      // 星级评分
      Row({ space: 8 }) {
        ForEach([1, 2, 3, 4, 5], (score: number) => {
          Text(this.reviewScore.score >= score ? '⭐' : '☆')
            .fontSize(32)
            .fontColor(this.reviewScore.score >= score ? '#FFD700' : '#CCCCCC')
            .onClick(() => {
              this.selectScore(score);
            })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 评分文字
      Text(this.getRatingText(this.reviewScore.score))
        .fontSize(14)
        .fontColor('#6b7280')
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  ContentSection() {
    Column({ space: 12 }) {
      Row() {
        Text('评价内容')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
        Text(`(${this.reviewContent.length}/500)`)
          .fontSize(12)
          .fontColor('#9ca3af')
      }
      .width('100%')

      TextArea({ placeholder: '分享您的入住体验，帮助其他用户更好地选择...' })
        .width('100%')
        .height(120)
        .fontSize(14)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          if (value.length <= 500) {
            this.reviewContent = value;
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  TagsSection() {
    Column({ space: 12 }) {
      Row() {
        Text('评价标签')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
        Text('(最多3个)')
          .fontSize(12)
          .fontColor('#9ca3af')
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
        ForEach(REVIEW_TAGS, (tag: string) => {
          Text(tag)
            .fontSize(13)
            .fontColor(this.selectedTags.includes(tag) ? '#1890ff' : '#666666')
            .backgroundColor(this.selectedTags.includes(tag) ? '#e6f7ff' : '#f5f5f5')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.toggleTag(tag);
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  ImagesSection() {
    Column({ space: 12 }) {
      Row() {
        Text('上传图片')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
        Text(`(${this.reviewImages.length}/9)`)
          .fontSize(12)
          .fontColor('#9ca3af')
      }
      .width('100%')

      if (this.reviewImages.length > 0) {
        Grid() {
          ForEach(this.reviewImages, (image: string, index: number) => {
            GridItem() {
              Stack() {
                Image(image)
                  .width('100%')
                  .height('100%')
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)

                // 删除按钮
                Column() {
                  Text('×')
                    .fontSize(20)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                }
                .width(24)
                .height(24)
                .backgroundColor('rgba(0,0,0,0.6)')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .position({ x: 0, y: 0 })
                .onClick(() => {
                  this.removeImage(index);
                })
              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
        .height(this.reviewImages.length <= 3 ? 100 : (this.reviewImages.length <= 6 ? 208 : 316))
      }

      // 添加图片按钮
      if (this.reviewImages.length < 9) {
        Row() {
          Column() {
            Text('+')
              .fontSize(32)
              .fontColor('#9ca3af')
            Text('添加图片')
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(100)
        .borderRadius(8)
        .border({
          width: 1,
          color: '#e5e7eb',
          style: BorderStyle.Dashed
        })
        .onClick(() => {
          this.addImage();
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getRatingText(score: number): string {
    const texts = ['', '很差', '较差', '一般', '满意', '非常满意'];
    return texts[score] || '';
  }
}

