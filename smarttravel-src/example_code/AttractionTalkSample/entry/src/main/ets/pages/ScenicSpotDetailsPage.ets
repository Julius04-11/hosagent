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
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function scenicSpotDetailsPageBuilder() {
  ScenicSpotDetailsPage();
}

@Component
struct ScenicSpotDetailsPage {
  pathStack: NavPathStack = new NavPathStack();
  singleAudioCommentary: SingleAudioCommentary = {
    id: '',
    title: $r('app.string.ancient_chinese_architecture1'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 0,
    playCount: 0,
    audioResource: 'example1.mp3'
  };
  instance: MediaPlayer | null = null;
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  timer: number | undefined = -1;
  @State time: number = 0;
  @State duration: number = 0;
  @State timeStr: string = '00:00:00';
  @State durationStr: string = '00:00:00';
  @State isPlaying: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  async aboutToAppear(): Promise<void> {
    this.isPlaying = false;
    MediaPlayer.isDetailsPage = true;
    AppStorage.setOrCreate('curAudioId', '');

    this.instance = await MediaPlayer.getInstance();

    MediaPlayer.audioUrl = this.singleAudioCommentary.audioResource;
    MediaPlayer.curAudioId = this.singleAudioCommentary.id;
    await this.instance.setAudioResourceFromRowFile(this.singleAudioCommentary.audioResource, this.context);

    this.timer = setInterval(() => {
      this.time = MediaPlayer.time;
      this.timeStr = this.formatTime(this.time);

      if (MediaPlayer.state === 'playing') {
        this.isPlaying = true;
      } else {
        this.isPlaying = false;
      }
    }, 500);
  }

  async aboutToDisappear(): Promise<void> {
    MediaPlayer.time = 0;
    MediaPlayer.duration = 0;
    AppStorage.setOrCreate('curAudioId', '');
    MediaPlayer.curAudioId = '';
    MediaPlayer.audioUrl = '';
    await this.instance?.reset();
    MediaPlayer.isDetailsPage = false;
    this.isPlaying = false;
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = undefined;
    }
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, }) {
        // 顶部工具栏
        Row() {
          Row() {
            Image($r('app.media.left'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.pathStack.pop();
              });

            Text(this.singleAudioCommentary.title)
              .fontWeight(700)
              .fontSize(20)
              .lineHeight(27)
              .align(Alignment.Start)
              .fontColor('rgba(0, 0, 0, 0.9)')
              .margin({
                left: 8
              });
          };

          Image($r('app.media.share'))
            .width(24)
            .height(24);
        }
        .height('58')
        .width('341')
        .justifyContent(FlexAlign.SpaceBetween);

        // 图片展示区
        Image(this.singleAudioCommentary.cover)
          .width('343')
          .height('343')
          .borderRadius(16)
          .margin({
            top: 10
          });

        // 播放区
        Column() {
          Slider({
            value: this.time,
            min: 0,
            max: this.duration,
            style: SliderStyle.OutSet
          })
            .padding({
              left: 10,
              right: 10,
              top: 0,
              bottom: 0
            })
            .showTips(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.time = value;
              this.instance?.avPlayer?.seek(this.time);
            });

          Row() {
            Text(this.timeStr)
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(14)
              .align(Alignment.Center)
              .fontColor('rgba(0, 0, 0, 0.7)');

            Text(this.durationStr)
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(14)
              .align(Alignment.Center)
              .fontColor('rgba(0, 0, 0, 0.7)');
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .padding({
            left: 20,
            right: 20,
            top: 0,
            bottom: 0
          });

          Row() {
            Image($r('app.media.go_backward_15'))
              .width('24')
              .height('24');

            Image(this.isPlaying ? $r('app.media.playing_big') : $r('app.media.play_circle_fill'))
              .width('48')
              .height('48')
              .margin({
                bottom: 20
              })
              .onClick(async () => {
                if (!this.instance) {
                  this.instance = await MediaPlayer.getInstance();
                }

                hilog.info(0x0000, 'ScenicSpotDetailsPage', `${MediaPlayer.state}`);

                if (this.isPlaying) {
                  this.isPlaying = false;
                  await this.instance.pause();
                } else {
                  if (MediaPlayer.state === 'prepared' || MediaPlayer.state === 'paused' ||
                    MediaPlayer.state === 'stopped' || MediaPlayer.state === 'completed') {
                    await this.instance.play();
                    this.isPlaying = true;
                  } else if (MediaPlayer.state === 'idle') {
                    MediaPlayer.audioUrl = this.singleAudioCommentary.audioResource;
                    MediaPlayer.curAudioId = this.singleAudioCommentary.id;
                    await this.instance.setAudioResourceFromRowFile(this.singleAudioCommentary.audioResource,
                      this.context);
                  }
                }
              });

            Image($r('app.media.go_forward_15'))
              .width('24')
              .height('24');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly);
        }
        .backgroundColor('rgb(255, 255, 255)')
        .borderRadius(16)
        .height('122')
        .margin({
          top: 10
        })
        .justifyContent(FlexAlign.Center);

        // 详情介绍区
        Column() {
          Row() {
            Text($r('app.string.temple_of_heaven'))
              .fontWeight(400)
              .fontSize(16)
              .lineHeight(19)
              .align(Alignment.Center)
              .fontColor('rgba(0, 0, 0, 0.9)');

            Image($r('app.media.coll'))
              .width('72')
              .height('28')
              .borderRadius(14);
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            right: 10,
            left: 10
          })
          .margin({
            bottom: 5
          })
          .width('100%');

          Text($r('app.string.details_instruction'))
            .fontWeight(400)
            .fontSize(14)
            .lineHeight(24)
            .align(Alignment.Start)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .padding({
              right: 10,
              left: 10
            })
            .maxLines(9)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            });
        }
        .backgroundColor('rgb(255, 255, 255)')
        .borderRadius(16)
        .height('306')
        .margin({
          top: 10
        })
        .padding({
          top: 16,
          right: 10,
          left: 10
        });
      }
      .height('100%')
      .width('100%');
    }
    .height('100%')
    .padding({
      right: 16,
      left: 16
    })
    .safeAreaPadding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .hideTitleBar(true)
    .backgroundColor('rgb(241, 243, 245)')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.singleAudioCommentary = context.pathInfo.param as SingleAudioCommentary;
      this.duration = this.singleAudioCommentary.duration;
      this.durationStr = this.formatTime(this.singleAudioCommentary.duration);
    });
  }

  private formatTime(ms: number): string {
    if (ms < 0) {
      return '00:00:00';
    }

    let hours: string = Math.floor(ms / 3600000).toString().padStart(2, '0');
    let minutes: string = Math.floor((ms % 3600000) / 60000).toString().padStart(2, '0');
    let seconds: string = Math.floor((ms % 60000) / 1000).toString().padStart(2, '0');

    let res: string = '';
    res = util.format('%s:%s:%s', hours, minutes, seconds);
    return res;
  }
}