import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { LocalImageConstants } from '../../constants/LocalImageConstants';

interface NatureItem {
  id: string;
  name: string;
  image: Resource;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  tags: string[];
  description: string;
}

@Entry
@Component
export struct NaturePage {
  @State natureList: NatureItem[] = [
    {
      id: '1',
      name: '梧桐山国家森林公园',
      image: LocalImageConstants.LIANHUA_MOUNTAIN,
      rating: 4.8,
      reviewCount: 2156,
      location: '罗湖区',
      distance: '8km',
      tags: ['森林公园', '登山', '自然'],
      description: '深圳第一高峰，原始森林覆盖，空气清新，是登山爱好者的天堂'
    },
    {
      id: '2',
      name: '深圳湾红树林',
      image: LocalImageConstants.SHENZHEN_BAY_PARK,
      rating: 4.7,
      reviewCount: 1890,
      location: '南山区',
      distance: '5km',
      tags: ['红树林', '观鸟', '湿地'],
      description: '国家级自然保护区，候鸟栖息地，生态优美'
    },
    {
      id: '3',
      name: '马峦山郊野公园',
      image: LocalImageConstants.LIANHUA_MOUNTAIN,
      rating: 4.6,
      reviewCount: 1234,
      location: '坪山区',
      distance: '35km',
      tags: ['郊野公园', '瀑布', '徒步'],
      description: '自然风光优美，有多个瀑布，适合徒步和野餐'
    },
    {
      id: '4',
      name: '羊台山森林公园',
      image: LocalImageConstants.SHENZHEN_BAY_PARK,
      rating: 4.5,
      reviewCount: 987,
      location: '宝安区',
      distance: '25km',
      tags: ['森林公园', '登山', '休闲'],
      description: '深圳第二高峰，绿树成荫，适合休闲登山'
    },
    {
      id: '5',
      name: '洪湖公园',
      image: LocalImageConstants.LIANHUA_MOUNTAIN,
      rating: 4.4,
      reviewCount: 756,
      location: '罗湖区',
      distance: '6km',
      tags: ['公园', '荷花', '休闲'],
      description: '以荷花著称的公园，夏季荷花盛开，景色优美'
    }
  ];

  @State searchKeyword: string = '';

  build() {
    Column() {
      TopNavigationBar({
        title: '自然风光',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索自然景点...' })
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

      // 自然景点列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredNatureList ?? [], (item: NatureItem) => {
            this.NatureCard(item)
          }, (item: NatureItem) => item.id)  // 添加keyGenerator
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

  get filteredNatureList(): NatureItem[] {
    if (!this.natureList || !Array.isArray(this.natureList)) {
      return [];
    }
    if (!this.searchKeyword) {
      return this.natureList;
    }
    return this.natureList.filter(item => 
      item.name.includes(this.searchKeyword) ||
      (item.tags ?? []).some(tag => tag.includes(this.searchKeyword)) ||
      item.location.includes(this.searchKeyword)
    );
  }

  @Builder NatureCard(item: NatureItem) {
    Row() {
      Image(item.image)
        .width(100)
        .height(100)
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
          ForEach((item.tags ?? []), (tag: string, index: number) => {
            Text(tag)
              .fontSize(11)
              .fontColor('#10b981')
              .backgroundColor('#d1fae5')
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
    .width('100%')
    .padding(12)
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
        params: { id: item.id, type: 'nature' }
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
      });
    })
  }
}

