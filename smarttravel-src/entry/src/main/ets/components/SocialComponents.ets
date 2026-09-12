import { SocialTravelService } from '../service/SocialTravelService';
import { SocialUser, TravelShare, Comment, TravelChallenge, NearbyUser, ShareType } from '../model/SocialModel';
import { AnimationUtils } from '../utils/AnimationUtils';

/**
 * 旅行分享卡片组件
 * 显示用户的旅行分享内容
 */
@Component
export struct TravelShareCard {
  @Prop share: TravelShare;
  @Prop currentUserId: string;
  @State isLiked: boolean = false;
  @State isAnimating: boolean = false;
  @State showComments: boolean = false;
  @State comments: Comment[] = [];
  @State newComment: string = '';

  private socialService: SocialTravelService = SocialTravelService.getInstance();

  async aboutToAppear() {
    await this.loadComments();
  }

  // 加载评论
  private async loadComments() {
    this.comments = await this.socialService.getShareComments(this.share.id);
  }

  // 处理点赞
  private async handleLike() {
    if (this.isAnimating) return;
    
    this.isAnimating = true;
    
    if (this.isLiked) {
      await this.socialService.unlikeShare(this.share.id, this.currentUserId);
      this.isLiked = false;
    } else {
      await this.socialService.likeShare(this.share.id, this.currentUserId);
      this.isLiked = true;
    }
    
    // 添加点赞动画
    await AnimationUtils.favoriteToggleAnimation(
      this.getUIContext(),
      { scale: (value) => {} },
      this.isLiked,
      200
    );
    
    this.isAnimating = false;
  }

  // 处理评论
  private async handleComment() {
    if (!this.newComment.trim()) return;
    
    try {
      await this.socialService.addComment(this.share.id, this.currentUserId, this.newComment);
      this.newComment = '';
      await this.loadComments();
    } catch (error) {
      console.error('添加评论失败:', error);
    }
  }

  // 切换评论显示
  private toggleComments() {
    this.showComments = !this.showComments;
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    
    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
    return `${Math.floor(diff / 86400000)}天前`;
  }

