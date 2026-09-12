import { NetworkConnectionManager } from '../managers/NetworkConnectionManager';
import { NetworkInfo, NetworkConnectivity } from '../services/NetworkService';

/**
 * 网络状态指示器组件
 * 显示当前网络状态（Wi-Fi/蜂窝/不可用）
 */
@Component
export struct NetworkStatusIndicator {
  @State private networkInfo: NetworkInfo | null = null;
  @State private isExpanded: boolean = false;
  private manager: NetworkConnectionManager = NetworkConnectionManager.getInstance();
  private networkCallback = (info: NetworkInfo) => {
    this.networkInfo = info;
  };

  aboutToAppear() {
    // 订阅网络变化
    this.manager.subscribe(this.networkCallback);
    // 获取当前网络信息
    this.networkInfo = this.manager.getCurrentNetworkInfo();
  }

  aboutToDisappear() {
    // 取消订阅
    this.manager.unsubscribe(this.networkCallback);
  }

  build() {
    if (this.isExpanded) {
      this.ExpandedView()
    } else {
      this.CompactView()
    }
  }

  @Builder CompactView() {
    Row() {
      Text(NetworkConnectionManager.getNetworkIcon(this.networkInfo))
        .fontSize(16)
        .margin({ right: 4 })

      Text(this.getCompactText())
        .fontSize(12)
        .fontColor(this.getStatusColor())
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(12)
    .onClick(() => {
      this.isExpanded = !this.isExpanded;
    })
  }

  @Builder ExpandedView() {
    Column() {
      // 标题栏
      Row() {
        Text('网络状态')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Text('✕')
          .fontSize(16)
          .fontColor('#999')
          .onClick(() => {
            this.isExpanded = false;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 网络图标和状态
      Row() {
        Text(NetworkConnectionManager.getNetworkIcon(this.networkInfo))
          .fontSize(32)
          .margin({ right: 12 })

        Column() {
          Text(NetworkConnectionManager.getNetworkStatusText(this.networkInfo))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a1a1a')

          if (this.networkInfo) {
            Text(this.getDetailText())
              .fontSize(12)
              .fontColor('#666')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 连通性提示
      if (this.networkInfo) {
        this.ConnectivityTip()
      }

      // 刷新按钮
      Button('刷新')
        .width('100%')
        .height(36)
        .fontSize(14)
        .backgroundColor('#f0f0f0')
        .fontColor('#666')
        .onClick(() => {
          this.manager.refreshNetworkInfo();
        })
    }
    .width(280)
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.15)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      // 阻止事件冒泡
    })
  }

  @Builder ConnectivityTip() {
    Row() {
      Text(this.getConnectivityIcon())
        .fontSize(14)
        .margin({ right: 6 })

      Text(this.getConnectivityTipText())
        .fontSize(12)
        .fontColor(this.getConnectivityTipColor())
        .layoutWeight(1)
    }
    .width('100%')
    .padding(8)
    .backgroundColor(this.getConnectivityTipBackground())
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  private getCompactText(): string {
    if (!this.networkInfo) {
      return '检查中...';
    }

    switch (this.networkInfo.connectivity) {
      case NetworkConnectivity.VALIDATED:
        return '已连接';
      case NetworkConnectivity.CHECKING:
        return '检查中';
      case NetworkConnectivity.NOT_VALIDATED:
        return '无互联网';
      case NetworkConnectivity.UNAVAILABLE:
        return '不可用';
      default:
        return '未知';
    }
  }

  private getDetailText(): string {
    if (!this.networkInfo) {
      return '';
    }

    const parts: string[] = [];
    parts.push(`网络ID: ${this.networkInfo.netId}`);

    if (this.networkInfo.isMetered) {
      parts.push('计费网络');
    } else {
      parts.push('免费网络');
    }

    return parts.join(' · ');
  }

  private getConnectivityIcon(): string {
    if (!this.networkInfo) {
      return 'ℹ️';
    }

    switch (this.networkInfo.connectivity) {
      case NetworkConnectivity.VALIDATED:
        return '✅';
      case NetworkConnectivity.CHECKING:
        return '🔄';
      case NetworkConnectivity.NOT_VALIDATED:
        return '⚠️';
      case NetworkConnectivity.UNAVAILABLE:
        return '❌';
      default:
        return 'ℹ️';
    }
  }

  private getConnectivityTipText(): string {
    if (!this.networkInfo) {
      return '正在获取网络信息...';
    }

    switch (this.networkInfo.connectivity) {
      case NetworkConnectivity.VALIDATED:
        return '网络正常，可以访问互联网';
      case NetworkConnectivity.CHECKING:
        return '正在验证网络连通性，请稍候...';
      case NetworkConnectivity.NOT_VALIDATED:
        return '网络已连接，但无法访问互联网';
      case NetworkConnectivity.UNAVAILABLE:
        return '网络不可用，请检查网络设置';
      default:
        return '网络状态未知';
    }
  }

  private getStatusColor(): string {
    if (!this.networkInfo) {
      return '#666';
    }

    switch (this.networkInfo.connectivity) {
      case NetworkConnectivity.VALIDATED:
        return '#52c41a'; // 绿色
      case NetworkConnectivity.CHECKING:
        return '#1890ff'; // 蓝色
      case NetworkConnectivity.NOT_VALIDATED:
        return '#faad14'; // 橙色
      case NetworkConnectivity.UNAVAILABLE:
        return '#f5222d'; // 红色
      default:
        return '#666';
    }
  }

  private getBackgroundColor(): string {
    if (!this.networkInfo) {
      return '#f0f0f0';
    }

    switch (this.networkInfo.connectivity) {
      case NetworkConnectivity.VALIDATED:
        return '#f6ffed'; // 浅绿
      case NetworkConnectivity.CHECKING:
        return '#e6f7ff'; // 浅蓝
      case NetworkConnectivity.NOT_VALIDATED:
        return '#fffbe6'; // 浅橙
      case NetworkConnectivity.UNAVAILABLE:
        return '#fff1f0'; // 浅红
      default:
        return '#f0f0f0';
    }
  }

  private getConnectivityTipColor(): string {
    return this.getStatusColor();
  }

  private getConnectivityTipBackground(): string {
    return this.getBackgroundColor();
  }
}
