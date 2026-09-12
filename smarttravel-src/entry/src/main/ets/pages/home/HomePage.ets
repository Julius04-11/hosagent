import { App } from "@kit.ArkUI";
import { router } from '@kit.ArkUI';
import { LocationBubble } from '../../components/LocationBubble';
import { SmartRecommendationList } from '../../components/SmartRecommendationComponents';
import { ActivityDetail } from '../../model/ActivityModel';
import { BehaviorType, PreferenceType } from '../../model/UserBehaviorModel';
import { HomeViewModel } from '../../viewmodel/HomeViewModel';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { ImageConstants } from '../../constants/ImageConstants';

interface ListItemInfo {
  image: Resource;
  title: string;
  description: string;
}

// ExplorePage.ets
@Component
export struct HomePage {
  // ViewModel实例
  private viewModel: HomeViewModel = new HomeViewModel();
  
  // UI状态 - 从ViewModel同步
  @State swiperIndex: number = 0;
  @State deviceWidth: number = 0;
  @State maxCount: number = 1;
  @State userId: string = '';
  @State availableActivities: ActivityDetail[] = [];
  @State showAIRecommendations: boolean = true;
  @State recommendedImages: string[] = [];
  @State ListInfos: ListItemInfo[] = [];

  async aboutToAppear() {
    console.log('[HomePage] aboutToAppear - 开始初始化');
    try {
      await this.viewModel.initialize();
      // 确保数据同步到UI
      this.syncStateFromViewModel();
      console.log('[HomePage] 数据加载完成，ListInfos长度:', this.ListInfos.length);
    } catch (error) {
      console.error('[HomePage] 初始化失败:', error);
    }
  }

  onConfigurationUpdate() {
    this.viewModel.updateWidth();
    this.syncStateFromViewModel();
  }

  // 从ViewModel同步状态到View
  private syncStateFromViewModel(): void {
    this.swiperIndex = this.viewModel.swiperIndex;
    this.deviceWidth = this.viewModel.deviceWidth;
    this.maxCount = this.viewModel.maxCount;
    this.userId = this.viewModel.userId;
    this.availableActivities = this.viewModel.availableActivities;
    this.showAIRecommendations = this.viewModel.showAIRecommendations;
    this.recommendedImages = this.viewModel.getRecommendedImages();
    
    // 重要：使用展开运算符创建新数组，触发UI更新
    const listInfos = this.viewModel.getListInfos();
    this.ListInfos = [...listInfos];
    console.log('[HomePage] syncStateFromViewModel - ListInfos已更新:', this.ListInfos.length);
  }

  // 导航到活动页面
  private async navigateToActivity(category: string) {
    await this.viewModel.navigateToActivity(category);
    
    // 设置选中的分类和切换到活动页面
    AppStorage.setOrCreate('selectedCategory', category);
    AppStorage.setOrCreate('selectedTab', 2);
  }

