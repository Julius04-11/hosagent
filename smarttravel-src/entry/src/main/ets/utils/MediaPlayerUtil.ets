/**
 * 媒体播放器工具类
 * 用于音频播放控制
 */
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import Logger from './Logger';

export class MediaPlayerUtil {
  private static instance: MediaPlayerUtil | null = null;
  private avPlayer: media.AVPlayer | null = null;
  
  // 播放状态
  public isPlaying: boolean = false;
  public duration: number = 0;
  public currentTime: number = 0;
  public state: string = 'idle';
  
  // 回调函数
  public onStateChange?: (state: string) => void;
  public onTimeUpdate?: (time: number) => void;
  public onDurationUpdate?: (duration: number) => void;
  public onError?: (error: BusinessError) => void;

  private constructor() {}

  public static getInstance(): MediaPlayerUtil {
    if (!MediaPlayerUtil.instance) {
      MediaPlayerUtil.instance = new MediaPlayerUtil();
    }
    return MediaPlayerUtil.instance;
  }

  /**
   * 初始化播放器
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    if (this.avPlayer) {
      return;
    }

    try {
      this.avPlayer = await media.createAVPlayer();
      this.setupCallbacks(context);
      Logger.info('MediaPlayer initialized successfully');
    } catch (error) {
      Logger.error(`Failed to initialize MediaPlayer: ${(error as BusinessError).message}`);
      if (this.onError) {
        this.onError(error as BusinessError);
      }
    }
  }

  /**
   * 设置回调函数
   */
  private setupCallbacks(context: common.UIAbilityContext): void {
    if (!this.avPlayer) return;

    // 错误处理
    this.avPlayer.on('error', (err: BusinessError) => {
      Logger.error(`MediaPlayer error: ${err.message}`);
      this.reset();
      if (this.onError) {
        this.onError(err);
      }
    });

    // 状态变化
    this.avPlayer.on('stateChange', (state) => {
      this.state = state;
      Logger.info(`MediaPlayer state changed to: ${state}`);
      
      if (this.onStateChange) {
        this.onStateChange(state);
      }

      switch (state) {
        case 'initialized':
          this.avPlayer?.prepare();
          break;
        case 'prepared':
          // 准备完成，可以播放
          break;
        case 'playing':
          this.isPlaying = true;
          break;
        case 'paused':
        case 'stopped':
        case 'completed':
          this.isPlaying = false;
          break;
      }
    });

    // 时长更新
    this.avPlayer.on('durationUpdate', (duration) => {
      this.duration = duration;
      if (this.onDurationUpdate) {
        this.onDurationUpdate(duration);
      }
    });

    // 播放进度更新
    this.avPlayer.on('timeUpdate', (time) => {
      this.currentTime = time;
      if (this.onTimeUpdate) {
        this.onTimeUpdate(time);
      }
    });

    // 跳转完成
    this.avPlayer.on('seekDone', (seekDoneTime: number) => {
      this.currentTime = seekDoneTime;
    });
  }

  /**
   * 从raw资源加载音频
   */
  public async loadAudioFromRaw(context: common.UIAbilityContext, url: string): Promise<void> {
    if (!this.avPlayer) {
      await this.initialize(context);
    }

    if (!this.avPlayer) {
      throw new Error('AVPlayer not initialized');
    }

    try {
      const fileDescriptor = context.resourceManager.getRawFdSync(url);
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.avPlayer.fdSrc = avFileDescriptor;
      Logger.info(`Audio loaded from raw: ${url}`);
    } catch (error) {
      const bizError = error as BusinessError;
      Logger.error(`Failed to load audio: ${bizError.message}`);
      throw new Error(bizError.message);
    }
  }

  /**
   * 播放
   */
  public async play(): Promise<void> {
    if (!this.avPlayer) {
      Logger.warn('AVPlayer not initialized');
      return;
    }

    try {
      await this.avPlayer.play();
      Logger.info('Playback started');
    } catch (error) {
      Logger.error(`Failed to play: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 暂停
   */
  public async pause(): Promise<void> {
    if (!this.avPlayer || !this.isPlaying) {
      return;
    }

    try {
      await this.avPlayer.pause();
      Logger.info('Playback paused');
    } catch (error) {
      Logger.error(`Failed to pause: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 停止
   */
  public async stop(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.avPlayer.stop();
      await this.avPlayer.reset();
      Logger.info('Playback stopped');
    } catch (error) {
      Logger.error(`Failed to stop: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 跳转到指定位置
   */
  public async seek(time: number): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.avPlayer.seek(time);
      Logger.info(`Seeked to: ${time}ms`);
    } catch (error) {
      Logger.error(`Failed to seek: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 重置播放器
   */
  public async reset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.avPlayer.reset();
      this.currentTime = 0;
      this.isPlaying = false;
      Logger.info('Player reset');
    } catch (error) {
      Logger.error(`Failed to reset: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 释放播放器资源
   */
  public async release(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.stop();
      await this.avPlayer.release();
      this.avPlayer = null;
      MediaPlayerUtil.instance = null;
      Logger.info('Player released');
    } catch (error) {
      Logger.error(`Failed to release: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 设置音量
   */
  public async setVolume(volume: number): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      const normalizedVolume = Math.max(0, Math.min(1, volume));
      await this.avPlayer.setVolume(normalizedVolume);
    } catch (error) {
      Logger.error(`Failed to set volume: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 获取当前播放进度百分比
   */
  public getProgress(): number {
    if (this.duration === 0) {
      return 0;
    }
    return (this.currentTime / this.duration) * 100;
  }

  /**
   * 格式化时间（毫秒转分:秒）
   */
  public static formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
