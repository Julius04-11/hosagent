import { Prompt } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface ScanOption {
  icon: string;
  name: string;
  description: string;
  color: string;
}

interface ScanHistoryItem {
  content: string;
  type: string;
  time: string;
}

@Entry
@Component
export struct ScanPage {
  @State isScanning: boolean = false;
  @State scanResult: string = '';
  @State flashOn: boolean = false;

  private scanOptions: ScanOption[] = [
    { icon: '📱', name: '扫一扫', description: '扫描二维码、条形码', color: '#3b82f6' },
    { icon: '🏷️', name: '商品码', description: '扫描商品条码', color: '#10b981' },
    { icon: '📄', name: '文档扫描', description: '扫描文档、名片', color: '#f59e0b' },
    { icon: '🌐', name: '网页链接', description: '扫描网页二维码', color: '#8b5cf6' },
    { icon: '💰', name: '支付码', description: '扫描支付二维码', color: '#ef4444' },
    { icon: '🚗', name: '车牌识别', description: '识别车牌号码', color: '#06b6d4' }
  ];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '扫一扫',
        showBack: true,
        showSearch: false,
        showNotification: false
      })
      
      Column() {
        // 扫描区域
        this.ScanArea()
        
        // 扫描选项
        this.ScanOptions()
        
        // 历史记录
        this.ScanHistory()
      }
      .layoutWeight(1)
      .backgroundColor('#f8fafc')
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder ScanArea() {
    Column() {
      // 扫描框
      Stack() {
        // 背景
        Column()
          .width('100%')
          .height(300)
          .backgroundColor(Color.Black)
        
        // 扫描框
        Column()
          .width(250)
          .height(250)
          .border({
            width: 2,
            color: this.isScanning ? '#3b82f6' : '#ffffff',
            style: BorderStyle.Solid
          })
          .borderRadius(12)
          .backgroundColor('transparent')
        
        // 四个角的装饰
        this.ScanCorner(0, 0) // 左上
        this.ScanCorner(250, 0) // 右上
        this.ScanCorner(0, 250) // 左下
        this.ScanCorner(250, 250) // 右下
        
        // 扫描线动画
        if (this.isScanning) {
          Column()
            .width(250)
            .height(2)
            .backgroundColor(Color.Blue)
            .animation({
              duration: 2000,
              curve: Curve.Linear,
              iterations: -1,
              playMode: PlayMode.Normal
            })
            .translate({ y: -125 })
        }
      }
      .width('100%')
      .height(300)
      .alignContent(Alignment.Center)
      .margin({ bottom: 20 })

      // 扫描提示
      Text('将二维码/条形码放入框内，即可自动扫描')
        .fontSize(14)
        .fontColor('#6b7280')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      // 控制按钮
      Row({ space: 20 }) {
        // 相册按钮
        Column() {
          Text('📷')
            .fontSize(24)
            .margin({ bottom: 4 })
          
          Text('相册')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .onClick(() => {
          Prompt.showToast({ message: '选择相册图片' })
        })

        // 扫描按钮
        Button(this.isScanning ? '停止扫描' : '开始扫描')
          .fontSize(16)
          .fontColor('#ffffff')
          .backgroundColor('#3b82f6')
          .borderRadius(25)
          .padding({ left: 30, right: 30, top: 12, bottom: 12 })
          .onClick(() => {
            this.toggleScanning()
          })

        // 闪光灯按钮
        Column() {
          Text(this.flashOn ? '💡' : '🔦')
            .fontSize(24)
            .margin({ bottom: 4 })
          
          Text('闪光灯')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .onClick(() => {
          this.toggleFlash()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 40, right: 40 })
      .margin({ bottom: 30 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(20)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ScanCorner(x: number, y: number) {
    Column() {
      Row() {
        Column()
          .width(20)
          .height(3)
          .backgroundColor('#3b82f6')
        
        Column()
          .width(3)
          .height(20)
          .backgroundColor('#3b82f6')
      }
    }
    .position({ x: x, y: y })
  }

  @Builder ScanOptions() {
    Column() {
      Text('扫描功能')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      GridRow({
        columns: 3,
        gutter: { x: 12, y: 12 }
      }) {
        ForEach(this.scanOptions, (option: ScanOption) => {
          GridCol({ span: 1 }) {
            this.ScanOptionItem(option)
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ScanOptionItem(option: ScanOption) {
    Column() {
      Text(option.icon)
        .fontSize(24)
        .margin({ bottom: 8 })
      
      Text(option.name)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 4 })
      
      Text(option.description)
        .fontSize(10)
        .fontColor('#6b7280')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      Prompt.showToast({ message: `选择功能：${option.name}` })
    })
  }

  @Builder ScanHistory() {
    Column() {
      Row() {
        Text('扫描历史')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text('清空历史 >')
          .fontSize(12)
          .fontColor('#6b7280')
          .onClick(() => {
            Prompt.showToast({ message: '清空扫描历史' })
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 历史记录列表
      Column({ space: 8 }) {
        this.HistoryItem('https://www.smarttravel.com', '网页链接', '2分钟前')
        this.HistoryItem('商品码：1234567890', '商品信息', '1小时前')
        this.HistoryItem('微信支付码', '支付二维码', '昨天')
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder HistoryItem(content: string, type: string, time: string) {
    Row() {
      Text('📱')
        .fontSize(20)
        .margin({ right: 12 })
      
      Column() {
        Text(content)
          .fontSize(14)
          .fontColor('#1f2937')
          .margin({ bottom: 2 })
        
        Text(`${type} · ${time}`)
          .fontSize(12)
          .fontColor('#6b7280')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Text('>')
        .fontSize(16)
        .fontColor('#d1d5db')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f8fafc')
    .borderRadius(8)
    .onClick(() => {
      Prompt.showToast({ message: `查看：${content}` })
    })
  }

  private toggleScanning() {
    this.isScanning = !this.isScanning
    
    if (this.isScanning) {
      Prompt.showToast({ message: '开始扫描...' })
      // 模拟扫描结果
      setTimeout(() => {
        this.scanResult = 'https://www.smarttravel.com'
        Prompt.showToast({ message: '扫描成功！' })
        this.isScanning = false
        // 处理扫描结果
        this.handleScanResult(this.scanResult)
      }, 3000)
    } else {
      Prompt.showToast({ message: '停止扫描' })
    }
  }

  // 处理扫描结果
  private handleScanResult(result: string) {
    // 判断扫描结果类型并进行相应处理
    if (result.startsWith('http')) {
      // 网页链接
      Prompt.showToast({ message: '检测到网页链接，正在打开...' })
      // 这里可以添加打开网页的逻辑
    } else if (result.includes('支付')) {
      // 支付二维码
      Prompt.showToast({ message: '检测到支付码' })
      // 这里可以添加支付处理逻辑
    } else {
      // 其他类型
      Prompt.showToast({ message: `扫描结果: ${result}` })
    }
    
    // 添加到历史记录
    this.addToHistory(result)
  }

  // 添加到扫描历史
  private addToHistory(result: string) {
    const historyItem: ScanHistoryItem = {
      content: result,
      type: this.getResultType(result),
      time: this.formatTime(new Date())
    }
    // 这里可以保存到本地存储
    console.log('添加扫描历史:', historyItem)
  }

  // 获取结果类型
  private getResultType(result: string): string {
    if (result.startsWith('http')) return '网页链接'
    if (result.includes('支付')) return '支付二维码'
    if (/^\d+$/.test(result)) return '商品码'
    return '文本信息'
  }

  // 格式化时间
  private formatTime(date: Date): string {
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    
    if (diff < 60000) return '刚刚'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
    return '昨天'
  }

  private toggleFlash() {
    this.flashOn = !this.flashOn
    Prompt.showToast({ message: this.flashOn ? '闪光灯已开启' : '闪光灯已关闭' })
  }
}
