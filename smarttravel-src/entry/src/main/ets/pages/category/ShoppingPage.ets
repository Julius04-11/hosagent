import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { RecommendationSection, RecommendationItem } from '../../components/RecommendationSection';
import { RecommendationService } from '../../services/RecommendationService';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface ShoppingItem {
  id: string;
  name: string;
  image: string;
  rating: number;
  reviewCount: number;
  location: string;
  distance: string;
  category: string;
  tags: string[];
  description: string;
}

@Entry
@Component
export struct ShoppingPage {
  @State shopList: ShoppingItem[] = [
    {
      id: '1',
      name: '华强北电子市场',
      image: 'https://picsum.photos/id/311/400/300',
      rating: 4.7,
      reviewCount: 2356,
      location: '福田区华强北',
      distance: '2.1km',
      category: '电子产品',
      tags: ['电子产品', '批发', '数码'],
      description: '中国最大的电子产品集散地，品种齐全，价格实惠'
    },
    {
      id: '2',
      name: '万象城购物中心',
      image: 'https://picsum.photos/id/312/400/300',
      rating: 4.8,
      reviewCount: 3421,
      location: '罗湖区万象城',
      distance: '3.5km',
      category: '购物中心',
      tags: ['购物中心', '品牌', '时尚'],
      description: '大型综合购物中心，国际品牌齐全，环境优雅，是深圳高端购物的首选之地'
    },
    {
      id: '3',
      name: '东门步行街',
      image: 'https://picsum.photos/id/313/400/300',
      rating: 4.5,
      reviewCount: 1890,
      location: '罗湖区东门',
      distance: '4.2km',
      category: '步行街',
      tags: ['步行街', '特色', '小吃'],
      description: '深圳最著名的商业步行街，吃喝玩乐一应俱全，深圳老字号商业街'
    },
    {
      id: '4',
      name: '海岸城购物中心',
      image: 'https://picsum.photos/id/314/400/300',
      rating: 4.6,
      reviewCount: 2123,
      location: '南山区海岸城',
      distance: '1.8km',
      category: '购物中心',
      tags: ['购物中心', '美食', '娱乐'],
      description: '集购物、美食、娱乐于一体的大型商业综合体，毗邻深圳湾'
    },
    {
      id: '5',
      name: '深圳湾万象城',
      image: 'https://picsum.photos/id/315/400/300',
      rating: 4.9,
      reviewCount: 2847,
      location: '南山区深圳湾',
      distance: '2.3km',
      category: '购物中心',
      tags: ['高端', '奢侈品', '海景'],
      description: '深圳高端购物中心，汇集国际一线品牌，享受海景购物体验'
    },
    {
      id: '6',
      name: 'COCO Park购物公园',
      image: 'https://picsum.photos/id/316/400/300',
      rating: 4.7,
      reviewCount: 3156,
      location: '福田区购物公园',
      distance: '2.8km',
      category: '购物中心',
      tags: ['时尚', '潮流', '年轻'],
      description: '深圳时尚地标，年轻人的购物天堂，品牌多样，活动丰富'
    },
    {
      id: '7',
      name: 'KK Mall',
      image: 'https://picsum.photos/id/317/400/300',
      rating: 4.6,
      reviewCount: 1567,
      location: '罗湖区笋岗',
      distance: '4.5km',
      category: '购物中心',
      tags: ['亲子', '体验', '美食'],
      description: '体验式购物中心，适合家庭出游，儿童娱乐设施齐全'
    },
    {
      id: '8',
      name: '欢乐海岸OCT Bay',
      image: 'https://picsum.photos/id/318/400/300',
      rating: 4.8,
      reviewCount: 2934,
      location: '南山区华侨城',
      distance: '3.2km',
      category: '商业街区',
      tags: ['滨水', '文创', '夜市'],
      description: '深圳网红打卡地，滨水商业街区，集购物、餐饮、娱乐于一体'
    },
    {
      id: '9',
      name: '壹方城购物中心',
      image: 'https://picsum.photos/id/319/400/300',
      rating: 4.7,
      reviewCount: 2245,
      location: '宝安区宝安中心',
      distance: '8.5km',
      category: '购物中心',
      tags: ['大型', '综合', '停车方便'],
      description: '宝安区最大的购物中心，品牌齐全，停车位充足'
    },
    {
      id: '10',
      name: '益田假日广场',
      image: 'https://picsum.photos/id/320/400/300',
      rating: 4.6,
      reviewCount: 1876,
      location: '福田区福田中心区',
      distance: '1.5km',
      category: '购物中心',
      tags: ['家庭', '亲子', '便利'],
      description: '福田核心商圈，交通便利，适合全家购物休闲'
    },
    {
      id: '11',
      name: '龙岗万达广场',
      image: 'https://picsum.photos/id/321/400/300',
      rating: 4.5,
      reviewCount: 1523,
      location: '龙岗区龙岗中心城',
      distance: '15.2km',
      category: '购物中心',
      tags: ['万达', '影院', '美食'],
      description: '龙岗区域性购物中心，万达影城，美食广场，一站式购物'
    },
    {
      id: '12',
      name: '深业上城',
      image: 'https://picsum.photos/id/322/400/300',
      rating: 4.8,
      reviewCount: 2678,
      location: '福田区皇岗',
      distance: '2.0km',
      category: '商业综合体',
      tags: ['网红', 'loft', '文艺'],
      description: '深圳文艺地标，loft风格，集购物、办公、创意于一体'
    },
    {
      id: '13',
      name: '华润万象天地',
      image: 'https://picsum.photos/id/323/400/300',
      rating: 4.9,
      reviewCount: 3234,
      location: '南山区科技园',
      distance: '3.8km',
      category: '购物中心',
      tags: ['高端', '艺术', '创新'],
      description: '南山科技园高端商业，建筑设计独特，购物体验一流'
    },
    {
      id: '14',
      name: '天虹商场',
      image: 'https://picsum.photos/id/324/400/300',
      rating: 4.4,
      reviewCount: 1345,
      location: '福田区华强北',
      distance: '2.2km',
      category: '百货商场',
      tags: ['百货', '超市', '实惠'],
      description: '深圳老牌百货商场，商品种类丰富，价格亲民'
    },
    {
      id: '15',
      name: '奥特莱斯(深圳龙岗)',
      image: 'https://picsum.photos/id/325/400/300',
      rating: 4.7,
      reviewCount: 987,
      location: '龙岗区坪山',
      distance: '25km',
      category: '折扣店',
      tags: ['折扣', '品牌', '优惠'],
      description: '深圳最大的品牌折扣购物中心，国际品牌3-7折，性价比极高'
    },
    {
      id: '16',
      name: '大梅沙奥特莱斯',
      image: 'https://picsum.photos/id/326/400/300',
      rating: 4.6,
      reviewCount: 856,
      location: '盐田区大梅沙',
      distance: '22km',
      category: '折扣店',
      tags: ['海景', '折扣', '度假'],
      description: '海滨奥特莱斯，购物的同时享受海景，周末度假首选'
    },
    {
      id: '17',
      name: '东部华侨城茶溪谷',
      image: 'https://picsum.photos/id/327/400/300',
      rating: 4.8,
      reviewCount: 1234,
      location: '盐田区大梅沙',
      distance: '20km',
      category: '主题商业',
      tags: ['度假', '文创', '特色'],
      description: '山地度假商业区，特色商品丰富，融合自然与购物体验'
    },
    {
      id: '18',
      name: '龙华九方购物中心',
      image: 'https://picsum.photos/id/328/400/300',
      rating: 4.7,
      reviewCount: 1678,
      location: '龙华区龙华中心',
      distance: '12km',
      category: '购物中心',
      tags: ['地铁直达', '新兴', '便利'],
      description: '龙华新兴商业中心，地铁直达，年轻时尚'
    },
    {
      id: '19',
      name: '水贝珠宝城',
      image: 'https://picsum.photos/id/329/400/300',
      rating: 4.5,
      reviewCount: 2156,
      location: '罗湖区水贝',
      distance: '5.5km',
      category: '专业市场',
      tags: ['珠宝', '批发', '专业'],
      description: '中国最大的珠宝批发市场，款式多样，价格优势明显'
    },
    {
      id: '20',
      name: '笋岗工艺城',
      image: 'https://picsum.photos/id/330/400/300',
      rating: 4.3,
      reviewCount: 876,
      location: '罗湖区笋岗',
      distance: '4.8km',
      category: '专业市场',
      tags: ['工艺品', '家居', '批发'],
      description: '工艺品家居集散地，品种齐全，适合淘货'
    }
  ];

