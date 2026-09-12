import { router } from '@kit.ArkUI';

@Component
export struct TopNavigationBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop showSearch: boolean = false;
  @Prop showNotification: boolean = false;
  @Prop showProfile: boolean = false;
  @Prop notificationCount: number = 0;

  build() {
    Row() {
      // 左侧区域
      Row() {
        if (this.showBack) {
          Text('←')
            .fontSize(20)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              router.back();
            })
        }
        
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ left: this.showBack ? 12 : 0 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      // 右侧区域
      Row({ space: 16 }) {
        if (this.showSearch) {
          Text('🔍')
            .fontSize(20)
            .onClick(() => {
              // 跳转到搜索页面
            })
        }
        
        if (this.showNotification) {
          Stack() {
            Text('🔔')
              .fontSize(20)
              .onClick(() => {
                // 跳转到通知页面
              })
            
            if (this.notificationCount > 0) {
              Text(this.notificationCount.toString())
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor('#ef4444')
                .borderRadius(8)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .position({ x: 12, y: -4 })
            }
          }
        }
        
        if (this.showProfile) {
          Text('👤')
            .fontSize(20)
            .onClick(() => {
              // 跳转到个人资料页面
            })
        }
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }
}

