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

import { SingleAudioCommentary } from '../model/AttractionsAlbumParam';
import MediaPlayer from '../utils/MediaPlayer';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';

@Component
export struct VoicePlayerComponent {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  indexTitle: string = '';
  durationStr: string = '';
  @Prop singleAudioCommentary: SingleAudioCommentary;
  @Prop index: number;
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('curAudioId') curAudioId: string = '';
  @Watch('network') @StorageLink('isForeGround') isForeGround: boolean = false;

  async network(changedPropertyName: string) {
    if (this.isForeGround) {
      AppStorage.setOrCreate('curAudioId', '');
    } else {
      AppStorage.setOrCreate('curAudioId', '');
      MediaPlayer.curAudioId = '';
      MediaPlayer.state = 'stopped';
      MediaPlayer.isPlaying = false;
      MediaPlayer.audioUrl = '';
    }
  }

  aboutToAppear(): void {
    this.indexTitle =
      `${this.index}.  ${this.context.resourceManager.getStringSync(this.singleAudioCommentary.title.id)}`;
    MediaPlayer.audioUrl = '';
    AppStorage.setOrCreate('curAudioId', '');
  }

  async aboutToDisappear(): Promise<void> {
    let instance: MediaPlayer = await MediaPlayer.getInstance();
    MediaPlayer.audioUrl = '';
    await instance.reset();
    AppStorage.setOrCreate('curAudioId', '');
  }

  onPageShow(): void {
    AppStorage.setOrCreate('curAudioId', '');
  }

  onPageHide(): void {
    AppStorage.setOrCreate('curAudioId', '');
  }

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Text(this.indexTitle)
          .fontWeight(400)
          .fontSize(16)
          .lineHeight(19)
          .align(Alignment.Start)
          .fontColor(this.curAudioId === this.singleAudioCommentary.id ?
            'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)');

        Row() {
          Image($r('app.media.duration_icon_default'))
            .width(13)
            .height(13)
            .fillColor(this.curAudioId === this.singleAudioCommentary.id ?
              'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)');
          Text(`${this.formatTime(this.singleAudioCommentary.duration)}`)
            .fontSize(10)
            .fontColor(this.curAudioId === this.singleAudioCommentary.id ?
              'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)')
            .padding({ left: 6 });

          Image($r('app.media.play_count_icon_default'))
            .width(13)
            .height(13)
            .margin({
              left: 18
            })
            .fillColor(this.curAudioId === this.singleAudioCommentary.id ?
              'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)');

          Text($r('app.string.play_count_default'))
            .fontSize(10)
            .fontColor('rgba(0, 0, 0, 0.7)')
            .padding({
              left: 6
            })
            .fontColor(this.curAudioId === this.singleAudioCommentary.id ?
              'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)');
        }
        .padding({ left: 22 });
      }
      .height('100%')
      .flexGrow(1)
      .flexShrink(1)
      .flexBasis(1)
      .onClick(async () => {
        let instance: MediaPlayer = await MediaPlayer.getInstance();
        if (MediaPlayer.isPlaying) {
          instance.reset();
        }
        this.pathStack.pushPath({
          name: 'ScenicSpotDetailsPage',
          param: this.singleAudioCommentary
        });
      });

      Image(this.curAudioId === this.singleAudioCommentary.id ?
        $r('app.media.item_pause_play') : $r('app.media.item_start_play'))
        .fillColor(this.curAudioId === this.singleAudioCommentary.id ?
          'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.9)')
        .width(24)
        .height(24)
        .margin({
          right: 10
        })
        .onClick(async () => {
          hilog.info(0x0000, 'VoicePlayerComponent',
            `检测到点击事件: ${this.context.resourceManager.getStringSync(this.singleAudioCommentary.title.id)}`);

          let instance: MediaPlayer = await MediaPlayer.getInstance();
          await instance.getAVPlayer(this.context);
          if (MediaPlayer.state === 'playing' && MediaPlayer.curAudioId === this.singleAudioCommentary.id) {
            // 播放中且当前ID就是点击ID 停止
            await instance.pause();
          } else if (MediaPlayer.state === 'playing' && MediaPlayer.curAudioId !== this.singleAudioCommentary.id) {
            // 播放中且当前ID不是点击ID 重置播放器 重新加载播放资源
            MediaPlayer.audioUrl = this.singleAudioCommentary.audioResource;
            MediaPlayer.curAudioId = this.singleAudioCommentary.id;
            await instance.reset();
          } else if (MediaPlayer.state === 'paused' && MediaPlayer.curAudioId === this.singleAudioCommentary.id) {
            // 当前歌曲 且是停止播放 继续播放
            await instance.play();
          } else if (MediaPlayer.state === 'paused' && MediaPlayer.curAudioId !== this.singleAudioCommentary.id) {
            // 停止状态且播放另一首
            MediaPlayer.audioUrl = this.singleAudioCommentary.audioResource;
            MediaPlayer.curAudioId = this.singleAudioCommentary.id;
            await instance.reset();
          } else {
            // 第一次播放
            MediaPlayer.audioUrl = this.singleAudioCommentary.audioResource;
            MediaPlayer.curAudioId = this.singleAudioCommentary.id;
            instance.setAudioResourceFromRowFile(this.singleAudioCommentary.audioResource,
              this.context);
          }
          AppStorage.setOrCreate('curAudioId', MediaPlayer.curAudioId);
        });
    }
    .height('100%')
    .width('100%')
    .padding({
      top: 13,
      bottom: 14,
      left: 5,
      right: 0
    })
    .border({
      width: {
        bottom: 0.5,
        top: 0,
        left: 0,
        right: 0
      },
      color: $r('sys.color.mask_fourth')
    });
  }

  private formatTime(ms: number): string {
    if (ms < 0) {
      return '00:00';
    }

    let totalSeconds = Math.floor(ms / 1000);
    let hours = Math.floor(totalSeconds / 3600);
    let minutes = Math.floor((totalSeconds % 3600) / 60);
    let seconds = totalSeconds % 60;

    if (hours > 0) {
      let hoursStr: string = String(hours).padStart(2, '0');
      let minutesStr: string = String(minutes).padStart(2, '0');
      let secondsStr: string = String(seconds).padStart(2, '0');
      return util.format(`%s:%s:%s`, hoursStr, minutesStr, secondsStr);
    } else {
      let minutesStr: string = String(minutes).padStart(2, '0');
      let secondsStr: string = String(seconds).padStart(2, '0');
      return util.format(`%s:%s`, minutesStr, secondsStr);
    }
  }
}