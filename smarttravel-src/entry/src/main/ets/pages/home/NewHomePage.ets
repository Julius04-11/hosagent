import { router } from '@kit.ArkUI';
import { NavigationUtil } from '../../utils/NavigationUtil';
import {
  shenzhenQuickEntries,
  shenzhenNotices,
  shenzhenAttractions,
  QuickEntryData,
  NoticeData,
  AttractionData
} from '../../viewmodel/ShenzhenData';

@Entry
@Component
struct NewHomePage {
  @State currentCity: string = '深圳市';
  @State currentBannerIndex: number = 0;
  @State openingTime: string = '10:00-22:00';
  @State notices: NoticeData[] = shenzhenNotices;
  @State quickEntries: QuickEntryData[] = shenzhenQuickEntries;
  @State hotAttractions: AttractionData[] = shenzhenAttractions.slice(0, 4);

  // Banner图片列表
  private bannerImages: string[] = [
    'https://picsum.photos/seed/banner1/1200/600',
    'https://picsum.photos/seed/banner2/1200/600',
    'https://picsum.photos/seed/banner3/1200/600'
  ];

  build() {
    Column() {
      // 顶部栏
      this.TopBar()
      
      Scroll() {
        Column() {
          // Banner轮播
          this.BannerSection()
          
          // 快捷入口
          this.QuickEntrySection()
          
          // 营业时间
          this.OpeningTimeCard()
          
          // 公告区域
          this.NoticeSection()
          
          // 推荐内容（保留原有推荐功能）
          this.RecommendSection()
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // 顶部栏
  @Builder TopBar() {
    Row() {
      // 城市定位
      Row({ space: 4 }) {
        Text(this.currentCity)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Text('▼')
          .fontSize(12)
          .fontColor('#666666')
      }
      .onClick(() => {
        // 城市选择
        console.log('选择城市');
      })

      // 搜索框
      Row({ space: 8 }) {
        Text('🔍')
          .fontSize(16)
        Text('搜索...')
          .fontSize(14)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .height(36)
      .backgroundColor('#ffffff')
      .borderRadius(18)
      .padding({ left: 12, right: 12 })
      .margin({ left: 12, right: 12 })
      .onClick(() => {
        NavigationUtil.toSearch();
      })

      // 消息中心
      Stack() {
        Text('🔔')
          .fontSize(24)
        // 红点提示
        Circle()
          .width(8)
          .height(8)
          .fill('#ff4d4f')
          .position({ x: 16, y: 0 })
      }
      .width(32)
      .height(32)
      .onClick(() => {
        NavigationUtil.toMessage();
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#ffffff')
    .padding({ left: 16, right: 16 })
  }

  // Banner轮播区域
  @Builder BannerSection() {
    Column() {
      // 大图Banner
      Stack({ alignContent: Alignment.BottomEnd }) {
        Swiper() {
          ForEach(this.bannerImages ?? [], (image: string, index: number) => {
            Image(image)
              .width('100%')
              .height(220)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
          }, (image: string, index: number) => `banner-${index}`)
        }
        .autoPlay(true)
        .interval(3000)
        .indicator(true)
        .loop(true)
        .onChange((index: number) => {
          this.currentBannerIndex = index;
        })

        // 点击放大提示
        Row({ space: 4 }) {
          Text('点击放大')
            .fontSize(12)
            .fontColor('#ffffff')
          Text('→')
            .fontSize(12)
            .fontColor('#ffffff')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .borderRadius(12)
        .margin(12)
      }
      .width('100%')
      .height(220)

      // 场次时间（如果是景区）
      Row({ space: 16 }) {
        Text('场次时间:')
          .fontSize(13)
          .fontColor('#666666')
        Text('09:30')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0086f6')
        Text('|')
          .fontSize(13)
          .fontColor('#d9d9d9')
        Text('19:30')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0086f6')
      }
      .margin({ top: 12 })

      // 缩略图列表
      Row({ space: 8 }) {
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          Image(this.bannerImages[index % this.bannerImages.length])
            .width(60)
            .height(40)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)
            .border({
              width: this.currentBannerIndex === index ? 2 : 0,
              color: '#0086f6'
            })
            .onClick(() => {
              this.currentBannerIndex = index;
            })
        }, (index: number) => `thumb-${index}`)
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
  }

  // 快捷入口区域（2行5列）
  @Builder QuickEntrySection() {
    Column() {
      Grid() {
        ForEach(this.quickEntries ?? [], (item: QuickEntryData, index: number) => {
          GridItem() {
            Column({ space: 8 }) {
              // 圆形图标
              Stack() {
                Circle()
                  .width(48)
                  .height(48)
                  .fill(item.color)
                  .opacity(0.1)
                
                Text(item.icon)
                  .fontSize(24)
              }
              
              Text(item.name)
                .fontSize(12)
                .fontColor('#333333')
            }
            .width('100%')
            .onClick(() => {
              router.pushUrl({ url: item.url });
            })
          }
        }, (item: QuickEntryData, index: number) => `qe-${index}-${item.name}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(16)
      .height(160)
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .margin({ top: 10 })
  }

  // 营业时间卡片
  @Builder OpeningTimeCard() {
    Row() {
      Column({ space: 4 }) {
        Text('今日开放时间')
          .fontSize(14)
          .fontColor('#666666')
        Text(this.openingTime)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0086f6')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 状态指示
      Row({ space: 4 }) {
        Circle()
          .width(8)
          .height(8)
          .fill('#52c41a')
        Text('营业中')
          .fontSize(12)
          .fontColor('#52c41a')
      }
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .padding(16)
    .margin({ left: 16, right: 16, top: 10 })
  }

  // 公告区域
  @Builder NoticeSection() {
    Row() {
      Row({ space: 8 }) {
        Text('🔊')
          .fontSize(16)
        Text('乐园公告')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .layoutWeight(1)

      Row({ space: 4 }) {
        Text(`1/${this.notices.length}条`)
          .fontSize(12)
          .fontColor('#999999')
        Text('→')
          .fontSize(12)
          .fontColor('#999999')
      }
      .onClick(() => {
        NavigationUtil.toNotice();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
    .backgroundColor('#ffffff')
    .margin({ top: 10 })

    // 公告内容
    Row({ space: 8 }) {
      Text(this.notices[0].title)
        .fontSize(14)
        .fontColor('#0086f6')
      Text('→')
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .height(40)
    .backgroundColor('#f0f8ff')
    .borderRadius(8)
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16, bottom: 16 })
    .onClick(() => {
      // 查看公告详情
      console.log('查看公告详情');
    })
  }

  // 推荐内容区域（保留原有功能）
  @Builder RecommendSection() {
    Column() {
      Row() {
        Text('热门推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('查看更多 →')
          .fontSize(13)
          .fontColor('#0086f6')
          .onClick(() => {
            NavigationUtil.toNatureCategory();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 推荐列表（横向滚动）
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.hotAttractions ?? [], (attraction: AttractionData, index: number) => {
            this.RecommendCard(attraction)
          }, (attraction: AttractionData, index: number) => `hot-${index}-${attraction.name}`)
        }
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .margin({ top: 10, bottom: 20 })
  }

  // 推荐卡片
  @Builder RecommendCard(attraction: AttractionData) {
    Column() {
      Image(attraction.image)
        .width(160)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      Column({ space: 6 }) {
        Text(attraction.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row({ space: 6 }) {
          Text(`⭐ ${attraction.rating}`)
            .fontSize(12)
            .fontColor('#ff9900')
          Text(attraction.location.split('深圳市')[1] || attraction.location)
            .fontSize(11)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        
        // 语音讲解标签
        if (attraction.hasAudio) {
          Row() {
            Text('🎵')
              .fontSize(11)
            Text('语音讲解')
              .fontSize(11)
              .fontColor('#0086f6')
              .margin({ left: 2 })
          }
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .backgroundColor('#e6f4ff')
          .borderRadius(10)
          .onClick(() => {
            // 跳转到语音讲解
            router.pushUrl({
              url: 'pages/attraction/AttractionAudioPage',
              params: {
                audioInfo: {
                  id: attraction.id,
                  title: attraction.name,
                  cover: attraction.image,
                  duration: attraction.audioDuration || '00:00',
                  audioUrl: `audio/${attraction.id}.mp3`
                }
              }
            });
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(8)
      .width('100%')
    }
    .width(160)
    .backgroundColor('#fafafa')
    .borderRadius(8)
    .onClick(() => {
      // 点击卡片跳转到活动详情页
      router.pushUrl({
        url: 'pages/activity/ActivityDetailPage',
        params: { 
          src: attraction.id,
          type: 'attraction'
        }
      });
    })
  }
}