  build() {
    Column() {
      // 关键改进：将整个页面内容包裹在 Scroll 组件中，确保页面在内容溢出时可以滚动
      Scroll() {
        Column() {
          // 搜索栏
          this.SearchBar()

        // 热门推荐 - Swiper 轮播图
        Text('热门推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#334155')
          .alignSelf(ItemAlign.Start)// 左对齐
          .margin({ left: '2.5%', bottom: 10 })// 左侧外边距和底部外边距
          .padding({ left: 10 }) // 左侧内边距

        Swiper() {
          ForEach(this.recommendedImages ?? [], (item: string, index: number) => {
            Image(item)
              .width('100%')
              .height(200)
              .borderRadius(16)
              .objectFit(ImageFit.Cover) // 图片裁剪模式
          }, (item: string, index: number) => `rec-${index}-${item}`)
        }
        .width('95%')
        .height(200)
        .indicator(true) // 显示指示器（小圆点）
        .loop(true) // 循环播放
        .autoPlay(true) // 自动播放
        .interval(3000) // 播放间隔3秒
        .onChange((index: number) => {
          this.viewModel.updateSwiperIndex(index);
          this.swiperIndex = index; // 更新当前轮播图索引
        })
        .borderRadius(10)
        .shadow({
          radius: 8,
          color: 'rgba(0,0,0,0.1)',
          offsetX: 0,
          offsetY: 4
        }) // 阴影
        .margin({ bottom: 20 }) // 底部外边距

        // 热门分类 - 携程风格设计
        Text('热门分类')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#334155')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '2.5%', bottom: 10 })
          .padding({ left: 10 })

        // 第一行：主要分类
        Row({ space: 8 }) {
          CategoryCard({ 
            icon: '🏞️', 
            title: '热门景点', 
            subtitle: '世界之窗·欢乐谷',
            color: '#FF6B35',
            onCardClick: () => {
              console.log('点击了热门景点卡片');
              ErrorHandler.safeExecute(async (): Promise<void> => {
                AppStorage.setOrCreate('selectedCategory', '热门推荐');
                AppStorage.setOrCreate('selectedTab', 2);
                await router.pushUrl({
                  url: 'pages/activity/ActivityPageNew'
                });
              }, (error: Error): void => ErrorHandler.handleRouterError(error, '社区活动页面'));
            }
          })

          CategoryCard({ 
            icon: '🎉', 
            title: '精彩活动', 
            subtitle: '文化节·音乐节',
            color: '#4ECDC4',
            onCardClick: () => {
              console.log('点击了精彩活动卡片');
              ErrorHandler.safeExecute(async (): Promise<void> => {
                AppStorage.setOrCreate('selectedCategory', '文化体验');
                AppStorage.setOrCreate('selectedTab', 2);
                await router.pushUrl({
                  url: 'pages/activity/ActivityPageNew'
                });
              }, (error: Error): void => ErrorHandler.handleRouterError(error, '社区活动页面'));
            }
          })
        }
        .width('95%')
        .margin({ bottom: 12 })

        // 分类网格 - 4x2布局，符合截图设计
        Column() {
          // 第一行
          Row() {
            CategoryItem({ 
              icon: '🍔', 
              text: '美食', 
              color: '#FF9F43',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/FoodPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '美食页面'));
              }
            })
            CategoryItem({ 
              icon: '🏨', 
              text: '住宿', 
              color: '#6C5CE7',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/HotelPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '住宿页面'));
              }
            })
            CategoryItem({ 
              icon: '🛍️', 
              text: '购物', 
              color: '#A29BFE',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/ShoppingPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '购物页面'));
              }
            })
            CategoryItem({ 
              icon: '🚌', 
              text: '交通', 
              color: '#74B9FF',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/TransportPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '交通页面'));
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ bottom: 12 })

          // 第二行
          Row() {
            CategoryItem({ 
              icon: '🗺️', 
              text: '路线', 
              color: '#00B894',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/RoutePage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '路线页面'));
              }
            })
            CategoryItem({ 
              icon: '📱', 
              text: '科技', 
              color: '#FDCB6E',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/TechPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '科技页面'));
              }
            })
            CategoryItem({ 
              icon: '🍀', 
              text: '自然', 
              color: '#55A3FF',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/NaturePage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '自然页面'));
              }
            })
            CategoryItem({ 
              icon: '🏖️', 
              text: '海景', 
              color: '#00CEC9',
              onItemClick: () => {
                ErrorHandler.safeExecute(async (): Promise<void> => {
                  await router.pushUrl({
                    url: 'pages/category/BeachPage'
                  });
                }, (error: Error): void => ErrorHandler.handleRouterError(error, '海景页面'));
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('95%')
        .margin({ bottom: 20 })

        // AI智能推荐区域
        if (this.showAIRecommendations) {
          SmartRecommendationList({
            userId: this.userId,
            availableActivities: this.availableActivities
          })
          .margin({ top: 20 })
        }

        // 精选推荐 - List (列表展示)
        Text('精选推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#334155')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '2.5%', bottom: 10 })
          .padding({ left: 10 })

        GridRow({
          columns: 6,
          gutter: { x: 10, y: 10 }
        }) {
          ForEach(this.ListInfos ?? [], (item: ListItemInfo, index: number) => {
            GridCol({ span: { xs: 6, md: 3, lg: 2 } }) {
              RecommendedItem({
                image: item.image,
                title: item.title,
                description: item.description
              })
            }
          }, (item: ListItemInfo, index: number) => `list-${index}-${item.title}`)
        }
        .margin({ left: '2.5%', right: '2.5%' })

        // List() {
        //   ListItem() {
        //     RecommendedItem({
        //       image: $r('app.string.GreenParkUrl'),
        //       title: '翠湖公园',
        //       description: '城市中心的绿洲，休闲散步好去处。'
        //     })
        //   }
        //
        //   ListItem() {
        //     RecommendedItem({
        //       image: $r('app.string.LampActivityUrl'),
        //       title: '城市文化节',
        //       description: '体验当地文化，感受城市魅力。'
        //     })
        //   }
        //
        //   ListItem() {
        //     RecommendedItem({
        //       image: $r('app.string.WaterStreetUrl'),
        //       title: '眉山水街',
        //       description: '品尝地道小吃，感受川蜀浪漫，满足您的味蕾。'
        //     })
        //   }
        //
        //   ListItem() {
        //     RecommendedItem({
        //       image: $r('app.string.BiFengGorgeUrl'),
        //       title: '碧峰峡',
        //       description: '领略大自然鬼斧神工，观赏熊猫基地的秀丽'
        //     })
        //   }
        //
        //   ListItem() {
        //     RecommendedItem({
        //       image: $r('app.string.GreenMountainUrl'),
        //       title: '蒙顶山',
        //       description: '扬子江心水，蒙山顶上茶。千年茶都，世界茶园，千秋蒙顶，值得一赏'
        //     })
        //   }
        // }
        // .width('95%')
        // // 在 Scroll 组件内部，List 的高度会根据其内容自适应，通常不需要设置 layoutWeight(1)
        // // .layoutWeight(1)
        // .listDirection(Axis.Vertical) // 垂直列表
        // .divider({ strokeWidth: 0, color: Color.Transparent }) // 无分隔线
        // .scrollBar(BarState.Off) // 关闭列表自身的滚动条
        }
        .width('100%') // Column 宽度填充 Scroll
        // 在 Scroll 组件内部，Column 的高度不需要固定为100%，它会根据内容自适应
        // .height('100%')
        .backgroundColor('#f0f4f8') // 轻柔的背景色
        .padding({ bottom: 20 }) // 底部留白，防止内容被底部导航栏遮挡
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off) // 隐藏 Scroll 组件的滚动条
      
      // 位置气泡组件
      LocationBubble()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }


  @Builder SearchBar() {
    Row() {
      TextInput({ placeholder: '搜索景点、活动...' })
        .layoutWeight(1)
        .height(48)
        .borderRadius(24)
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20 })
        .fontSize(16)
        .fontColor('#1f2937')
        .placeholderColor('#9ca3af')
        .border({ width: 1, color: '#e5e7eb', radius: 24 })
        .shadow({
          radius: 8,
          color: 'rgba(0,0,0,0.1)',
          offsetX: 0,
          offsetY: 2
        })
        .onClick(() => {
          // 跳转到搜索页面
          router.pushUrl({
            url: 'pages/search/SearchPage'
          }).catch((error: Error) => {
            ErrorHandler.handleRouterError(error, '搜索页面');
          });
        })

      // 地图按钮
      Column() {
        Text('🗺️')
          .fontSize(20)
        Text('地图')
          .fontSize(10)
          .fontColor('#6b7280')
          .margin({ top: 2 })
      }
      .margin({ left: 12 })
      .onClick(() => {
        // 跳转到地图页面
        AppStorage.setOrCreate('selectedTab', 1);
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
  }
}

