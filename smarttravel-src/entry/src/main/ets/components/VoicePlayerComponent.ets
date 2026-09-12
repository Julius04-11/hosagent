import MediaPlayer from '../utils/MediaPlayer';
import { common } from '@kit.AbilityKit';
// getContext is available globally in ArkTS

/**
 * 景点语音播放组件
 * 用于播放景点的语音讲解音频
 */
@Component
export struct VoicePlayerComponent {
  // 音频资源路径（相对于rawfile目录）
  @Prop audioResource: string = '';
  // 音频ID（用于标识不同的音频）
  @Prop audioId: string = '';
  // 是否显示播放器（可选，用于控制显示/隐藏）
  @State isVisible: boolean = true;
  // 播放状态
  @State isPlaying: boolean = false;
  // 当前播放时间（秒）
  @State currentTime: number = 0;
  // 总时长（秒）
  @State totalDuration: number = 0;
  // 时间字符串显示
  @State timeStr: string = '00:00';
  @State durationStr: string = '00:00';
  // MediaPlayer实例
  private instance: MediaPlayer | null = null;
  // 定时器
  private timer: number | null = null;

  aboutToAppear() {
    this.initMediaPlayer();
  }

  aboutToDisappear() {
    this.cleanup();
  }

  /**
   * 初始化MediaPlayer
   */
  private async initMediaPlayer() {
    try {
      this.instance = await MediaPlayer.getInstance();
      this.startTimer();
    } catch (error) {
      console.error('初始化MediaPlayer失败:', error);
    }
  }

  /**
   * 启动定时器，用于更新播放时间和状态
   */
  private startTimer() {
    if (this.timer) {
      clearInterval(this.timer);
    }
    this.timer = setInterval(() => {
      this.updatePlaybackInfo();
    }, 500);
  }

  /**
   * 更新播放信息
   */
  private updatePlaybackInfo() {
    if (this.instance) {
      this.currentTime = Math.floor(MediaPlayer.time / 1000); // 转换为秒
      this.totalDuration = Math.floor(MediaPlayer.duration / 1000); // 转换为秒
      this.timeStr = this.formatTime(this.currentTime);
      this.durationStr = this.formatTime(this.totalDuration);
      
      if (MediaPlayer.state === 'playing') {
        this.isPlaying = true;
      } else {
        this.isPlaying = false;
      }
    }
  }

  /**
   * 格式化时间显示（秒转MM:SS）
   */
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 处理播放/暂停点击
   */
  private async handlePlayPause() {
    if (!this.instance) {
      this.instance = await MediaPlayer.getInstance();
    }

    try {
      if (this.isPlaying) {
        // 当前正在播放，执行暂停
        this.isPlaying = false;
        await this.instance.pause();
      } else {
        // 当前未播放，执行播放
        if (MediaPlayer.state === 'prepared' || MediaPlayer.state === 'paused' || 
            MediaPlayer.state === 'completed') {
          // 已准备好，直接播放
          await this.instance.play();
          this.isPlaying = true;
        } else if (MediaPlayer.state === 'idle' || MediaPlayer.curAudioId !== this.audioId) {
          // 需要重新加载音频资源
          if (this.audioResource) {
            try {
              const context = getContext(this) as common.UIAbilityContext;
              MediaPlayer.audioUrl = this.audioResource;
              MediaPlayer.curAudioId = this.audioId;
              await this.instance.setAudioResourceFromRowFile(this.audioResource, context);
              await this.instance.play();
              this.isPlaying = true;
            } catch (error) {
              console.error('加载音频资源失败:', error);
            }
          } else {
            console.error('音频资源路径为空');
          }
        }
      }
    } catch (error) {
      console.error('播放/暂停操作失败:', error);
      this.isPlaying = false;
    }
  }

  /**
   * 清理资源
   */
  private cleanup() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
    // 注意：不在这里释放MediaPlayer，因为可能是单例，其他组件可能在使用
  }

  build() {
    if (!this.isVisible || !this.audioResource) {
      // 如果没有音频资源或不可见，不显示播放器
      Column()
    } else {
      Row() {
        // 播放/暂停按钮
        Row() {
          Text(this.isPlaying ? '⏸️' : '▶️')
            .fontSize(32)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handlePlayPause();
        })
        
        // 时间显示
        Column() {
          Text(this.timeStr)
            .fontSize(12)
            .fontColor('#666666')
          
          if (this.totalDuration > 0) {
            Text(`/ ${this.durationStr}`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#f5f5f5')
      .borderRadius(8)
      .alignItems(VerticalAlign.Center)
    }
  }
}

/**
 * 简化版语音播放组件（仅显示播放按钮）
 * 适用于列表项等紧凑场景
 */
@Component
export struct SimpleVoicePlayerComponent {
  @Prop audioResource: string = '';
  @Prop audioId: string = '';
  @State isPlaying: boolean = false;
  private instance: MediaPlayer | null = null;

  aboutToAppear() {
    this.initMediaPlayer();
  }

  private async initMediaPlayer() {
    try {
      this.instance = await MediaPlayer.getInstance();
      // 监听播放状态变化
      const timer = setInterval(() => {
        if (MediaPlayer.curAudioId === this.audioId) {
          this.isPlaying = MediaPlayer.state === 'playing';
        } else {
          this.isPlaying = false;
        }
      }, 300);
    } catch (error) {
      console.error('初始化MediaPlayer失败:', error);
    }
  }

  private async handlePlayPause() {
    if (!this.instance) {
      this.instance = await MediaPlayer.getInstance();
    }

    try {
      if (this.isPlaying && MediaPlayer.curAudioId === this.audioId) {
        await this.instance.pause();
        this.isPlaying = false;
      } else {
        if (MediaPlayer.curAudioId !== this.audioId || MediaPlayer.state === 'idle') {
          if (this.audioResource) {
            try {
              const context = getContext(this) as common.UIAbilityContext;
              MediaPlayer.audioUrl = this.audioResource;
              MediaPlayer.curAudioId = this.audioId;
              await this.instance.setAudioResourceFromRowFile(this.audioResource, context);
            } catch (error) {
              console.error('加载音频资源失败:', error);
              return;
            }
          }
        }
        await this.instance.play();
        this.isPlaying = true;
      }
    } catch (error) {
      console.error('播放/暂停操作失败:', error);
    }
  }

  build() {
    if (!this.audioResource) {
      Column()
    } else {
      Row() {
        Text(this.isPlaying ? '⏸️' : '▶️')
          .fontSize(24)
      }
      .width(32)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.handlePlayPause();
      })
    }
  }
}
