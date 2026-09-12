import { router } from '@kit.ArkUI';
import { MapPage } from './map/MapPage';
import { ProfilePage } from './profile/ProfilePage';

@Entry
@Component
struct MainPage {
  @State currentTabIndex: number = 0;

  aboutToAppear() {
    // 初始化
  }

  build() {
    Tabs({ index: this.currentTabIndex }) {
      // Tab 1: 首页
      TabContent() {
        Column() {
          Text('首页开发中...')
        }
        .width('100%')
        .height('100%')
      }
      .tabBar(this.TabBuilder(0, '首页', '🏠'))

      // Tab 2: 游园
      TabContent() {
        Column() {
          Text('游园开发中...')
        }
        .width('100%')
        .height('100%')
      }
      .tabBar(this.TabBuilder(1, '游园', '🎡'))

      // Tab 3: 地图
      TabContent() {
        MapPage()
      }
      .tabBar(this.TabBuilder(2, '地图', '🗺️'))

      // Tab 4: 我的
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder(3, '我的', '👤'))
    }
    .barPosition(BarPosition.End)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
    .backgroundColor('#f5f5f5')
    .barBackgroundColor('#ffffff')
  }

  // Tab栏构建器
  @Builder TabBuilder(index: number, name: string, icon: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(24)
        .fontColor(this.currentTabIndex === index ? '#0086f6' : '#999999')
      
      Text(name)
        .fontSize(11)
        .fontColor(this.currentTabIndex === index ? '#0086f6' : '#999999')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  // 游园页面占位符（后续实现）
  @Builder ParkPlaceholder() {
    Column() {
      Text('游园页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })
      
      Text('敬请期待...')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 20 })
      
      Button('查看路线推荐')
        .margin({ top: 40 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/category/RoutePage' });
        })
      
      Button('查看自然景点')
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/category/NaturePage' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#ffffff')
  }

  // 地图页面占位符（后续实现）
  @Builder MapPlaceholder() {
    Column() {
      Text('地图导航页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })
      
      Text('需要集成华为Map Kit')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 20 })
      
      Column({ space: 16 }) {
        Text('功能规划:')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 40 })
        
        Text('✅ 园区地图展示')
          .fontSize(14)
          .fontColor('#666666')
        
        Text('✅ 景点位置标记')
          .fontSize(14)
          .fontColor('#666666')
        
        Text('✅ 定位功能')
          .fontSize(14)
          .fontColor('#666666')
        
        Text('✅ 路径规划')
          .fontSize(14)
          .fontColor('#666666')
        
        Text('✅ 导航跳转')
          .fontSize(14)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .backgroundColor('#ffffff')
  }

  // 个人中心占位符（后续整合现有功能）
  @Builder PersonalPlaceholder() {
    Column() {
      Text('个人中心')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })
      
      Text('整合现有"我的"页面功能')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 20 })
      
      Button('查看订单')
        .margin({ top: 40 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/order/OrderPage' });
        })
      
      Button('查看收藏')
        .margin({ top: 20 })
        .onClick(() => {
          // 跳转到收藏页面
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#ffffff')
  }
}
