import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { SmartTravelRcpApi, UserInfo } from '../../api/SmartTravelRcpApi';

const TAG = 'RcpAdvancedPage';
const DOMAIN = 0xFF00;

/**
 * RCP 高级功能演示页面
 * 
 * 演示功能：
 * 1. 自定义 DNS 服务器
 * 2. 静态 DNS 规则
 * 3. DNS over HTTPS
 * 4. 拦截器使用（缓存、日志、认证）
 * 5. 请求追踪
 * 6. PATCH 请求
 * 7. 多表单提交
 */
@Entry
@Component
export struct RcpAdvancedPage {
  @State responseText: string = '';
  @State isLoading: boolean = false;
  @State cacheSize: number = 0;
  @State selectedTab: number = 0;

  private api: SmartTravelRcpApi = SmartTravelRcpApi.getInstance();

  aboutToAppear() {
    this.updateCacheSize();
  }

  private updateCacheSize(): void {
    this.cacheSize = this.api.getCacheSize();
  }

  // ==================== DNS 配置示例 ====================

  /**
   * 示例1: 自定义 DNS 服务器
   */
  private async testCustomDNS(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试自定义 DNS 服务器...\n\n';

    try {
      // 配置自定义 DNS 服务器
      const customDnsServers: rcp.DnsServers = [
        { ip: '8.8.8.8' },      // Google DNS
        { ip: '8.8.4.4', port: 53 }
      ];

      const sessionWithCustomDns = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsRules: customDnsServers
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });

      this.responseText += '✅ DNS 服务器配置：\n';
      this.responseText += '  - 8.8.8.8 (Google DNS)\n';
      this.responseText += '  - 8.8.4.4:53\n\n';

      const response = await sessionWithCustomDns.get('http://www.example.com');
      this.responseText += `✅ 请求成功\n状态码: ${response.statusCode}\n`;

