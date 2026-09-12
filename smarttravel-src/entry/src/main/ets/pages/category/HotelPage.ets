import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { LocalImageConstants } from '../../constants/LocalImageConstants';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface HotelItem {
  id: string;
  name: string;
  image: Resource;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  price: string;
  tags: string[];
  description: string;
  facilities: string[];
}

@Entry
@Component
export struct HotelPage {
  @State hotelList: HotelItem[] = [
    {
      id: '1',
      name: '深圳湾万豪酒店',
      image: LocalImageConstants.LUXURY_HOTEL,
      rating: 4.8,
      reviewCount: 1256,
      location: '南山区深圳湾',
      distance: '1.2km',
      price: '¥680/晚',
      tags: ['五星级', '海景', '商务'],
      description: '豪华海景酒店，设施完善，服务一流',
      facilities: ['WiFi', '停车场', '健身房', '游泳池', '餐厅']
    },
    {
      id: '2',
      name: '精品民宿',
      image: LocalImageConstants.BOUTIQUE_HOTEL,
      rating: 4.6,
      reviewCount: 892,
      location: '福田区中心区',
      distance: '2.5km',
      price: '¥280/晚',
      tags: ['民宿', '温馨', '性价比'],
      description: '温馨舒适的精品民宿，交通便利',
      facilities: ['WiFi', '空调', '厨房']
    },
    {
      id: '3',
      name: '经济型酒店',
      image: LocalImageConstants.BUSINESS_HOTEL,
      rating: 4.4,
      reviewCount: 1534,
      location: '罗湖区东门',
      distance: '3.8km',
      price: '¥158/晚',
      tags: ['经济', '便捷', '实惠'],
      description: '价格实惠，位置便利，适合短期住宿',
      facilities: ['WiFi', '空调', '24小时前台']
    },
    {
      id: '4',
      name: '度假村',
      image: LocalImageConstants.RESORT_HOTEL,
      rating: 4.9,
      reviewCount: 567,
      location: '大鹏新区',
      distance: '25km',
      price: '¥1280/晚',
      tags: ['度假', '自然', '休闲'],
      description: '环境优美，设施齐全，适合度假休闲',
      facilities: ['WiFi', '停车场', '健身房', '游泳池', 'SPA', '餐厅', '海滩']
    },
    {
      id: '5',
      name: '商务酒店',
      image: LocalImageConstants.BUSINESS_HOTEL,
      rating: 4.5,
      reviewCount: 768,
      location: '福田区CBD',
      distance: '1.0km',
      price: '¥450/晚',
      tags: ['商务', '便利', '现代化'],
      description: '地理位置优越，适合商务出行',
      facilities: ['WiFi', '停车场', '会议室', '餐厅', '健身房']
    }
  ];

  @State searchKeyword: string = '';

  build() {
    Column() {
      TopNavigationBar({
        title: '住宿',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索酒店...' })
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

      // 酒店列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredHotelList, (item: HotelItem) => {
            this.HotelCard(item)
          }, (item: HotelItem) => item.id)  // 添加keyGenerator
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

  get filteredHotelList(): HotelItem[] {
    if (!this.hotelList || !Array.isArray(this.hotelList)) {
      return [];
    }
    if (!this.searchKeyword) {
      return this.hotelList;
    }
    return this.hotelList.filter(item => 
      item.name.includes(this.searchKeyword) ||
      item.tags.some(tag => tag.includes(this.searchKeyword)) ||
      item.location.includes(this.searchKeyword)
    );
  }

  @Builder HotelCard(item: HotelItem) {
    Column({ space: 12 }) {
      // 酒店图片
      Stack({ alignContent: Alignment.TopStart }) {
        // 使用emoji作为后备显示
        Column() {
          Text(item.image)
            .fontSize(60)
        }
        .width('100%')
        .height(160)
        .backgroundColor('#f0f4f8')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        
        // 评分标签
        Row({ space: 4 }) {
          Text('⭐')
            .fontSize(12)
          Text(item.rating.toFixed(1))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .backgroundColor('rgba(0,0,0,0.7)')
        .borderRadius(12)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .margin({ top: 8, left: 8 })
      }
      
      Column({ space: 8 }) {
        Row() {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .layoutWeight(1)

          Row({ space: 4 }) {
            Text('📍')
              .fontSize(12)
            Text(item.distance)
              .fontSize(12)
              .fontColor('#9ca3af')
          }
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(`(${item.reviewCount}条评价)`)
            .fontSize(12)
            .fontColor('#9ca3af')
            .layoutWeight(1)

          Text(item.price)
            .fontSize(16)
            .fontColor('#ef4444')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')

        // 标签
        Row({ space: 6 }) {
          ForEach(item.tags.slice(0, 3), (tag: string, index: number) => {
            Text(tag)
              .fontSize(11)
              .fontColor('#6366f1')
              .backgroundColor('#eef2ff')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
          }, (tag: string, index: number) => `${item.id}-tag-${index}`)  // 添加keyGenerator
        }
        .width('100%')

        Row({ space: 4 }) {
          Text('📍')
            .fontSize(12)
          Text(item.location)
            .fontSize(12)
            .fontColor('#6b7280')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')

        Text(item.description)
          .fontSize(13)
          .fontColor('#9ca3af')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      ErrorHandler.safeExecute(async (): Promise<void> => {
        await router.pushUrl({
          url: 'pages/detail/HotelDetailPage',
          params: { 
            id: item.id, 
            name: item.name
          }
        });
      }, (error: Error): void => ErrorHandler.handleRouterError(error, '酒店详情页面'));
    })
  }
}

