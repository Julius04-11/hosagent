/*
 *
 *    Copyright (c) 2025 Huawei Device Co., Ltd.
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 *
 */

import { MemberShipData } from '@ohos/common'

const homeHeadText: Resource[] | String[] = [
  '门票',
  '年卡',
  '酒店',
  '增强服务',
  '交通出行'
]


const mainTabFirst: MemberShipData[] = [
  {
    index: 1,
    img: $r('app.media.home_picket'),
    title: '门票',
    action: 'CardPage'
  },
  {
    index: 0,
    img: $r('app.media.home_card'),
    title: '年卡',
    action: 'CardPage'
  },
  {
    index: 2,
    img: $r('app.media.home_hotel'),
    title: '酒店'
  },
  {
    index: 3,
    img: $r('app.media.home_vip'),
    title: '尊享服务'
  },
  {
    index: 4,
    img: $r('app.media.home_tran'),
    title: '交通出行',
  }
]


const homeTabSecond: MemberShipData[] = [
  {
    index: 0,
    img: $r('app.media.home_time'),
    title: '项目时间'
  },
  {
    index: 1,
    img: $r('app.media.home_car'),
    title: '小电车'
  },
  {
    index: 2,
    img: $r('app.media.home_dinner'),
    title: '自助点餐'
  },
  {
    index: 3,
    img: $r('app.media.home_line'),
    title: '云排队'
  },
  {
    index: 4,
    img: $r('app.media.home_money'),
    title: '停车缴费'
  }
]

const playBookData: MemberShipData[] = [
  {
    index: 0,
    title: '合家游攻略',
    subTitle: '合家欢篇',
    bgImg: $r('app.media.home_family'),
    action: 'TravelTips'
  },
  {
    index: 1,
    title: '情侣游攻略',
    subTitle: '情侣篇',
    bgImg: $r('app.media.home_loves'),
    action: 'TravelTips'
  },
  {
    index: 2,
    title: '闺蜜游攻略',
    subTitle: '闺蜜篇',
    bgImg: $r('app.media.home_friend'),
    action: 'TravelTips'
  },
  {
    index: 3,
    title: '亲子游攻略',
    subTitle: '亲子篇',
    bgImg: $r('app.media.home_qinzi'),
    action: 'TravelTips'
  }
]


const parkVisitingData: MemberShipData[] = [
  {
    index: 0,
    img: $r('app.media.play_time'),
    title: '项目时间',
    action: ''
  },
  {
    index: 1,
    img: $r('app.media.play_vip'),
    title: '尊享服务',
    action: ''
  },
  {
    index: 2,
    img: $r('app.media.play_mall'),
    title: '乐园商城'
  },
  {
    index: 3,
    img: $r('app.media.play_heart'),
    title: '我的收藏'
  },
  {
    index: 4,
    img: $r('app.media.play_notice'),
    title: '我的提醒'
  }
]

const swiperImage: Resource[] = [
  $r('app.media.bg2x'),
  $r('app.media.bg3x'),
  $r('app.media.bg1x'),
  $r('app.media.bg')
]

const swiperImage2: Resource[] = [
  $r('app.media.swip')
]

const middleSwiperImage: Resource[] = [
  $r('app.media.startIcon'),
  $r('app.media.startIcon'),
  $r('app.media.startIcon'),
  $r('app.media.startIcon')
]

class ActivityTitleModel {
  title?: Resource | string
  desc?: Resource
  image?: Resource
}

const activityTitle: ActivityTitleModel[] = [
  {
    title: '乘客超市',
    image: $r('app.media.startIcon')
  },
  {
    title: '抱抱商城',
    image: $r('app.media.startIcon')
  },
  {
    title: '停车场',
    image: $r('app.media.startIcon')
  },
  {
    title: '优惠乘车',
    image: $r('app.media.startIcon')
  },
  {
    title: '外卖红包',
    image: $r('app.media.startIcon')
  },
  {
    title: '地铁e站',
    image: $r('app.media.startIcon')
  }
]
const adsList: Resource[] = [
  $r("app.media.startIcon"),
  $r('app.media.startIcon'),
  $r('app.media.startIcon')
]

export {
  homeHeadText,
  swiperImage,
  middleSwiperImage,
  activityTitle,
  ActivityTitleModel,
  adsList,
  mainTabFirst,
  homeTabSecond,
  parkVisitingData,
  playBookData,
  swiperImage2
}