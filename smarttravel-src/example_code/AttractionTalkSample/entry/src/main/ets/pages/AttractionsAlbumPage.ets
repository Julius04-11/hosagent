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

import {
  AttractionsAlbum,
  AttractionsAlbumParam,
  ATTRACTIONS_ALBUM,
  AUDIO_COMMENTARY_LIST,
  SingleAudioCommentary
} from '../model/AttractionsAlbumParam';
import { VoicePlayerComponent } from '../component/VoicePlayerComponent';
import MediaPlayer from '../utils/MediaPlayer';
import { common } from '@kit.AbilityKit';

@Builder
export function attractionsAlbumPageBuilder() {
  AttractionsAlbumPage();
}

@Component
struct AttractionsAlbumPage {
  private hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private uiContext = this.getUIContext();
  attractionsAlbumParam: AttractionsAlbumParam = {
    id: '-1',
    title: $r('app.string.ancient_chinese_architecture1')
  };
  attractionsAlbum: AttractionsAlbum = {
    id: '-1',
    title: $r('app.string.ancient_chinese_architecture1'),
    cover: $r('app.media.ancient_chinese_architecture1'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: []
  };
  summary: string = '';
  exhibit: string = '';
  scroller: Scroller = new Scroller();
  @State contentCount: number = 0;
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  async aboutToAppear(): Promise<void> {
    let instance: MediaPlayer = await MediaPlayer.getInstance();
    MediaPlayer.audioUrl = '';
    await instance.reset();
  }

  async aboutToDisappear(): Promise<void> {
    let instance: MediaPlayer = await MediaPlayer.getInstance();
    MediaPlayer.audioUrl = '';
    await instance.reset();
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        // 1.顶部导航栏
        Row() {
          Image($r('app.media.left'))
            .width(40)
            .height(40)
            .onClick(() => {
              this.pathStack.pop();
            });

          Image($r('app.media.share'))
            .width(24)
            .height(24);
        }
        .padding({
          left: 16,
          right: 16
        })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        // 2.景点专辑简介区
        Flex() {
          // 封面
          Image(this.attractionsAlbum.cover)
            .borderRadius(12)
            .width(140)
            .height(112);

          // 描述区
          Column() {
            Row() {
              // 标题
              Text(this.attractionsAlbum.title)
                .fontWeight(500)
                .fontSize(16)
                .lineHeight(19)
                .align(Alignment.Start)
                .fontColor('rgba(0, 0, 0, 0.9)')
                .padding({
                  right: 8
                });

              // 简介播放按钮
              Image($r('app.media.media_sound'))
                .width(24)
                .height(24);
            };

            // 简介展示
            Text(this.summary)
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(20)
              .align(Alignment.Start)
              .padding({
                top: 27
              })
              .fontColor('rgba(0, 0, 0, 0.7)')
              .maxLines(2)
              .textOverflow({
                overflow: TextOverflow.Clip
              });

            // 陈列展示
            Text(this.exhibit)
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(20)
              .align(Alignment.Start)
              .fontColor('rgba(0, 0, 0, 0.7)');
          }
          .width(1)
          .padding({
            left: 13
          })
          .flexGrow(1)
          .flexShrink(1)
          .flexBasis(1)
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .height(133)
        .padding({
          top: 7,
          bottom: 12,
          left: 16,
          right: 16
        });

        // 3.语音讲解区
        Flex({ direction: FlexDirection.Column }) {
          Row() {
            Row() {
              Text($r('app.string.Audio_Guide'))
                .fontWeight(400)
                .fontSize(18)
                .lineHeight(20)
                .align(Alignment.Start)
                .margin({
                  left: 15
                });

              Text(`（共${this.contentCount}条）`)
                .fontWeight(400)
                .fontSize(14)
                .lineHeight(20)
                .align(Alignment.Start);
            };


            Image($r('app.media.start_all'))
              .width('89')
              .margin({
                right: 16
              });
          }
          .padding({
            bottom: 4
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%');

          List({ initialIndex: 0, space: 0, scroller: this.scroller }) {
            ForEach(AUDIO_COMMENTARY_LIST,
              (item: SingleAudioCommentary, index: number) => {
                VoicePlayerComponent({
                  singleAudioCommentary: item,
                  index: index + 1,
                })
                  .height(64);
              });
          }
          .height('100%')
          .width('100%')
          .padding(10);
        }
        .padding({
          top: 22
        })
        .height(1)
        .backgroundColor(Color.White)
        .width('100%')
        .flexGrow(1)
        .flexShrink(1)
        .flexBasis(1)
        .borderRadius(16);
      };
    }
    .safeAreaPadding({
      top: this.uiContext.px2vp(this.topRectHeight)
    })
    .height('100%')
    .hideToolBar(true)
    .backgroundImage($r('app.media.series_background_pic'))
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.attractionsAlbumParam = context.pathInfo.param as AttractionsAlbumParam;
      // 查询专辑其他信息
      this.attractionsAlbum = ATTRACTIONS_ALBUM.find(item => item.id === this.attractionsAlbumParam.id)!;
      // 修改展示的简介与陈列信息
      this.summary = this.hostContext.resourceManager.getStringSync($r('app.string.brief').id) + ':' +
      this.hostContext.resourceManager.getStringSync(this.attractionsAlbum.summary.id);
      this.exhibit = this.hostContext.resourceManager.getStringSync($r('app.string.Exhibition').id) + ':' +
      this.hostContext.resourceManager.getStringSync(this.attractionsAlbum.exhibit.id);
      this.contentCount = this.attractionsAlbum.audioCommentaryList.length;

      MediaPlayer.playList = this.attractionsAlbum.audioCommentaryList;
    });
  }
}