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

// 单条语音讲解
export interface SingleAudioCommentary {
  id: string;
  title: Resource;
  cover: Resource;
  duration: number;
  playCount: number;
  audioResource: string;
}

// 景点专辑参数
export interface AttractionsAlbumParam {
  id: string;
  title: Resource;
}

// 景点专辑数据结构
export interface AttractionsAlbum {
  id: string;
  title: Resource;
  cover: Resource;
  summary: Resource;
  exhibit: Resource;
  audioCommentaryList: SingleAudioCommentary[];
}

export const AUDIO_COMMENTARY_LIST: SingleAudioCommentary[] = [
  {
    id: '0',
    title: $r('app.string.temple_of_heaven'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example1.mp3'
  },
  {
    id: '1',
    title: $r('app.string.bell_and_drum_tower'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example2.mp3'
  },
  {
    id: '2',
    title: $r('app.string.ming_tombs'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example3.mp3'
  },
  {
    id: '3',
    title: $r('app.string.white_horse_temple'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example4.mp3'
  },
  {
    id: '4',
    title: $r('app.string.chongfu_temple'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example5.mp3'
  },
  {
    id: '5',
    title: $r('app.string.suzhou_classical_gardens'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example6.mp3'
  },
  {
    id: '6',
    title: $r('app.string.summer_palace'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example7.mp3'
  },
  {
    id: '7',
    title: $r('app.string.wang_family_courtyard'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example8.mp3'
  },
  {
    id: '8',
    title: $r('app.string.terracotta_army'),
    cover: $r('app.media.temple_of_heaven'),
    duration: 61000,
    playCount: 50,
    audioResource: 'example9.mp3'
  }
];

// 景点专辑数据
export const ATTRACTIONS_ALBUM: AttractionsAlbum[] = [
  {
    id: '0',
    title: $r('app.string.ancient_chinese_architecture1'),
    cover: $r('app.media.ancient_chinese_architecture1'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: AUDIO_COMMENTARY_LIST
  },
  {
    id: '1',
    title: $r('app.string.ancient_chinese_architecture2'),
    cover: $r('app.media.ancient_chinese_architecture2'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: AUDIO_COMMENTARY_LIST
  },
  {
    id: '2',
    title: $r('app.string.ancient_chinese_architecture3'),
    cover: $r('app.media.ancient_chinese_architecture3'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: AUDIO_COMMENTARY_LIST
  },
  {
    id: '3',
    title: $r('app.string.ancient_chinese_architecture4'),
    cover: $r('app.media.ancient_chinese_architecture4'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: AUDIO_COMMENTARY_LIST
  },
  {
    id: '4',
    title: $r('app.string.ancient_chinese_architecture5'),
    cover: $r('app.media.ancient_chinese_architecture5'),
    summary: $r('app.string.ancient_chinese_architecture_description'),
    exhibit: $r('app.string.ancient_chinese_architecture_exhibit'),
    audioCommentaryList: AUDIO_COMMENTARY_LIST
  }
];