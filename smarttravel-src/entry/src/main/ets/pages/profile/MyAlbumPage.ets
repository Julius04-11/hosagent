import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface PhotoItem {
  id: string;
  url: string;
  title: string;
  location: string;
  date: string;
  likes: number;
  comments: number;
  tags: string[];
}

interface AlbumCategory {
  id: string;
  name: string;
  count: number;
  coverUrl: string;
}

@Entry
@Component
export struct MyAlbumPage {
  @State photoList: PhotoItem[] = [
    {
      id: '1',
      url: 'https://picsum.photos/300/200?random=1',
      title: '深圳湾日出',
      location: '深圳湾公园',
      date: '2024-06-01',
      likes: 128,
      comments: 23,
      tags: ['日出', '深圳湾', '自然风光']
    },
    {
      id: '2',
      url: 'https://picsum.photos/300/200?random=2',
      title: '莲花山夜景',
      location: '莲花山公园',
      date: '2024-06-02',
      likes: 95,
      comments: 15,
      tags: ['夜景', '城市', '莲花山']
    },
    {
      id: '3',
      url: 'https://picsum.photos/300/200?random=3',
      title: '东湖荷花',
      location: '东湖公园',
      date: '2024-06-03',
      likes: 156,
      comments: 31,
      tags: ['荷花', '夏季', '东湖']
    },
    {
      id: '4',
      url: 'https://picsum.photos/300/200?random=4',
      title: '民俗文化节',
      location: '市民中心',
      date: '2024-06-04',
      likes: 89,
      comments: 18,
      tags: ['民俗', '文化', '节日']
    },
    {
      id: '5',
      url: 'https://picsum.photos/300/200?random=5',
      title: '海边日落',
      location: '大梅沙',
      date: '2024-06-05',
      likes: 203,
      comments: 42,
      tags: ['日落', '海边', '浪漫']
    },
    {
      id: '6',
      url: 'https://picsum.photos/300/200?random=6',
      title: '城市马拉松',
      location: '深圳湾体育中心',
      date: '2024-06-06',
      likes: 167,
      comments: 28,
      tags: ['运动', '马拉松', '活力']
    }
  ];

  @State albumCategories: AlbumCategory[] = [
    { id: '1', name: '自然风光', count: 15, coverUrl: 'https://picsum.photos/150/150?random=10' },
    { id: '2', name: '城市建筑', count: 8, coverUrl: 'https://picsum.photos/150/150?random=11' },
    { id: '3', name: '人文纪实', count: 12, coverUrl: 'https://picsum.photos/150/150?random=12' },
    { id: '4', name: '美食探店', count: 6, coverUrl: 'https://picsum.photos/150/150?random=13' }
  ];

  @State selectedTab: number = 0;
  @State selectedCategory: string = '';
  private tabs: string[] = ['全部', '分类', '收藏'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '我的相册',
        showBack: true,
        showSearch: true,
        showNotification: false
      })

      // 统计信息
      this.StatisticsCard()

      // 标签页
      this.TabBar()

      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder StatisticsCard() {
    Column() {
      Row() {
        Column() {
          Text('6')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('照片总数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('838')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('总获赞')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('157')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3b82f6')
          Text('总评论')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('4')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('相册分类')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder TabBar() {
    Row() {
      ForEach(this.tabs ?? [], (tab: string, index: number) => {
        Text(tab)
          .fontSize(14)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#3b82f6' : '#6b7280')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = index;
          })
      }, (tab: string, index: number) => `tab-${index}-${tab}`)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ContentArea() {
    Scroll() {
      Column() {
        if (this.selectedTab === 0) {
          // 全部照片 - 网格布局
          this.PhotoGrid()
        } else if (this.selectedTab === 1) {
          // 分类相册
          this.AlbumCategories()
        } else {
          // 收藏照片
          this.FavoritePhotos()
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder PhotoGrid() {
    GridRow({
      columns: 2,
      gutter: { x: 12, y: 12 }
    }) {
      ForEach(this.photoList ?? [], (photo: PhotoItem, index: number) => {
        GridCol({ span: 1 }) {
          this.PhotoCard(photo)
        }
      }, (photo: PhotoItem, index: number) => `photo-${photo.id}-${index}`)
    }
    .width('100%')
  }

  @Builder PhotoCard(photo: PhotoItem) {
    Column() {
      // 照片
      Stack() {
        Image(photo.url)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        // 点赞和评论数
        Row() {
          Blank()
          Row({ space: 8 }) {
            Text('❤️')
              .fontSize(12)
            Text(photo.likes.toString())
              .fontSize(12)
              .fontColor(Color.White)
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.5)')
          .borderRadius(12)
          .margin({ right: 8 })

          Row({ space: 8 }) {
            Text('💬')
              .fontSize(12)
            Text(photo.comments.toString())
              .fontSize(12)
              .fontColor(Color.White)
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.5)')
          .borderRadius(12)
        }
        .width('100%')
        .padding(8)
      }
      .width('100%')

      // 照片信息
      Column() {
        Text(photo.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${photo.location} · ${photo.date}`)
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ bottom: 8 })

        // 标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach((photo.tags ?? []).slice(0, 2), (tag: string, index: number) => {
            Text(`#${tag}`)
              .fontSize(10)
              .fontColor('#3b82f6')
              .backgroundColor('#dbeafe')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 4, bottom: 4 })
          }, (tag: string, index: number) => `tag-${photo.id}-${index}-${tag}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.viewPhotoDetail(photo.id);
    })
  }

  @Builder AlbumCategories() {
    Column() {
      ForEach(this.albumCategories ?? [], (category: AlbumCategory, index: number) => {
        Row() {
          // 封面图片
          Image(category.coverUrl)
            .width(60)
            .height(60)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .margin({ right: 12 })

          // 分类信息
          Column() {
            Text(category.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .margin({ bottom: 4 })

            Text(`${category.count} 张照片`)
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          // 箭头
          Text('>')
            .fontSize(16)
            .fontColor('#9ca3af')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 12 })
        .shadow({
          radius: 4,
          color: 'rgba(0,0,0,0.05)',
          offsetX: 0,
          offsetY: 2
        })
        .onClick(() => {
          this.viewCategory(category.id);
        })
      }, (category: AlbumCategory, index: number) => `cat-${category.id ?? ''}-${index}`)
    }
    .width('100%')
  }

  @Builder FavoritePhotos() {
    Column() {
      Text('收藏的照片')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      GridRow({
        columns: 3,
        gutter: { x: 8, y: 8 }
      }) {
        ForEach((this.photoList ?? []).slice(0, 6), (photo: PhotoItem, index: number) => {
          GridCol({ span: 1 }) {
            Image(photo.url)
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .onClick(() => {
                this.viewPhotoDetail(photo.id);
              })
          }
        }, (photo: PhotoItem, index: number) => `fav-${photo.id}-${index}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private viewPhotoDetail(id: string): void {
    // 跳转到照片详情页面
    router.pushUrl({ 
      url: 'pages/photo/PhotoDetailPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转照片详情页面失败:', error.message);
    });
  }

  private viewCategory(categoryId: string): void {
    // 跳转到分类详情页面
    router.pushUrl({ 
      url: 'pages/album/AlbumCategoryPage',
      params: { id: categoryId }
    }).catch((error: Error) => {
      console.error('跳转相册分类页面失败:', error.message);
    });
  }
}
