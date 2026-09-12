/**
 * 景点语音讲解页面
 * 参考示例: example_code/AttractionTalkSample
 * v5.0: 集成MediaPlayerUtil实现真实音频播放
 */

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { MediaPlayerUtil } from '../../utils/MediaPlayerUtil';
import Logger from '../../utils/Logger';

interface AudioInfo {
  id: string;
  title: string;
  cover: string;
  duration: string;
  audioUrl: string;
}

@Entry
@Component
export struct AttractionAudioPage {
  @State isPlaying: boolean = false;
  @State currentTime: string = '00:00';
  @State totalTime: string = '00:00';
  @State progress: number = 0;
  @State isLoading: boolean = false;
  @State playerState: string = 'idle';
  @State isFavorite: boolean = false;
  
  private audioInfo: AudioInfo = {
    id: '',
    title: '景点介绍',
    cover: 'https://picsum.photos/seed/banner1/800/600',
    duration: '05:30',
    audioUrl: 'audio/sample.mp3' // 默认音频文件
  };
  
  private mediaPlayer: MediaPlayerUtil | null = null;
  private context: common.UIAbilityContext | null = null;
  private updateTimer: number = -1;

  async aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.audioInfo) {
      this.audioInfo = params.audioInfo as AudioInfo;
      this.totalTime = this.audioInfo.duration;
    }
    
    // 获取Context
    try {
      this.context = getContext(this) as common.UIAbilityContext;
      await this.initializePlayer();
    } catch (error) {
      Logger.error('Failed to get context:', (error as Error).message);
      promptAction.showToast({
        message: '初始化失败',
        duration: 2000
      });
    }
  }
  
  aboutToDisappear() {
    // 清理资源
    this.cleanupPlayer();
  }
  
  // 初始化播放器
  private async initializePlayer() {
    try {
      this.isLoading = true;
      this.mediaPlayer = MediaPlayerUtil.getInstance();
      
      if (!this.context) {
        throw new Error('Context not available');
      }
      
      await this.mediaPlayer.initialize(this.context);
      
      // 设置回调
      this.mediaPlayer.onStateChange = (state: string) => {
        this.playerState = state;
        Logger.info(`Player state changed: ${state}`);
        
        if (state === 'playing') {
          this.isPlaying = true;
          this.startProgressUpdate();
        } else if (state === 'paused' || state === 'stopped' || state === 'completed') {
          this.isPlaying = false;
          this.stopProgressUpdate();
        }
      };
      
      this.mediaPlayer.onTimeUpdate = (time: number) => {
        this.currentTime = MediaPlayerUtil.formatTime(time);
        if (this.mediaPlayer && this.mediaPlayer.duration > 0) {
          this.progress = (time / this.mediaPlayer.duration) * 100;
        }
      };
      
      this.mediaPlayer.onDurationUpdate = (duration: number) => {
        this.totalTime = MediaPlayerUtil.formatTime(duration);
      };
      
      this.mediaPlayer.onError = (error) => {
        Logger.error('Media player error:', error.message);
        promptAction.showToast({
          message: '播放出错',
          duration: 2000
        });
        this.isPlaying = false;
      };
      
      // 加载音频
      if (this.audioInfo.audioUrl) {
        await this.mediaPlayer.loadAudioFromRaw(this.context, this.audioInfo.audioUrl);
        Logger.info('Audio loaded successfully');
      }
      
      this.isLoading = false;
    } catch (error) {
      Logger.error('Initialize player failed:', (error as Error).message);
      this.isLoading = false;
      promptAction.showToast({
        message: '音频加载失败，使用模拟播放',
        duration: 2000
      });
    }
  }
  
  // 清理播放器
  private cleanupPlayer() {
    this.stopProgressUpdate();
    if (this.mediaPlayer) {
      this.mediaPlayer.release();
      this.mediaPlayer = null;
    }
  }
  
  // 开始进度更新
  private startProgressUpdate() {
    this.stopProgressUpdate();
    // 定时刷新UI
    this.updateTimer = setInterval(() => {
      // 触发UI更新
    }, 100);
  }
  
  // 停止进度更新
  private stopProgressUpdate() {
    if (this.updateTimer !== -1) {
      clearInterval(this.updateTimer);
      this.updateTimer = -1;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()
      
      Column() {
        // 图片展示区
        Image(this.audioInfo.cover)
          .width('100%')
          .aspectRatio(1)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .margin({ top: 20 })

        // 播放控制区
        this.PlayerControlSection()

        // 详情介绍区
        this.DetailSection()
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // 顶部导航栏
  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text(this.audioInfo.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 8 })
        .layoutWeight(1)
      
      Text('🔗')
        .fontSize(20)
        .onClick(() => {
          // 分享功能
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  // 播放控制区
  @Builder PlayerControlSection() {
    Column() {
      // 进度条
      Slider({
        value: this.progress,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .trackThickness(4)
        .showTips(false)
        .blockColor('#0086f6')
        .trackColor('#e0e0e0')
        .selectedColor('#0086f6')
        .onChange((value: number) => {
          // 跳转到指定位置
          if (this.mediaPlayer && this.mediaPlayer.duration > 0) {
            const targetTime = (value / 100) * this.mediaPlayer.duration;
            this.mediaPlayer.seek(targetTime);
            this.progress = value;
          }
        })

      // 时间显示
      Row() {
        Text(this.currentTime)
          .fontSize(12)
          .fontColor('#666666')
        
        Text(this.totalTime)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      // 播放控制按钮
      Row() {
        // 后退15秒
        Column() {
          Text('⏪')
            .fontSize(24)
          Text('-15s')
            .fontSize(10)
            .fontColor('#666666')
        }
        .onClick(() => {
          this.seekBackward(15000);
        })

        // 播放/暂停按钮
        Text(this.isPlaying ? '⏸️' : '▶️')
          .fontSize(48)
          .onClick(() => {
            this.togglePlay();
          })

        // 前进15秒
        Column() {
          Text('⏩')
            .fontSize(24)
          Text('+15s')
            .fontSize(10)
            .fontColor('#666666')
        }
        .onClick(() => {
          this.seekForward(15000);
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 20 })
    .backgroundColor('#ffffff')
    .borderRadius(16)
  }

  // 详情介绍区
  @Builder DetailSection() {
    Column() {
      Row() {
        Text(this.audioInfo.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Row() {
          Text(this.isFavorite ? '⭐' : '☆')
            .fontSize(14)
          Text(this.isFavorite ? '已收藏' : '收藏')
            .fontSize(14)
            .fontColor('#0086f6')
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#e6f4ff')
        .borderRadius(14)
        .onClick(() => {
          this.toggleFavorite();
        })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text('景点详细介绍')
        .fontSize(14)
        .lineHeight(24)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      Text(this.getDetailDescription())
        .fontSize(14)
        .lineHeight(24)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
        .maxLines(10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 10 })
    .backgroundColor('#ffffff')
    .borderRadius(16)
  }

  // 切换播放状态
  private async togglePlay() {
    if (!this.mediaPlayer) {
      promptAction.showToast({
        message: '播放器未初始化',
        duration: 2000
      });
      return;
    }
    
    try {
      if (this.isPlaying) {
        await this.mediaPlayer.pause();
        Logger.info('Playback paused');
      } else {
        await this.mediaPlayer.play();
        Logger.info('Playback started');
      }
    } catch (error) {
      Logger.error('Toggle play failed:', (error as Error).message);
      promptAction.showToast({
        message: '播放控制失败',
        duration: 2000
      });
    }
  }
  
  // 快退
  private async seekBackward(ms: number) {
    if (!this.mediaPlayer) return;
    
    const targetTime = Math.max(0, this.mediaPlayer.currentTime - ms);
    await this.mediaPlayer.seek(targetTime);
  }
  
  // 快进
  private async seekForward(ms: number) {
    if (!this.mediaPlayer) return;
    
    const targetTime = Math.min(this.mediaPlayer.duration, this.mediaPlayer.currentTime + ms);
    await this.mediaPlayer.seek(targetTime);
  }
  
  // 切换收藏状态
  private toggleFavorite() {
    this.isFavorite = !this.isFavorite;
    promptAction.showToast({
      message: this.isFavorite ? '已添加到收藏' : '已取消收藏',
      duration: 2000
    });
  }

  // 获取详细描述
  private getDetailDescription(): string {
    return '这里是景点的详细介绍内容。包括景点的历史背景、文化内涵、建筑特色、游览建议等信息。' +
      '您可以通过语音讲解深入了解景点的故事和特色，获得更好的游览体验。';
  }
}
