import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface PhotoItem {
  id: string;
  url: string;
  title: string;
  location: string;
  date: string;
  likes: number;
  comments: number;
}

@Entry
@Component
export struct AlbumCategoryPage {
  @State categoryId: string = '';
  @State categoryName: string = '自然风光';
  @State photoCount: number = 15;
  
  @State photoList: PhotoItem[] = [
    {
      id: '1',
      url: 'https://picsum.photos/300/200?random=20',
      title: '深圳湾日出',
      location: '深圳湾公园',
      date: '2024-06-01',
      likes: 128,
      comments: 23
    },
    {
      id: '2',
      url: 'https://picsum.photos/300/200?random=21',
      title: '莲花山晨雾',
      location: '莲花山公园',
      date: '2024-06-02',
      likes: 95,
      comments: 15
    },
    {
      id: '3',
      url: 'https://picsum.photos/300/200?random=22',
      title: '东湖荷花',
      location: '东湖公园',
      date: '2024-06-03',
      likes: 156,
      comments: 31
    },
    {
      id: '4',
      url: 'https://picsum.photos/300/200?random=23',
      title: '大鹏山海景',
      location: '大鹏半岛',
      date: '2024-06-04',
      likes: 203,
      comments: 42
    },
    {
      id: '5',
      url: 'https://picsum.photos/300/200?random=24',
      title: '梧桐山云海',
      location: '梧桐山',
      date: '2024-06-05',
      likes: 187,
      comments: 35
    },
    {
      id: '6',
      url: 'https://picsum.photos/300/200?random=25',
      title: '仙湖植物园',
      location: '仙湖植物园',
      date: '2024-06-06',
      likes: 142,
      comments: 28
    },
    {
      id: '7',
      url: 'https://picsum.photos/300/200?random=26',
      title: '红树林湿地',
      location: '福田红树林',
      date: '2024-06-07',
      likes: 165,
      comments: 31
    },
    {
      id: '8',
      url: 'https://picsum.photos/300/200?random=27',
      title: '杨梅坑海岸',
      location: '大鹏杨梅坑',
      date: '2024-06-08',
      likes: 218,
      comments: 46
    },
    {
      id: '9',
      url: 'https://picsum.photos/300/200?random=28',
      title: '笔架山公园',
      location: '笔架山公园',
      date: '2024-06-09',
      likes: 134,
      comments: 25
    },
    {
      id: '10',
      url: 'https://picsum.photos/300/200?random=29',
      title: '香蜜湖夕阳',
      location: '香蜜公园',
      date: '2024-06-10',
      likes: 176,
      comments: 33
    },
    {
      id: '11',
      url: 'https://picsum.photos/300/200?random=30',
      title: '深圳河畔',
      location: '深圳河',
      date: '2024-06-11',
      likes: 98,
      comments: 18
    },
    {
      id: '12',
      url: 'https://picsum.photos/300/200?random=31',
      title: '观澜湖风光',
      location: '观澜湖',
      date: '2024-06-12',
      likes: 112,
      comments: 22
    },
    {
      id: '13',
      url: 'https://picsum.photos/300/200?random=32',
      title: '西涌海滩',
      location: '大鹏西涌',
      date: '2024-06-13',
      likes: 245,
      comments: 51
    },
    {
      id: '14',
      url: 'https://picsum.photos/300/200?random=33',
      title: '七娘山风景',
      location: '七娘山',
      date: '2024-06-14',
      likes: 189,
      comments: 37
    },
    {
      id: '15',
      url: 'https://picsum.photos/300/200?random=34',
      title: '海上世界',
      location: '蛇口海上世界',
      date: '2024-06-15',
      likes: 156,
      comments: 29
    }
  ];

