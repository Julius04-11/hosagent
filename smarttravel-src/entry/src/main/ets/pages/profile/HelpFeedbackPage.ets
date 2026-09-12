import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface HelpItem {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
}

interface FeedbackItem {
  id: string;
  type: 'bug' | 'suggestion' | 'complaint' | 'praise';
  title: string;
  content: string;
  status: 'pending' | 'processing' | 'resolved';
  createTime: string;
  reply?: string;
}

@Entry
@Component
export struct HelpFeedbackPage {
  @State selectedTab: number = 0;
  @State feedbackContent: string = '';
  @State feedbackType: string = 'suggestion';
  @State contactInfo: string = '';

  private tabs: string[] = ['帮助中心', '意见反馈', '常见问题'];

  private helpItems: HelpItem[] = [
    {
      id: '1',
      title: '使用指南',
      description: '了解如何快速上手SmartTravel',
      icon: '📖',
      color: '#3b82f6'
    },
    {
      id: '2',
      title: '活动报名',
      description: '如何报名参加活动',
      icon: '🎫',
      color: '#10b981'
    },
    {
      id: '3',
      title: '支付问题',
      description: '支付失败、退款等',
      icon: '💳',
      color: '#f59e0b'
    },
    {
      id: '4',
      title: '账户安全',
      description: '密码找回、账户保护',
      icon: '🔒',
      color: '#ef4444'
    },
    {
      id: '5',
      title: '联系客服',
      description: '在线客服、电话咨询',
      icon: '🎧',
      color: '#8b5cf6'
    },
    {
      id: '6',
      title: '隐私政策',
      description: '了解我们的隐私保护',
      icon: '🛡️',
      color: '#6b7280'
    }
  ];

  private feedbackList: FeedbackItem[] = [
    {
      id: '1',
      type: 'suggestion',
      title: '建议增加夜间模式',
      content: '希望应用能够支持深色模式，在夜间使用时更加护眼。',
      status: 'resolved',
      createTime: '2024-06-01',
      reply: '感谢您的建议！我们已经在最新版本中增加了深色模式功能。'
    },
    {
      id: '2',
      type: 'bug',
      title: '活动详情页面加载缓慢',
      content: '在查看活动详情时，页面加载速度较慢，影响用户体验。',
      status: 'processing',
      createTime: '2024-06-03'
    },
    {
      id: '3',
      type: 'praise',
      title: '界面设计很棒',
      content: '应用的界面设计非常美观，用户体验很好！',
      status: 'resolved',
      createTime: '2024-06-05',
      reply: '谢谢您的认可！我们会继续努力提供更好的服务。'
    }
  ];

