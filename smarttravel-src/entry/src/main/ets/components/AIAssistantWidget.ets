/**
 * AI智能助手组件 - 可在任何页面使用
 * 提供语音交互、智能推荐、图像识别等AI功能
 */
import { AIEngineManager, AIInput } from '../ai/AIEngineManager';

@Component
export struct AIAssistantWidget {
  @State isExpanded: boolean = false;
  @State aiResponse: string = '';
  @State isProcessing: boolean = false;
  @State inputText: string = '';
  
  private aiEngine = AIEngineManager.getInstance();

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // AI助手悬浮球
      if (!this.isExpanded) {
        this.FloatingButton()
      } else {
        this.AIPanel()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder FloatingButton() {
    Button() {
      Column() {
        Text('🤖')
          .fontSize(28)
        Text('AI助手')
          .fontSize(10)
          .fontColor(Color.White)
          .margin({ top: 4 })
      }
    }
    .width(70)
    .height(70)
    .borderRadius(35)
    .backgroundColor('#0A59F7')
    .margin({ right: 20, bottom: 80 })
    .shadow({
      radius: 10,
      color: 'rgba(10, 89, 247, 0.3)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.isExpanded = true;
    })
  }

  @Builder AIPanel() {
    Column() {
      // 标题栏
      Row() {
        Text('🤖 AI智能助手')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)
        
        Text('✕')
          .fontSize(24)
          .fontColor('#9ca3af')
          .onClick(() => {
            this.isExpanded = false;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })

      // AI功能菜单
      Scroll() {
        Column({ space: 12 }) {
          this.QuickAction('🎤 语音咨询', '说出您的需求', () => this.handleVoice())
          this.QuickAction('📷 拍照识别', '识别景点、美食', () => this.handleCamera())
          this.QuickAction('✨ 智能推荐', '为您推荐精选内容', () => this.handleRecommend())
          this.QuickAction('🗺️ 行程规划', '规划完美行程', () => this.handlePlanTrip())
          
          // 输入框
          Column({ space: 8 }) {
            Text('💬 文字咨询')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextArea({ placeholder: '输入您的问题...', text: this.inputText })
              .height(80)
              .borderRadius(8)
              .backgroundColor('#f3f4f6')
              .onChange((value) => {
                this.inputText = value;
              })
            
            Button('发送')
              .width('100%')
              .backgroundColor('#0A59F7')
              .onClick(() => {
                this.handleTextInput();
              })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)

          // AI响应区域
          if (this.aiResponse) {
            Column({ space: 8 }) {
              Text('AI回复：')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1f2937')
                .alignSelf(ItemAlign.Start)
              
              Text(this.aiResponse)
                .fontSize(14)
                .lineHeight(22)
                .fontColor('#374151')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#eef2ff')
            .borderRadius(12)
          }

          // 加载状态
          if (this.isProcessing) {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#0A59F7')
              Text('AI思考中...')
                .fontSize(14)
                .fontColor('#6b7280')
                .margin({ left: 8 })
            }
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#f9fafb')
    }
    .width('90%')
    .height('70%')
    .margin({ right: 20, bottom: 20 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder QuickAction(title: string, desc: string, action: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1f2937')
        Text(desc)
          .fontSize(12)
          .fontColor('#6b7280')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('→')
        .fontSize(20)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(action)
  }

  /**
   * 处理语音输入
   */
  private async handleVoice() {
    this.isProcessing = true;
    this.aiResponse = '';

    try {
      // 模拟语音识别
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const input: AIInput = {
        type: 'voice',
        data: { text: '推荐附近的美食' }
      };

      const result = await this.aiEngine.process(input);
      
      if (result.success) {
        this.aiResponse = '根据您的位置和偏好，为您推荐：\n\n' +
          '1. 🦞 深圳湾海鲜大排档 (评分4.8)\n' +
          '   距离1.2km，人均¥120\n\n' +
          '2. 🌶️ 川味火锅城 (评分4.7)\n' +
          '   距离2.5km，人均¥150';
      }
    } catch (error) {
      this.aiResponse = '抱歉，AI处理出错了';
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 处理拍照识别
   */
  private async handleCamera() {
    this.isProcessing = true;
    this.aiResponse = '';

    try {
      await new Promise(resolve => setTimeout(resolve, 800));
      
      this.aiResponse = '📸 识别结果：\n\n' +
        '景点：深圳平安金融中心\n' +
        '高度：599米\n' +
        '建成：2017年\n\n' +
        '💡 推荐：观光层位于541米，门票¥200\n' +
        '最佳拍摄时间：傍晚18:00-19:00';
    } catch (error) {
      this.aiResponse = '识别失败';
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 处理智能推荐
   */
  private async handleRecommend() {
    this.isProcessing = true;
    this.aiResponse = '';

    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      
      this.aiResponse = '✨ 根据您的兴趣，为您推荐：\n\n' +
        '🏞️ 东部华侨城 (匹配度95%)\n' +
        '   理由：您喜欢自然风光\n\n' +
        '🎢 欢乐谷夜场 (匹配度88%)\n' +
        '   理由：附近热门活动\n\n' +
        '🌅 深圳湾看日落 (匹配度85%)\n' +
        '   理由：天气很好';
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 处理行程规划
   */
  private async handlePlanTrip() {
    this.isProcessing = true;
    this.aiResponse = '';

    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      this.aiResponse = '🗺️ 为您规划周末2日游：\n\n' +
        '【Day 1】\n' +
        '09:00 东部华侨城\n' +
        '12:00 山顶餐厅午餐\n' +
        '14:00 茶溪谷\n' +
        '18:00 深圳湾晚餐+日落\n\n' +
        '【Day 2】\n' +
        '09:30 世界之窗\n' +
        '12:30 欢乐海岸午餐\n' +
        '15:00 海上世界\n\n' +
        '预算：¥1850  距离：45km';
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 处理文字输入
   */
  private async handleTextInput() {
    if (!this.inputText.trim()) {
      return;
    }

    this.isProcessing = true;
    const userInput = this.inputText;
    this.inputText = '';

    try {
      const input: AIInput = {
        type: 'text',
        data: { text: userInput }
      };

      const result = await this.aiEngine.process(input);
      
      if (result.success) {
        // 根据意图生成回复
        const intent = result.data.intent;
        
        switch (intent) {
          case 'query_restaurant':
            this.aiResponse = '为您推荐以下餐厅：\n' +
              '1. 深圳湾海鲜大排档\n' +
              '2. 川味火锅城\n' +
              '3. 日式料理店';
            break;
          case 'query_hotel':
            this.aiResponse = '为您推荐酒店：\n' +
              '1. 深圳湾万豪酒店\n' +
              '2. 香格里拉大酒店';
            break;
          default:
            this.aiResponse = `收到您的咨询："${userInput}"\n\n` +
              '我可以帮您：\n' +
              '• 推荐餐厅和景点\n' +
              '• 规划旅行行程\n' +
              '• 识别景点和美食';
        }
      }
    } catch (error) {
      this.aiResponse = '抱歉，处理失败';
    } finally {
      this.isProcessing = false;
    }
  }
}
