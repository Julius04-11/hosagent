import webview from "@ohos.web.webview";
import Prompt from "@system.prompt";
import { BusinessError } from "@kit.BasicServicesKit";
import util from "@ohos.util";
import { ActivityDetail, MessageModel, routerParams } from "../../model/ActivityModel";
import { router } from "@kit.ArkUI";
import { VoicePlayerComponent } from "../../components/VoicePlayerComponent";
import { mapCommon, site } from '@kit.MapKit';
import { MetroInfo } from '../../model/MetroStationModel';
import { MapConstants } from '../../constants/MapConstants';
import { MarkerViewModel } from '../../viewmodel/MarkerViewModel';
import { ErrorHandler } from '../../utils/ErrorHandler';

@Entry
@Component
export struct ActivityDetailPage {
  activityDetailPath: Resource = $rawfile('activity_detail.html')
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  nativePort: webview.WebMessagePort | null = null;
  @State activitiesDetail: ActivityDetail = {} as ActivityDetail;
  @State receiveMessage: MessageModel = {} as MessageModel;
  @State params: routerParams = router.getParams() as routerParams;
  @State activityId: number = Number(this.params.src);
  @State metros: MetroInfo[] = [];
  private markerVM: MarkerViewModel = MarkerViewModel.instance;

  async aboutToAppear() {
    await this.loadActivitiesDetailFromFile();
  }