@Component
struct ListView {
  @State tab_index: number = 0;
  @Prop data: ListItemInfo[];
  @Prop maxCount: number = 3;
  @Prop rowCount: number = Math.ceil(this.data.length / this.maxCount);

  build() {
    // List() {
    //   // 遍历每一“行”
    //   ForEach(Array(this.rowCount).fill(0), (rowIndex: number) => {
    //     ListItem() {
    //       Row({ space: 10 }) {
    //         // 当前行的所有列
    //         ForEach(this.data.slice(rowIndex * this.maxCount, (rowIndex + 1) * this.maxCount), (item: ListItemInfo) => {
    //           ListItem() {
    //             RecommendedItem({
    //               image: item.image,
    //               title: item.title,
    //               description: item.description
    //             })
    //           }
    //           .width(`${100 / this.maxCount}%`) // 平均分配宽度
    //         })
    //       }
    //     }
    //   })
    // }

  }
}

// 热门分类卡片组件（携程风格）
@Component
struct CategoryCard {
  private icon: string = '';
  private title: string = '';
  private subtitle: string = '';
  private color: string = '#FF6B35';
  private onCardClick?: () => void;

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 8 })

      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 4 })

      Text(this.subtitle)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width(160)
    .height(120)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: this.color + '15',
      offsetX: 0,
      offsetY: 4
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      console.log('点击了分类卡片:', this.title);
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}

// 热门分类项组件
@Component
struct CategoryItem {
  private icon: string = '';
  private text: string = '';
  private color: string = '#FF6B35';
  private onItemClick?: () => void;

  build() {
    Column() {
      Text(this.icon)
        .fontSize(24)
        .margin({ bottom: 6 })

      Text(this.text)
        .fontSize(11)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
    }
    .width(70)
    .height(70)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: this.color + '20',
      offsetX: 0,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      console.log('点击了分类:', this.text);
      try {
        if (this.onItemClick) {
          this.onItemClick();
        } else {
          console.error('onItemClick回调函数未定义');
        }
      } catch (error) {
        console.error('分类点击事件执行失败:', error);
      }
    })
  }
}

// 精选推荐项组件
@Component
struct RecommendedItem {
  private image: Resource = $r('app.string.module_desc');
  private title: string = '';
  private description: string = '';

  build() {
    Row() {
      Image(this.image)
        .width(80)
        .height(80)
        .borderRadius(6)
        .objectFit(ImageFit.Cover)
        .margin({ right: 15 })

      Column() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)// 左对齐
          .margin({ bottom: 5 })
        Text(this.description)
          .fontSize(14)
          .fontColor('#4b5563')
          .alignSelf(ItemAlign.Start) // 左对齐
      }
      .alignItems(HorizontalAlign.Start) // 子组件水平左对齐
      .layoutWeight(1) // 允许内容填充剩余空间
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({
      radius: 5,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    }) // 阴影
    .margin({ bottom: 10 }) // 底部外边距
    .onClick(() => {
      // 跳转到活动详情页面
      router.pushUrl({
        url: 'pages/activity/ActivityDetailPage',
        params: { id: this.title }
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
      });
    })
  }
}
