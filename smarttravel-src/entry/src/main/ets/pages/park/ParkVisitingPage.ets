import { router } from '@kit.ArkUI';
import {
  shenzhenAttractions,
  shenzhenRoutes,
  AttractionData,
  TourRouteData
} from '../../viewmodel/ShenzhenData';

@Entry
@Component
struct ParkVisitingPage {
  @State currentShowIndex: number = 0;
  @State showTimes: string[] = ['09:30', '13:30', '16:00', '19:30'];
  @State attractions: AttractionData[] = shenzhenAttractions;
  @State routes: TourRouteData[] = shenzhenRoutes;
  
  // 演出/活动海报图片
  private showImages: string[] = [
    'https://picsum.photos/seed/show1/1200/600',
    'https://picsum.photos/seed/show2/1200/600',
    'https://picsum.photos/seed/show3/1200/600'
  ];

  build() {
    Column() {
      // 顶部导航栏（可选）
      this.TopBar()
      
      Scroll() {
        Column() {
          // 演出/活动海报区域
          this.ShowSection()
          
          // 玩乐项目区域
          this.AttractionsSection()
          
          // 路线推荐（整合现有路线功能）
          this.RouteSection()
          
          // 旅游攻略
          this.TipsSection()
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // 顶部导航栏
  @Builder TopBar() {
    Row() {
      Text('← ')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text('游园')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
      
      Text('🔍')
        .fontSize(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/search/SearchPage' });
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  // 演出/活动海报区域
  @Builder ShowSection() {
    Column() {
      // 大图海报
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper() {
          ForEach(this.showImages ?? [], (image: string, index: number) => {
            Image(image)
              .width('100%')
              .height(200)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
          }, (image: string, index: number) => `show-${index}`)
        }
        .autoPlay(true)
        .interval(3000)
        .indicator(true)
        .loop(true)
        .onChange((index: number) => {
          this.currentShowIndex = index;
        })

        // 演出信息覆盖层
        Column() {
          Text('深圳欢乐谷精彩演出')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .margin({ bottom: 6 })
          
          Row({ space: 8 }) {
            Text('场次时间:')
              .fontSize(13)
              .fontColor('#ffffff')
            Text(this.showTimes.join(' | '))
              .fontSize(13)
              .fontColor('#ffffff')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      }
      .width('100%')
      .height(200)

      // 缩略图列表
      Row({ space: 8 }) {
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          Image(this.showImages[index % this.showImages.length])
            .width(64)
            .height(48)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)
            .border({
              width: this.currentShowIndex === index ? 3 : 0,
              color: '#0086f6'
            })
            .onClick(() => {
              this.currentShowIndex = index;
            })
        }, (index: number) => `thumb-${index}`)
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
  }

  // 玩乐项目区域
  @Builder AttractionsSection() {
    Column() {
      // 标题行
      Row() {
        Text('玩乐项目')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Row({ space: 4 }) {
          Text('全部')
            .fontSize(13)
            .fontColor('#0086f6')
          Text('→')
            .fontSize(12)
            .fontColor('#0086f6')
        }
        .onClick(() => {
          // 查看全部项目
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 项目网格（2列）
      Grid() {
        ForEach((this.attractions ?? []).slice(0, 6), (item: AttractionData, index: number) => {
          GridItem() {
            this.AttractionCard(item)
          }
        }, (item: AttractionData, index: number) => `attraction-${item.id ?? index}`)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .height(640)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .margin({ top: 10 })
  }

  // 玩乐项目卡片
  @Builder AttractionCard(item: AttractionData) {
    Column() {
      Image(item.image)
        .width('100%')
        .height(140)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      Column({ space: 6 }) {
        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row() {
          Text(item.subtitle)
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1)
          
          Text(`⭐${item.rating}`)
            .fontSize(12)
            .fontColor('#ff9900')
        }
        .width('100%')
        
        // 语音讲解按钮
        if (item.hasAudio) {
          Row() {
            Text('🎵')
              .fontSize(12)
            Text('语音讲解')
              .fontSize(12)
              .fontColor('#0086f6')
              .margin({ left: 4 })
            Text(`${item.audioDuration}`)
              .fontSize(11)
              .fontColor('#999999')
              .margin({ left: 4 })
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#e6f4ff')
          .borderRadius(12)
          .onClick(() => {
            // 跳转到语音讲解页面
            router.pushUrl({
              url: 'pages/attraction/AttractionAudioPage',
              params: {
                audioInfo: {
                  id: item.id,
                  title: item.name,
                  cover: item.image,
                  duration: item.audioDuration || '00:00',
                  audioUrl: `audio/${item.id}.mp3`
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
    .backgroundColor('#fafafa')
    .borderRadius(8)
  }

  // 路线推荐区域（整合现有路线功能）
  @Builder RouteSection() {
    Column() {
      Row() {
        Text('🗺️ 推荐路线')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('查看更多 →')
          .fontSize(13)
          .fontColor('#0086f6')
          .onClick(() => {
            router.pushUrl({ url: 'pages/category/RoutePage' });
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.routes ?? [], (route: TourRouteData, index: number) => {
            this.RouteCard(route)
          }, (route: TourRouteData, index: number) => `route-${route.id ?? index}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .margin({ top: 10 })
  }

  // 路线卡片
  @Builder RouteCard(route: TourRouteData) {
    Column() {
      Image(route.image)
        .width(180)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      Column() {
        Text(route.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })
        
        Row({ space: 6 }) {
          Text(`⏱️ ${route.duration}`)
            .fontSize(12)
            .fontColor('#999999')
          Text('|')
            .fontSize(12)
            .fontColor('#d9d9d9')
          Text(`📍 ${route.spots.length}个景点`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(8)
    }
    .width(180)
    .backgroundColor('#fafafa')
    .borderRadius(8)
    .onClick(() => {
      console.log('路线详情:', route.name);
    })
  }

  // 旅游攻略区域
  @Builder TipsSection() {
    Column() {
      Row() {
        Text('📖 旅游攻略')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('更多 →')
          .fontSize(13)
          .fontColor('#0086f6')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column({ space: 12 }) {
        ForEach([1, 2, 3], (index: number) => {
          this.TipItem()
        }, (index: number) => `tip-${index}`)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .margin({ top: 10, bottom: 20 })
  }

  // 攻略条目
  @Builder TipItem() {
    Row() {
      Image('https://picsum.photos/seed/tip1/400/400')
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      Column() {
        Text('游园必备攻略指南')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
        
        Row({ space: 8 }) {
          Text('👁️ 1.2万')
            .fontSize(12)
            .fontColor('#999999')
          Text('💬 156')
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fafafa')
    .borderRadius(8)
  }
}
