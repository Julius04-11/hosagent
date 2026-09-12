import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ResourceManager } from '../../utils/ResourceManager';
import { ImageConstants } from '../../constants/ImageConstants';

interface RestaurantData {
  id: string;
  name: string;
  category: string;
  rating: number;
  reviewCount: number;
  priceRange: string;
  address: string;
  openHours: string;
  phone: string;
  description: string;
  specialties: string[];
  tags: string[];
  images: string[];
  facilities: string[];
}

@Entry
@Component
export struct RestaurantDetailPage {
  @State restaurantId: string = '';
  @State restaurantData: RestaurantData | null = null;
  @State isFavorite: boolean = false;
  @State restaurantImage: Resource = $r('app.media.placeholder');
  
  private resourceManager = ResourceManager.getInstance();

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.restaurantId = params.id;
      await this.loadRestaurantData();
    } else {
      // 加载默认示例数据
      this.loadDefaultData();
    }
  }

  /**
   * 从JSON文件加载餐厅数据
   */
  private async loadRestaurantData() {
    try {
      // TODO: 实际应从rawfile/data/restaurants.json加载
      // const data = await loadJsonData('restaurants.json');
      // this.restaurantData = data.find(r => r.id === this.restaurantId);
      
      // 临时使用默认数据
      this.loadDefaultData();
    } catch (error) {
      console.error('加载餐厅数据失败:', error);
      this.loadDefaultData();
    }
  }

  /**
   * 加载默认示例数据
   */
  private loadDefaultData() {
    this.restaurantData = {
      id: 'restaurant_001',
      name: '深圳湾海鲜大排档',
      category: 'seafood',
      rating: 4.8,
      reviewCount: 856,
      priceRange: '¥120/人',
      address: '南山区深圳湾',
      openHours: '10:00-22:00',
      phone: '0755-12345678',
      description: '新鲜海鲜，现点现做，环境优雅，适合聚餐',
      specialties: ['清蒸石斑鱼', '椒盐濑尿虾', '姜葱炒蟹'],
      tags: ['海鲜', '粤菜', '聚餐'],
      images: ['seafood_restaurant_01.jpg'],
      facilities: ['停车场', '包厢', 'WiFi', '儿童座椅']
    };

    // 使用ResourceManager获取图片
    this.restaurantImage = this.resourceManager.getRestaurantImage('seafood');
  }

  build() {
    Column() {
      TopNavigationBar({ title: '餐厅详情', showBack: true })

      Scroll() {
        Column() {
          // 餐厅图片
          if (this.restaurantData) {
            Image(this.restaurantImage)
              .width('100%')
              .height(250)
              .objectFit(ImageFit.Cover)
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })
              .margin({ bottom: 20 })
          }
          
          if (this.restaurantData) {
            Text(this.restaurantData.name)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            // 标签展示
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.restaurantData?.tags ?? [], (item: string) => {
                Text(item)
                  .fontSize(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor('#eff6ff')
                  .fontColor('#3b82f6')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
              }, (item: string) => item)
            }.margin({ bottom: 16 })

            Row({ space: 8 }) {
              Text(`⭐ ${this.restaurantData.rating}`)
              Text(`(${this.restaurantData.reviewCount}条评价)`)
                .fontSize(14)
                .fontColor('#6b7280')
            }
            .margin({ bottom: 16 })

            Column() {
              Row() {
                Text('📍 位置：').fontColor('#6b7280')
                Text(this.restaurantData.address)
              }.width('100%').margin({ bottom: 8 })

              Row() {
                Text('💰 人均：').fontColor('#6b7280')
                Text(this.restaurantData.priceRange).fontColor('#ef4444')
              }.width('100%').margin({ bottom: 8 })

              Row() {
                Text('⏰ 营业时间：').fontColor('#6b7280')
                Text(this.restaurantData.openHours)
              }.width('100%').margin({ bottom: 8 })

              Row() {
                Text('📞 电话：').fontColor('#6b7280')
                Text(this.restaurantData.phone)
              }.width('100%')
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })

            Column() {
              Text('餐厅介绍')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Text(this.restaurantData.description)
                .fontSize(14)
                .fontColor('#4b5563')
                .lineHeight(22)
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 特色菜品
            Column() {
              Text('招牌特色')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Column({ space: 8 }) {
                ForEach(this.restaurantData?.specialties ?? [], (item: string, index: number) => {
                  Row() {
                    Text(`${index + 1}.`).fontColor('#6b7280').margin({ right: 8 })
                    Text(item).fontSize(15)
                  }.width('100%')
                }, (item: string) => item)
              }
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 设施标签
            Column() {
              Text('餐厅设施')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.restaurantData?.facilities ?? [], (item: string) => {
                  Text(item)
                    .fontSize(14)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor('#f3f4f6')
                    .borderRadius(16)
                    .margin({ right: 8, bottom: 8 })
                }, (item: string) => item)
              }
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })
          }
        }
        .padding({ bottom: 80 })
      }
      .width('100%')
      .layoutWeight(1)

      // 底部操作栏
      Row() {
        Button('收藏')
          .width('45%')
          .height(44)
          .backgroundColor(this.isFavorite ? '#fbbf24' : Color.White)
          .fontColor(this.isFavorite ? Color.White : '#6b7280')
          .border({ width: 1, color: '#e5e7eb' })
          .onClick(() => {
            this.isFavorite = !this.isFavorite;
          })

        Button('立即预订')
          .width('45%')
          .height(44)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .onClick(() => {
            // TODO: 跳转到预订页面
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.1)',
        offsetY: -2
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
