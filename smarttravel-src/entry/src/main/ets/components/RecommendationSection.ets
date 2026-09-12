import { router } from '@kit.ArkUI';
import { ErrorHandler } from '../utils/ErrorHandler';

interface NavigationParams {
  id: string;
  name: string;
  type: string;
}

export interface RecommendationItem {
  id: string;
  title: string;
  image: string;
  rating: number;
  price?: string;
  tags: string[];
  description: string;
  location: string;
  type: string;
}

@Component
export struct RecommendationSection {
  @Prop title: string = '为您推荐';
  @Prop items: RecommendationItem[] = [];
  @Prop categoryType: string = '';

  build() {
    Column() {
      if (this.items.length > 0) {
        // 推荐标题
        Row() {
          Text('🔥')
            .fontSize(18)
            .margin({ right: 8 })
          
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .layoutWeight(1)
          
          Text('查看更多')
            .fontSize(14)
            .fontColor('#6366f1')
            .onClick(() => {
              ErrorHandler.showToast('更多推荐功能开发中...');
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        // 推荐列表
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.items ?? [], (item: RecommendationItem, index: number) => {
              this.RecommendationCard(item)
            }, (item: RecommendationItem, index: number) => `rec-${item.id}-${index}`)
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .backgroundColor('#f8fafc')
    .margin({ bottom: 16 })
  }

  @Builder RecommendationCard(item: RecommendationItem) {
    Column() {
      // 图片
      Stack() {
        Image(item.image)
          .width(160)
          .height(120)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .objectFit(ImageFit.Cover)

        // 评分标签
        if (item.rating > 0) {
          Row() {
            Text('⭐')
              .fontSize(12)
            Text(item.rating.toFixed(1))
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .backgroundColor('rgba(0,0,0,0.6)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .position({ x: 8, y: 8 })
        }

        // 价格标签
        if (item.price) {
          Text(item.price)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#ef4444')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .position({ x: 8, y: '100%' })
            .translate({ y: -28 })
        }
      }
      .width(160)
      .height(120)

      // 内容信息
      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(item.description)
          .fontSize(12)
          .fontColor('#6b7280')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 标签
        if ((item.tags ?? []).length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach((item.tags ?? []).slice(0, 2), (tag: string, index: number) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#6366f1')
                .backgroundColor('#eef2ff')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 4, bottom: 2 })
            }, (tag: string, index: number) => `tag-${item.id}-${index}-${tag}`)
          }
          .width('100%')
        }

        // 位置
        Row() {
          Text('📍')
            .fontSize(10)
          Text(item.location)
            .fontSize(10)
            .fontColor('#9ca3af')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width(160)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.navigateToDetail(item);
    })
  }

  private navigateToDetail(item: RecommendationItem) {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      let targetUrl = '';
      let params: NavigationParams = {
        id: item.id,
        name: item.title,
        type: item.type
      };

      // 根据类型决定跳转的页面
      switch (item.type) {
        case 'hotel':
          targetUrl = 'pages/detail/HotelDetailPage';
          break;
        case 'restaurant':
        case 'food':
          targetUrl = 'pages/detail/FoodDetailPage';
          break;
        case 'transport':
          targetUrl = 'pages/transport/TransportDetailPage';
          break;
        case 'tech':
        case 'attraction':
        case 'activity':
        default:
          targetUrl = 'pages/activity/ActivityDetailPage';
          break;
      }

      await router.pushUrl({
        url: targetUrl,
        params: params
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '详情页面'));
  }
}