  initWebviewPort() {
    try {
      this.ports = this.controller.createWebMessagePorts();
      this.ports[1].onMessageEvent((result: webview.WebMessage) => {
        let msg: MessageModel;
        if (typeof (result) === "string") {
          console.log("received string message from html5, string is:" + result);
          // 收到 HTML 发送过来的活动 ID
          let message: MessageModel = JSON.parse(result);
          msg = message;
          if (message.type == 'back') {
            router.back();
          } else if (message.type == 'event') {
            const content = message.content;
            this.selectEvent(content);
          } else {
            console.error("消息的type是：", message.type)
            console.error("消息的内容是：", message.content)
          }
        } else {
          console.log("received unknown message type from html5");
          msg = {
            type: 'error',
            content: '收到的消息类型未知'
          };
        }
        this.receiveMessage = msg;
      });
      this.controller.postMessage('__init_port__', [this.ports[0]], '*');
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  async loadActivitiesDetailFromFile() {
    try {
      getContext().resourceManager.getRawFileContent("data/activity_details.json").then(async (value: Uint8Array) => {
        let rawFile = value;
        let decoder = util.TextDecoder.create('utf-8');
        let content = decoder.decodeToString(rawFile);
        let json: ActivityDetail[] = JSON.parse(content);
        this.activitiesDetail = json[this.activityId - 1];
        console.error(JSON.stringify(this.activitiesDetail));
        // 数据加载完成后，如果有位置信息，搜索周边地铁站
        if (this.activitiesDetail.location) {
          await this.searchNearbyMetros();
        }
      }).catch((error: BusinessError) => {
        console.error("getRawFileContent promise error is " + error);
      });
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.error(`promise getRawFileContent failed, error code: ${code}, message: ${message}.`);
    }
  }

  postMessageToHtml(content: string) {
    try {
      if (this.ports && this.ports[1]) {
        this.ports[1].postMessageEvent(content);
      } else {
        console.error(`ports is null, Please initialize first`);
      }
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  selectEvent(event: string) {
    switch (event) {
      case 'signup':
        router.pushUrl({
          url: 'pages/activity/SignUpPage',
          params: new routerParams(this.activitiesDetail.activityId.toString() + this.activitiesDetail.title)
        })
        break
      default:
        return
    }
  }

  // 搜索周边地铁站
  async searchNearbyMetros() {
    if (!this.activitiesDetail.location) {
      return;
    }
    try {
      const center: mapCommon.LatLng = {
        latitude: this.activitiesDetail.location.latitude,
        longitude: this.activitiesDetail.location.longitude
      };
      
      let params: site.SearchByTextParams = {
        query: '地铁站',
        location: center,
        poiTypes: ['SUBWAY'],
        isChildren: true,
        language: 'zh_CN',
        radius: MapConstants.DISTANCE
      };
      
      let result = await site.searchByText(params);
      if (result.sites) {
        this.metros.length = 0;
        for (let siteItem of result.sites) {
          if (siteItem.distance! <= MapConstants.DISTANCE && !siteItem.name!.endsWith('(规划中)')) {
            let metro: MetroInfo = {
              siteId: siteItem.siteId,
              name: siteItem.name,
              address: siteItem.formatAddress,
              location: siteItem.location,
              distance: siteItem.distance
            } as MetroInfo;
            this.metros.push(metro);
          }
        }
        this.metros.sort((a, b) => a.distance - b.distance);
        this.markerVM.metros = this.metros;
      }
    } catch (error) {
      console.error('搜索周边地铁站失败:', error);
    }
  }

  // 跳转到地图页面
  navigateToMap() {
    if (!this.activitiesDetail.location) {
      Prompt.showToast({
        message: '该活动暂无位置信息',
        duration: 2000
      });
      return;
    }
    
    router.pushUrl({
      url: 'pages/activity/ActivityMapPage',
      params: {
        metros: this.metros,
        center: {
          latitude: this.activitiesDetail.location.latitude,
          longitude: this.activitiesDetail.location.longitude
        }
      }
    });
  }

  build() {
    Stack() {
      Column() {
        // 语音播放组件（如果有音频资源）
        if (this.activitiesDetail.audioResource) {
          VoicePlayerComponent({
            audioResource: this.activitiesDetail.audioResource,
            audioId: `activity_${this.activitiesDetail.activityId}`
          })
          .margin({ top: 8, left: 16, right: 16 })
        }
        
        // 查看地图按钮（如果有位置信息）
        if (this.activitiesDetail.location) {
          this.mapButtonBuilder()
        }
        
        // WebView 显示活动详情
        Web({ src: this.activityDetailPath, controller: this.controller })
          .onPageEnd(() => {
            this.initWebviewPort();
            this.postMessageToHtml(JSON.stringify(this.activitiesDetail));
          })
          .layoutWeight(1)
          .margin({ bottom: 80 }) // 为底部按钮留出空间
      }
      .width('100%')
      .height('100%')
      
      // 返回按钮
      Row() {
        Text('⬅️')// 使用左箭头 emoji
          .fontSize(24)// 调整 emoji 大小
          .onClick(() => {
            router.back();
          })
      }
      .width(36) // 按钮宽度
      .height(36) // 按钮高度
      .backgroundColor(Color.Gray) // 灰色背景
      .borderRadius(24) // 圆角，使其看起来像一个圆形按钮
      .opacity(0.8) // 半透明效果
      .position({ x: 16, y: 16 }) // 定位到左上角，距离左边和顶部各16vp
      .zIndex(1) // 确保按钮在 WebView 上层
      .alignItems(VerticalAlign.Center) // 居中图片
      .justifyContent(FlexAlign.Center)

      // 购票按钮
      this.ticketButtonBuilder()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  mapButtonBuilder() {
    Row() {
      Row({ space: 8 }) {
        Text('📍')
          .fontSize(18)
        Column({ space: 2 }) {
          Text('查看地图')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White) // 白色文字在绿色背景上
          if (this.metros.length > 0) {
            Text(`附近${this.metros[0].name}·相距${this.metros[0].distance.toFixed(0)}m`)
              .fontSize(12)
              .fontColor('#f0f0f0') // 浅色文字
          } else if (this.activitiesDetail.location?.address) {
            Text(this.activitiesDetail.location.address)
              .fontSize(12)
              .fontColor('#f0f0f0') // 浅色文字
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Text('➡️')
          .fontSize(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#22c55e') // 绿色背景
    .margin({ top: 8, left: 16, right: 16 })
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .zIndex(1) // 确保在红色按钮下方
    .onClick(() => {
      this.navigateToMap();
    })
  }

  @Builder
  ticketButtonBuilder() {
    Row() {
      Button('立即购票')
        .backgroundColor('#ef4444')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          ErrorHandler.safeExecute(async (): Promise<void> => {
            await router.pushUrl({
              url: 'pages/booking/EnhancedBookingPage',
              params: { 
                id: this.activityId.toString(),
                name: this.activitiesDetail.title || '景点门票'
              }
            });
          }, (error: Error): void => ErrorHandler.handleRouterError(error, '购票页面'));
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: -76 }) // 调整位置，避免与绿色按钮重叠
    .zIndex(2)
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }
}