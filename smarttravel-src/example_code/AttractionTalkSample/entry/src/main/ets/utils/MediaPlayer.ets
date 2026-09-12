/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { media } from '@kit.MediaKit';
import { SingleAudioCommentary } from '../model/AttractionsAlbumParam';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Logger from './Logger';

const PLAY_SINGLE: number = 0;

export default class MediaPlayer {
  // 单例实例
  private static instance: MediaPlayer | null;
  // avPlayer
  public avPlayer: media.AVPlayer | null = null;
  // 状态
  public static state: string = '';
  // 是否在详情页
  public static isDetailsPage: boolean = false;
  // 播放列表
  public static playList: SingleAudioCommentary[] = [];
  // 当前的音频id
  public static curAudioId: string = '';
  // 当前播放资源
  public static audioUrl: string = '';
  // 是否播放
  public static isPlaying: boolean = false;
  // 播放索引
  public static playIndex: number = 0;
  // 歌曲时长
  public static duration: number = 0;
  // 播放时长
  public static time: number = 0;
  // 播放模式: 0: 单曲播放； 1：全部播放. (默认单曲播放)
  public static playMode: number = PLAY_SINGLE;

  // 私有构造函数，防止外部实例化
  private constructor() {
  }

  // 获取单例实例的方法
  public static async getInstance(): Promise<MediaPlayer> {
    if (!MediaPlayer.instance) {
      MediaPlayer.instance = new MediaPlayer();
    }
    return MediaPlayer.instance;
  }

  // 初始化播放器
  public async initialize(context: common.UIAbilityContext, avPlayer: media.AVPlayer): Promise<void> {
    if (avPlayer) {
      this.avPlayer = avPlayer;
      this.setupCallbacks(context, this.avPlayer);
      return;
    }

    try {
      avPlayer = await media.createAVPlayer();
      this.setupCallbacks(context, avPlayer);
    } catch (error) {
      hilog.error(0x0000, 'MediaPlayer', `播放器初始化失败：${(error as BusinessError).message}`);
    }
  }

  private setupCallbacks(context: common.UIAbilityContext, avPlayer: media.AVPlayer): void {
    avPlayer.on('error', (err: BusinessError) => {
      MediaPlayer.instance?.reset(); // 调用reset重置资源，触发idle状态
    });

    avPlayer.on('stateChange', (state) => {
      MediaPlayer.state = state;
      switch (state) {
        case 'idle':
          Logger.info('idle');
          MediaPlayer.isPlaying = false;
          MediaPlayer.state = 'idle';

          if (MediaPlayer.audioUrl !== '') {
            let fileDescriptor = context.resourceManager.getRawFdSync(MediaPlayer.audioUrl);
            let avFileDescriptor: media.AVFileDescriptor =
              { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
            avPlayer.fdSrc = avFileDescriptor;
          }
          break;
        case 'initialized':
          Logger.info('initialized');
          MediaPlayer.state = 'initialized';
          avPlayer.prepare();
          break;
        case 'prepared':
          Logger.info('prepared');
          MediaPlayer.state = 'prepared';
          if (!MediaPlayer.isDetailsPage) {
            avPlayer.play();
          }
          break;
        case 'playing':
          MediaPlayer.isPlaying = true;
          MediaPlayer.state = 'playing';
          Logger.info('playing');
          break;
        case 'paused':
          Logger.info('paused');
          MediaPlayer.state = 'paused';
          MediaPlayer.isPlaying = false;
          break;
        case 'completed':
          Logger.info('completed');
          MediaPlayer.state = 'completed';
          MediaPlayer.isPlaying = false;
          MediaPlayer.time = 0;
          avPlayer.reset();
          break;
        case 'stopped':
          Logger.info('stopped');
          MediaPlayer.state = 'stopped';
          MediaPlayer.isPlaying = false;
          avPlayer.reset();
          break;
        case 'released':
          Logger.info('released');
          MediaPlayer.time = 0;
          MediaPlayer.state = 'released';
          MediaPlayer.isPlaying = false;
          break;
        case 'error':
          Logger.info('error');
          MediaPlayer.state = 'error';
          avPlayer.reset();
          break;
        default:
          Logger.info('state unknown');
          avPlayer.reset();
          break;
      }
    });

    avPlayer.on('seekDone', (seekDoneTime: number) => {
      MediaPlayer.time = seekDoneTime;
    });

    avPlayer.on('durationUpdate', (duration) => {
      MediaPlayer.duration = duration;
    });

    avPlayer.on('timeUpdate', (time) => {
      MediaPlayer.time = time;
    });
  }

  public async setAudioResourceFromRowFile(url: string, context: common.UIAbilityContext) {
    if (url === undefined) {
      return;
    }

    if (!this.avPlayer) {
      this.avPlayer = await this.getAVPlayer(context);
    }

    let fileDescriptor = context.resourceManager.getRawFdSync(url);
    let avFileDescriptor: media.AVFileDescriptor =
      { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
    this.avPlayer.fdSrc = avFileDescriptor;
  }

  public async playAudioFromRawFile(context: common.UIAbilityContext, url: string, id?: string) {
    if (url === undefined) {
      return;
    }

    if (id) {
      MediaPlayer.curAudioId = id;
    }

    if (!this.avPlayer) {
      this.avPlayer = await this.getAVPlayer(context);
    }

    await this.setAudioResourceFromRowFile(url, context);
  }

  public async prepare() {
    if (!this.avPlayer) {
      return;
    }

    await this.avPlayer.prepare();
  }

  // 播放函数
  public async play() {
    if (!this.avPlayer) {
      return;
    }
    await this.avPlayer.play();
  }

  public async pause() {
    if (!this.avPlayer || !MediaPlayer.isPlaying) {
      return;
    }

    try {
      await this.avPlayer.pause();
      // 使用MediaPlayer.curAudioId判断的情况 停止后下次从头播放
      MediaPlayer.curAudioId = '';
    } catch (error) {
      Logger.error(`暂停播放失败: ${(error as BusinessError).message}`);
    }
  }

  public async reset() {
    if (!this.avPlayer) {
      return;
    }
    await this.avPlayer.reset();
  }

  public async stop() {
    if (!this.avPlayer || !MediaPlayer.isPlaying) {
      return;
    }

    try {
      await this.avPlayer.stop();
      await this.avPlayer.reset();
      MediaPlayer.curAudioId = '';
    } catch (error) {
      Logger.error(`停止播放失败: ${(error as BusinessError).message}`);
    }
  }

  public async release() {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.stop();
      await this.avPlayer.release();
      this.avPlayer = null;
      MediaPlayer.instance = null;
    } catch (error) {
      Logger.error(`释放播放器失败: ${(error as BusinessError).message}`);
    }
  }

  public setPlayList(playList: SingleAudioCommentary[]) {
    MediaPlayer.playList = playList;
  }

  public getPlayList(): SingleAudioCommentary[] {
    return MediaPlayer.playList;
  }

  public setPlayIndex(index: number) {
    MediaPlayer.playIndex = index;
  }

  public getPlayIndex(): number {
    return MediaPlayer.playIndex;
  }

  public async getAVPlayer(context: common.UIAbilityContext): Promise<media.AVPlayer> {
    if (!this.avPlayer) {
      this.avPlayer = await media.createAVPlayer();
      this.setupCallbacks(context, this.avPlayer);
    }
    return this.avPlayer;
  }
};