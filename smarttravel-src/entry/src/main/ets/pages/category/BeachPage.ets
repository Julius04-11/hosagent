import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { LocalImageConstants } from '../../constants/LocalImageConstants';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface BeachItem {
  id: string;
  name: string;
  image: Resource;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  tags: string[];
  description: string;
  facilities: string[];
}

@Entry
@Component
export struct BeachPage {
  @State beachList: BeachItem[] = [
    {
      id: '1',
      name: '大梅沙海滨公园',
      image: LocalImageConstants.DAMEISHA_BEACH,
      rating: 4.7,
      reviewCount: 3421,
      location: '盐田区',
      distance: '25km',
      tags: ['海滩', '游泳', '休闲'],
      description: '深圳最著名的海滩之一，沙质细腻，海水清澈',
      facilities: ['更衣室', '淋浴', '停车场', '商店', '餐厅']
    },
    {
      id: '2',
      name: '小梅沙',
      image: LocalImageConstants.DAMEISHA_BEACH,
      rating: 4.6,
      reviewCount: 2156,
      location: '盐田区',
      distance: '28km',
      tags: ['海滩', '度假', '娱乐'],
      description: '风景优美的海滩，配套设施完善，适合度假',
      facilities: ['更衣室', '淋浴', '停车场', '水上项目', '度假村']
    },
    {
      id: '3',
      name: '西涌海滩',
      image: LocalImageConstants.DAMEISHA_BEACH,
      rating: 4.8,
      reviewCount: 1890,
      location: '大鹏新区',
      distance: '50km',
      tags: ['海滩', '原生态', '徒步'],
      description: '原生态海滩，人少景美，适合安静度假',
      facilities: ['停车场', '商店', '露营区']
    },
    {
      id: '4',
      name: '杨梅坑',
      image: LocalImageConstants.DAMEISHA_BEACH,
      rating: 4.9,
      reviewCount: 2345,
      location: '大鹏新区',
      distance: '55km',
      tags: ['海滩', '拍照', '浪漫'],
      description: '电影《美人鱼》取景地，风景绝美，适合拍照',
      facilities: ['停车场', '商店', '民宿', '餐厅']
    },
    {
      id: '5',
      name: '桔钓沙',
      image: LocalImageConstants.DAMEISHA_BEACH,
      rating: 4.5,
      reviewCount: 987,
      location: '大鹏新区',
      distance: '60km',
      tags: ['海滩', '私密', '高端'],
      description: '私密性较好的海滩，环境优雅，适合高端度假',
      facilities: ['停车场', '度假酒店', 'SPA', '餐厅']
    }
  ];

  @State searchKeyword: string = '';

  build() {
    Column() {
      TopNavigationBar({
        title: '海景风光',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索海滩...' })
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

      // 海滩列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredBeachList, (item: BeachItem) => {
            this.BeachCard(item)
          }, (item: BeachItem) => item.id)  // 添加keyGenerator
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

  get filteredBeachList(): BeachItem[] {
    if (!this.beachList || !Array.isArray(this.beachList)) {
      return [];
    }
    if (!this.searchKeyword) {
      return this.beachList;
    }
    return this.beachList.filter(item => 
      item.name.includes(this.searchKeyword) ||
      item.tags.some(tag => tag.includes(this.searchKeyword)) ||
      item.location.includes(this.searchKeyword)
    );
  }

  @Builder BeachCard(item: BeachItem) {
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

            Text(item.distance)
              .fontSize(12)
              .fontColor('#9ca3af')
          }
          .width('100%')

          Row({ space: 8 }) {
            Row({ space: 4 }) {
              Text('⭐')
                .fontSize(12)
              Text(item.rating.toFixed(1))
                .fontSize(14)
                .fontColor('#f59e0b')
              Text(`(${item.reviewCount})`)
                .fontSize(12)
                .fontColor('#9ca3af')
            }
          }
          .width('100%')

          Row({ space: 6 }) {
            ForEach(item.tags, (tag: string, index: number) => {
              Text(tag)
                .fontSize(11)
                .fontColor('#0891b2')
                .backgroundColor('#cffafe')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }, (tag: string, index: number) => `${item.id}-tag-${index}`)  // 添加keyGenerator
          }
          .width('100%')

          Text(item.description)
            .fontSize(13)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.location)
            .fontSize(12)
            .fontColor('#6b7280')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }

      // 设施信息
      if (item.facilities && item.facilities.length > 0) {
        Row({ space: 6 }) {
          Text('🏖️ 设施:')
            .fontSize(12)
            .fontColor('#374151')
            .fontWeight(FontWeight.Medium)

          ForEach(item.facilities.slice(0, 4), (facility: string, index: number) => {
            Text(facility)
              .fontSize(11)
              .fontColor('#6b7280')
              .backgroundColor('#f3f4f6')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(3)
          }, (facility: string, index: number) => `${item.id}-facility-${index}`)  // 添加keyGenerator
        }
        .width('100%')
        .padding({ top: 4 })
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
      ErrorHandler.safeExecute(async () => {
        await router.pushUrl({
          url: 'pages/activity/ActivityDetailPage',
          params: { id: item.id, type: 'beach', name: item.name }
        });
      }, (error: Error): void => ErrorHandler.handleRouterError(error, '景点详情页面'));
    })
  }
}

