import webview from "@ohos.web.webview";
import Prompt from "@system.prompt";
import { BusinessError } from "@kit.BasicServicesKit";
import util from "@ohos.util";
import { ActivityDetail, MessageModel, routerParams } from "../../model/ActivityModel";
import { router } from "@kit.ArkUI";

@Component
export struct ActivityPage {

  activityPath: Resource = $rawfile('activity.html');
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  nativePort: webview.WebMessagePort | null = null;
  @State activitiesData: string = '';
  @State receiveMessage: MessageModel = {} as MessageModel;

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
          if (message.type == 'navigator') {
            const activityId = message.content;
            router.pushUrl({
              url: 'pages/activity/ActivityDetailPage',
              params: new routerParams(activityId)
            }).catch((error:Error) => {
              console.error(error.message)
            });
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

  async loadActivitiesDataFromFile() {
    try {
      getContext().resourceManager.getRawFileContent("data/activities.json").then((value: Uint8Array) => {
        let rawFile = value;
        let decoder = util.TextDecoder.create('utf-8');
        let json = decoder.decodeToString(rawFile);
        this.activitiesData = json
      }).catch((error: BusinessError) => {
        console.error("getRawFileContent promise error is " + error);
      });
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.error(`promise getRawFileContent failed, error code: ${code}, message: ${message}.`);
    }
  }

  async aboutToAppear() {
    Promise.all([this.loadActivitiesDataFromFile()])
      .then(results => {
        console.error(`所有 Promise 都成功了`); // [ 'Data from api/data1', 'Data from api/data2', 'Data from api/data3' ]
      })
      .catch((error: BusinessError) => {
        console.error('有 Promise 失败了:', error);
      });
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

  build() {
    Column() {
      Web({ src: this.activityPath, controller: this.controller })
        .onPageEnd(() => {
          this.initWebviewPort();
          this.postMessageToHtml(this.activitiesData);
        })
    }

  }
}