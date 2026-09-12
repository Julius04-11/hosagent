// Index.ets
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import { SignupInfo } from '../activity/SignUpPage';
import { signupList } from './mockData';

@Entry
@Component
struct SignupInfoList {

  build() {
    Column() {
      Text('报名信息列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });

      List() {
        ForEach(signupList, (item: SignupInfo) => {
          ListItem() {
            Column() {
              Text(`姓名: ${item.name}`)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Black)
                .margin({ bottom: 4 });

              Text(`性别: ${item.sex}, 年龄: ${item.age} 岁`)
                .fontSize(14)
                .margin({ bottom: 2 });

              Text(`活动: ${item.activity}`)
                .fontSize(14)
                .margin({ bottom: 2 });

              Text(`活动ID: ${item.activityId}`)
                .fontSize(12)
            }
            .width('95%')
            .height(120)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({
              radius: 6, // 阴影半径增大，使阴影更明显
              color: Color.Gray, // 阴影颜色稍微透明化
              offsetX: 0,
              offsetY: 4 // 阴影垂直偏移量增大，更显浮动
            })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 15, right: 15 })
            .margin({ bottom: 10 })
            .onClick(() => {
              // router.pushUrl({ url: "pages/SignUpData" });
              prompt.showToast({
                message: `点击了 ${item.name} 的报名信息`,
                duration: 2000
              });
            });
          }
        }, (item: SignupInfo) => item.id);
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10, top: 20, bottom: 10 })
    .backgroundColor(0xF5F5F5); // 给整个页面背景设置一个浅灰色
  }
}