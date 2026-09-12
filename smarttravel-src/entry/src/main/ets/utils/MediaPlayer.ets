import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 音频播放工具类
 * 基于AVPlayer实现音频播放功能
 * 支持从rawfile资源文件播放音频
 */
export default class MediaPlayer {
  private static instance: MediaPlayer | null = null;
  private avPlayer: media.AVPlayer | null = null;
  public static state: string = 'idle';
  public static time: number = 0;
  public static duration: number = 0;
  public static audioUrl: string = '';
  public static curAudioId: string = '';

  private constructor() {
    this.initAVPlayer().catch((error: Error) => {
      console.error('构造函数中初始化AVPlayer失败:', error);
    });
  }

  /**
   * 获取MediaPlayer单例实例
   */
  public static async getInstance(): Promise<MediaPlayer> {
    if (!MediaPlayer.instance) {
      MediaPlayer.instance = new MediaPlayer();
    }
    return MediaPlayer.instance;
  }

  /**
   * 初始化AVPlayer
   */
  private async initAVPlayer(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.setupEventListeners();
    } catch (error) {
      console.error('初始化AVPlayer失败:', error);
    }
  }

  /**
   * 设置事件监听器
   */
  private setupEventListeners(): void {
    if (!this.avPlayer) {
      return;
    }

    // 监听状态变化
    this.avPlayer.on('stateChange', (state: string) => {
      MediaPlayer.state = state;
      console.info('AVPlayer state changed to:', state);
    });

    // 监听时间更新
    this.avPlayer.on('timeUpdate', (time: number) => {
      MediaPlayer.time = time;
    });

    // 监听时长更新
    this.avPlayer.on('durationUpdate', (duration: number) => {
      MediaPlayer.duration = duration;
    });

    // 监听播放完成
    this.avPlayer.on('endOfStream', () => {
      MediaPlayer.state = 'completed';
      console.info('音频播放完成');
    });

    // 监听错误
    this.avPlayer.on('error', (error: BusinessError) => {
      console.error('AVPlayer error:', error);
      MediaPlayer.state = 'error';
    });
  }

  /**
   * 从rawfile资源文件设置音频资源
   * @param url 资源文件路径（相对于rawfile目录）
   * @param context UIAbility上下文
   */
  public async setAudioResourceFromRowFile(url: string, context: common.UIAbilityContext): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      const fileDescriptor = context.resourceManager.getRawFdSync(url);
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.avPlayer.fdSrc = avFileDescriptor;
      MediaPlayer.audioUrl = url;
      await this.avPlayer.prepare();
      MediaPlayer.state = 'prepared';
      console.info('音频资源设置成功:', url);
    } catch (error) {
      console.error('设置音频资源失败:', error);
      MediaPlayer.state = 'error';
      throw new Error(`设置音频资源失败: ${error}`);
    }
  }

  /**
   * 从网络URL设置音频资源
   * @param url 音频URL
   */
  public async setAudioResourceFromUrl(url: string): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      this.avPlayer.url = url;
      MediaPlayer.audioUrl = url;
      await this.avPlayer.prepare();
      MediaPlayer.state = 'prepared';
      console.info('音频资源设置成功:', url);
    } catch (error) {
      console.error('设置音频资源失败:', error);
      MediaPlayer.state = 'error';
      throw new Error(`设置音频资源失败: ${error}`);
    }
  }

  /**
   * 播放音频
   */
  public async play(): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      await this.avPlayer.play();
      MediaPlayer.state = 'playing';
      console.info('开始播放音频');
    } catch (error) {
      console.error('播放失败:', error);
      throw new Error(`播放失败: ${error}`);
    }
  }

  /**
   * 暂停播放
   */
  public async pause(): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      await this.avPlayer.pause();
      MediaPlayer.state = 'paused';
      console.info('暂停播放');
    } catch (error) {
      console.error('暂停失败:', error);
      throw new Error(`暂停失败: ${error}`);
    }
  }

  /**
   * 停止播放
   */
  public async stop(): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      await this.avPlayer.stop();
      MediaPlayer.state = 'idle';
      MediaPlayer.time = 0;
      console.info('停止播放');
    } catch (error) {
      console.error('停止失败:', error);
      throw new Error(`停止失败: ${error}`);
    }
  }

  /**
   * 跳转到指定位置
   * @param time 时间位置（毫秒）
   */
  public async seek(time: number): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      await this.avPlayer.seek(time);
      console.info('跳转到位置:', time);
    } catch (error) {
      console.error('跳转失败:', error);
      throw new Error(`跳转失败: ${error}`);
    }
  }

  /**
   * 设置音量
   * @param volume 音量值（0.0-1.0）
   */
  public setVolume(volume: number): void {
    if (!this.avPlayer) {
      console.error('AVPlayer未初始化');
      return;
    }

    try {
      // Volume control is not directly available on AVPlayer
      // Use system volume control instead
      console.info('音量设置请求:', volume);
      console.warn('AVPlayer不支持直接音量控制，请使用系统音量');
    } catch (error) {
      console.error('设置音量失败:', error);
    }
  }

  /**
   * 释放资源
   */
  public release(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.release();
        this.avPlayer = null;
        MediaPlayer.state = 'idle';
        MediaPlayer.time = 0;
        MediaPlayer.duration = 0;
        MediaPlayer.audioUrl = '';
        MediaPlayer.curAudioId = '';
        console.info('释放AVPlayer资源');
      } catch (error) {
        console.error('释放资源失败:', error);
      }
    }
  }

  /**
   * 获取当前播放状态
   */
  public getState(): string {
    return MediaPlayer.state;
  }

  /**
   * 获取当前播放时间
   */
  public getCurrentTime(): number {
    return MediaPlayer.time;
  }

  /**
   * 获取总时长
   */
  public getDuration(): number {
    return MediaPlayer.duration;
  }
}