  aboutToAppear() {
    // 从路由参数获取分类ID
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.categoryId = params.id;
      this.loadCategoryData(params.id);
    }
  }

  private loadCategoryData(id: string): void {
    // 模拟根据分类ID加载不同的数据
    switch (id) {
      case '1':
        this.categoryName = '自然风光';
        break;
      case '2':
        this.categoryName = '城市建筑';
        this.updateUrbanPhotos();
        break;
      case '3':
        this.categoryName = '人文纪实';
        this.updateCulturalPhotos();
        break;
      case '4':
        this.categoryName = '美食探店';
        this.updateFoodPhotos();
        break;
      default:
        this.categoryName = '我的相册';
    }
  }

  private updateUrbanPhotos(): void {
    this.photoList = [
      {
        id: '101',
        url: 'https://picsum.photos/300/200?random=40',
        title: '平安金融中心',
        location: '福田CBD',
        date: '2024-05-01',
        likes: 234,
        comments: 45
      },
      {
        id: '102',
        url: 'https://picsum.photos/300/200?random=41',
        title: '京基100夜景',
        location: '罗湖',
        date: '2024-05-02',
        likes: 198,
        comments: 38
      },
      {
        id: '103',
        url: 'https://picsum.photos/300/200?random=42',
        title: '深圳湾大桥',
        location: '南山',
        date: '2024-05-03',
        likes: 267,
        comments: 52
      },
      {
        id: '104',
        url: 'https://picsum.photos/300/200?random=43',
        title: '市民中心',
        location: '福田',
        date: '2024-05-04',
        likes: 145,
        comments: 27
      },
      {
        id: '105',
        url: 'https://picsum.photos/300/200?random=44',
        title: '华强北商圈',
        location: '华强北',
        date: '2024-05-05',
        likes: 189,
        comments: 34
      },
      {
        id: '106',
        url: 'https://picsum.photos/300/200?random=45',
        title: '欢乐海岸',
        location: '南山',
        date: '2024-05-06',
        likes: 212,
        comments: 41
      },
      {
        id: '107',
        url: 'https://picsum.photos/300/200?random=46',
        title: '深圳北站',
        location: '龙华',
        date: '2024-05-07',
        likes: 134,
        comments: 25
      },
      {
        id: '108',
        url: 'https://picsum.photos/300/200?random=47',
        title: '深业上城',
        location: '福田',
        date: '2024-05-08',
        likes: 156,
        comments: 29
      }
    ];
  }

  private updateCulturalPhotos(): void {
    this.photoList = [
      {
        id: '201',
        url: 'https://picsum.photos/300/200?random=50',
        title: '客家民居',
        location: '龙岗',
        date: '2024-04-01',
        likes: 167,
        comments: 31
      },
      {
        id: '202',
        url: 'https://picsum.photos/300/200?random=51',
        title: '深圳博物馆',
        location: '福田',
        date: '2024-04-02',
        likes: 145,
        comments: 27
      },
      {
        id: '203',
        url: 'https://picsum.photos/300/200?random=52',
        title: '文化创意园',
        location: '南山',
        date: '2024-04-03',
        likes: 198,
        comments: 36
      },
      {
        id: '204',
        url: 'https://picsum.photos/300/200?random=53',
        title: '大芬油画村',
        location: '龙岗',
        date: '2024-04-04',
        likes: 223,
        comments: 43
      },
      {
        id: '205',
        url: 'https://picsum.photos/300/200?random=54',
        title: '街头艺人表演',
        location: '华侨城',
        date: '2024-04-05',
        likes: 189,
        comments: 35
      },
      {
        id: '206',
        url: 'https://picsum.photos/300/200?random=55',
        title: '古城墙遗址',
        location: '南头古城',
        date: '2024-04-06',
        likes: 176,
        comments: 32
      },
      {
        id: '207',
        url: 'https://picsum.photos/300/200?random=56',
        title: '赶集日',
        location: '观澜',
        date: '2024-04-07',
        likes: 154,
        comments: 28
      },
      {
        id: '208',
        url: 'https://picsum.photos/300/200?random=57',
        title: '音乐会现场',
        location: '深圳音乐厅',
        date: '2024-04-08',
        likes: 201,
        comments: 39
      },
      {
        id: '209',
        url: 'https://picsum.photos/300/200?random=58',
        title: '传统工艺展',
        location: '甘坑客家小镇',
        date: '2024-04-09',
        likes: 167,
        comments: 31
      },
      {
        id: '210',
        url: 'https://picsum.photos/300/200?random=59',
        title: '舞龙表演',
        location: '罗湖',
        date: '2024-04-10',
        likes: 235,
        comments: 47
      },
      {
        id: '211',
        url: 'https://picsum.photos/300/200?random=60',
        title: '书法展览',
        location: '关山月美术馆',
        date: '2024-04-11',
        likes: 142,
        comments: 26
      },
      {
        id: '212',
        url: 'https://picsum.photos/300/200?random=61',
        title: '民俗节庆',
        location: '市民中心',
        date: '2024-04-12',
        likes: 189,
        comments: 35
      }
    ];
  }

  private updateFoodPhotos(): void {
    this.photoList = [
      {
        id: '301',
        url: 'https://picsum.photos/300/200?random=70',
        title: '粤式早茶',
        location: '罗湖',
        date: '2024-03-01',
        likes: 256,
        comments: 51
      },
      {
        id: '302',
        url: 'https://picsum.photos/300/200?random=71',
        title: '海鲜大餐',
        location: '南山海岸城',
        date: '2024-03-02',
        likes: 298,
        comments: 62
      },
      {
        id: '303',
        url: 'https://picsum.photos/300/200?random=72',
        title: '川味火锅',
        location: '东门',
        date: '2024-03-03',
        likes: 234,
        comments: 48
      },
      {
        id: '304',
        url: 'https://picsum.photos/300/200?random=73',
        title: '日式料理',
        location: '海岸城',
        date: '2024-03-04',
        likes: 267,
        comments: 54
      },
      {
        id: '305',
        url: 'https://picsum.photos/300/200?random=74',
        title: '港式甜品',
        location: '福田',
        date: '2024-03-05',
        likes: 189,
        comments: 37
      },
      {
        id: '306',
        url: 'https://picsum.photos/300/200?random=75',
        title: '特色小吃',
        location: '东门步行街',
        date: '2024-03-06',
        likes: 212,
        comments: 42
      }
    ];
  }

  build() {
    Column() {
      TopNavigationBar({
        title: this.categoryName,
        showBack: true,
        showSearch: true
      })

      // 分类统计信息
      Row() {
        Text(`共 ${this.photoList.length} 张照片`)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      // 照片网格
      Scroll() {
        GridRow({
          columns: 2,
          gutter: { x: 12, y: 12 }
        }) {
          ForEach(this.photoList, (photo: PhotoItem) => {
            GridCol({ span: 1 }) {
              this.PhotoCard(photo)
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
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

        // 互动数据
        Row() {
          Blank()
          Row({ space: 8 }) {
            Row({ space: 4 }) {
              Text('❤️')
                .fontSize(12)
              Text(photo.likes.toString())
                .fontSize(12)
                .fontColor(Color.White)
            }
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(10)

            Row({ space: 4 }) {
              Text('💬')
                .fontSize(12)
              Text(photo.comments.toString())
                .fontSize(12)
                .fontColor(Color.White)
            }
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(10)
          }
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

  private viewPhotoDetail(id: string): void {
    router.pushUrl({
      url: 'pages/photo/PhotoDetailPage',
      params: { id: id }
    }).catch((error: Error) => {
      console.error('跳转失败:', error.message);
    });
  }
}
