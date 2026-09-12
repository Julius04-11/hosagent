import { CollectedMarker } from '../model/CollectMarkerModel'
import { StyleConstants } from '../constants/StyleConstants'

@Component
export struct CollectListDialog {
  @Link visible: boolean
  @Link favorites: CollectedMarker[]
  @Prop onClose: () => void
  @Prop onSelect: (marker: CollectedMarker) => void
  @Prop onRemove: (marker: CollectedMarker) => void

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.visible) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(StyleConstants.BACKDROP_COLOR)
          .onClick(() => {
            this.onClose()
          })

        Column() {
          Row() {
            Text('我的收藏')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)

            Blank()

            Button('关闭')
              .height(32)
              .borderRadius(16)
              .backgroundColor(Color.White)
              .border({ width: 1, color: StyleConstants.DIALOG_BUTTON_OUTLINE_COLOR })
              .fontColor(StyleConstants.DIALOG_BUTTON_TEXT_COLOR)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.onClose()
              })
          }
          .width('100%')
          .margin({ bottom: 16 })

          if (this.favorites.length === 0) {
            Column() {
              Text('暂无收藏')
                .fontSize(16)
                .fontColor('#888888')
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            Scroll() {
              Column() {
                ForEach(this.favorites, (marker: CollectedMarker) => {
                  Row() {
                    Column() {
                      Text(marker.simpleAddress || '未命名地址')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)

                      Text(marker.detailAddress || '')
                        .fontSize(13)
                        .fontColor('#666666')
                        .maxLines(2)
                    }
                    .width('70%')

                    Column() {
                      Button('查看')
                        .height(32)
                        .borderRadius(12)
                        .backgroundColor('#0A59F7')
                        .fontColor(Color.White)
                        .padding({ left: 12, right: 12 })
                        .onClick(() => {
                          this.onSelect(marker)
                        })
                        .margin({ bottom: 8 })

                      Button('删除')
                        .height(32)
                        .borderRadius(12)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: StyleConstants.DIALOG_BUTTON_OUTLINE_COLOR })
                        .fontColor(StyleConstants.DIALOG_BUTTON_TEXT_COLOR)
                        .padding({ left: 12, right: 12 })
                        .onClick(() => {
                          this.onRemove(marker)
                        })
                    }
                    .width('30%')
                  }
                  .padding(StyleConstants.LIST_ITEM_PADDING)
                  .backgroundColor('#F6F8FF')
                  .borderRadius(StyleConstants.LIST_ITEM_RADIUS)
                  .margin({ bottom: StyleConstants.LIST_ITEM_GAP })
                }, (marker: CollectedMarker) => marker.id)
              }
              .width('100%')
            }
            .width('100%')
            .height(`${StyleConstants.LIST_MAX_HEIGHT_RATIO * 100}%`)
          }
        }
        .width(340)
        .padding(StyleConstants.DIALOG_PADDING)
        .backgroundColor(Color.White)
        .borderRadius(StyleConstants.DIALOG_BORDER_RADIUS)
      }
    }
    .width('100%')
    .height('100%')
  }
}

// 深圳本地示例版本（不影响现有 CollectListDialog 的对外 API）
interface FavoriteLocation {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  category: string;
  addTime: string;
}

@Component
export struct CollectListDialogSZ {
  @State favoriteLocations: FavoriteLocation[] = [];
  @State isVisible: boolean = false;
  @State selectedCategory: string = '全部';
  private categories: string[] = ['全部', '景点', '餐厅', '酒店', '购物', '其他'];

  aboutToAppear() {
    this.loadFavoriteLocations();
  }

