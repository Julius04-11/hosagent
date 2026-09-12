/**
 * 智能人机交互演示页面
 * 展示AI如何在鸿蒙原生布局中实现优秀交互
 */
import { router } from '@kit.ArkUI';
import { AIEngineManager, AIInput } from '../../ai/AIEngineManager';
import { CausalMultimodalAnalyzer } from '../../algorithm/CausalMultimodalFramework';
import { TopNavigationBar } from '../../components/TopNavigationBar';

@Entry
@Component
export struct SmartInteractionDemo {
  @State messages: ChatMessage[] = [];
  @State userInput: string = '';
  @State isThinking: boolean = false;
  @State currentMode: 'chat' | 'voice' | 'image' = 'chat';

  private aiEngine = AIEngineManager.getInstance();
  private analyzer = CausalMultimodalAnalyzer.getInstance();
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await this.aiEngine.initialize();
    
    // AI欢迎语
    this.addMessage({
      role: 'ai',
      content: '您好！我是智能旅行助手，基于因果推理和多模态分析。\n\n我可以帮您：\n🎤 语音对话\n📷 拍照识别\n✨ 智能推荐\n🗺️ 行程规划',
      timestamp: Date.now()
    });
  }

  build() {
    Column() {
      // 导航栏
      TopNavigationBar({ title: 'AI智能助手', showBack: true })

      // 对话区域
      List({ scroller: this.scroller }) {
        ForEach(this.messages, (msg: ChatMessage) => {
          ListItem() {
            this.MessageBubble(msg)
          }
        }, (msg: ChatMessage) => msg.timestamp.toString())
      }
      .layoutWeight(1)
      .backgroundColor('#f9fafb')
      .padding(16)
      .divider({ strokeWidth: 0 })
      .onScrollIndex((start, end) => {
        // 滚动到底部
      })

      // AI思考状态
      if (this.isThinking) {
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
        .padding(12)
        .backgroundColor('#eef2ff')
      }

      // 输入区域
      this.InputArea()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder MessageBubble(msg: ChatMessage) {
    Row() {
      if (msg.role === 'user') {
        Blank()
      }

      Column({ space: 4 }) {
        // 消息内容
        Text(msg.content)
          .fontSize(15)
          .fontColor(msg.role === 'user' ? Color.White : '#1f2937')
          .lineHeight(22)
          .padding(12)
          .backgroundColor(msg.role === 'user' ? '#0A59F7' : Color.White)
          .borderRadius(12)
          .maxWidth('75%')
          .shadow(msg.role === 'ai' ? {
            radius: 4,
            color: 'rgba(0,0,0,0.08)',
            offsetY: 2
          } : {})

        // 因果推理显示
        if (msg.causalChain) {
          Text(`🔗 ${msg.causalChain}`)
            .fontSize(12)
            .fontColor('#6b7280')
            .padding(8)
            .backgroundColor('#f3f4f6')
            .borderRadius(8)
            .maxWidth('75%')
        }

        // 时间戳
        Text(this.formatTime(msg.timestamp))
          .fontSize(11)
          .fontColor('#9ca3af')
          .margin({ top: 4 })
      }
      .alignItems(msg.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)

      if (msg.role === 'ai') {
        Blank()
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder InputArea() {
    Column() {
      // 模式切换
      Row({ space: 16 }) {
        this.ModeButton('💬', 'chat', '文字')
        this.ModeButton('🎤', 'voice', '语音')
        this.ModeButton('📷', 'image', '拍照')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 8 })

      // 输入框
      Row({ space: 8 }) {
        TextInput({ placeholder: '输入您的问题...', text: this.userInput })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f3f4f6')
          .borderRadius(20)
          .onChange((value) => {
            this.userInput = value;
          })

        Button('发送')
          .height(40)
          .backgroundColor('#0A59F7')
          .borderRadius(20)
          .onClick(() => {
            this.sendMessage();
          })
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.08)',
      offsetY: -2
    })
  }

  @Builder ModeButton(icon: string, mode: 'chat' | 'voice' | 'image', label: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(24)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentMode === mode ? '#0A59F7' : '#6b7280')
    }
    .padding(8)
    .borderRadius(8)
    .backgroundColor(this.currentMode === mode ? '#eef2ff' : Color.Transparent)
    .onClick(() => {
      this.currentMode = mode;
      if (mode === 'voice') {
        this.handleVoiceInput();
      } else if (mode === 'image') {
        this.handleImageInput();
      }
    })
  }

  /**
   * 发送消息
   */
  private async sendMessage() {
    if (!this.userInput.trim()) return;

    const userMessage = this.userInput;
    this.userInput = '';

    // 添加用户消息
    this.addMessage({
      role: 'user',
      content: userMessage,
      timestamp: Date.now()
    });

    this.isThinking = true;

    try {
      // AI处理
      const result = await this.aiEngine.process({
        type: 'text',
        data: { text: userMessage }
      });

      // 生成AI回复
      const aiResponse = this.generateAIResponse(userMessage, result);
      
      this.addMessage({
        role: 'ai',
        content: aiResponse.content,
        causalChain: aiResponse.causalChain,
        timestamp: Date.now()
      });

      // 滚动到底部
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 100);
    } catch (error) {
      this.addMessage({
        role: 'ai',
        content: '抱歉，AI处理出错了',
        timestamp: Date.now()
      });
    } finally {
      this.isThinking = false;
    }
  }

  /**
   * 生成AI回复
   */
  private generateAIResponse(userInput: string, aiResult: any): AIResponse {
    const intent = aiResult.data?.intent || 'unknown';

    switch (intent) {
      case 'query_restaurant':
        return {
          content: '为您推荐以下餐厅：\n\n' +
            '🦞 深圳湾海鲜大排档 (匹配度95%)\n' +
            '  人均¥120，距离1.2km\n\n' +
            '🌶️ 川味火锅城 (匹配度88%)\n' +
            '  人均¥150，距离2.5km',
          causalChain: '因果推理：您偏好海鲜 → 新鲜度重要 → 推荐高评分餐厅'
        };

      case 'plan_trip':
        return {
          content: '🗺️ 为您规划周末行程：\n\n' +
            '【Day 1】\n' +
            '09:00 东部华侨城\n' +
            '12:00 山顶餐厅\n' +
            '14:00 茶溪谷\n' +
            '18:00 深圳湾日落\n\n' +
            '预算：¥850',
          causalChain: '因果链：晴天 → 户外活动 → 自然风光 → 高满意度'
        };

      case 'query_hotel':
        return {
          content: '为您推荐酒店：\n\n' +
            '🏨 深圳湾万豪酒店 (匹配度92%)\n' +
            '  五星级，海景房¥800/晚',
          causalChain: '位置优越 → 交通便利 → 出行方便 → 体验佳'
        };

      default:
        return {
          content: `收到您的咨询："${userInput}"\n\n` +
            '我可以帮您：\n' +
            '• 推荐餐厅和景点（基于因果分析）\n' +
            '• 规划旅行行程（多目标优化）\n' +
            '• 分析评论情感（方面级+因果链）',
          causalChain: '基于您的需求和偏好进行因果推理'
        };
    }
  }

  /**
   * 语音输入
   */
  private async handleVoiceInput() {
    this.addMessage({
      role: 'user',
      content: '🎤 [语音输入]',
      timestamp: Date.now()
    });

    this.isThinking = true;

    // 模拟语音识别
    await new Promise(resolve => setTimeout(resolve, 1000));

    const voiceText = '推荐附近的美食';
    
    this.addMessage({
      role: 'ai',
      content: `识别：${voiceText}\n\n` +
        '根据您的位置和偏好，为您推荐：\n\n' +
        '🦞 深圳湾海鲜大排档\n' +
        '距离1.2km，评分4.8',
      causalChain: '语音识别 → 意图理解 → 因果推荐',
      timestamp: Date.now()
    });

    this.isThinking = false;
  }

  /**
   * 图像输入
   */
  private async handleImageInput() {
    this.addMessage({
      role: 'user',
      content: '📷 [拍照识别]',
      timestamp: Date.now()
    });

    this.isThinking = true;

    // 模拟图像识别
    await new Promise(resolve => setTimeout(resolve, 800));

    this.addMessage({
      role: 'ai',
      content: '📸 识别结果：\n\n' +
        '景点：深圳平安金融中心\n' +
        '高度：599米\n' +
        '建议：傍晚18:00-19:00最佳拍摄',
      causalChain: '图像识别 → 特征提取 → 场景理解 → 个性化建议',
      timestamp: Date.now()
    });

    this.isThinking = false;
  }

  /**
   * 添加消息
   */
  private addMessage(msg: ChatMessage) {
    this.messages.push(msg);
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
}

interface ChatMessage {
  role: 'user' | 'ai';
  content: string;
  causalChain?: string;
  timestamp: number;
}

interface AIResponse {
  content: string;
  causalChain?: string;
}
