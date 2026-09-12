import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { RecommendationSection, RecommendationItem } from '../../components/RecommendationSection';
import { RecommendationService } from '../../services/RecommendationService';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface RouteItem {
  id: string;
  name: string;
  image: string;
  duration: string;
  distance: string;
  difficulty: '简单' | '中等' | '困难';
  tags: string[];
  description: string;
  waypoints: string[];
}

@Entry
@Component
export struct RoutePage {
  @State routeList: RouteItem[] = [
    {
      id: '1',
      name: '深圳湾海滨栈道',
      image: 'https://picsum.photos/id/321/400/300',
      duration: '2-3小时',
      distance: '8公里',
      difficulty: '简单',
      tags: ['海滨', '徒步', '休闲'],
      description: '沿着深圳湾海岸线，欣赏海景和城市风光',
      waypoints: ['起点: 深圳湾公园', '中途: 红树林', '终点: 蛇口码头']
    },
    {
      id: '2',
      name: '梧桐山登山路线',
      image: 'https://picsum.photos/id/322/400/300',
      duration: '4-5小时',
      distance: '12公里',
      difficulty: '困难',
      tags: ['登山', '自然', '挑战'],
      description: '深圳第一高峰，登顶可俯瞰全城',
      waypoints: ['起点: 梧桐山入口', '中途: 好汉坡', '终点: 梧桐山顶']
    },
    {
      id: '3',
      name: '东部华侨城环线',
      image: 'https://picsum.photos/id/323/400/300',
      duration: '全天',
      distance: '15公里',
      difficulty: '中等',
      tags: ['主题公园', '自然', '娱乐'],
      description: '主题公园内的环线游览，包含多个景点',
      waypoints: ['起点: 入口广场', '中途: 茶溪谷', '终点: 大峡谷']
    },
    {
      id: '4',
      name: '莲花山公园环线',
      image: 'https://picsum.photos/id/324/400/300',
      duration: '1-2小时',
      distance: '3公里',
      difficulty: '简单',
      tags: ['公园', '休闲', '亲子'],
      description: '适合全家的轻松步行路线',
      waypoints: ['起点: 南门', '中途: 山顶广场', '终点: 风筝广场']
    },
    {
      id: '5',
      name: '大梅沙海滨路线',
      image: 'https://picsum.photos/id/325/400/300',
      duration: '3-4小时',
      distance: '10公里',
      difficulty: '中等',
      tags: ['海滨', '沙滩', '游泳'],
      description: '海滨度假路线，可以游泳和沙滩活动',
      waypoints: ['起点: 大梅沙海滨公园', '中途: 海滨栈道', '终点: 小梅沙']
    }
  ];

  @State searchKeyword: string = '';

  build() {
    Column() {
      TopNavigationBar({
        title: '旅游路线',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索路线...' })
        .width('90%')
        .height(40)
        .margin({ top: 12, bottom: 16 })
        .borderRadius(20)
        .backgroundColor('#f5f5f5')
        .padding({ left: 16, right: 16 })
        .fontSize(14)
        .onChange((value: string) => {
          this.searchKeyword = value;
        })

      // 路线列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredRouteList, (item: RouteItem) => {
            this.RouteCard(item)
          }, (item: RouteItem) => item.id)  // 添加keyGenerator
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  get filteredRouteList(): RouteItem[] {
    if (!this.routeList || !Array.isArray(this.routeList)) {
      return [];
    }
    if (!this.searchKeyword) {
      return this.routeList;
    }
    return this.routeList.filter(item => 
      item.name.includes(this.searchKeyword) ||
      item.tags.some(tag => tag.includes(this.searchKeyword)) ||
      item.difficulty.includes(this.searchKeyword)
    );
  }

  @Builder RouteCard(item: RouteItem) {
    Column({ space: 12 }) {
      Row() {
        Image(item.image)
          .width(120)
          .height(120)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column({ space: 8 }) {
          Row() {
            Text(item.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .layoutWeight(1)

            Text(item.difficulty)
              .fontSize(12)
              .fontColor(item.difficulty === '简单' ? '#10b981' : item.difficulty === '中等' ? '#f59e0b' : '#ef4444')
              .backgroundColor(item.difficulty === '简单' ? '#d1fae5' : item.difficulty === '中等' ? '#fef3c7' : '#fee2e2')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          .width('100%')

          Text(item.description)
            .fontSize(13)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Text('⏱️')
                .fontSize(14)
              Text(item.duration)
                .fontSize(13)
                .fontColor('#6b7280')
            }

            Row({ space: 4 }) {
              Text('📏')
                .fontSize(14)
              Text(item.distance)
                .fontSize(13)
                .fontColor('#6b7280')
            }
          }
          .width('100%')
          .margin({ top: 4 })

          Row({ space: 6 }) {
            ForEach(item.tags, (tag: string, index: number) => {
              Text(tag)
                .fontSize(11)
                .fontColor('#6366f1')
                .backgroundColor('#eef2ff')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }, (tag: string, index: number) => `${item.id}-tag-${index}`)  // 添加keyGenerator
          }
          .width('100%')
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }

      // 路线途经点
      if (item.waypoints && item.waypoints.length > 0) {
        Column({ space: 6 }) {
          Text('📍 途经点')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .width('100%')

          Column({ space: 4 }) {
            ForEach(item.waypoints, (waypoint: string, index: number) => {
              Row({ space: 6 }) {
                Text(`${index + 1}`)
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor('#6366f1')
                  .width(20)
                  .height(20)
                  .borderRadius(10)
                  .textAlign(TextAlign.Center)
                Text(waypoint)
                  .fontSize(12)
                  .fontColor('#6b7280')
                  .layoutWeight(1)
              }
              .width('100%')
            }, (waypoint: string, index: number) => `${item.id}-waypoint-${index}`)  // 添加keyGenerator
          }
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
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
    .onClick(() => {
      router.pushUrl({
        url: 'pages/activity/ActivityDetailPage',
        params: { id: item.id, type: 'route' }
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
      });
    })
  }
}

