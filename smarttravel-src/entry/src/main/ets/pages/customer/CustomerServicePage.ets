import { Prompt, router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface ServiceItem {
  icon: string;
  name: string;
  description: string;
  color: string;
}

interface OrderItem {
  route: string;
  status: string;
  date: string;
  time: string;
  flightNumber: string;
  price: string;
}

@Entry
@Component
export struct CustomerServicePage {
  @State userName: string = 'syt';
  @State userLevel: string = '白银贵宾';
  @State isCheckedIn: boolean = false;
  @State checkInDays: number = 0;

  private serviceItems: ServiceItem[] = [
    { icon: '📞', name: '在线客服', description: '7×24小时在线服务', color: '#3b82f6' },
    { icon: '📱', name: '电话客服', description: '400-123-4567', color: '#10b981' },
    { icon: '💬', name: '微信客服', description: '扫码添加客服微信', color: '#06b6d4' },
    { icon: '📧', name: '邮件客服', description: 'service@smarttravel.com', color: '#8b5cf6' }
  ];

  private orderItems: OrderItem[] = [
    {
      route: '合肥-深圳',
      status: '已出票',
      date: '8月27日',
      time: '06:35',
      flightNumber: 'CZ8596',
      price: '¥530'
    },
    {
      route: '深圳-合肥',
      status: '已出票',
      date: '1月8日',
      time: '07:20',
      flightNumber: 'CZ8595',
      price: '¥528'
    }
  ];

  private quickActions: ServiceItem[] = [
    { icon: '📋', name: '我要开发票', description: '电子发票申请', color: '#f59e0b' },
    { icon: '📄', name: '报销行程单', description: '行程单下载', color: '#ef4444' },
    { icon: '🔍', name: '查询订单', description: '订单状态查询', color: '#6366f1' },
    { icon: '💰', name: '我要报销', description: '报销申请', color: '#84cc16' },
    { icon: '👤', name: '乘客信息', description: '查看乘客详情', color: '#ec4899' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '客服中心',
        showBack: true,
        showSearch: false,
        showNotification: false
      })
      
      Scroll() {
        Column() {
          // 欢迎横幅
          this.WelcomeBanner()
          
          // 签到功能
          this.CheckInCard()
          
          // 订单选择区域
          this.OrderSelectionCard()
          
          // 快捷服务
          this.QuickServiceCard()
          
          // 推荐服务
          this.RecommendedServiceCard()
          
          // 底部客服入口
          this.BottomServiceCard()
        }
        .width('100%')
        .backgroundColor('#f8fafc')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder WelcomeBanner() {
    Column() {
      Row() {
        // 客服头像
        Column() {
          Text('👩‍💼')
            .fontSize(48)
            .margin({ bottom: 8 })
          
          // 标签
          Row({ space: 8 }) {
            Text('放心')
              .fontSize(12)
              .fontColor('#3b82f6')
              .backgroundColor('#dbeafe')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
            
            Text('专业')
              .fontSize(12)
              .fontColor('#10b981')
              .backgroundColor('#d1fae5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
            
            Text('温暖')
              .fontSize(12)
              .fontColor('#f59e0b')
              .backgroundColor('#fef3c7')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
          }
        }
        .margin({ right: 20 })

        // 欢迎信息
        Column() {
          Text(`亲爱的${this.userLevel},您好`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .margin({ bottom: 8 })
          
          Text('智能旅行客服随时为您服务 >')
            .fontSize(14)
            .fontColor('#3b82f6')
            .onClick(() => {
              Prompt.showToast({ message: '正在连接客服...' })
            })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor('#e0f2fe')
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
  }

  @Builder CheckInCard() {
    Column() {
      Row() {
        Text('📅')
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text('每日签到')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .margin({ bottom: 4 })
          
          Text(`已连续签到 ${this.checkInDays} 天`)
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button(this.isCheckedIn ? '已签到' : '立即签到')
          .fontSize(14)
          .fontColor(this.isCheckedIn ? '#6b7280' : '#ffffff')
          .backgroundColor(this.isCheckedIn ? '#f3f4f6' : '#3b82f6')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .enabled(!this.isCheckedIn)
          .onClick(() => {
            this.handleCheckIn()
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder OrderSelectionCard() {
    Column() {
      Text('请选择您需要咨询的订单')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Column({ space: 12 }) {
        ForEach(this.orderItems ?? [], (order: OrderItem, index: number) => {
          this.OrderItem(order, index)
        }, (order: OrderItem, index: number) => `order-${index}-${order.route}`)
      }
      .width('100%')

      Text('查看全部订单 >')
        .fontSize(14)
        .fontColor('#3b82f6')
        .margin({ top: 12 })
        .onClick(() => {
          Prompt.showToast({ message: '查看全部订单' })
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder OrderItem(order: OrderItem, index: number) {
    Row() {
      // 航班图标
      Text('✈️')
        .fontSize(20)
        .margin({ right: 12 })

      // 订单信息
      Column() {
        Text(order.route)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 4 })
        
        Text(`${order.status} | ${order.date} ${order.time} ${order.flightNumber}`)
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ bottom: 4 })
        
        Text(order.price)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ef4444')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 客服按钮
      Column() {
        Text('🎧')
          .fontSize(20)
          .margin({ bottom: 4 })
        
        Text('客服')
          .fontSize(12)
          .fontColor('#3b82f6')
      }
      .onClick(() => {
        Prompt.showToast({ message: `正在为订单 ${order.route} 连接客服...` })
      })

      // 快捷操作
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          ForEach((this.quickActions ?? []).slice(0, 2), (action: ServiceItem, index: number) => {
            Text(action.name)
              .fontSize(10)
              .fontColor('#6b7280')
              .backgroundColor('#f3f4f6')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)
              .onClick(() => {
                Prompt.showToast({ message: action.name })
              })
          }, (action: ServiceItem, index: number) => `qa1-${index}-${action.name}`)
        }
        
        Row({ space: 8 }) {
          ForEach((this.quickActions ?? []).slice(2, 4), (action: ServiceItem, index: number) => {
            Text(action.name)
              .fontSize(10)
              .fontColor('#6b7280')
              .backgroundColor('#f3f4f6')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)
              .onClick(() => {
                Prompt.showToast({ message: action.name })
              })
          }, (action: ServiceItem, index: number) => `qa2-${index}-${action.name}`)
        }
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
    .borderRadius(12)
    .onClick(() => {
      Prompt.showToast({ message: `选择订单：${order.route}` })
    })
  }

  @Builder QuickServiceCard() {
    Column() {
      Text('推荐服务')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Row({ space: 16 }) {
        ForEach((this.serviceItems ?? []).slice(0, 3), (service: ServiceItem, index: number) => {
          this.ServiceItem(service)
        }, (service: ServiceItem, index: number) => `svc-${index}-${service.name}`)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ServiceItem(service: ServiceItem) {
    Column() {
      Text(service.icon)
        .fontSize(32)
        .margin({ bottom: 8 })
      
      Text(service.name)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 4 })
      
      Text(service.description)
        .fontSize(10)
        .fontColor('#6b7280')
        .textAlign(TextAlign.Center)
    }
    .width(80)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      Prompt.showToast({ message: `点击了：${service.name}` })
    })
  }

  @Builder RecommendedServiceCard() {
    Column() {
      Text('更多服务')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      GridRow({
        columns: 2,
        gutter: { x: 12, y: 12 }
      }) {
        ForEach(this.quickActions ?? [], (action: ServiceItem, index: number) => {
          GridCol({ span: 1 }) {
            this.ActionItem(action)
          }
        }, (action: ServiceItem, index: number) => `gridqa-${index}-${action.name}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ActionItem(action: ServiceItem) {
    Row() {
      Text(action.icon)
        .fontSize(20)
        .margin({ right: 12 })
      
      Column() {
        Text(action.name)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 2 })
        
        Text(action.description)
          .fontSize(12)
          .fontColor('#6b7280')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(60)
    .padding(12)
    .backgroundColor('#f8fafc')
    .borderRadius(12)
    .onClick(() => {
      Prompt.showToast({ message: action.name })
    })
  }

  @Builder BottomServiceCard() {
    Row({ space: 20 }) {
      // 在线客服
      Column() {
        Text('🎧')
          .fontSize(32)
          .margin({ bottom: 8 })
        
        Text('在线客服')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3b82f6')
      }
      .layoutWeight(1)
      .height(80)
      .backgroundColor('#dbeafe')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        Prompt.showToast({ message: '正在连接在线客服...' })
      })

      // 电话客服
      Column() {
        Text('📞')
          .fontSize(32)
          .margin({ bottom: 8 })
        
        Text('电话客服')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#10b981')
      }
      .layoutWeight(1)
      .height(80)
      .backgroundColor('#d1fae5')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        Prompt.showToast({ message: '正在拨打客服电话...' })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private handleCheckIn() {
    this.isCheckedIn = true
    this.checkInDays += 1
    
    Prompt.showToast({ 
      message: `签到成功！连续签到 ${this.checkInDays} 天，获得 10 积分` 
    })
  }
}