  private faqItems: HelpItem[] = [
    {
      id: '1',
      title: '如何报名参加活动？',
      description: '在活动详情页面点击"立即报名"按钮，填写相关信息即可完成报名。',
      icon: '❓',
      color: '#3b82f6'
    },
    {
      id: '2',
      title: '报名后可以取消吗？',
      description: '在活动开始前24小时内可以取消报名，具体规则请查看活动详情。',
      icon: '❓',
      color: '#10b981'
    },
    {
      id: '3',
      title: '如何查看我的报名记录？',
      description: '在"我的"页面点击"报名情况"即可查看所有报名记录。',
      icon: '❓',
      color: '#f59e0b'
    },
    {
      id: '4',
      title: '忘记密码怎么办？',
      description: '在登录页面点击"忘记密码"，通过手机验证码重置密码。',
      icon: '❓',
      color: '#ef4444'
    },
    {
      id: '5',
      title: '如何联系客服？',
      description: '可以通过应用内客服功能或拨打客服热线400-123-4567联系我们。',
      icon: '❓',
      color: '#8b5cf6'
    }
  ];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '帮助与反馈',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      // 标签页
      this.TabBar()

      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
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
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
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
          // 帮助中心
          this.HelpCenter()
        } else if (this.selectedTab === 1) {
          // 意见反馈
          this.FeedbackSection()
        } else {
          // 常见问题
          this.FAQSection()
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder HelpCenter() {
    Column() {
      Text('帮助中心')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      GridRow({
        columns: 2,
        gutter: { x: 12, y: 12 }
      }) {
        ForEach(this.helpItems ?? [], (item: HelpItem, index: number) => {
          GridCol({ span: 1 }) {
            this.HelpCard(item)
          }
        }, (item: HelpItem, index: number) => `help-${item.id}-${index}`)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder HelpCard(item: HelpItem) {
    Column() {
      Text(item.icon)
        .fontSize(32)
        .margin({ bottom: 8 })

      Text(item.title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 4 })
        .textAlign(TextAlign.Center)

      Text(item.description)
        .fontSize(12)
        .fontColor('#6b7280')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(120)
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.openHelpDetail(item.id);
    })
  }

  @Builder FeedbackSection() {
    Column() {
      // 反馈表单
      this.FeedbackForm()

      // 历史反馈
      this.FeedbackHistory()
    }
    .width('100%')
  }

  @Builder FeedbackForm() {
    Column() {
      Text('提交反馈')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      // 反馈类型选择
      Column() {
        Text('反馈类型')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row({ space: 12 }) {
          this.FeedbackTypeButton('建议', 'suggestion', this.feedbackType === 'suggestion')
          this.FeedbackTypeButton('Bug', 'bug', this.feedbackType === 'bug')
          this.FeedbackTypeButton('投诉', 'complaint', this.feedbackType === 'complaint')
          this.FeedbackTypeButton('表扬', 'praise', this.feedbackType === 'praise')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 16 })
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      // 反馈内容
      Column() {
        Text('反馈内容')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextArea({ placeholder: '请详细描述您的问题或建议...' })
          .width('100%')
          .height(120)
          .fontSize(14)
          .backgroundColor('#f9fafb')
          .borderRadius(8)
          .onChange((value: string) => {
            this.feedbackContent = value;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 16 })
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      // 联系方式
      Column() {
        Text('联系方式（可选）')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '手机号或邮箱，方便我们回复' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#f9fafb')
          .borderRadius(8)
          .onChange((value: string) => {
            this.contactInfo = value;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 16 })
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      // 提交按钮
      Button('提交反馈')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#3b82f6')
        .borderRadius(12)
        .width('100%')
        .height(48)
        .onClick(() => {
          this.submitFeedback();
        })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder FeedbackTypeButton(text: string, type: string, isSelected: boolean) {
    Text(text)
      .fontSize(12)
      .fontColor(isSelected ? '#3b82f6' : '#6b7280')
      .backgroundColor(isSelected ? '#dbeafe' : '#f3f4f6')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .onClick(() => {
        this.feedbackType = type;
      })
  }

  @Builder FeedbackHistory() {
    Column() {
      Text('历史反馈')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      ForEach(this.feedbackList ?? [], (feedback: FeedbackItem, index: number) => {
        this.FeedbackHistoryCard(feedback)
      }, (feedback: FeedbackItem, index: number) => `fb-${feedback.id}-${index}`)
    }
    .width('100%')
  }

  @Builder FeedbackHistoryCard(feedback: FeedbackItem) {
    Column() {
      Row() {
        Text(this.getFeedbackTypeText(feedback.type))
          .fontSize(12)
          .fontColor(this.getFeedbackTypeColor(feedback.type))
          .backgroundColor(this.getFeedbackTypeBgColor(feedback.type))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)

        Blank()

        Text(this.getStatusText(feedback.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(feedback.status))
          .backgroundColor(this.getStatusBgColor(feedback.status))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(feedback.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Text(feedback.content)
        .fontSize(14)
        .fontColor('#6b7280')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      if (feedback.reply) {
        Column() {
          Text('官方回复:')
            .fontSize(12)
            .fontColor('#10b981')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(feedback.reply)
            .fontSize(14)
            .fontColor('#374151')
            .alignSelf(ItemAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f0fdf4')
        .borderRadius(8)
        .margin({ bottom: 8 })
      }

      Text(`提交时间: ${feedback.createTime}`)
        .fontSize(12)
        .fontColor('#9ca3af')
        .alignSelf(ItemAlign.Start)
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

  @Builder FAQSection() {
    Column() {
      Text('常见问题')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      ForEach(this.faqItems ?? [], (item: HelpItem, index: number) => {
        this.FAQCard(item)
      }, (item: HelpItem, index: number) => `faq-${item.id}-${index}`)
    }
    .width('100%')
  }

  @Builder FAQCard(item: HelpItem) {
    Column() {
      Row() {
        Text(item.icon)
          .fontSize(20)
          .margin({ right: 12 })

        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
          .alignSelf(ItemAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(item.description)
        .fontSize(14)
        .fontColor('#6b7280')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 32 })
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
      this.openFAQDetail(item.id);
    })
  }

  private getFeedbackTypeText(type: string): string {
    switch (type) {
      case 'suggestion': return '建议';
      case 'bug': return 'Bug';
      case 'complaint': return '投诉';
      case 'praise': return '表扬';
      default: return '其他';
    }
  }

  private getFeedbackTypeColor(type: string): string {
    switch (type) {
      case 'suggestion': return '#3b82f6';
      case 'bug': return '#ef4444';
      case 'complaint': return '#f59e0b';
      case 'praise': return '#10b981';
      default: return '#6b7280';
    }
  }

  private getFeedbackTypeBgColor(type: string): string {
    switch (type) {
      case 'suggestion': return '#dbeafe';
      case 'bug': return '#fee2e2';
      case 'complaint': return '#fef3c7';
      case 'praise': return '#d1fae5';
      default: return '#f3f4f6';
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'pending': return '待处理';
      case 'processing': return '处理中';
      case 'resolved': return '已解决';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'pending': return '#f59e0b';
      case 'processing': return '#3b82f6';
      case 'resolved': return '#10b981';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'pending': return '#fef3c7';
      case 'processing': return '#dbeafe';
      case 'resolved': return '#d1fae5';
      default: return '#f3f4f6';
    }
  }

  private openHelpDetail(id: string): void {
    router.pushUrl({ 
      url: 'pages/help/HelpDetailPage',
      params: { id: id }
    });
  }

  private openFAQDetail(id: string): void {
    router.pushUrl({ 
      url: 'pages/help/FAQDetailPage',
      params: { id: id }
    });
  }

  private submitFeedback(): void {
    if (!this.feedbackContent.trim()) {
      console.log('请填写反馈内容');
      return;
    }

    // 提交反馈逻辑
    console.log('反馈已提交');
    this.feedbackContent = '';
    this.contactInfo = '';
  }
}
