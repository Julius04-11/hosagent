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

import { GroupedOrder } from '../model/GroupedOrder';
import { HotelOrder } from '../model/HotelOrder';

/**
 * 订单列表页
 */
@Entry
@ComponentV2
struct Index {
  pageInfos: NavPathStack = new NavPathStack();
  // 模拟数据：包含同一日期的多笔订单
  @Local orderData: HotelOrder[] =
    [new HotelOrder(
      'H2830797702407958080',
      '已支付',
      '南京时尚大厦的五星级酒店',
      '标准大床房 双早 1间',
      '2025-05-30至2025-05-31',
      '周一杰',
      '¥870.48',
      '2025-05-12',
      false),
      new HotelOrder(
        'H2830797702407741526',
        '已支付',
        '南京苹果汁龙眠大道的五星级酒店',
        '标准大床房 双早 1间',
        '2025-05-30至2025-05-31',
        '周一杰',
        '¥870.48',
        '2025-05-12',
        false),
      new HotelOrder(
        'H2830797702407325416',
        '已支付',
        '南京金龙大厦四星级酒店',
        '标准大床房 双早 1间',
        '2025-05-30至2025-05-31',
        '周一杰',
        '¥820.00',
        '2025-05-11',
        false)
    ];
  // 订单分组
  @Local groupedOrders: GroupedOrder[] = [];
  @Local tabData: string[] = ['全部', '待处理', '待支付', '点评'];

  aboutToAppear() {
    this.groupedOrders = this.groupOrders(this.orderData);
  }

  // 核心分组逻辑
  private groupOrders(orders: HotelOrder[]): GroupedOrder[] {
    let groupedOrders: GroupedOrder[] = [];
    let orderMap = new Map<string, HotelOrder[]>();
    // 1. 使用Map按日期分组
    orders.forEach(order => {
      const key = order.bookingDate;
      if (!orderMap.has(key)) {
        orderMap.set(key, []);
      }
      orderMap.get(key)!.push(order);
    });
    // 2. Map转为数组
    orderMap.forEach((orders, date) => {
      groupedOrders.push(new GroupedOrder(date, orders));
    });
    // 倒序
    groupedOrders.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    return groupedOrders;
  }

  @Builder
  buildOrderCard(order: HotelOrder) {
    Column() {
      Column({ space: 6 }) {
        Row({ space: 12 }) {
          Text(order.orderId)
            .fontSize(14)
            .fontColor($r('sys.color.mask_secondary'))
            .fontWeight(FontWeight.Medium);
          Text(order.isReviewed ? '已点评' : '未点评')
            .fontSize(14)
            .fontColor(order.isReviewed ? '#00C853' : '#E6EE6F20');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Text(order.hotelName)
          .fontSize(16)
          .lineHeight(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'));
      }
      .alignItems(HorizontalAlign.Start);

      Row({ space: 100 }) {
        Column({ space: 4 }) {
          ForEach([order.roomInfo, order.dateRange, order.guestName], (orderInfoText: string) => {
            Text(orderInfoText)
              .fontSize(12)
              .lineHeight(14)
              .fontColor($r('sys.color.mask_secondary'));
          });
        }
        .alignItems(HorizontalAlign.Start);

        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('已支付').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.mask_secondary'));
            Text(order.price).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#0A59F7');
          };

          Button('去评价')
            .fontSize(14)
            .fontColor('#0A59F7')
            .backgroundColor('#0D000000')
            .height(24)
            .visibility(order.isReviewed ? Visibility.Hidden : Visibility.Visible)
            .onClick(() => {
              this.pageInfos.pushPathByName('UserReviewPage', order.orderId, (popInfo) => {
                // 评价完成设置为已评价
                order.isReviewed = true;
              });
            });
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.End);
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%');

    }
    .width('100%')
    .height(180)
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  myTab() {
    Scroll() {
      Column({ space: 16 }) {
        ForEach(this.groupedOrders, (groupedOrder: GroupedOrder) => {
          Column({ space: 12 }) {
            Text('预订日期：' + groupedOrder.date)
              .fontColor('#B3000000')
              .fontSize(14);
            List({ space: 12 }) {
              ForEach(groupedOrder.orders, (hotelOrder: HotelOrder) => {
                ListItem() {
                  this.buildOrderCard(hotelOrder);
                };
              });
            }
            .width('auto').height('auto');
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start);
        });
      }
      .width('90%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .align(Alignment.Top);
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Row() {
          ForEach(this.tabData, (item: string, index: number) => {
            Column({ space: 6 }) {
              Text(item)
                .fontSize(16)
                .fontColor(index === 3 ? 'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.6)')
                .fontWeight(400)
                .lineHeight(24);
              Divider()
                .color('rgb(10, 89, 247)')
                .width(index === 3 ? 30 : 0)
                .strokeWidth(2);
            };

          });
        }
        .alignItems(VerticalAlign.Center)
        .padding(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(64)
        .width('100%');

        this.myTab();
      };
    }
    .title('OrderShowPage')
    // 隐藏标题栏
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5');
  }
}
