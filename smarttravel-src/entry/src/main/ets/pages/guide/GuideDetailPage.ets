import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface GuideSection {
  title: string;
  content: string;
  images?: string[];
}

@Entry
@Component
export struct GuideDetailPage {
  @State guideId: string = '';
  @State guideTitle: string = '深圳旅游完整攻略';
  @State author: string = '旅行达人小王';
  @State authorAvatar: string = '👤';
  @State publishDate: string = '2024-11-20';
  @State views: number = 1256;
  @State likes: number = 328;
  @State isLiked: boolean = false;
  @State isFavorite: boolean = false;
  
  @State sections: GuideSection[] = [
    {
      title: '🎯 行前准备',
      content: '1. 证件准备：身份证、港澳通行证（如需前往香港）\n2. 季节穿搭：深圳气候温暖湿润，建议携带轻便衣物\n3. 必备物品：防晒霜、雨伞、充电宝、舒适的鞋子',
      images: []
    },
    {
      title: '🚇 交通指南',
      content: '深圳地铁线路发达，建议使用地铁出行。可以下载"深圳地铁"APP或使用微信、支付宝扫码乘车。打车建议使用滴滴、高德等网约车平台。',
      images: []
    },
    {
      title: '🏞️ 必游景点',
      content: '1. 世界之窗 - 一天游遍世界\n2. 欢乐谷 - 刺激游乐体验\n3. 深圳湾公园 - 海滨栈道散步\n4. 东部华侨城 - 山海度假胜地\n5. 大梅沙海滨公园 - 免费海滩',
      images: []
    },
    {
      title: '🍜 美食推荐',
      content: '1. 粤式早茶：点都德、陶陶居\n2. 海鲜：南澳海鲜街、蛇口海鲜街\n3. 火锅：海底捞、湊湊\n4. 小吃：东门步行街、华强北\n5. 夜宵：大排档、烧烤',
      images: []
    },
    {
      title: '🏨 住宿建议',
      content: '福田、南山区域交通便利，适合商务出行。罗湖区性价比高。想要度假体验可选择大鹏、东部华侨城附近。',
      images: []
    },
    {
      title: '💰 费用预算',
      content: '人均消费：\n• 经济型：300-500元/天\n• 舒适型：500-1000元/天\n• 豪华型：1000元以上/天\n\n包括：住宿、餐饮、交通、门票',
      images: []
    }
  ];

  aboutToAppear() {
    // 1. 先检查路由参数
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.guideId = params.id;
    }
    
    // 2. 检查意图框架传递的参数（来自小艺AI助手）
    const intentGuideId = AppStorage.get<string>('intentGuideId');
    const intentGuideName = AppStorage.get<string>('intentGuideName');
    const intentGuideLocation = AppStorage.get<string>('intentGuideLocation');
    
    if (intentGuideId) {
      this.guideId = intentGuideId;
      // 清除已使用的参数
      AppStorage.delete('intentGuideId');
    }
    
    if (intentGuideName) {
      this.guideTitle = intentGuideName;
      // 清除已使用的参数
      AppStorage.delete('intentGuideName');
    }
    
    if (intentGuideLocation) {
      // 可以根据位置信息更新内容
      // 清除已使用的参数
      AppStorage.delete('intentGuideLocation');
    }
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '攻略详情',
        showBack: true
      })

      Scroll() {
        Column() {
          this.HeaderSection()
          this.AuthorSection()
          this.ContentSection()
          this.ActionButtons()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder HeaderSection() {
    Column() {
      Text(this.guideTitle)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Text('👁️')
            .fontSize(14)
          Text(`${this.views}`)
            .fontSize(13)
            .fontColor('#6b7280')
        }

        Row({ space: 4 }) {
          Text('❤️')
            .fontSize(14)
          Text(`${this.likes}`)
            .fontSize(13)
            .fontColor('#6b7280')
        }

        Text(this.publishDate)
          .fontSize(13)
          .fontColor('#9ca3af')
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AuthorSection() {
    Row() {
      Text(this.authorAvatar)
        .fontSize(36)
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#f3f4f6')
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      Column() {
        Text(this.author)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
          .margin({ bottom: 4 })

        Text('资深旅游博主')
          .fontSize(13)
          .fontColor('#6b7280')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('关注')
        .fontSize(14)
        .height(32)
        .backgroundColor('#3b82f6')
        .borderRadius(16)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder ContentSection() {
    Column({ space: 20 }) {
      ForEach(this.sections, (section: GuideSection) => {
        this.SectionItem(section)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SectionItem(section: GuideSection) {
    Column() {
      Text(section.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)

      Text(section.content)
        .fontSize(14)
        .fontColor('#4b5563')
        .lineHeight(24)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActionButtons() {
    Row() {
      Column() {
        Text(this.isLiked ? '❤️' : '🤍')
          .fontSize(24)
          .onClick(() => {
            this.isLiked = !this.isLiked;
            this.likes += this.isLiked ? 1 : -1;
          })

        Text('点赞')
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(40)
        .color('#e5e7eb')

      Column() {
        Text(this.isFavorite ? '⭐' : '☆')
          .fontSize(24)
          .onClick(() => {
            this.isFavorite = !this.isFavorite;
          })

        Text('收藏')
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(40)
        .color('#e5e7eb')

      Column() {
        Text('📤')
          .fontSize(24)

        Text('分享')
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceEvenly)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: -2
    })
  }
}
