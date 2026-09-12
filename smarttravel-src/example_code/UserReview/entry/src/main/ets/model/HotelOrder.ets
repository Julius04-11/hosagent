/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

@ObservedV2
export class HotelOrder {
  @Trace orderId: string; // 订单号
  status: string; // 状态（如“已支付”）
  hotelName: string; // 酒店名称
  roomInfo: string; // 房型信息
  dateRange: string; // 入住日期范围
  guestName: string; // 客人姓名
  price: string; // 价格描述
  bookingDate: string; // 预订日期
  @Trace isReviewed: boolean; // 是否已评价

  constructor(orderId: string, status: string, hotelName: string, roomInfo: string, dateRange: string,
    guestName: string, price: string, bookingDate: string, isReviewed: boolean) {
    this.orderId = orderId;
    this.status = status;
    this.hotelName = hotelName;
    this.roomInfo = roomInfo;
    this.dateRange = dateRange;
    this.guestName = guestName;
    this.price = price;
    this.bookingDate = bookingDate;
    this.isReviewed = isReviewed;
  }
}