import { ActivityPageNew } from './activity/ActivityPageNew';
import { HomePage } from './home/HomePage';
import { ProfilePage } from './profile/ProfilePage';
import { MessagePage } from './message/MessagePage';
import { ItineraryPage } from './itinerary/ItineraryPage';
import { MapPage } from './map/MapPage';
import { display } from '@kit.ArkUI';

interface TabItem {
  title: string;
  icon: string;
  selectedIcon: string;
  hasNotification?: boolean;
  notificationCount?: number;
}

@Entry
@Component
struct Index {
  @State selected: number = 0;
  @State deviceWidth: number = 0;
  @State selectedCategory: string = '热门推荐';

  private tabItems: TabItem[] = [
    {
      title: '首页',
      icon: '🏠',
      selectedIcon: '🏠'
    },
    {
      title: '地图',
      icon: '🗺️',
      selectedIcon: '🗺️'
    },
    {
      title: '社区',
      icon: '👥',
      selectedIcon: '👥',
      hasNotification: true,
      notificationCount: 3
    },
    {
      title: '行程',
      icon: '📅',
      selectedIcon: '📅'
    },
    {
      title: '我的',
      icon: '👤',
      selectedIcon: '👤'
    }
  ];

  aboutToAppear() {
    this.updateDeviceInfo();
    // 监听AppStorage变化
    AppStorage.setOrCreate('selectedTab', 0);
    AppStorage.setOrCreate('selectedCategory', '热门推荐');
  }

  onConfigurationUpdate() {
    this.updateDeviceInfo();
  }

  private updateDeviceInfo() {
    const defaultDisplay = display.getDefaultDisplaySync();
    this.deviceWidth = defaultDisplay.width;
  }

  build() {
    Column() {
      // 主要内容区域 - 使用layoutWeight确保为底部导航栏留出空间
      if (this.selected === 0) {
        HomePage()
          .layoutWeight(1)
      } else if (this.selected === 1) {
        MapPage()
          .layoutWeight(1)
      } else if (this.selected === 2) {
        ActivityPageNew()
          .layoutWeight(1)
      } else if (this.selected === 3) {
        ItineraryPage()
          .layoutWeight(1)
      } else if (this.selected === 4) {
        ProfilePage()
          .layoutWeight(1)
      }

      // 现代化底部导航栏 - 确保始终显示
      this.BottomNavigationBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
    .onAppear(() => {
      // 监听AppStorage变化，实现页面切换
      AppStorage.setAndLink('selectedTab', 0);
    })
  }

  @Builder BottomNavigationBar() {
    Row() {
      ForEach(this.tabItems ?? [], (item: TabItem, index: number) => {
        Column() {
          // 图标容器
          Stack({ alignContent: Alignment.TopEnd }) {
            // 主图标
            Text(item.icon)
              .fontSize(22)
              .fontColor(this.selected === index ? '#1890ff' : '#666666')
              .fontWeight(this.selected === index ? FontWeight.Bold : FontWeight.Normal)
            
            // 通知徽章 - 右上角显示
            if (item.hasNotification && item.notificationCount && item.notificationCount > 0) {
              Text(item.notificationCount.toString())
                .fontSize(10)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#ff4d4f')
                .borderRadius(8)
                .width(16)
                .height(16)
                .textAlign(TextAlign.Center)
                .position({ x: 10, y: -2 })
            }
          }
          .width(32)
          .height(32)

          // 标题
          Text(item.title)
            .fontSize(11)
            .fontColor(this.selected === index ? '#1890ff' : '#666666')
            .fontWeight(this.selected === index ? FontWeight.Medium : FontWeight.Normal)
            .margin({ top: 4 })
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.selected === index ? '#f0f8ff' : Color.Transparent)
        .borderRadius(8)
        .margin({ left: 1, right: 1 })
        .onClick(() => {
          this.selected = index;
          // 更新AppStorage状态
          AppStorage.set('selectedTab', index);
        })
      }, (item: TabItem, index: number) => `tab-${item.title}-${index}`)
    }
    .width('100%')
    .height(80)
    .backgroundColor('#ffffff')
    .padding({ top: 6, bottom: 6, left: 4, right: 4 })
    .shadow({
      radius: 16,
      color: 'rgba(0,0,0,0.12)',
      offsetX: 0,
      offsetY: -6
    })
    .borderRadius({ topLeft: 20, topRight: 20 })
    .border({
      width: { top: 1 },
      color: 'rgba(0,0,0,0.08)'
    })
    .zIndex(999)
  }
}