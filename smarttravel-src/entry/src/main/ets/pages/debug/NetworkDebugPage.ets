import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { NetworkStatusIndicator } from '../../components/NetworkStatusIndicator';
import { NetworkService, NetworkInfo, NetworkType, NetworkConnectivity } from '../../services/NetworkService';
import { NetworkConnectionManager } from '../../managers/NetworkConnectionManager';
import { connection } from '@kit.NetworkKit';

/**
 * 网络调试页面
 * 用于测试和展示网络管理功能
 */
@Entry
@Component
export struct NetworkDebugPage {
  @State currentNetwork: NetworkInfo | null = null;
  @State allNetworks: NetworkInfo[] = [];
  @State resolvedIPs: connection.NetAddress[] = [];
  @State testHostname: string = 'www.example.com';
  @State isResolved: boolean = false;

  private networkService: NetworkService = NetworkService.getInstance();
  private networkManager: NetworkConnectionManager = NetworkConnectionManager.getInstance();

  private networkCallback = (info: NetworkInfo) => {
    this.currentNetwork = info;
  };

  aboutToAppear() {
    // 订阅网络变化
    this.networkManager.subscribe(this.networkCallback);
    
    // 获取当前网络信息
    this.refreshNetworkInfo();
  }

  aboutToDisappear() {
    // 取消订阅
    this.networkManager.unsubscribe(this.networkCallback);
  }

  private refreshNetworkInfo(): void {
    // 获取默认网络
    this.currentNetwork = this.networkService.getDefaultNetworkInfo();
    
    // 获取所有网络
    this.networkService.getAllNetworks().then(networks => {
      this.allNetworks = networks;
    });
  }

