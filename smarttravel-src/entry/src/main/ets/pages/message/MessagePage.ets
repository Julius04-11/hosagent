import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface MessageItem {
  id: string;
  title: string;
  content: string;
  time: string;
  unread: boolean;
  avatar: string;
  type: 'order' | 'interactive' | 'account' | 'member';
}

interface GeneratedTypeLiteralInterface_1 {
  icon: string;
  title: string;
  count: number;
  color: string;
}

@Entry
@Component
export struct MessagePage {
  @State messageList: MessageItem[] = [
    {
      id: '1',
      title: '订单出行',
      content: '您的深圳世界之窗门票订单已确认，请按时出行',
      time: '20:05',
      unread: true,
      avatar: '📋',
      type: 'order'
    },
    {
      id: '2',
      title: '互动消息',
      content: '您发布的"深圳一日游攻略"收到了5个赞',
      time: '19:30',
      unread: true,
      avatar: '💬',
      type: 'interactive'
    },
    {
      id: '3',
      title: '账户通知',
      content: '您的账户安全设置已更新',
      time: '18:45',
      unread: true,
      avatar: '🔔',
      type: 'account'
    },
    {
      id: '4',
      title: '会员服务',
      content: '恭喜您升级为黄金会员，享受更多专属权益',
      time: '17:20',
      unread: false,
      avatar: '👑',
      type: 'member'
    },
    {
      id: '5',
      title: '活动优惠',
      content: '深圳欢乐谷限时优惠，门票8折起',
      time: '16:10',
      unread: false,
      avatar: '🎉',
      type: 'member'
    }
  ];
  @State unreadCount: number = 3;

  build() {
    Column() {
      // 统一的顶部导航栏
      TopNavigationBar({
        title: '消息',
        showSearch: true,
        showNotification: true,
        notificationCount: this.unreadCount
      })

      // 消息分类
      this.MessageCategories()

      // 消息列表
      this.MessageList()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }


  @Builder
  MessageCategories() {
    Row({ space: 20 }) {
      ForEach([
        {
          icon: '📋',
          title: '订单出行',
          count: 1,
          color: '#3b82f6'
        },
        {
          icon: '💬',
          title: '互动消息',
          count: 1,
          color: '#f59e0b'
        },
        {
          icon: '🔔',
          title: '账户通知',
          count: 1,
          color: '#f59e0b'
        },
        {
          icon: '👑',
          title: '会员服务',
          count: 2,
          color: '#f59e0b'
        }
      ], (category: GeneratedTypeLiteralInterface_1, index: number) => {
        Column() {
          Stack() {
            Text(category.icon)
              .fontSize(24)
              .fontColor(Color.White)
          }
          .width(48)
          .height(48)
          .backgroundColor(category.color)
          .borderRadius(24)
          .alignContent(Alignment.Center)
          .margin({ bottom: 8 })

          Text(category.title)
            .fontSize(12)
            .fontColor('#374151')
            .textAlign(TextAlign.Center)

          if (category.count > 0) {
            Text(category.count.toString())
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#ef4444')
              .borderRadius(8)
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .margin({ top: 4 })
          }
        }
        .width(60)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          // 跳转到对应分类的消息
        })
      }, (category: GeneratedTypeLiteralInterface_1, index: number) => `msgcat-${index}-${category.title}`)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder
  MessageList() {
    Scroll() {
      Column() {
        ForEach(this.messageList ?? [], (message: MessageItem, index: number) => {
          this.MessageItem(message)
        }, (message: MessageItem, index: number) => `msg-${message.id}-${index}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  MessageItem(message: MessageItem) {
    Row() {
      // 头像
      Text(message.avatar)
        .fontSize(24)
        .width(48)
        .height(48)
        .backgroundColor('#f3f4f6')
        .borderRadius(24)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      // 消息内容
      Column() {
        Row() {
          Text(message.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .layoutWeight(1)

          Text(message.time)
            .fontSize(12)
            .fontColor('#9ca3af')
        }
        .width('100%')
        .margin({ bottom: 4 })

        Text(message.content)
          .fontSize(14)
          .fontColor('#6b7280')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 未读标识
      if (message.unread) {
        Circle({ width: 8, height: 8 })
          .fill('#ef4444')
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 2,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      // 标记为已读
      message.unread = false;
      this.updateUnreadCount();
    })
  }

  private updateUnreadCount() {
    this.unreadCount = this.messageList.filter(msg => msg.unread).length;
  }
}
