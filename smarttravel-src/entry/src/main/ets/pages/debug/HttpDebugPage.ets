import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { HttpService } from '../../services/HttpService';
import { HttpStreamService } from '../../services/HttpStreamService';
import { SmartTravelApi } from '../../api/SmartTravelApi';
import { ErrorHandler } from '../../utils/ErrorHandler';

/**
 * HTTP 调试页面
 * 用于测试 HTTP 请求和流式传输功能
 */
@Entry
@Component
export struct HttpDebugPage {
  @State testUrl: string = 'https://jsonplaceholder.typicode.com/posts/1';
  @State responseText: string = '';
  @State isLoading: boolean = false;
  @State uploadProgress: number = 0;
  @State downloadProgress: number = 0;

  private httpService: HttpService = HttpService.getInstance();
  private streamService: HttpStreamService = HttpStreamService.getInstance();
  private apiService: SmartTravelApi = SmartTravelApi.getInstance();

  build() {
    Column() {
      TopNavigationBar({
        title: 'HTTP 调试',
        showBack: true
      })

      Scroll() {
        Column() {
          // 基础请求测试
          this.BasicRequestSection()

          // 流式传输测试
          this.StreamTransferSection()

          // API 服务测试
          this.ApiServiceSection()

          // 响应结果显示
          this.ResponseSection()
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder BasicRequestSection() {
    Column() {
      Text('基础 HTTP 请求')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      TextInput({ placeholder: '请输入测试 URL', text: this.testUrl })
        .fontSize(14)
        .height(44)
        .backgroundColor('#f9f9f9')
        .onChange((value: string) => {
          this.testUrl = value;
        })
        .margin({ bottom: 12 })

      Row() {
        Button('GET')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => this.testGetRequest())
          .enabled(!this.isLoading)

        Button('POST')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .onClick(() => this.testPostRequest())
          .enabled(!this.isLoading)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Button('PUT')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => this.testPutRequest())
          .enabled(!this.isLoading)

        Button('DELETE')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .onClick(() => this.testDeleteRequest())
          .enabled(!this.isLoading)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder StreamTransferSection() {
    Column() {
      Text('流式传输测试')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      // 下载进度
      if (this.downloadProgress > 0) {
        Column() {
          Text(`下载进度: ${this.downloadProgress.toFixed(0)}%`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ bottom: 4 })

          Progress({ value: this.downloadProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .color('#007AFF')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      // 上传进度
      if (this.uploadProgress > 0) {
        Column() {
          Text(`上传进度: ${this.uploadProgress.toFixed(0)}%`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ bottom: 4 })

          Progress({ value: this.uploadProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .color('#52c41a')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      Row() {
        Button('流式下载')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => this.testStreamDownload())
          .enabled(!this.isLoading)

        Button('取消请求')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#ff4d4f')
          .onClick(() => this.cancelStreamRequests())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ApiServiceSection() {
    Column() {
      Text('API 服务测试')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      Row() {
        Button('获取攻略列表')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => this.testGetGuides())
          .enabled(!this.isLoading)

        Button('搜索景点')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .onClick(() => this.testSearchAttractions())
          .enabled(!this.isLoading)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Button('搜索酒店')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => this.testSearchHotels())
          .enabled(!this.isLoading)

        Button('获取用户信息')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .onClick(() => this.testGetUserInfo())
          .enabled(!this.isLoading)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ResponseSection() {
    Column() {
      Row() {
        Text('响应结果')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.isLoading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#007AFF')
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.responseText) {
        Text(this.responseText)
          .fontSize(12)
          .fontColor('#1a1a1a')
          .fontFamily('monospace')
          .width('100%')
          .maxLines(20)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding(12)
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
      } else {
        Text('暂无响应数据')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 20, bottom: 20 })
      }

      Button('清空结果')
        .width('100%')
        .height(44)
        .fontSize(14)
        .backgroundColor('#f0f0f0')
        .fontColor('#666')
        .margin({ top: 12 })
        .onClick(() => {
          this.responseText = '';
          this.downloadProgress = 0;
          this.uploadProgress = 0;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 测试方法 ====================

  private async testGetRequest(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在请求...';

    try {
      const response = await this.httpService.get(this.testUrl);
      this.responseText = `✅ GET 请求成功\n\n状态码: ${response.statusCode}\n\n响应数据:\n${JSON.stringify(response.data, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ GET 请求失败\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testPostRequest(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在请求...';

    try {
      const response = await this.httpService.post(this.testUrl, {
        title: 'SmartTravel Test',
        body: 'This is a test post',
        userId: 1
      });
      this.responseText = `✅ POST 请求成功\n\n状态码: ${response.statusCode}\n\n响应数据:\n${JSON.stringify(response.data, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ POST 请求失败\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testPutRequest(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在请求...';

    try {
      const response = await this.httpService.put(this.testUrl, {
        title: 'SmartTravel Updated',
        body: 'This is an updated post'
      });
      this.responseText = `✅ PUT 请求成功\n\n状态码: ${response.statusCode}\n\n响应数据:\n${JSON.stringify(response.data, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ PUT 请求失败\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testDeleteRequest(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在请求...';

    try {
      const response = await this.httpService.delete(this.testUrl);
      this.responseText = `✅ DELETE 请求成功\n\n状态码: ${response.statusCode}\n\n响应数据:\n${JSON.stringify(response.data, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ DELETE 请求失败\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testStreamDownload(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在流式下载...';
    this.downloadProgress = 0;

    try {
      const requestId = 'test_download_' + Date.now();
      const data = await this.streamService.downloadStream(
        'https://jsonplaceholder.typicode.com/photos',
        requestId,
        {
          onReceiveProgress: (receiveSize, totalSize) => {
            this.downloadProgress = (receiveSize / totalSize) * 100;
          },
          onDataEnd: () => {
            this.responseText = '✅ 流式下载完成';
          }
        }
      );

      this.responseText = `✅ 流式下载成功\n\n数据大小: ${data.byteLength} 字节`;
    } catch (error) {
      this.responseText = `❌ 流式下载失败\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private cancelStreamRequests(): void {
    this.streamService.cancelAllRequests();
    this.responseText = '已取消所有流式请求';
    this.isLoading = false;
    this.downloadProgress = 0;
    this.uploadProgress = 0;
  }

  private async testGetGuides(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在获取攻略列表...';

    try {
      // 注意：这里会失败因为没有真实的服务器
      const guides = await this.apiService.getGuideList(1, 10);
      this.responseText = `✅ 获取攻略列表成功\n\n数量: ${guides.length}\n\n数据:\n${JSON.stringify(guides, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ 获取攻略列表失败（预期行为，无真实服务器）\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testSearchAttractions(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在搜索景点...';

    try {
      const attractions = await this.apiService.getAttractionList('深圳');
      this.responseText = `✅ 搜索景点成功\n\n数量: ${attractions.length}\n\n数据:\n${JSON.stringify(attractions, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ 搜索景点失败（预期行为，无真实服务器）\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testSearchHotels(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在搜索酒店...';

    try {
      const hotels = await this.apiService.searchHotels('深圳', '2024-12-01', '2024-12-02');
      this.responseText = `✅ 搜索酒店成功\n\n数量: ${hotels.length}\n\n数据:\n${JSON.stringify(hotels, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ 搜索酒店失败（预期行为，无真实服务器）\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }

  private async testGetUserInfo(): Promise<void> {
    this.isLoading = true;
    this.responseText = '正在获取用户信息...';

    try {
      const user = await this.apiService.getUserInfo();
      this.responseText = `✅ 获取用户信息成功\n\n数据:\n${JSON.stringify(user, null, 2)}`;
    } catch (error) {
      this.responseText = `❌ 获取用户信息失败（预期行为，无真实服务器）\n\n${JSON.stringify(error)}`;
    } finally {
      this.isLoading = false;
    }
  }
}
