import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface NoticeItem {
  id: string;
  title: string;
  content: string;
  time: string;
  type: 'system' | 'activity' | 'promotion';
  isRead: boolean;
  icon: string;
}

@Entry
@Component
export struct NoticeListPage {
  @State notices: NoticeItem[] = [];
  @State isLoading: boolean = true;
  @State selectedType: string = '全部';

  private noticeTypes: string[] = ['全部', '系统通知', '活动通知', '优惠通知'];

  aboutToAppear() {
    this.loadNotices();
  }

  private loadNotices() {
    setTimeout(() => {
      this.notices = [
        {
          id: '1',
          title: '系统维护通知',
          content: '系统将于2025年11月15日 00:00-06:00进行维护升级，期间可能无法正常使用部分功能，给您带来不便敬请谅解。',
          time: '2025-11-14 10:30',
          type: 'system',
          isRead: false,
          icon: '🔔'
        },
        {
          id: '2',
          title: '世界之窗文化节即将开始',
          content: '世界之窗国际文化节将于11月20日正式开幕，提前购票享受8折优惠，快来体验多元文化魅力吧！',
          time: '2025-11-14 09:15',
          type: 'activity',
          isRead: false,
          icon: '🎉'
        },
        {
          id: '3',
          title: '限时优惠：酒店预订8折',
          content: '即日起至11月30日，预订指定酒店享受8折优惠，还有免费早餐和延迟退房服务，数量有限，先到先得！',
          time: '2025-11-13 16:45',
          type: 'promotion',
          isRead: true,
          icon: '💰'
        },
        {
          id: '4',
          title: '新功能上线：智能路线推荐',
          content: '我们推出了全新的智能路线推荐功能，根据您的喜好和位置，为您推荐最适合的旅游路线，快来体验吧！',
          time: '2025-11-12 14:20',
          type: 'system',
          isRead: true,
          icon: '✨'
        },
        {
          id: '5',
          title: '欢乐谷万圣节活动开始报名',
          content: '欢乐谷万圣节狂欢夜活动开始报名啦！参与活动还有机会获得精美礼品，快来报名参加吧！',
          time: '2025-11-11 11:00',
          type: 'activity',
          isRead: true,
          icon: '🎃'
        }
      ];
      this.isLoading = false;
    }, 600);
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '通知中心',
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Column() {
          // 分类筛选
          this.TypeFilter()

          // 通知列表
          Scroll() {
            Column({ space: 12 }) {
              if (this.filteredNotices.length === 0) {
                this.EmptyView()
              } else {
                ForEach(this.filteredNotices ?? [], (notice: NoticeItem, index: number) => {
                  this.NoticeCard(notice)
                }, (notice: NoticeItem, index: number) => `notice-${notice.id}-${index}`)
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
          }
          .layoutWeight(1)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('📬')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在加载通知...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder EmptyView() {
    Column() {
      Text('📭')
        .fontSize(64)
        .margin({ bottom: 16 })
      
      Text('暂无通知')
        .fontSize(16)
        .fontColor('#6b7280')
        .margin({ bottom: 8 })
      
      Text('您还没有收到任何通知')
        .fontSize(14)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(40)
    .justifyContent(FlexAlign.Center)
  }

  @Builder TypeFilter() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.noticeTypes ?? [], (type: string, index: number) => {
          Text(type)
            .fontSize(14)
            .fontColor(this.selectedType === type ? Color.White : '#6b7280')
            .backgroundColor(this.selectedType === type ? '#6366f1' : '#f3f4f6')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(20)
            .onClick(() => {
              this.selectedType = type;
            })
        }, (type: string, index: number) => `ntype-${index}-${type}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
  }

  @Builder NoticeCard(notice: NoticeItem) {
    Row() {
      // 图标
      Text(notice.icon)
        .fontSize(32)
        .margin({ right: 12 })

      Column({ space: 6 }) {
        Row() {
          Text(notice.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (!notice.isRead) {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor('#ef4444')
          }

          Text(this.getTypeLabel(notice.type))
            .fontSize(10)
            .fontColor(this.getTypeColor(notice.type))
            .backgroundColor(this.getTypeBgColor(notice.type))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ left: 8 })
        }
        .width('100%')

        Text(notice.content)
          .fontSize(13)
          .fontColor('#6b7280')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)

        Text(notice.time)
          .fontSize(11)
          .fontColor('#9ca3af')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(notice.isRead ? Color.White : '#f0f9ff')
    .borderRadius(12)
    .border({
      width: notice.isRead ? 0 : 1,
      color: '#dbeafe'
    })
    .onClick(() => {
      this.markAsRead(notice.id);
    })
  }

  get filteredNotices(): NoticeItem[] {
    if (this.selectedType === '全部') {
      return this.notices;
    }
    const typeMap: Record<string, string> = {
      '系统通知': 'system',
      '活动通知': 'activity',
      '优惠通知': 'promotion'
    };
    return this.notices.filter(notice => notice.type === typeMap[this.selectedType]);
  }

  private getTypeLabel(type: string): string {
    const labelMap: Record<string, string> = {
      'system': '系统',
      'activity': '活动',
      'promotion': '优惠'
    };
    return labelMap[type] || '通知';
  }

  private getTypeColor(type: string): string {
    const colorMap: Record<string, string> = {
      'system': '#6366f1',
      'activity': '#10b981',
      'promotion': '#f59e0b'
    };
    return colorMap[type] || '#6b7280';
  }

  private getTypeBgColor(type: string): string {
    const bgMap: Record<string, string> = {
      'system': '#eef2ff',
      'activity': '#d1fae5',
      'promotion': '#fef3c7'
    };
    return bgMap[type] || '#f3f4f6';
  }

  private markAsRead(id: string): void {
    const notice = this.notices.find(n => n.id === id);
    if (notice) {
      notice.isRead = true;
      this.notices = [...this.notices];
    }
  }
}