  private async testDNSResolve(): Promise<void> {
    if (!this.testHostname) {
      return;
    }

    this.isResolved = false;
    this.resolvedIPs = await this.networkService.resolveHostname(this.testHostname);
    this.isResolved = true;
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '网络调试',
        showBack: true
      })

      Scroll() {
        Column() {
          // 网络状态指示器
          Row() {
            Text('网络状态指示器:')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ right: 12 })

            NetworkStatusIndicator()
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 默认网络信息
          this.NetworkInfoSection()

          // 所有网络列表
          this.AllNetworksSection()

          // DNS 解析测试
          this.DNSResolveSection()

          // 操作按钮
          this.ActionButtons()
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder NetworkInfoSection() {
    Column() {
      Row() {
        Text('默认网络信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Text(NetworkConnectionManager.getNetworkIcon(this.currentNetwork))
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.currentNetwork) {
        this.InfoItem('网络 ID', this.currentNetwork.netId.toString())
        this.InfoItem('网络类型', this.getNetworkTypeText(this.currentNetwork.type))
        this.InfoItem('连通性', this.getConnectivityText(this.currentNetwork.connectivity))
        this.InfoItem('计费状态', this.currentNetwork.isMetered ? '计费网络' : '免费网络')
        this.InfoItem('状态描述', NetworkConnectionManager.getNetworkStatusText(this.currentNetwork))
      } else {
        Text('网络信息不可用')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 20, bottom: 20 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AllNetworksSection() {
    Column() {
      Text('所有网络列表')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      if (this.allNetworks.length === 0) {
        Text('暂无可用网络')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 20, bottom: 20 })
      } else {
        ForEach(this.allNetworks, (network: NetworkInfo, index: number) => {
          Column() {
            Row() {
              Text(NetworkConnectionManager.getNetworkIcon(network))
                .fontSize(20)
                .margin({ right: 8 })

              Column() {
                Text(`网络 ${index + 1}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1a1a1a')

                Text(`ID: ${network.netId} · ${this.getNetworkTypeText(network.type)}`)
                  .fontSize(12)
                  .fontColor('#666')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(this.getConnectivityBadgeText(network.connectivity))
                .fontSize(11)
                .fontColor(this.getConnectivityColor(network.connectivity))
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(this.getConnectivityBgColor(network.connectivity))
                .borderRadius(10)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#f9f9f9')
            .borderRadius(8)
            .margin({ bottom: 8 })
          }
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder DNSResolveSection() {
    Column() {
      Text('DNS 解析测试')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      TextInput({ placeholder: '输入域名', text: this.testHostname })
        .fontSize(14)
        .height(44)
        .backgroundColor('#f9f9f9')
        .onChange((value: string) => {
          this.testHostname = value;
        })
        .margin({ bottom: 12 })

      Button('解析域名')
        .width('100%')
        .height(44)
        .fontSize(15)
        .onClick(() => {
          this.testDNSResolve();
        })
        .margin({ bottom: 12 })

      if (this.isResolved) {
        if (this.resolvedIPs.length === 0) {
          Text('解析失败或域名不存在')
            .fontSize(13)
            .fontColor('#f5222d')
            .padding(12)
            .backgroundColor('#fff1f0')
            .borderRadius(8)
        } else {
          Column() {
            Text(`解析成功，共 ${this.resolvedIPs.length} 个 IP 地址:`)
              .fontSize(13)
              .fontColor('#52c41a')
              .margin({ bottom: 8 })

            ForEach(this.resolvedIPs, (addr: connection.NetAddress, idx: number) => {
              Row() {
                Text(`${idx + 1}.`)
                  .fontSize(12)
                  .fontColor('#999')
                  .width(30)

                Text(`${addr.address}`)
                  .fontSize(12)
                  .fontColor('#1a1a1a')
                  .fontFamily('monospace')
                  .layoutWeight(1)

                Text(`端口 ${addr.port || 0}`)
                  .fontSize(11)
                  .fontColor('#666')
              }
              .width('100%')
              .padding({ top: 6, bottom: 6 })
            })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#f6ffed')
          .borderRadius(8)
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActionButtons() {
    Column() {
      Button('刷新网络信息')
        .width('100%')
        .height(44)
        .fontSize(15)
        .backgroundColor('#007AFF')
        .margin({ bottom: 12 })
        .onClick(() => {
          this.refreshNetworkInfo();
        })

      Button('返回')
        .width('100%')
        .height(44)
        .fontSize(15)
        .backgroundColor('#f0f0f0')
        .fontColor('#666')
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666')
        .width(100)

      Text(value)
        .fontSize(13)
        .fontColor('#1a1a1a')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  private getNetworkTypeText(type: NetworkType): string {
    const map = {
      [NetworkType.WIFI]: 'Wi-Fi',
      [NetworkType.CELLULAR]: '蜂窝网络',
      [NetworkType.ETHERNET]: '以太网',
      [NetworkType.UNKNOWN]: '未知'
    };
    return map[type] || '未知';
  }

  private getConnectivityText(connectivity: NetworkConnectivity): string {
    const map = {
      [NetworkConnectivity.VALIDATED]: '已验证，可访问互联网',
      [NetworkConnectivity.NOT_VALIDATED]: '未验证，无法访问互联网',
      [NetworkConnectivity.CHECKING]: '正在验证中...',
      [NetworkConnectivity.UNAVAILABLE]: '不可用'
    };
    return map[connectivity] || '未知';
  }

  private getConnectivityBadgeText(connectivity: NetworkConnectivity): string {
    const map = {
      [NetworkConnectivity.VALIDATED]: '已连接',
      [NetworkConnectivity.NOT_VALIDATED]: '无互联网',
      [NetworkConnectivity.CHECKING]: '检查中',
      [NetworkConnectivity.UNAVAILABLE]: '不可用'
    };
    return map[connectivity] || '未知';
  }

  private getConnectivityColor(connectivity: NetworkConnectivity): string {
    const map = {
      [NetworkConnectivity.VALIDATED]: '#52c41a',
      [NetworkConnectivity.NOT_VALIDATED]: '#faad14',
      [NetworkConnectivity.CHECKING]: '#1890ff',
      [NetworkConnectivity.UNAVAILABLE]: '#f5222d'
    };
    return map[connectivity] || '#666';
  }

  private getConnectivityBgColor(connectivity: NetworkConnectivity): string {
    const map = {
      [NetworkConnectivity.VALIDATED]: '#f6ffed',
      [NetworkConnectivity.NOT_VALIDATED]: '#fffbe6',
      [NetworkConnectivity.CHECKING]: '#e6f7ff',
      [NetworkConnectivity.UNAVAILABLE]: '#fff1f0'
    };
    return map[connectivity] || '#f0f0f0';
  }
}
