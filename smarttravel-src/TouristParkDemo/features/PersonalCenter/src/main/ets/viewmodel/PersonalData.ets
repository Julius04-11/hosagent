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

import { MemberShipData } from '@ohos/common';
import { MineListModel } from './MineListModel';

const memberShip: MemberShipData[] = [
  {
    index: 0,
    img: $r('app.media.all_order'),
    title: '全部订单'
  },
  {
    index: 1,
    img: $r('app.media.order_pay'),
    title: '待支付'
  },
  {
    index: 2,
    img: $r('app.media.order_use'),
    title: '待使用'
  },
  {
    index: 3,
    img: $r('app.media.order_back'),
    title: '退款'
  }
]


const memberShipPaper: MemberShipData[] = [

  {
    index: 4,
    img: $r('app.media.youhui'),
    title: '优惠券'
  },
  {
    index: 5,
    img: $r('app.media.lingquan'),
    title: '领券中心'
  }
]

const memberShipInter: MemberShipData[] = [

  {
    index: 1,
    img: $r('app.media.order_yunpaidui'),
    title: '云排队码'
  },
  {
    index: 2,
    img: $r('app.media.order_zunxiang'),
    title: '尊享服务'
  },
  {
    index: 3,
    img: $r('app.media.order_yuyue'),
    title: '入园预约码'
  }
]


const moreFunction: MemberShipData[] = [
  {
    index: 0,
    img: $r("app.media.order_person"),
    title: '常用游客'
  },
  {
    index: 1,
    img: $r('app.media.order_mark'),
    title: '我的收藏'
  },
  {
    index: 2,
    img: $r('app.media.order_notice'),
    title: '我的提醒'
  },
  {
    index: 3,
    img: $r('app.media.order_invite'),
    title: '邀请好友'
  },
  {
    index: 4,
    img: $r('app.media.order_kefu'),
    title: '客服中心'
  },
  {
    index: 5,
    img: $r('app.media.order_comment'),
    title: '意见反馈'
  },
  {
    index: 6,
    img: $r('app.media.order_shoukuan'),
    title: '收款账单'
  }
]

const listModel: MineListModel[] = [
  new MineListModel(
    $r('app.media.ic_credit_card'),
    $r('app.string.mine_title_about'),
    "1",
    "/aboutUs"
  ),
  new MineListModel(
    $r('app.media.ic_credit_card'),
    $r('app.string.update_password'),
    "2",
    "/updatePwd"
  ),
  new MineListModel(
    $r('app.media.ic_credit_card'),
    $r('app.string.mine_title_quit'),
    "3",
    "/logout"
  )
]

export { listModel, memberShip, memberShipPaper, memberShipInter, moreFunction };
