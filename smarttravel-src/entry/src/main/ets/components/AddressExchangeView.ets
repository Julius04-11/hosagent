@Component
export struct AddressExchangeView {
  @State departureAddress: string = '';
  @State destinationAddress: string = '';
  @State isAnimating: boolean = false;

  // 地址交换动画
  private async swapAddresses() {
    if (this.isAnimating) return;
    
    this.isAnimating = true;
    
    // 使用animateTo实现地址交换动画
    animateTo({
      duration: 500,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.isAnimating = false;
      }
    }, () => {
      const temp = this.departureAddress;
      this.departureAddress = this.destinationAddress;
      this.destinationAddress = temp;
    });
  }

  // 清空地址
  private clearAddresses() {
    this.departureAddress = '';
    this.destinationAddress = '';
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('地址交换')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e40af')
        
        Blank()
        
        Button() {
          Text('清空')
            .fontSize(14)
            .fontColor('#64748b')
        }
        .height(32)
        .backgroundColor('#f1f5f9')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.clearAddresses();
        })
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 出发地输入
      Column() {
        Text('出发地')
          .fontSize(16)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ 
          placeholder: '请输入出发地',
          text: this.departureAddress
        })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#1e293b')
          .backgroundColor('#f8fafc')
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .border({
            width: 1,
            color: '#e2e8f0'
          })
          .onChange((value: string) => {
            this.departureAddress = value;
          })
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 交换按钮
      Button() {
        Text('🔄')
          .fontSize(20)
          .fontColor(this.isAnimating ? '#94a3b8' : '#1e40af')
      }
      .width(48)
      .height(48)
      .backgroundColor(this.isAnimating ? '#f1f5f9' : '#f0f8ff')
      .borderRadius(24)
      .margin({ bottom: 16 })
      .enabled(!this.isAnimating)
      .onClick(() => {
        this.swapAddresses();
      })
      
      // 目的地输入
      Column() {
        Text('目的地')
          .fontSize(16)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ 
          placeholder: '请输入目的地',
          text: this.destinationAddress
        })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#1e293b')
          .backgroundColor('#f8fafc')
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .border({
            width: 1,
            color: '#e2e8f0'
          })
          .onChange((value: string) => {
            this.destinationAddress = value;
          })
      }
      .width('100%')
      
      // 操作按钮
      Row() {
        Button() {
          Text('开始导航')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#1e40af')
        .borderRadius(24)
        .margin({ right: 8 })
        .enabled(this.departureAddress.length > 0 && this.destinationAddress.length > 0)
        .onClick(() => {
          // 开始导航逻辑
          console.log('开始导航:', this.departureAddress, '->', this.destinationAddress);
        })
        
        Button() {
          Text('查看路线')
            .fontSize(16)
            .fontColor('#1e40af')
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#f0f8ff')
        .borderRadius(24)
        .margin({ left: 8 })
        .enabled(this.departureAddress.length > 0 && this.destinationAddress.length > 0)
        .onClick(() => {
          // 查看路线逻辑
          console.log('查看路线:', this.departureAddress, '->', this.destinationAddress);
        })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
