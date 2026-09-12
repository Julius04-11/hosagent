import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface PhotoComment {
  id: string;
  userName: string;
  avatar: string;
  content: string;
  time: string;
  likes: number;
}

interface PhotoData {
  title: string;
  location: string;
  date: string;
  likes: number;
  comments: number;
  tags: string[];
  url: string;
  description: string;
  commentList: PhotoComment[];
}

@Entry
@Component
export struct PhotoDetailPage {
  @State photoId: string = '';
  @State photoUrl: string = 'https://picsum.photos/400/600?random=1';
  @State photoTitle: string = '深圳湾日出';
  @State photoLocation: string = '深圳湾公园';
  @State photoDate: string = '2024-06-01';
  @State photoDescription: string = '清晨的深圳湾，朝霞满天，海面波光粼粼，是深圳最美的日出观赏地之一。';
  @State photoTags: string[] = ['日出', '深圳湾', '自然风光', '早晨'];
  @State likes: number = 128;
  @State comments: number = 23;
  @State isLiked: boolean = false;
  @State isFavorite: boolean = false;
  
  @State commentList: PhotoComment[] = [];
  @State newComment: string = '';

  aboutToAppear() {
    // 从路由参数获取照片ID
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.photoId = params.id;
      this.loadPhotoData(params.id);
    }
  }

  private loadPhotoData(id: string): void {
    // 根据ID加载对应的照片数据
    const photoData = this.getPhotoById(id);
    if (photoData) {
      this.photoTitle = photoData.title;
      this.photoLocation = photoData.location;
      this.photoDate = photoData.date;
      this.likes = photoData.likes;
      this.comments = photoData.comments;
      this.photoTags = photoData.tags;
      this.photoUrl = photoData.url;
      this.photoDescription = photoData.description;
      this.commentList = photoData.commentList;
    }
  }

  private getPhotoById(id: string): PhotoData | undefined {
    const photos: Record<string, PhotoData> = {
      '1': {
        title: '深圳湾日出',
        location: '深圳湾公园',
        date: '2024-06-01',
        likes: 128,
        comments: 23,
        tags: ['日出', '深圳湾'],
        url: 'https://picsum.photos/400/600?random=1',
        description: '清晨的深圳湾，朝霞满天，海面波光粼粼。',
        commentList: [
          { id: '1', userName: '旅行达人', avatar: '👤', content: '太美了！', time: '2小时前', likes: 5 } as PhotoComment
        ]
      },
      '2': {
        title: '莲花山夜景',
        location: '莲花山公园',
        date: '2024-06-02',
        likes: 95,
        comments: 15,
        tags: ['夜景', '城市'],
        url: 'https://picsum.photos/400/600?random=2',
        description: '莲花山顶俯瞰深圳夜景，万家灯火璀璨。',
        commentList: [
          { id: '1', userName: '摄影师', avatar: '📷', content: '夜景真美！', time: '1小时前', likes: 3 } as PhotoComment
        ]
      },
      '3': {
        title: '东湖荷花',
        location: '东湖公园',
        date: '2024-06-03',
        likes: 156,
        comments: 31,
        tags: ['荷花', '夏季'],
        url: 'https://picsum.photos/400/600?random=3',
        description: '夏日的东湖公园，荷花盛开，清香扑鼻。',
        commentList: [
          { id: '1', userName: '花卉爱好者', avatar: '🌸', content: '荷花拍得真好', time: '3小时前', likes: 8 } as PhotoComment
        ]
      },
      '4': {
        title: '民俗文化节',
        location: '市民中心',
        date: '2024-06-04',
        likes: 89,
        comments: 18,
        tags: ['民俗', '文化'],
        url: 'https://picsum.photos/400/600?random=4',
        description: '市民中心举办的民俗文化节，精彩纷呈。',
        commentList: [
          { id: '1', userName: '文化爱好者', avatar: '🎭', content: '很有意义的活动', time: '5小时前', likes: 6 } as PhotoComment
        ]
      }
    };
    return photos[id];
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '照片详情',
        showBack: true
      })

      Scroll() {
        Column() {
          // 照片展示区
          this.PhotoView()

          // 照片信息区
          this.PhotoInfo()

          // 标签区
          this.TagsSection()

          // 互动按钮区
          this.ActionButtons()

          // 评论列表
          this.CommentSection()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder PhotoView() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.photoUrl)
        .width('100%')
        .height(400)
        .objectFit(ImageFit.Cover)

      // 收藏按钮
      Column() {
        Text(this.isFavorite ? '⭐' : '☆')
          .fontSize(24)
          .fontColor(Color.White)
      }
      .width(48)
      .height(48)
      .backgroundColor('rgba(0,0,0,0.5)')
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16, right: 16 })
      .onClick(() => {
        this.isFavorite = !this.isFavorite;
      })
    }
    .width('100%')
  }

  @Builder PhotoInfo() {
    Column() {
      Text(this.photoTitle)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)

      Row({ space: 16 }) {
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(14)
          Text(this.photoLocation)
            .fontSize(14)
            .fontColor('#6b7280')
        }

        Row({ space: 6 }) {
          Text('📅')
            .fontSize(14)
          Text(this.photoDate)
            .fontSize(14)
            .fontColor('#6b7280')
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(this.photoDescription)
        .fontSize(14)
        .fontColor('#4b5563')
        .lineHeight(22)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder TagsSection() {
    Column() {
      Text('标签')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.photoTags ?? [], (tag: string, index: number) => {
          Text(`#${tag}`)
            .fontSize(13)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              console.log('点击标签:', tag);
              // 可以跳转到标签搜索页面
            })
        }, (tag: string, index: number) => `ptag-${index}-${tag}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActionButtons() {
    Row() {
      // 点赞按钮
      Column() {
        Text(this.isLiked ? '❤️' : '🤍')
          .fontSize(24)
          .onClick(() => {
            this.isLiked = !this.isLiked;
            this.likes += this.isLiked ? 1 : -1;
          })

        Text(this.likes.toString())
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(40)
        .color('#e5e7eb')

      // 评论按钮
      Column() {
        Text('💬')
          .fontSize(24)

        Text(this.comments.toString())
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        // 滚动到评论区
        console.log('滚动到评论区');
      })

      Divider()
        .vertical(true)
        .height(40)
        .color('#e5e7eb')

      // 分享按钮
      Column() {
        Text('📤')
          .fontSize(24)

        Text('分享')
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        console.log('分享照片');
      })
    }
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder CommentSection() {
    Column() {
      Row() {
        Text('评论')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)

        Text(`${this.commentList.length}条`)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .width('100%')
      .margin({ bottom: 16 })

      Column({ space: 16 }) {
        ForEach(this.commentList ?? [], (comment: PhotoComment, index: number) => {
          this.CommentItem(comment)
        }, (comment: PhotoComment, index: number) => `cmt-${index}-${comment.id}`)
      }
      .width('100%')

      // 评论输入框
      Row() {
        TextInput({ placeholder: '说点什么...', text: this.newComment })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#f3f4f6')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.newComment = value;
          })

        Button('发送')
          .height(40)
          .fontSize(14)
          .backgroundColor('#3b82f6')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => {
            this.sendComment();
          })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder CommentItem(comment: PhotoComment) {
    Row() {
      // 头像
      Text(comment.avatar)
        .fontSize(32)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#f3f4f6')
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      Column() {
        // 用户名和时间
        Row() {
          Text(comment.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .layoutWeight(1)

          Text(comment.time)
            .fontSize(12)
            .fontColor('#9ca3af')
        }
        .width('100%')
        .margin({ bottom: 6 })

        // 评论内容
        Text(comment.content)
          .fontSize(14)
          .fontColor('#4b5563')
          .lineHeight(20)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        // 点赞
        Row({ space: 4 }) {
          Text('👍')
            .fontSize(14)
          Text(comment.likes.toString())
            .fontSize(12)
            .fontColor('#6b7280')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  private sendComment(): void {
    if (this.newComment.trim() === '') {
      console.log('评论内容不能为空');
      return;
    }

    // 创建新评论
    const newCommentItem: PhotoComment = {
      id: Date.now().toString(),
      userName: '我',
      avatar: '😊',
      content: this.newComment,
      time: '刚刚',
      likes: 0
    };

    // 添加到评论列表
    this.commentList.unshift(newCommentItem);
    this.comments += 1;

    // 清空输入框
    this.newComment = '';

    console.log('评论发送成功');
  }
}
