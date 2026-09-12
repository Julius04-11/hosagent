import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface GuideItem {
  id: string;
  title: string;
  description: string;
  coverImage: string;
  author: string;
  createTime: string;
  updateTime: string;
  views: number;
  likes: number;
  comments: number;
  tags: string[];
  status: 'draft' | 'published' | 'archived';
  content: string;
  locations: string[];
  duration: string;
  difficulty: 'easy' | 'medium' | 'hard';
}

@Entry
@Component
export struct MyGuidesPage {
  @State guideList: GuideItem[] = [
    {
      id: '1',
      title: '深圳一日游完美攻略',
      description: '从早到晚，带你玩转深圳最精华的景点，体验这座现代化都市的魅力。',
      coverImage: 'https://picsum.photos/300/200?random=1',
      author: 'syt',
      createTime: '2024-06-01',
      updateTime: '2024-06-05',
      views: 1250,
      likes: 89,
      comments: 23,
      tags: ['一日游', '深圳', '精华路线'],
      status: 'published',
      content: '详细攻略内容...',
      locations: ['深圳湾公园', '莲花山公园', '东门老街'],
      duration: '1天',
      difficulty: 'easy'
    },
    {
      id: '2',
      title: '深圳美食探店指南',
      description: '精选深圳最地道的餐厅和小吃，从粤菜到川菜，满足你的味蕾。',
      coverImage: 'https://picsum.photos/300/200?random=2',
      author: 'syt',
      createTime: '2024-06-02',
      updateTime: '2024-06-06',
      views: 980,
      likes: 67,
      comments: 18,
      tags: ['美食', '探店', '粤菜'],
      status: 'published',
      content: '美食攻略内容...',
      locations: ['谭师傅私房菜', '一旬一味', '东门小吃街'],
      duration: '半天',
      difficulty: 'easy'
    },
    {
      id: '3',
      title: '深圳夜景拍摄攻略',
      description: '专业摄影师教你如何拍摄深圳最美的夜景，包含最佳拍摄点和技巧。',
      coverImage: 'https://picsum.photos/300/200?random=3',
      author: 'syt',
      createTime: '2024-06-03',
      updateTime: '2024-06-07',
      views: 756,
      likes: 45,
      comments: 12,
      tags: ['摄影', '夜景', '技巧'],
      status: 'published',
      content: '摄影攻略内容...',
      locations: ['深圳湾', '莲花山', '平安金融中心'],
      duration: '2-3小时',
      difficulty: 'medium'
    },
    {
      id: '4',
      title: '深圳户外徒步路线',
      description: '探索深圳周边的自然风光，推荐几条适合不同难度级别的徒步路线。',
      coverImage: 'https://picsum.photos/300/200?random=4',
      author: 'syt',
      createTime: '2024-06-04',
      updateTime: '2024-06-08',
      views: 634,
      likes: 38,
      comments: 8,
      tags: ['徒步', '户外', '自然'],
      status: 'draft',
      content: '徒步攻略内容...',
      locations: ['梧桐山', '七娘山', '马峦山'],
      duration: '1-2天',
      difficulty: 'hard'
    },
    {
      id: '5',
      title: '深圳购物攻略',
      description: '从奢侈品到平价商品，从商场到夜市，全面覆盖深圳购物指南。',
      coverImage: 'https://picsum.photos/300/200?random=5',
      author: 'syt',
      createTime: '2024-06-05',
      updateTime: '2024-06-09',
      views: 892,
      likes: 52,
      comments: 15,
      tags: ['购物', '商场', '夜市'],
      status: 'published',
      content: '购物攻略内容...',
      locations: ['华强北', '东门', '海岸城'],
      duration: '1天',
      difficulty: 'easy'
    }
  ];

  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '已发布', '草稿', '已归档'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '我的攻略',
        showBack: true,
        showSearch: true,
        showNotification: false
      })

      // 统计信息
      this.StatisticsCard()

      // 标签页
      this.TabBar()

      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder StatisticsCard() {
    Column() {
      Row() {
        Column() {
          Text('5')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('攻略总数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('4')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('已发布')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('草稿')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('4512')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3b82f6')
          Text('总阅读')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder TabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Text(tab)
          .fontSize(14)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#3b82f6' : '#6b7280')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = index;
          })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ContentArea() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredGuides(), (guide: GuideItem) => {
          this.GuideCard(guide)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder GuideCard(guide: GuideItem) {
    Column() {
      Row() {
        // 封面图片
        Image(guide.coverImage)
          .width(100)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .margin({ right: 12 })

        // 内容信息
        Column() {
          // 标题和状态标签
          Row() {
            Text(guide.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getStatusText(guide.status))
              .fontSize(10)
              .fontColor(this.getStatusColor(guide.status))
              .backgroundColor(this.getStatusBgColor(guide.status))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 描述
          Text(guide.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          // 难度和时长
          Row() {
            Text('⏱️')
              .fontSize(12)
              .margin({ right: 4 })
            Text(guide.duration)
              .fontSize(12)
              .fontColor('#6b7280')

            Text('📊')
              .fontSize(12)
              .margin({ left: 12, right: 4 })
            Text(this.getDifficultyText(guide.difficulty))
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 统计信息
          Row() {
            Text('👁️')
              .fontSize(12)
              .margin({ right: 2 })
            Text(guide.views.toString())
              .fontSize(12)
              .fontColor('#6b7280')

            Text('❤️')
              .fontSize(12)
              .margin({ left: 12, right: 2 })
            Text(guide.likes.toString())
              .fontSize(12)
              .fontColor('#6b7280')

            Text('💬')
              .fontSize(12)
              .margin({ left: 12, right: 2 })
            Text(guide.comments.toString())
              .fontSize(12)
              .fontColor('#6b7280')

            Blank()

            Text(`更新于 ${guide.updateTime}`)
              .fontSize(10)
              .fontColor('#9ca3af')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(guide.tags, (tag: string) => {
          Text(`#${tag}`)
            .fontSize(10)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ right: 6, bottom: 4 })
        })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 操作按钮
      Row() {
        Button('查看攻略')
          .fontSize(12)
          .fontColor('#3b82f6')
          .backgroundColor('#dbeafe')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.viewGuide(guide.id);
          })

        if (guide.status === 'draft') {
          Button('继续编辑')
            .fontSize(12)
            .fontColor('#f59e0b')
            .backgroundColor('#fef3c7')
            .borderRadius(8)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ left: 8 })
            .onClick(() => {
              this.editGuide(guide.id);
            })
        }

        Blank()

        Button('分享')
          .fontSize(12)
          .fontColor('#10b981')
          .backgroundColor('#d1fae5')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.shareGuide(guide.id);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getFilteredGuides(): GuideItem[] {
    switch (this.selectedTab) {
      case 1: // 已发布
        return this.guideList.filter(guide => guide.status === 'published');
      case 2: // 草稿
        return this.guideList.filter(guide => guide.status === 'draft');
      case 3: // 已归档
        return this.guideList.filter(guide => guide.status === 'archived');
      default: // 全部
        return this.guideList;
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'published': return '已发布';
      case 'draft': return '草稿';
      case 'archived': return '已归档';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'published': return '#10b981';
      case 'draft': return '#f59e0b';
      case 'archived': return '#6b7280';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'published': return '#d1fae5';
      case 'draft': return '#fef3c7';
      case 'archived': return '#f3f4f6';
      default: return '#f3f4f6';
    }
  }

  private getDifficultyText(difficulty: string): string {
    switch (difficulty) {
      case 'easy': return '简单';
      case 'medium': return '中等';
      case 'hard': return '困难';
      default: return '未知';
    }
  }

  private viewGuide(id: string): void {
    router.pushUrl({ 
      url: 'pages/guide/GuideDetailPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转攻略详情页失败:', error.message);
    });
  }

  private editGuide(id: string): void {
    router.pushUrl({ 
      url: 'pages/guide/GuideEditPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转攻略编辑页失败:', error.message);
    });
  }

  private shareGuide(id: string): void {
    // 分享功能实现
    console.log(`分享攻略: ${id}`);
  }
}
