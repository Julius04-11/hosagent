import { MessageModel, routerParams } from "../../model/ActivityModel";
import { prompt, Prompt, router } from "@kit.ArkUI";
import { webview } from "@kit.ArkWeb";
import { BusinessError } from "@kit.BasicServicesKit";
import { postSignUpData } from "../../service/api";
import { checkIDCardNo, checkPhoneNo } from "../../utils/CheckInformation";

export interface SignupInfo {
  id: string;
  name: string;
  sex: string;
  age: number;
  phoneNo?: string; // 手机号（可选）
  activity: string;
  activityId: number;
}

function signupInfoToString(info: SignupInfo): string {
  return `SignupInfo(id=${info.id}, name=${info.name}, sex=${info.sex}, age=${info.age}, activity=${info.activity}, activityId=${info.activityId})`;
}

interface ActivityMessage {
  activity: string;
  activityId: string;
}

@Entry
@Component
export struct SignUpPage {
  private signupPagePath: Resource = $rawfile('signup.html');
  @State params: routerParams = router.getParams() as routerParams;
  @State activity: string = this.params.src;
  @State signupInfo: SignupInfo = {} as SignupInfo;
  @State activityMessage: string = '';
  @State dialogShow: boolean = false;
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  nativePort: webview.WebMessagePort | null = null;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SignupInfoDialog({ info: this.signupInfo }),
  });

  aboutToAppear(): void {
    this.activityMessage = this.generateActivityMessage();
  }

  generateActivityMessage() {
    const activityId = this.activity.charAt(0);
    const activity = this.activity.slice(1);
    const message: ActivityMessage = {
      activity: activity,
      activityId: activityId
    };
    return JSON.stringify(message)
  }

  initWebviewPort() {
    try {
      this.ports = this.controller.createWebMessagePorts();
      this.ports[1].onMessageEvent((result: webview.WebMessage) => {
        if (typeof (result) === "string") {
          console.log("received string message from html5, string is:" + result);
          // 收到 HTML 发送过来的活动 ID
          let message: MessageModel = JSON.parse(result);
          if (message.type == 'back') {
            router.back();
          } else if (message.type == 'event') {
            const content = message.content;
            this.signupInfo = JSON.parse(content);
            
            // 验证身份证号
            if (!checkIDCardNo(this.signupInfo.id)) {
              Prompt.showToast({
                message: '身份证号格式不正确，请重新输入',
                duration: 2000
              });
              return;
            }
            
            // 如果提供了手机号，验证手机号
            if (this.signupInfo.phoneNo && !checkPhoneNo(this.signupInfo.phoneNo)) {
              Prompt.showToast({
                message: '手机号格式不正确，请重新输入',
                duration: 2000
              });
              return;
            }
            
            Prompt.showToast({
              message: signupInfoToString(this.signupInfo)
            })
            this.dialogController.open()
          } else {
            console.error(message.type + '\n' + message.content);
          }
        } else {
          console.log("received unknown message type from html5");
        }
      });
      this.controller.postMessage('__init_port__', [this.ports[0]], '*');
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
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

  build() {
    Column() {
      Web({ src: this.signupPagePath, controller: this.controller })
        .javaScriptAccess(true)
        .onPageEnd(() => {
          this.initWebviewPort();
          this.postMessageToHtml(this.activityMessage);
        })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}

@CustomDialog
struct SignupInfoDialog {
  controller?: CustomDialogController;
  info: SignupInfo = {} as SignupInfo;

  build() {
    Column({ space: 15 }) { // 增加垂直间距
      Text('报名信息')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 10 })

      Divider()
        .strokeWidth(1)
        .color('#e0e0e0')
        .margin({ bottom: 10 })

      // 信息展示区域
      Column({ space: 8 }) { // 保持垂直间距
        Row() {
          Text('证件号:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start) // 键左对齐
          Text(this.info.id).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End) // 值右对齐
        }
        .width('100%') // 确保 Row 占据全部宽度
        .justifyContent(FlexAlign.SpaceBetween) // 键和值两端对齐

        Row() {
          Text('姓名:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
          Text(this.info.name).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('性别:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
          Text(this.info.sex).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('年龄:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
          Text(this.info.age.toString()).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.info.phoneNo) {
          Row() {
            Text('手机号:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
            Text(this.info.phoneNo).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }

        Row() {
          Text('报名活动:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
          Text(this.info.activity).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('活动ID:').fontSize(16).fontColor('#757575').textAlign(TextAlign.Start)
          Text(this.info.activityId.toString()).fontSize(16).fontColor(Color.Black).fontWeight(FontWeight.Medium).textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }.width('100%') // 确保整个信息列占据全部宽度

      Divider()
        .strokeWidth(1)
        .color('#e0e0e0')
        .margin({ top: 15, bottom: 10 }) // 增加分割线与按钮的间距

      // 按钮组
      Row({ space: 15 }) {
        Button("取消")
          .width('45%') // 按钮宽度
          .height(40)
          .fontSize(16)
          .fontColor('#555555')
          .backgroundColor('#f0f0f0')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close() // 关闭弹窗
            }
          })
          .borderRadius(8) // 圆角
          .border({ width: 1, color: '#cccccc' }) // 边框

        Button("确定")
          .width('45%')
          .height(40)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007bff') // 主色调蓝色
          .onClick(() => {
            postSignUpData(this.info);
            if (this.controller != undefined) {
              this.controller.close() // 关闭弹窗
            }
          })
          .borderRadius(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround) // 按钮均匀分布
    }
    .padding({ left: 25, right: 25, top: 20, bottom: 20 }) // 整体内边距
    .backgroundColor('#ffffff')
    .borderRadius(16) // 更大的圆角
    .border({ width: 1, color: '#cccccc' }) // 轻微的边框
  }
}