      hilog.info(DOMAIN, TAG, 'Custom DNS test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `Custom DNS test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 示例2: 静态 DNS 规则
   */
  private async testStaticDNS(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试静态 DNS 规则...\n\n';

    try {
      // 配置静态 DNS 规则
      const staticDnsRules: rcp.StaticDnsRules = [
        {
          host: 'example.com',
          port: 80,
          ipAddresses: ['192.168.1.1', '192.168.1.2']
        }
      ];

      const sessionWithStaticDns = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsRules: staticDnsRules
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });

      this.responseText += '✅ 静态 DNS 规则配置：\n';
      this.responseText += '  - Host: example.com:80\n';
      this.responseText += '  - IP: 192.168.1.1, 192.168.1.2\n\n';

      const response = await sessionWithStaticDns.get('http://example.com');
      this.responseText += `✅ 请求成功\n状态码: ${response.statusCode}\n`;

      hilog.info(DOMAIN, TAG, 'Static DNS test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `Static DNS test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 示例3: DNS over HTTPS
   */
  private async testDNSOverHTTPS(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试 DNS over HTTPS...\n\n';

    try {
      // 配置 DNS over HTTPS
      const dohConfig: rcp.DnsOverHttpsConfiguration = {
        url: 'https://dns.example.com/dns-query',
        skipCertificatesValidation: true
      };

      const sessionWithDoh = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsOverHttps: dohConfig
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });

      this.responseText += '✅ DNS over HTTPS 配置：\n';
      this.responseText += '  - URL: https://dns.example.com/dns-query\n';
      this.responseText += '  - 跳过证书验证: 是\n\n';

      const response = await sessionWithDoh.get('http://www.example.com');
      this.responseText += `✅ 请求成功\n状态码: ${response.statusCode}\n`;

      hilog.info(DOMAIN, TAG, 'DNS over HTTPS test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `DNS over HTTPS test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 拦截器示例 ====================

  /**
   * 示例4: 测试缓存拦截器
   */
  private async testCacheInterceptor(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试缓存拦截器...\n\n';

    try {
      // 第一次请求
      this.responseText += '📡 第一次请求（无缓存）...\n';
      const startTime1 = Date.now();
      await this.api.getGuideList(1, 10);
      const duration1 = Date.now() - startTime1;
      this.responseText += `✅ 请求完成，耗时: ${duration1}ms\n\n`;

      // 第二次请求（应该命中缓存）
      this.responseText += '📡 第二次请求（应命中缓存）...\n';
      const startTime2 = Date.now();
      await this.api.getGuideList(1, 10);
      const duration2 = Date.now() - startTime2;
      this.responseText += `✅ 请求完成，耗时: ${duration2}ms\n\n`;

      if (duration2 < duration1) {
        this.responseText += `🚀 缓存生效！速度提升: ${((duration1 - duration2) / duration1 * 100).toFixed(1)}%\n`;
      }

      this.updateCacheSize();
      this.responseText += `\n📦 缓存大小: ${this.cacheSize} 项\n`;

      hilog.info(DOMAIN, TAG, 'Cache interceptor test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `Cache test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 示例5: 清除缓存
   */
  private clearCache(): void {
    this.api.clearCache();
    this.updateCacheSize();
    this.responseText = `✅ 缓存已清除\n\n📦 当前缓存大小: ${this.cacheSize} 项\n`;
    ErrorHandler.showToast('缓存已清除');
  }

  // ==================== PATCH 请求示例 ====================

  /**
   * 示例6: PATCH 请求（部分更新）
   */
  private async testPatchRequest(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试 PATCH 请求（部分更新）...\n\n';

    try {
      const userId = 'user_001';

      // 只更新用户名，不影响其他字段
      this.responseText += '📝 更新用户信息（只更新 userName）...\n';
      const updates: Partial<UserInfo> = {
        userName: '张三（已更新）'
      };

      const updatedUser = await this.api.updateUserInfo(userId, updates);

      this.responseText += '✅ 更新成功\n\n';
      this.responseText += '更新后的信息：\n';
      this.responseText += `  - 用户ID: ${updatedUser.userId}\n`;
      this.responseText += `  - 用户名: ${updatedUser.userName}\n`;
      this.responseText += `  - 性别: ${updatedUser.userGender}\n`;
      this.responseText += `  - 年龄: ${updatedUser.userAge}\n\n`;
      this.responseText += '💡 PATCH 只更新指定字段，其他字段保持不变\n';

      hilog.info(DOMAIN, TAG, 'PATCH request test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `PATCH test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 多表单提交示例 ====================

  /**
   * 示例7: 多表单提交
   */
  private async testMultipartForm(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试多表单提交...\n\n';

    try {
      this.responseText += '📋 提交酒店预订表单...\n\n';

      const result = await this.api.createHotelBooking({
        hotelId: 'hotel_001',
        roomType: '豪华大床房',
        checkInDate: '2024-12-01',
        checkOutDate: '2024-12-03',
        guestName: '张三',
        guestPhone: '13800138000',
        specialRequests: '需要无烟房间'
      });

      this.responseText += '✅ 预订成功\n\n';
      this.responseText += '订单信息：\n';
      this.responseText += `  - 订单ID: ${result.orderId}\n`;
      this.responseText += `  - 订单号: ${result.orderNo}\n\n`;
      this.responseText += '💡 使用 MultipartForm 提交多个表单字段\n';

      hilog.info(DOMAIN, TAG, 'Multipart form test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `Multipart form test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 请求追踪示例 ====================

  /**
   * 示例8: 请求详细追踪
   */
  private async testRequestTracing(): Promise<void> {
    this.isLoading = true;
    this.responseText = '测试请求详细追踪...\n\n';

    try {
      // 配置追踪
      const customHttpEventsHandler: rcp.HttpEventsHandler = {
        onDataReceive: (incomingData: ArrayBuffer) => {
          this.responseText += `📥 接收数据: ${incomingData.byteLength} 字节\n`;
          return incomingData.byteLength;
        },
        onHeaderReceive: (headers: rcp.RequestHeaders) => {
          this.responseText += `📋 接收响应头\n`;
        },
        onDataEnd: () => {
          this.responseText += `✅ 数据传输完成\n`;
        }
      };

      const tracingConfig: rcp.TracingConfiguration = {
        verbose: true,
        infoToCollect: {
          incomingHeader: true,
          outgoingHeader: true,
          incomingData: true,
          outgoingData: true
        },
        collectTimeInfo: true,
        httpEventsHandler: customHttpEventsHandler
      };

      const sessionWithTracing = rcp.createSession({
        requestConfiguration: {
          tracing: tracingConfig,
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });

      this.responseText += '🔍 开始追踪请求...\n\n';

      const response = await sessionWithTracing.get('http://developer.huawei.com');

      this.responseText += `\n📊 请求统计：\n`;
      this.responseText += `  - 状态码: ${response.statusCode}\n`;
      if (response.timeInfo) {
        this.responseText += `  - DNS 解析: ${response.timeInfo.dnsLookupTime}ms\n`;
        this.responseText += `  - 连接建立: ${response.timeInfo.tcpConnectionTime}ms\n`;
        this.responseText += `  - SSL 握手: ${response.timeInfo.tlsConnectionTime}ms\n`;
        this.responseText += `  - 总时间: ${response.timeInfo.totalTime}ms\n`;
      }

      hilog.info(DOMAIN, TAG, 'Request tracing test succeeded');
    } catch (error) {
      const err = error as BusinessError;
      this.responseText += `\n❌ 失败: ${err.message}\n`;
      hilog.error(DOMAIN, TAG, `Tracing test failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      TopNavigationBar({
        title: 'RCP 高级功能',
        showBack: true
      })

      // 标签页
      Tabs({ index: this.selectedTab }) {
        // DNS 配置
        TabContent() {
          this.DnsConfigTab()
        }.tabBar('DNS 配置')

        // 拦截器
        TabContent() {
          this.InterceptorsTab()
        }.tabBar('拦截器')

        // 高级请求
        TabContent() {
          this.AdvancedRequestsTab()
        }.tabBar('高级请求')

        // 追踪
        TabContent() {
          this.TracingTab()
        }.tabBar('追踪')
      }
      .onChange((index: number) => {
        this.selectedTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  DnsConfigTab() {
    Scroll() {
      Column({ space: 12 }) {
        Text('DNS 配置示例')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })

        Button('测试自定义 DNS 服务器')
          .width('100%')
          .onClick(() => this.testCustomDNS())
          .enabled(!this.isLoading)

        Button('测试静态 DNS 规则')
          .width('100%')
          .onClick(() => this.testStaticDNS())
          .enabled(!this.isLoading)

        Button('测试 DNS over HTTPS')
          .width('100%')
          .onClick(() => this.testDNSOverHTTPS())
          .enabled(!this.isLoading)

        if (this.responseText) {
          Column() {
            Text('响应结果：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })
            Text(this.responseText)
              .fontSize(12)
              .fontColor('#333')
              .fontFamily('monospace')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
        }
      }
      .padding(16)
    }
  }

  @Builder
  InterceptorsTab() {
    Scroll() {
      Column({ space: 12 }) {
        Text('拦截器示例')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })

        Row() {
          Text(`缓存大小: ${this.cacheSize} 项`)
            .fontSize(14)
            .layoutWeight(1)
          Button('清除缓存')
            .height(36)
            .fontSize(14)
            .onClick(() => this.clearCache())
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(8)

        Button('测试缓存拦截器')
          .width('100%')
          .onClick(() => this.testCacheInterceptor())
          .enabled(!this.isLoading)

        if (this.responseText) {
          Column() {
            Text('响应结果：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })
            Text(this.responseText)
              .fontSize(12)
              .fontColor('#333')
              .fontFamily('monospace')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
        }
      }
      .padding(16)
    }
  }

  @Builder
  AdvancedRequestsTab() {
    Scroll() {
      Column({ space: 12 }) {
        Text('高级请求示例')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })

        Button('测试 PATCH 请求')
          .width('100%')
          .onClick(() => this.testPatchRequest())
          .enabled(!this.isLoading)

        Button('测试多表单提交')
          .width('100%')
          .onClick(() => this.testMultipartForm())
          .enabled(!this.isLoading)

        if (this.responseText) {
          Column() {
            Text('响应结果：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })
            Text(this.responseText)
              .fontSize(12)
              .fontColor('#333')
              .fontFamily('monospace')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
        }
      }
      .padding(16)
    }
  }

  @Builder
  TracingTab() {
    Scroll() {
      Column({ space: 12 }) {
        Text('请求追踪示例')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })

        Button('测试请求详细追踪')
          .width('100%')
          .onClick(() => this.testRequestTracing())
          .enabled(!this.isLoading)

        if (this.responseText) {
          Column() {
            Text('追踪信息：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })
            Text(this.responseText)
              .fontSize(12)
              .fontColor('#333')
              .fontFamily('monospace')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
        }
      }
      .padding(16)
    }
  }
}
