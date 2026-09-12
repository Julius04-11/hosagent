import { router } from '@kit.ArkUI';

@Entry
@Component
export struct SplashPage {
  @State private animationProgress: number = 0;
  @State private textOpacity: number = 0;
  @State private scaleValue: number = 0.8;
  @State private rotationAngle: number = 0;
  @State private showContent: boolean = false;
  @State private currentText: string = '精彩即将呈现';
  
  private textList: string[] = [
    '精彩即将呈现',
    '智慧出行',
    '探索世界',
    '开启旅程'
  ];
  private currentIndex: number = 0;

  aboutToAppear() {
    this.startSplashAnimation();
  }

  private async startSplashAnimation() {
    // 延迟显示内容
    setTimeout(() => {
      this.showContent = true;
    }, 500);

    // 启动动画序列
    await this.playAnimationSequence();
    
    // 动画完成后跳转到主页
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/Index' });
    }, 1500);
  }

  private async playAnimationSequence() {
    // 第一阶段：缩放和旋转动画
    await this.animateScaleAndRotation();
    
    // 第二阶段：文字淡入动画
    await this.animateTextFadeIn();
    
    // 第三阶段：文字切换动画
    await this.animateTextSwitch();
    
    // 第四阶段：进度条动画
    await this.animateProgress();
  }

  private async animateScaleAndRotation(): Promise<void> {
    return new Promise((resolve) => {
      // 缩放动画
      animateTo({
        duration: 800,
        curve: Curve.EaseOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        this.scaleValue = 1.0;
      });

      // 旋转动画
      animateTo({
        duration: 1200,
        curve: Curve.EaseInOut,
        onFinish: () => {}
      }, () => {
        this.rotationAngle = 360;
      });
    });
  }

  private async animateTextFadeIn(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        animateTo({
          duration: 600,
          curve: Curve.EaseOut,
          onFinish: () => {
            resolve();
          }
        }, () => {
          this.textOpacity = 1.0;
        });
      }, 200);
    });
  }

  private async animateTextSwitch(): Promise<void> {
    return new Promise((resolve) => {
      const switchText = () => {
        if (this.currentIndex < this.textList.length - 1) {
          setTimeout(() => {
            // 淡出当前文字
            animateTo({
              duration: 300,
              curve: Curve.EaseInOut,
              onFinish: () => {
                this.currentIndex++;
                this.currentText = this.textList[this.currentIndex];
                
                // 淡入新文字
                animateTo({
                  duration: 300,
                  curve: Curve.EaseInOut,
                  onFinish: () => {
                    switchText();
                  }
                }, () => {
                  this.textOpacity = 1.0;
                });
              }
            }, () => {
              this.textOpacity = 0;
            });
          }, 800);
        } else {
          resolve();
        }
      };
      
      switchText();
    });
  }

  private async animateProgress(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        animateTo({
          duration: 1000,
          curve: Curve.EaseInOut,
          onFinish: () => {
            resolve();
          }
        }, () => {
          this.animationProgress = 1.0;
        });
      }, 500);
    });
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#667eea', 0.0],
            ['#764ba2', 0.5],
            ['#f093fb', 1.0]
          ]
        })

      // 主要内容
      if (this.showContent) {
        Column() {
          // Logo 区域
          Column() {
            // 主图标
            Stack() {
              // 背景圆形
              Circle()
                .width(120)
                .height(120)
                .fill('#ffffff')
                .opacity(0.2)
                .shadow({
                  radius: 20,
                  color: 'rgba(255,255,255,0.3)',
                  offsetX: 0,
                  offsetY: 10
                })
              
              // 旋转的装饰元素
              Column() {
                ForEach([0, 1, 2, 3], (index: number) => {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill('#ffffff')
                    .opacity(0.6)
                    .position({
                      x: Math.cos(index * Math.PI / 2) * 40,
                      y: Math.sin(index * Math.PI / 2) * 40
                    })
                })
              }
              .width(120)
              .height(120)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .rotate({ angle: this.rotationAngle })
              
              // 中心图标
              Text('🚀')
                .fontSize(48)
                .fontColor('#ffffff')
                .scale({ x: this.scaleValue, y: this.scaleValue })
            }
            .width(120)
            .height(120)
            .alignContent(Alignment.Center)
          }
          .margin({ bottom: 40 })

          // 文字区域
          Column() {
            Text(this.currentText)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })

            // 副标题
            Text('Smart Travel')
              .fontSize(16)
              .fontColor('#ffffff')
              .opacity(0.8)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 40 })
          }

          // 进度条
          Column() {
            // 进度条背景
            Row() {
              Row()
                .width(`${this.animationProgress * 100}%`)
                .height(4)
                .backgroundColor('#ffffff')
                .borderRadius(2)
                .animation({
                  duration: 1000,
                  curve: Curve.EaseInOut
                })
            }
            .width(200)
            .height(4)
            .backgroundColor('rgba(255,255,255,0.3)')
            .borderRadius(2)
            .margin({ bottom: 8 })

            // 进度文字
            Text(`${Math.round(this.animationProgress * 100)}%`)
              .fontSize(12)
              .fontColor('#ffffff')
              .opacity(0.7)
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 装饰性粒子效果
      Stack() {
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Circle()
            .width(4)
            .height(4)
            .fill('#ffffff')
            .opacity(0.6)
            .position({
              x: Math.random() * 100 + '%',
              y: Math.random() * 100 + '%'
            })
            .animation({
              duration: 2000 + index * 200,
              iterations: -1,
              curve: Curve.EaseInOut
            })
            .scale({
              x: this.animationProgress * 0.5 + 0.5,
              y: this.animationProgress * 0.5 + 0.5
            })
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
