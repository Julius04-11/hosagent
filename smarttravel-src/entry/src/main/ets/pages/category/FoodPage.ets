import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ImageConstants } from '../../constants/ImageConstants';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface FoodItem {
  id: string;
  name: string;
  image: string;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  price: string;
  tags: string[];
  description: string;
}

@Entry
@Component
export struct FoodPage {
  @State foodList: FoodItem[] = [];
  @State filteredList: FoodItem[] = [];

  private readonly initialFoodList: FoodItem[] = [
    {
      id: '1',
      name: '深圳湾海鲜大排档',
      image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/292/400/300', 'restaurant'),
      rating: 4.8,
      reviewCount: 1256,
      location: '南山区深圳湾',
      distance: '1.2km',
      price: '人均¥120',
      tags: ['海鲜', '大排档', '夜宵'],
      description: '新鲜海鲜，现点现做，环境优雅，适合聚餐'
    },
    {
      id: '2',
      name: '老字号肠粉店',
      image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/293/400/300', 'restaurant'),
      rating: 4.6,
      reviewCount: 892,
      location: '福田区华强北',
      distance: '2.5km',
      price: '人均¥35',
      tags: ['肠粉', '早餐', '老字号'],
      description: '传统广式肠粉，口感嫩滑，价格实惠'
    },
    {
      id: '3',
      name: '川味火锅城',
      image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/294/400/300', 'restaurant'),
      rating: 4.7,
      reviewCount: 1534,
      location: '罗湖区东门',
      distance: '3.8km',
      price: '人均¥150',
      tags: ['火锅', '川菜', '聚餐'],
      description: '正宗川味火锅，麻辣鲜香，食材新鲜'
    },
    {
      id: '4',
      name: '日式料理店',
      image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/295/400/300', 'restaurant'),
      rating: 4.9,
      reviewCount: 567,
      location: '南山区海岸城',
      distance: '0.8km',
      price: '人均¥200',
      tags: ['日料', '寿司', '刺身'],
      description: '精致的日式料理，环境优雅，服务贴心'
    },
    {
      id: '5',
      name: '特色茶餐厅',
      image: ImageConstants.getSafeImageUrl('https://picsum.photos/id/296/400/300', 'restaurant'),
      rating: 4.5,
      reviewCount: 768,
      location: '福田区中心区',
      distance: '1.5km',
      price: '人均¥60',
      tags: ['茶餐厅', '港式', '便餐'],
      description: '地道港式茶餐厅，经典菜品，性价比高'
    }
  ];

  @State searchKeyword: string = '';

  aboutToAppear() {
    // 初始化数据
    this.foodList = [...this.initialFoodList];
    this.updateFilteredList();
    console.log('[FoodPage] aboutToAppear - 美食数据加载完成:', this.foodList.length, '过滤后:', this.filteredList.length);
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '美食',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索美食...' })
        .width('90%')
        .height(40)
        .margin({ top: 12, bottom: 16 })
        .borderRadius(20)
        .backgroundColor('#f5f5f5')
        .padding({ left: 16, right: 16 })
        .fontSize(14)
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.updateFilteredList();
        })

      // 美食列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredList, (item: FoodItem) => {
            this.FoodCard(item)
          }, (item: FoodItem) => item.id) // 添加keyGenerator
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

  /**
   * 更新过滤列表 - 使用方法代替computed属性
   */
  private updateFilteredList() {
    if (!this.searchKeyword) {
      this.filteredList = [...this.foodList];
    } else {
      const filtered = this.foodList.filter(item => 
        item.name.includes(this.searchKeyword) ||
        item.tags.some(tag => tag.includes(this.searchKeyword)) ||
        item.location.includes(this.searchKeyword)
      );
      this.filteredList = [...filtered];
    }
    console.log('[FoodPage] updateFilteredList - 过滤后数量:', this.filteredList.length);
  }

  @Builder FoodCard(item: FoodItem) {
    Column({ space: 12 }) {
      // 美食图片
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(item.image)
          .width('100%')
          .height(180)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .alt('🍽️')
        
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
        .margin({ top: 8, right: 8 })
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
      // 跳转到美食详情页
      router.pushUrl({
        url: 'pages/detail/FoodDetailPage',
        params: { id: item.id, name: item.name }
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
      });
    })
  }
}

