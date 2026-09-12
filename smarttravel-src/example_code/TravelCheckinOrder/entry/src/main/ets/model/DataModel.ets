/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
import { OrderStatus, OrderType } from './CommonEnum';
import { ArrayList } from '@kit.ArkTS';
import { systemDateTime } from '@kit.BasicServicesKit';

export interface OrderTabModel {
  index: number;
  title: ResourceStr;
  orderType: OrderType;
}

export const CUSTOM_TABS: OrderTabModel[] = [
  { index: 0, title: $r('app.string.all_orders_tab_title'), orderType: OrderType.ALL },
  { index: 1, title: $r('app.string.paying_orders_tab_title'), orderType: OrderType.PAYING },
  { index: 2, title: $r('app.string.staying_orders_tab_title'), orderType: OrderType.STAYING },
  { index: 3, title: $r('app.string.commenting_orders_tab_title'), orderType: OrderType.COMMENTING }
];

@Observed
export class Order {
  orderId: string;
  hotelName: string;
  hotelImage: Resource;
  title: string;
  prodImage: Resource;
  startDate: Date;
  endDate: Date;
  payment: number;
  status: OrderStatus;
  createTime: number;

  constructor(orderId: string, hotelName: string, hotelImage: Resource, title: string, prodImage: Resource,
    startDate: Date, endDate: Date, payment: number, status: OrderStatus, createTime: number) {
    this.orderId = orderId;
    this.hotelName = hotelName;
    this.hotelImage = hotelImage;
    this.title = title;
    this.prodImage = prodImage;
    this.startDate = startDate;
    this.endDate = endDate;
    this.payment = payment;
    this.status = status;
    this.createTime = createTime;
  }
}

export const ORDER_SAMPLES: ArrayList<Order> = new ArrayList();

ORDER_SAMPLES.add(new Order('1', '白金酒店', $r('app.media.ic_hotel_1'), '行政大床房', $r('app.media.ic_room_1'),
  new Date(), new Date(), 489.45, OrderStatus.CLOSED, systemDateTime.getTime()));
ORDER_SAMPLES.add(new Order('2', '钻石酒店', $r('app.media.ic_hotel_2'), '钻石套房', $r('app.media.ic_room_2'),
  new Date(), new Date(), 489.45, OrderStatus.PAYING, systemDateTime.getTime()));
ORDER_SAMPLES.add(new Order('3', '豪华酒店', $r('app.media.ic_hotel_3'), '豪华套房', $r('app.media.ic_room_3'),
  new Date(), new Date(), 489.45, OrderStatus.STAYING, systemDateTime.getTime()));
ORDER_SAMPLES.add(new Order('4', '豪华酒店', $r('app.media.ic_hotel_3'), '极简大床房', $r('app.media.ic_room_2'),
  new Date(), new Date(), 489.45, OrderStatus.COMMENTING, systemDateTime.getTime()));
ORDER_SAMPLES.add(new Order('5', '白金酒店', $r('app.media.ic_hotel_1'), '双人套房', $r('app.media.ic_room_1'),
  new Date(), new Date(), 489.45, OrderStatus.FINISHED, systemDateTime.getTime()));