  // 加载收藏位置（深圳本地示例数据）
  private loadFavoriteLocations() {
    this.favoriteLocations = [
      {
        id: '1',
        name: '世界之窗',
        address: '深圳市南山区深南大道9037号',
        latitude: 22.5431,
        longitude: 114.0579,
        category: '景点',
        addTime: '2025-01-15'
      },
      {
        id: '2',
        name: '欢乐谷',
        address: '深圳市南山区华侨城',
        latitude: 22.5231,
        longitude: 114.0379,
        category: '景点',
        addTime: '2025-01-14'
      },
      {
        id: '3',
        name: '海底捞火锅',
        address: '深圳市福田区华强北路',
        latitude: 22.5531,
        longitude: 114.0679,
        category: '餐厅',
        addTime: '2025-01-13'
      },
      {
        id: '4',
        name: '万象城',
        address: '深圳市罗湖区宝安南路',
        latitude: 22.5331,
        longitude: 114.0479,
        category: '购物',
        addTime: '2025-01-12'
      }
    ];
  }

  // 显示/隐藏对话框（示例组件内部控制）
  showDialog() {
    this.isVisible = true;
  }

  hideDialog() {
    this.isVisible = false;
  }

  // 删除收藏
  private deleteFavorite(id: string) {
    this.favoriteLocations = this.favoriteLocations.filter(item => item.id !== id);
  }

  // 导航到位置（示例输出）
  private navigateToLocation(location: FavoriteLocation) {
    console.log('导航到:', location.name);
  }

  // 过滤收藏位置
  private getFilteredLocations(): FavoriteLocation[] {
    if (this.selectedCategory === '全部') {
      return this.favoriteLocations;
    }
    return this.favoriteLocations.filter(item => item.category === this.selectedCategory);
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.hideDialog();
          })
        
        // 对话框内容
        Column() {
          // 头部
          Row() {
            Text('收藏位置')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            
            Blank()
            
            Button() {
              Text('✕')
                .fontSize(18)
                .fontColor('#64748b')
            }
            .width(32)
            .height(32)
            .backgroundColor(Color.Transparent)
            .borderRadius(16)
            .onClick(() => {
              this.hideDialog();
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 12 })
          
          // 分类筛选
          Scroll() {
            Row() {
              ForEach(this.categories, (category: string, index: number) => {
                Button() {
                  Text(category)
                    .fontSize(14)
                    .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.selectedCategory === category ? Color.White : '#64748b')
                }
                .height(32)
                .borderRadius(16)
                .backgroundColor(this.selectedCategory === category ? '#1e40af' : '#f1f5f9')
                .padding({ left: 16, right: 16 })
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedCategory = category;
                })
              })
            }
            .padding({ left: 20, right: 20, bottom: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          
          // 收藏列表
          Scroll() {
            Column() {
              ForEach(this.getFilteredLocations(), (location: FavoriteLocation, index: number) => {
                this.FavoriteItem(location, index)
              })
              
              if (this.getFilteredLocations().length === 0) {
                Column() {
                  Text('📌')
                    .fontSize(48)
                    .fontColor('#cbd5e1')
                    .margin({ bottom: 16 })
                  
                  Text('暂无收藏位置')
                    .fontSize(16)
                    .fontColor('#64748b')
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            }
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .scrollBar(BarState.Auto)
          .layoutWeight(1)
        }
        .width('90%')
        .height('80%')
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.15)',
          offsetX: 0,
          offsetY: 8
        })
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-45%', y: '-40%' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  @Builder FavoriteItem(location: FavoriteLocation, index: number) {
    Row() {
      // 位置图标
      Column() {
        Text('📍')
          .fontSize(24)
          .fontColor('#1e40af')
      }
      .width(50)
      .height(50)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 位置信息
      Column() {
        Text(location.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .alignSelf(ItemAlign.Start)

        Text(location.address)
          .fontSize(14)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
          .maxLines(1)
        
        Row() {
          Text(location.category)
            .fontSize(12)
            .fontColor('#1e40af')
            .backgroundColor('#f0f8ff')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
          
          Blank()
          
          Text(location.addTime)
            .fontSize(12)
            .fontColor('#94a3b8')
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      // 操作按钮
      Column() {
        Button() {
          Text('🗑️')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor('#fef2f2')
        .borderRadius(18)
        .margin({ bottom: 4 })
        .onClick(() => {
          this.deleteFavorite(location.id);
        })
        
        Button() {
          Text('🧭')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor('#f0f8ff')
        .borderRadius(18)
        .onClick(() => {
          this.navigateToLocation(location);
        })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }
}