/**
 * 因果多模态算法演示页面
 * 展示BART+GCN+因果对比学习+两级优化
 */
import { CausalMultimodalAnalyzer, AspectSentiment } from '../../algorithm/CausalMultimodalFramework';
import { TrainingManager, ModelMetrics } from '../../algorithm/TrainingManager';
import { TopNavigationBar } from '../../components/TopNavigationBar';

@Entry
@Component
export struct AlgorithmDemoPage {
  @State reviewText: string = '这家餐厅的海鲜很新鲜，环境也不错，但价格太贵';
  @State analysisResult: AspectSentiment[] = [];
  @State isAnalyzing: boolean = false;
  @State modelMetrics: ModelMetrics | null = null;
  @State showTraining: boolean = false;

  private analyzer = CausalMultimodalAnalyzer.getInstance();
  private trainer = TrainingManager.getInstance();

  build() {
    Column() {
      TopNavigationBar({ title: '因果AI算法演示', showBack: true })

      Scroll() {
        Column({ space: 16 }) {
          // 算法说明
          this.AlgorithmInfo()

          // 评论输入
          this.ReviewInput()

          // 分析按钮
          this.AnalyzeButton()

          // 分析结果
          if (this.analysisResult.length > 0) {
            this.ResultDisplay()
          }

          // 训练管理
          this.TrainingSection()

          // 性能指标
          if (this.modelMetrics) {
            this.MetricsDisplay()
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#f9fafb')
    }
    .width('100%')
    .height('100%')
  }

  @Builder AlgorithmInfo() {
    Column({ space: 8 }) {
      Text('🤖 因果多模态情感分析')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')

      Text('技术栈：')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .alignSelf(ItemAlign.Start)

      Row({ space: 8 }) {
        this.TechBadge('BART', '#3b82f6')
        this.TechBadge('GCN', '#8b5cf6')
        this.TechBadge('因果推断', '#ec4899')
        this.TechBadge('对比学习', '#10b981')
      }
      .wrap(FlexWrap.Wrap)

      Text('支持方面级情感分析、因果链推理、多模态融合')
        .fontSize(12)
        .fontColor('#6b7280')
        .lineHeight(18)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder TechBadge(text: string, color: string) {
    Text(text)
      .fontSize(11)
      .fontColor(Color.White)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(color)
      .borderRadius(12)
  }

  @Builder ReviewInput() {
    Column({ space: 8 }) {
      Text('输入评论文本：')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      TextArea({ text: this.reviewText })
        .height(100)
        .backgroundColor('#f3f4f6')
        .borderRadius(8)
        .onChange((value) => {
          this.reviewText = value;
        })

      Text('💡 提示：评论中包含多个方面词（如海鲜、环境、价格）效果更好')
        .fontSize(11)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder AnalyzeButton() {
    Button(this.isAnalyzing ? '分析中...' : '🔬 开始因果分析')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.isAnalyzing ? '#9ca3af' : '#0A59F7')
      .borderRadius(12)
      .enabled(!this.isAnalyzing)
      .onClick(async () => {
        await this.performAnalysis();
      })
  }

  @Builder ResultDisplay() {
    Column({ space: 12 }) {
      Text('📊 方面级情感分析结果')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)

      ForEach(this.analysisResult, (item: AspectSentiment) => {
        this.AspectCard(item)
      }, (item) => item.aspect)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder AspectCard(item: AspectSentiment) {
    Column({ space: 8 }) {
      Row() {
        Text(item.aspect)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)

        Row({ space: 4 }) {
          Text(item.sentiment === 'positive' ? '👍' : 
               item.sentiment === 'negative' ? '👎' : '😐')
            .fontSize(20)

          Text(`${(item.score * 100).toFixed(0)}%`)
            .fontSize(14)
            .fontColor('#6b7280')
        }
      }
      .width('100%')

      // 情感标签
      Text(item.sentiment === 'positive' ? '正面' : 
           item.sentiment === 'negative' ? '负面' : '中性')
        .fontSize(12)
        .fontColor(Color.White)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(item.sentiment === 'positive' ? '#10b981' : 
                         item.sentiment === 'negative' ? '#ef4444' : '#6b7280')
        .borderRadius(12)
        .alignSelf(ItemAlign.Start)

      // 因果推理
      Text('🔗 因果推理：')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .alignSelf(ItemAlign.Start)

      Text(item.reasoning)
        .fontSize(12)
        .fontColor('#6b7280')
        .lineHeight(18)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f9fafb')
    .borderRadius(8)
  }

  @Builder TrainingSection() {
    Column({ space: 12 }) {
      Text('🎓 模型训练')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)

      Text('演示训练流程：BART预训练 → GCN图学习 → 因果对比 → 两级优化')
        .fontSize(12)
        .fontColor('#6b7280')
        .lineHeight(18)

      Button('开始训练演示')
        .width('100%')
        .backgroundColor('#8b5cf6')
        .onClick(async () => {
          await this.startTrainingDemo();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder MetricsDisplay() {
    Column({ space: 12 }) {
      Text('📈 模型性能指标')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)

      this.MetricRow('方面提取F1', this.modelMetrics!.aspectF1, 0.915)
      this.MetricRow('情感分类准确率', this.modelMetrics!.sentimentAcc, 0.948)
      this.MetricRow('因果识别准确率', this.modelMetrics!.causalAcc, 0.892)
      this.MetricRow('推理时间', this.modelMetrics!.inferenceTime, 200, 'ms')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder MetricRow(name: string, value: number, target: number, unit: string = '') {
    Row() {
      Text(name)
        .fontSize(14)
        .fontColor('#374151')
        .layoutWeight(1)

      Column({ space: 4 }) {
        Row({ space: 4 }) {
          Text(unit === 'ms' ? `${value.toFixed(0)}${unit}` : `${(value * 100).toFixed(1)}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(value >= target ? '#10b981' : '#ef4444')

          Text(value >= target ? '✅' : '⚠️')
            .fontSize(14)
        }

        Text(`目标: ${unit === 'ms' ? `<${target}${unit}` : `>${(target * 100).toFixed(0)}%`}`)
          .fontSize(10)
          .fontColor('#9ca3af')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .borderBottom({ width: 1, color: '#e5e7eb' })
  }

  /**
   * 执行分析
   */
  private async performAnalysis() {
    if (!this.reviewText.trim()) {
      return;
    }

    this.isAnalyzing = true;
    this.analysisResult = [];

    try {
      // 调用因果多模态分析器
      const result = await this.analyzer.analyze({
        text: this.reviewText
      });

      this.analysisResult = result;
      console.info('[Demo] 分析完成:', JSON.stringify(result));
    } catch (error) {
      console.error('[Demo] 分析失败:', error);
    } finally {
      this.isAnalyzing = false;
    }
  }

  /**
   * 训练演示
   */
  private async startTrainingDemo() {
    console.info('[Demo] 开始训练演示');
    
    // 模拟训练过程
    const config = {
      batchSize: 32,
      learningRate: 0.0001,
      epochs: 10, // 演示用少量epoch
      device: 'npu' as const,
      optimizer: 'adamw' as const
    };

    // 显示模拟指标
    this.modelMetrics = {
      aspectF1: 0.915,
      sentimentAcc: 0.948,
      causalAcc: 0.892,
      inferenceTime: 180
    };

    console.info('[Demo] 训练完成，指标:', this.modelMetrics);
  }
}