  build() {
    Column() {
      // 用户信息头部
      Row() {
        // 用户头像
        Image(this.share.userId === this.currentUserId ? 
          (this.socialService.getCurrentUser()?.avatar || '') : 
          (this.socialService.getUserById(this.share.userId)?.avatar || ''))
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
        
        // 用户信息
        Column() {
          Text(this.share.userId === this.currentUserId ? 
            (this.socialService.getCurrentUser()?.nickname || '我') : 
            (this.socialService.getUserById(this.share.userId)?.nickname || '未知用户'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .alignSelf(ItemAlign.Start)
          
          Text(this.formatTime(this.share.createdAt))
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
        
        // 更多按钮
        Button() {
          Text('⋯')
            .fontSize(16)
            .fontColor('#6b7280')
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 分享内容
      Column() {
        Text(this.share.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        Text(this.share.content)
          .fontSize(14)
          .fontColor('#4b5563')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })
        
        // 分享图片
        if (this.share.images && this.share.images.length > 0) {
          Image(this.share.images[0])
            .width('100%')
            .height(200)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
            .margin({ bottom: 12 })
        }
        
        // 位置信息
        if (this.share.location) {
          Row() {
            Text('📍')
              .fontSize(14)
              .margin({ right: 6 })
            
            Text(this.share.location.name)
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 12 })
        }
        
        // 标签
        if (this.share.tags && this.share.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.share.tags ?? [], (tag: string, index: number) => {
              Text(`#${tag}`)
                .fontSize(10)
                .fontColor('#1e40af')
                .backgroundColor('#f0f8ff')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
                .margin({ right: 4, bottom: 4 })
            }, (tag: string, index: number) => `share-tag-${this.share.id}-${index}-${tag}`)
          }
          .width('100%')
          .margin({ bottom: 12 })
        }
      }
      .alignItems(HorizontalAlign.Start)

      // 互动按钮
      Row() {
        Button() {
          Text(this.isLiked ? '❤️' : '🤍')
            .fontSize(16)
            .margin({ right: 4 })
          Text(this.share.likes.toString())
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.handleLike();
        })
        
        Button() {
          Text('💬')
            .fontSize(16)
            .margin({ right: 4 })
          Text(this.share.comments.toString())
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.toggleComments();
        })
        
        Button() {
          Text('📤')
            .fontSize(16)
            .margin({ right: 4 })
          Text(this.share.shares.toString())
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .height(32)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 评论区域
      if (this.showComments) {
        Column() {
          // 评论列表
          ForEach(this.comments ?? [], (comment: Comment, index: number) => {
            Row() {
              Image(this.socialService.getUserById(comment.userId)?.avatar || '')
                .width(24)
                .height(24)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
              
              Column() {
                Text(this.socialService.getUserById(comment.userId)?.nickname || '未知用户')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1f2937')
                  .alignSelf(ItemAlign.Start)
                
                Text(comment.content)
                  .fontSize(12)
                  .fontColor('#4b5563')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 8 })
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 8 })
          }, (comment: Comment, index: number) => `cmt-${this.share.id}-${index}-${comment.userId}`)
          
          // 添加评论
          Row() {
            TextInput({ placeholder: '添加评论...' })
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .onChange((value: string) => {
                this.newComment = value;
              })
            
            Button() {
              Text('发送')
                .fontSize(12)
                .fontColor(Color.White)
            }
            .height(32)
            .backgroundColor('#1e40af')
            .borderRadius(16)
            .margin({ left: 8 })
            .onClick(() => {
              this.handleComment();
            })
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f8fafc')
        .borderRadius(8)
        .margin({ bottom: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }
}

/**
 * 附近用户卡片组件
 * 显示附近的旅行用户
 */
@Component
export struct NearbyUserCard {
  @Prop nearbyUser: NearbyUser;
  @Prop currentUserId: string;
  @State isFollowing: boolean = false;

  private socialService: SocialTravelService = SocialTravelService.getInstance();

  // 处理关注
  private async handleFollow() {
    if (this.isFollowing) {
      await this.socialService.unfollowUser(this.currentUserId, this.nearbyUser.user.userId);
      this.isFollowing = false;
    } else {
      await this.socialService.followUser(this.currentUserId, this.nearbyUser.user.userId);
      this.isFollowing = true;
    }
  }

  // 格式化距离
  private formatDistance(distance: number): string {
    if (distance < 1000) {
      return `${Math.round(distance)}m`;
    } else {
      return `${(distance / 1000).toFixed(1)}km`;
    }
  }

  build() {
    Row() {
      // 用户头像
      Stack() {
        Image(this.nearbyUser.user.avatar)
          .width(50)
          .height(50)
          .borderRadius(25)
          .objectFit(ImageFit.Cover)
        
        // 在线状态指示器
        Circle()
          .width(12)
          .height(12)
          .fill(this.nearbyUser.isOnline ? '#10b981' : '#6b7280')
          .position({ x: 38, y: 38 })
      }
      
      // 用户信息
      Column() {
        Text(this.nearbyUser.user.nickname)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
        
        Text(this.nearbyUser.user.bio || '热爱旅行的探索者')
          .fontSize(12)
          .fontColor('#6b7280')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
        
        Row() {
          Text('📍')
            .fontSize(10)
            .margin({ right: 4 })
          
          Text(this.formatDistance(this.nearbyUser.distance))
            .fontSize(10)
            .fontColor('#059669')
        }
        .justifyContent(FlexAlign.Start)
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
      
      // 关注按钮
      Button() {
        Text(this.isFollowing ? '已关注' : '关注')
          .fontSize(12)
          .fontColor(this.isFollowing ? '#6b7280' : Color.White)
      }
      .height(28)
      .backgroundColor(this.isFollowing ? '#f1f5f9' : '#1e40af')
      .borderRadius(14)
      .onClick(() => {
        this.handleFollow();
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 8 })
  }
}

/**
 * 旅行挑战卡片组件
 * 显示旅行挑战信息
 */
@Component
export struct TravelChallengeCard {
  @Prop challenge: TravelChallenge;
  @Prop currentUserId: string;
  @State isJoined: boolean = false;
  @State progress: number = 0;

  private socialService: SocialTravelService = SocialTravelService.getInstance();

  async aboutToAppear() {
    this.isJoined = this.challenge.participants.includes(this.currentUserId);
    if (this.isJoined) {
      // 获取用户进度
      const userProgress = this.socialService.getUserById(this.currentUserId);
      // 这里应该从实际数据获取进度
      this.progress = 0;
    }
  }

  // 参与挑战
  private async handleJoin() {
    if (this.isJoined) return;
    
    const success = await this.socialService.joinChallenge(this.currentUserId, this.challenge.id);
    if (success) {
      this.isJoined = true;
    }
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  build() {
    Column() {
      // 挑战头部
      Row() {
        Text(this.challenge.icon)
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text(this.challenge.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .alignSelf(ItemAlign.Start)
          
          Text(this.challenge.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 挑战进度
      if (this.isJoined) {
        Column() {
          Row() {
            Text('进度:')
              .fontSize(12)
              .fontColor('#6b7280')
            
            Text(`${this.progress}/${this.challenge.target} ${this.challenge.unit}`)
              .fontSize(12)
              .fontColor('#059669')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 8 })
          }
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 8 })
          
          // 进度条
          Progress({ value: this.progress, total: this.challenge.target })
            .width('100%')
            .height(6)
            .color('#059669')
            .backgroundColor('#e5e7eb')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }
      
      // 挑战信息
      Row() {
        Column() {
          Text('奖励')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(`${this.challenge.reward.points}积分`)
            .fontSize(12)
            .fontColor('#f59e0b')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text('参与人数')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(this.challenge.participants.length.toString())
            .fontSize(12)
            .fontColor('#1e40af')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Column() {
          Text('截止时间')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(this.formatTime(this.challenge.endDate))
            .fontSize(12)
            .fontColor('#dc2626')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 参与按钮
      Button() {
        Text(this.isJoined ? '已参与' : '参与挑战')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(36)
      .backgroundColor(this.isJoined ? '#6b7280' : this.challenge.color)
      .borderRadius(18)
      .enabled(!this.isJoined)
      .onClick(() => {
        this.handleJoin();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }
}
