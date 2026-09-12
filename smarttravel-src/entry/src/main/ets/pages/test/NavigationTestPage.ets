/**
 * 导航测试页面 - 快速访问所有截图页面
 * 用于课程设计展示和截图
 */
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct NavigationTestPage {
  @State currentSection: string = 'main'
  
  private mainPages: PageItem[] = [
    { title: '【截图1】主页面', route: 'pages/MainPage', desc: '底部导航栏' } as PageItem,
    { title: '【截图2】首页信息流', route: 'pages/home/NewHomePage', desc: 'Banner+快捷入口' } as PageItem,
  ]
  
  private categoryPages: PageItem[] = [
    { title: '【截图4】美食列表', route: 'pages/category/FoodPage', desc: '美食分类页面' } as PageItem,
    { title: '【截图5】酒店列表', route: 'pages/category/HotelPage', desc: '酒店分类页面' } as PageItem,
    { title: '【截图6】购物列表', route: 'pages/category/ShoppingPage', desc: '购物分类页面' } as PageItem,
  ]
  
  private activityPages: PageItem[] = this.createActivityPages()
  private mapPages: PageItem[] = this.createMapPages()
  private hotelPages: PageItem[] = this.createHotelPages()
  private profilePages: PageItem[] = this.createProfilePages()
  private searchPages: PageItem[] = this.createSearchPages()
  private detailPages: PageItem[] = this.createDetailPages()
  private specialPages: PageItem[] = this.createSpecialPages()

  private createActivityPages(): PageItem[] {
    return [
      { title: '【截图7-8】活动详情', route: 'pages/activity/ActivityDetailPage', desc: '活动详情+报名浮层' } as PageItem,
      { title: '活动列表', route: 'pages/activity/ActivityPage', desc: '活动列表页面' } as PageItem,
    ]
  }

  private createMapPages(): PageItem[] {
    return [
      { title: '【截图10】地图主页', route: 'pages/map/MapPage', desc: '地图+气泡提醒' } as PageItem,
      { title: '【截图12】路线规划', route: 'pages/transport/RouteNavigationPage', desc: '地址交换动画' } as PageItem,
    ]
  }

  private createHotelPages(): PageItem[] {
    return [
      { title: '【截图14】酒店搜索', route: 'pages/hotel/HotelSearchPage', desc: '搜索筛选' } as PageItem,
      { title: '【截图15】酒店详情', route: 'pages/hotel/HotelDetailPage', desc: '详情页' } as PageItem,
      { title: '【截图16】订单确认', route: 'pages/hotel/HotelBookingPage', desc: '预订确认' } as PageItem,
      { title: '【截图17】我的订单', route: 'pages/order/HotelOrderPage', desc: '订单列表' } as PageItem,
    ]
  }

  private createProfilePages(): PageItem[] {
    return [
      { title: '【截图18-19】个人中心', route: 'pages/profile/ProfilePage', desc: '用户信息+功能' } as PageItem,
      { title: '【截图20】报名情况', route: 'pages/profile/RegistrationStatusPage', desc: '报名记录' } as PageItem,
      { title: '【截图21】我的订单', route: 'pages/order/HotelOrderPage', desc: '订单管理' } as PageItem,
    ]
  }

  private createSearchPages(): PageItem[] {
    return [
      { title: '【截图22-23】搜索页面', route: 'pages/search/SearchPage', desc: '搜索+结果' } as PageItem,
    ]
  }

  private createDetailPages(): PageItem[] {
    return [
      { title: '【截图24】美食详情', route: 'pages/detail/FoodDetailPage', desc: '餐厅详情' } as PageItem,
      { title: '【截图25】景点详情', route: 'pages/activity/ActivityDetailPage', desc: '景点详情' } as PageItem,
    ]
  }

  private createSpecialPages(): PageItem[] {
    return [
      { title: '【截图26】语音讲解', route: 'pages/attraction/AttractionAudioPage', desc: '语音讲解界面' } as PageItem,
      { title: 'AR导航', route: 'pages/ar/ARNavigationPage', desc: 'AR导航功能' } as PageItem,
    ]
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('📸 截图导航测试')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#3b82f6')
      
      // 分类Tab
      Scroll() {
        Row({ space: 12 }) {
          this.TabButton('主要页面', 'main')
          this.TabButton('分类页面', 'category')
          this.TabButton('活动模块', 'activity')
          this.TabButton('地图导航', 'map')
          this.TabButton('酒店预订', 'hotel')
          this.TabButton('个人中心', 'profile')
          this.TabButton('搜索功能', 'search')
          this.TabButton('详情页面', 'detail')
          this.TabButton('特色功能', 'special')
        }
        .padding(12)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')
      
      // 内容区域
      Scroll() {
        Column({ space: 12 }) {
          this.renderCurrentSection()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#f9fafb')
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder TabButton(title: string, section: string) {
    Text(title)
      .fontSize(14)
      .fontColor(this.currentSection === section ? Color.White : '#333333')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentSection === section ? '#3b82f6' : Color.White)
      .borderRadius(16)
      .onClick(() => {
        this.currentSection = section
      })
  }
  
  // 获取当前章节的页面列表
  private getCurrentPages(): PageItem[] {
    switch (this.currentSection) {
      case 'main': return this.mainPages
      case 'category': return this.categoryPages
      case 'activity': return this.activityPages
      case 'map': return this.mapPages
      case 'hotel': return this.hotelPages
      case 'profile': return this.profilePages
      case 'search': return this.searchPages
      case 'detail': return this.detailPages
      case 'special': return this.specialPages
      default: return []
    }
  }
  
  // 获取当前章节标题
  private getSectionTitle(): string {
    switch (this.currentSection) {
      case 'main': return '主要页面'
      case 'category': return '分类页面'
      case 'activity': return '活动模块'
      case 'map': return '地图导航'
      case 'hotel': return '酒店预订'
      case 'profile': return '个人中心'
      case 'search': return '搜索功能'
      case 'detail': return '详情页面'
      case 'special': return '特色功能'
      default: return ''
    }
  }
  
  @Builder renderCurrentSection() {
    Column() {
      // 章节标题
      Text(this.getSectionTitle())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      // 页面列表
      ForEach(this.getCurrentPages(), (item: PageItem) => {
        this.PageCard(item)
      })
    }
  }
  
  @Builder PageCard(item: PageItem) {
    Column() {
      Row() {
        Column() {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .margin({ bottom: 4 })
          
          Text(item.desc)
            .fontSize(14)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        Text('→')
          .fontSize(20)
          .fontColor('#9ca3af')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick(() => {
      this.navigateTo(item.route, item.params)
    })
  }
  
  private navigateTo(route: string, params?: Record<string, Object>) {
    try {
      router.pushUrl({
        url: route,
        params: params || ({} as Record<string, Object>)
      })
    } catch (error) {
      promptAction.showToast({
        message: `页面跳转失败: ${route}`,
        duration: 2000
      })
      console.error('Navigation error:', error)
    }
  }
}

interface PageItem {
  title: string
  route: string
  desc: string
  params?: Record<string, Object>
}
