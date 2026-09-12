import { router, promptAction } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface SettingItem {
  id: string;
  title: string;
  subtitle?: string;
  type: 'switch' | 'arrow' | 'button';
  value?: boolean;
  icon: string;
  color?: string;
}

@Entry
@Component
export struct SettingsPage {
  @State notificationEnabled: boolean = true;
  @State locationEnabled: boolean = true;
  @State autoUpdateEnabled: boolean = false;
  @State darkModeEnabled: boolean = false;
  @State cacheSize: string = '125.6 MB';

  private accountSettings: SettingItem[] = [
    { id: '1', title: '个人资料', subtitle: '编辑个人信息', type: 'arrow', icon: '👤', color: '#3b82f6' },
    { id: '2', title: '账户安全', subtitle: '密码、手机号等', type: 'arrow', icon: '🔒', color: '#10b981' },
    { id: '3', title: '隐私设置', subtitle: '数据使用权限', type: 'arrow', icon: '🛡️', color: '#f59e0b' },
    { id: '4', title: '会员中心', subtitle: '查看会员权益', type: 'arrow', icon: '👑', color: '#8b5cf6' }
  ];

  private appSettings: SettingItem[] = [
    { id: '5', title: '消息通知', subtitle: '接收活动提醒', type: 'switch', icon: '🔔', color: '#ef4444' },
    { id: '6', title: '位置服务', subtitle: '获取附近活动', type: 'switch', icon: '📍', color: '#3b82f6' },
    { id: '7', title: '自动更新', subtitle: 'WiFi下自动更新', type: 'switch', icon: '🔄', color: '#10b981' },
    { id: '8', title: '深色模式', subtitle: '护眼模式', type: 'switch', icon: '🌙', color: '#6b7280' }
  ];

  private otherSettings: SettingItem[] = [
    { id: '9', title: '清除缓存', subtitle: this.cacheSize, type: 'button', icon: '🗑️', color: '#f59e0b' },
    { id: '10', title: '检查更新', subtitle: '当前版本 v1.0.0', type: 'button', icon: '📱', color: '#3b82f6' },
    { id: '11', title: '意见反馈', subtitle: '帮助我们改进', type: 'arrow', icon: '💬', color: '#10b981' },
    { id: '12', title: '关于我们', subtitle: 'SmartTravel v1.0.0', type: 'arrow', icon: 'ℹ️', color: '#6b7280' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '设置',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      Scroll() {
        Column() {
          // 账户设置
          this.SettingsSection('账户设置', this.accountSettings)

          // 应用设置
          this.SettingsSection('应用设置', this.appSettings)

          // 其他设置
          this.SettingsSection('其他', this.otherSettings)

          // 退出登录
          this.LogoutSection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder SettingsSection(title: string, items: SettingItem[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Column() {
        ForEach(items, (item: SettingItem, index: number) => {
          this.SettingItem(item, index === items.length - 1)
        })
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
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder SettingItem(item: SettingItem, isLast: boolean) {
    Row() {
      // 图标
      Text(item.icon)
        .fontSize(20)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      // 内容
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontColor('#1f2937')
          .margin({ bottom: 2 })

        if (item.subtitle) {
          Text(item.subtitle)
            .fontSize(12)
            .fontColor('#6b7280')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧控件
      if (item.type === 'switch') {
        Toggle({ type: ToggleType.Switch, isOn: this.getSwitchValue(item.id) })
          .onChange((isOn: boolean) => {
            this.handleSwitchChange(item.id, isOn);
          })
      } else if (item.type === 'arrow') {
        Text('>')
          .fontSize(16)
          .fontColor('#9ca3af')
      } else if (item.type === 'button') {
        Button('操作')
          .fontSize(12)
          .fontColor(item.color || '#3b82f6')
          .backgroundColor(this.getButtonBgColor(item.color || '#3b82f6'))
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .onClick(() => {
            this.handleButtonClick(item.id);
          })
      }
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      if (item.type === 'arrow') {
        this.handleArrowClick(item.id);
      }
    })

    // 分割线
    if (!isLast) {
      Divider()
        .color('#f3f4f6')
        .margin({ left: 52, right: 16 })
    }
  }

  @Builder LogoutSection() {
    Column() {
      Button('退出登录')
        .fontSize(16)
        .fontColor('#ef4444')
        .backgroundColor('#fef2f2')
        .borderRadius(12)
        .width('100%')
        .height(48)
        .onClick(() => {
          this.logout();
        })
    }
    .width('100%')
    .margin({ top: 20 })
  }

  private getSwitchValue(id: string): boolean {
    switch (id) {
      case '5': return this.notificationEnabled;
      case '6': return this.locationEnabled;
      case '7': return this.autoUpdateEnabled;
      case '8': return this.darkModeEnabled;
      default: return false;
    }
  }

  private handleSwitchChange(id: string, value: boolean): void {
    switch (id) {
      case '5':
        this.notificationEnabled = value;
        break;
      case '6':
        this.locationEnabled = value;
        break;
      case '7':
        this.autoUpdateEnabled = value;
        break;
      case '8':
        this.darkModeEnabled = value;
        break;
    }
  }

  private handleArrowClick(id: string): void {
    switch (id) {
      case '1':
        // 个人资料编辑 - 功能开发中
        promptAction.showToast({ 
          message: '个人资料编辑功能开发中，敬请期待',
          duration: 2000
        });
        break;
      case '2':
        // 账户安全 - 功能开发中
        promptAction.showToast({ 
          message: '账户安全功能开发中，敬请期待',
          duration: 2000
        });
        break;
      case '3':
        // 隐私设置 - 功能开发中
        promptAction.showToast({ 
          message: '隐私设置功能开发中，敬请期待',
          duration: 2000
        });
        break;
      case '4':
        // 会员中心 - 功能开发中
        promptAction.showToast({ 
          message: '会员中心功能开发中，敬请期待',
          duration: 2000
        });
        break;
      case '11':
        // 意见反馈 - 跳转到帮助与反馈页
        try {
          router.pushUrl({ url: 'pages/profile/HelpFeedbackPage' });
        } catch (error) {
          console.error('Failed to navigate to HelpFeedbackPage:', error);
          promptAction.showToast({ message: '页面跳转失败' });
        }
        break;
      case '12':
        // 关于我们 - 功能开发中
        promptAction.showToast({ 
          message: '关于我们功能开发中，敬请期待',
          duration: 2000
        });
        break;
    }
  }

  private handleButtonClick(id: string): void {
    switch (id) {
      case '9':
        this.clearCache();
        break;
      case '10':
        this.checkUpdate();
        break;
    }
  }

  private getButtonBgColor(color: string): string {
    switch (color) {
      case '#3b82f6': return '#dbeafe';
      case '#10b981': return '#d1fae5';
      case '#f59e0b': return '#fef3c7';
      case '#ef4444': return '#fee2e2';
      case '#8b5cf6': return '#ede9fe';
      case '#6b7280': return '#f3f4f6';
      default: return '#f3f4f6';
    }
  }

  private clearCache(): void {
    // 清除缓存逻辑
    this.cacheSize = '0 MB';
    console.log('缓存已清除');
  }

  private checkUpdate(): void {
    // 检查更新逻辑
    console.log('检查更新中...');
  }

  private logout(): void {
    // 退出登录逻辑
    console.log('退出登录');
    promptAction.showToast({ 
      message: '退出登录功能开发中，敬请期待',
      duration: 2000
    });
    // TODO: 实现退出登录逻辑和登录页面后，跳转到登录页
    // router.replaceUrl({ url: 'pages/login/LoginPage' });
  }
}