  @State searchKeyword: string = '';

  build() {
    Column() {
      TopNavigationBar({
        title: '购物',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索购物场所...' })
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

      // 购物列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredShopList, (item: ShoppingItem) => {
            this.ShopCard(item)
          }, (item: ShoppingItem) => item.id)  // 添加keyGenerator
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

  get filteredShopList(): ShoppingItem[] {
    if (!this.shopList || !Array.isArray(this.shopList)) {
      return [];
    }
    if (!this.searchKeyword) {
      return this.shopList;
    }
    return this.shopList.filter(item => 
      item.name.includes(this.searchKeyword) ||
      item.tags.some(tag => tag.includes(this.searchKeyword)) ||
      item.location.includes(this.searchKeyword) ||
      item.category.includes(this.searchKeyword)
    );
  }

  @Builder ShopCard(item: ShoppingItem) {
    Column({ space: 12 }) {
      // 购物场所图片
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          Text('🛍️')
            .fontSize(60)
        }
        .width('100%')
        .height(160)
        .backgroundColor('#fef3e8')
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

          Text(item.category)
            .fontSize(12)
            .fontColor('#6366f1')
            .backgroundColor('#eef2ff')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        }
        .width('100%')

        // 标签
        Row({ space: 6 }) {
          ForEach(item.tags.slice(0, 3), (tag: string, index: number) => {
            Text(tag)
              .fontSize(11)
              .fontColor('#10b981')
              .backgroundColor('#d1fae5')
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
      router.pushUrl({
        url: 'pages/activity/ActivityDetailPage',
        params: { id: item.id, type: 'shopping' }
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
      });
    })
  }
}

