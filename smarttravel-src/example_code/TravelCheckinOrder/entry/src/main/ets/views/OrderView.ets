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
import { OrderStatus, OrderType } from '../model/CommonEnum';
import { Order, ORDER_SAMPLES, OrderTabModel } from '../model/DataModel';
import { ArrayList } from '@kit.ArkTS';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct OrderView {
  @State orderTabType: OrderTabModel = { index: -1, title: '', orderType: OrderType.ALL };
  @State orderArray: Order[] = [];
  @State orderList: ArrayList<Order> = new ArrayList();
  @State @Watch('orderChange') change: boolean = true;
  @State isAddOrDelete: boolean = false;
  @Link @Watch('tabChange') selectedIndex: number;

  aboutToAppear() {
    this.filterOrder();
  }

  orderChange() {
    this.filterOrder();
  }

  tabChange() {
    if (this.orderTabType.index === this.selectedIndex) {
      this.filterOrder();
    }
  }

  filterOrder() {
    /* Sorting is only performed during the addition or deletion of orders,
       and order sorting is solely influenced by the creation time.
     */
    if (this.isAddOrDelete) {
      ORDER_SAMPLES.sort((first: Order, second: Order) => {
        return second.createTime - first.createTime;
      });
    }
    if (this.orderTabType.orderType === OrderType.ALL) {
      this.orderList = ORDER_SAMPLES;
    } else {
      this.orderList.clear();
      switch (this.orderTabType.orderType) {
        case OrderType.PAYING:
          ORDER_SAMPLES.forEach((order) => {
            if (order.status === OrderStatus.PAYING) {
              this.orderList.add(order);
            }
          });
          break;
        case OrderType.STAYING:
          ORDER_SAMPLES.forEach((order) => {
            if (order.status === OrderStatus.STAYING) {
              this.orderList.add(order);
            }
          });
          break;
        case OrderType.COMMENTING:
          ORDER_SAMPLES.forEach((order) => {
            if (order.status === OrderStatus.COMMENTING) {
              this.orderList.add(order);
            }
          });
          break;
      }
    }
    this.orderArray = this.orderList.convertToArray();
  }

  build() {
    Column() {
      if (this.orderArray && this.orderArray.length > 0) {
        List({ initialIndex: 0, space: 12 }) {
          ForEach(this.orderArray, (order: Order, index: number) => {
            ListItem() {
              OrderContent({ change: this.change, order: order, isAddOrDelete: this.isAddOrDelete })
            }
          }, (order: Order, index: number) => order.orderId + index)
        }.width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Image($r('app.media.ic_no_data'))
            .width($r('app.float.no_order_tip_icon_len'))
            .aspectRatio(1)
            .margin({ bottom: $r('app.float.normal_8_margin') })
          Text($r('app.string.no_order_tip'))
            .fontSize($r('app.float.small_font_size'))
            .fontColor($r('app.color.no_order_tip_font_color'))
        }.width('100%')
      }
    }.width('100%')
    .height('100%')
  }
}

@Component
struct OrderContent {
  @ObjectLink order: Order;
  @Link change: boolean;
  @Link isAddOrDelete: boolean;
  private customDateFormatter: Intl.DateTimeFormat = new Intl.DateTimeFormat('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });

  getFormattedTime(date: Date) {
    return this.customDateFormatter.format(date);
  }

  @Builder
  orderButtons() {
    Row({ space: 8 }) {
      Text($r('app.string.more_oper_text'))
        .fontSize($r('app.float.small_font_size'))
        .fontColor($r('app.color.normal_other_button_font_color'))
      if (this.order.status === OrderStatus.CLOSED) {
        Button($r('app.string.delete_order_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(false)
          .onClick(() => {
            let rIndex = -1;
            ORDER_SAMPLES.forEach((order: Order, index: number) => {
              if (order.orderId === this.order.orderId) {
                rIndex = index;
              }
            });
            if (rIndex >= 0 && rIndex < ORDER_SAMPLES.length) {
              ORDER_SAMPLES.removeByIndex(rIndex);
              this.isAddOrDelete = true;
              this.change = !this.change;
            }
          })
      }
      if (this.order.status === OrderStatus.PAYING) {
        Button($r('app.string.close_order_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(false)
          .onClick(() => {
            this.order.status = OrderStatus.CLOSED;
            this.isAddOrDelete = false;
            this.change = !this.change;
          })
      }
      if (this.order.status === OrderStatus.STAYING) {
        Button($r('app.string.request_refund_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(false)
          .onClick(() => {
            this.order.status = OrderStatus.CLOSED;
            this.isAddOrDelete = false;
            this.change = !this.change;
          })
      }
      if (this.order.status !== OrderStatus.PAYING) {
        Button($r('app.string.rebook_order_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(false)
          .onClick(() => {
            let nowTime = new Date();
            let reOrder: Order =
              new Order(nowTime.getTime().toString(), this.order.hotelName, this.order.hotelImage, this.order.title,
                this.order.prodImage, nowTime, nowTime, this.order.payment, OrderStatus.PAYING, nowTime.getTime());
            ORDER_SAMPLES.add(reOrder);
            this.isAddOrDelete = true;
            this.change = !this.change;
          })
      }
      if (this.order.status === OrderStatus.PAYING || this.order.status === OrderStatus.STAYING) {
        Button($r('app.string.modify_order_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(this.order.status === OrderStatus.STAYING)
      }
      if (this.order.status === OrderStatus.PAYING) {
        Button($r('app.string.immediate_payment_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(true)
          .onClick(() => {
            this.order.status = OrderStatus.STAYING;
            this.isAddOrDelete = false;
            this.change = !this.change;
          })
      }
      if (this.order.status === OrderStatus.COMMENTING) {
        Button($r('app.string.evaluate_immediately_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(true)
          .onClick(() => {
            this.order.status = OrderStatus.FINISHED;
            this.isAddOrDelete = false;
            this.change = !this.change;
          })
      }
      if (this.order.status === OrderStatus.FINISHED) {
        Button($r('app.string.additional_evaluation_text'), { type: ButtonType.Capsule })
          .orderButtonStyle(true)
      }
    }.width('100%')
    .justifyContent(FlexAlign.End)
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Image(this.order.hotelImage)
          .width($r('app.float.order_hotel_image_len'))
          .aspectRatio(1)
          .margin({ right: $r('app.float.normal_8_margin') })
        Text(this.order.hotelName)
          .fontSize($r('app.float.normal_font_size'))
          .fontWeight(CommonConstants.TIP_FONT_WEIGHT)
        Blank()
        Text(this.order.status)
          .fontSize($r('app.float.normal_font_size'))
          .fontColor($r('app.color.normal_blue_color'))
      }.width('100%')

      Row() {
        Image(this.order.prodImage)
          .width($r('app.float.order_room_image_width'))
          .height($r('app.float.order_room_image_height'))
          .borderRadius($r('app.float.order_room_image_border_radius'))
          .margin({ right: $r('app.float.order_room_image_right_margin') })
        Column({ space: 8 }) {
          Text(this.order.title)
            .fontWeight(CommonConstants.TIP_FONT_WEIGHT)
          Text() {
            Span(this.getFormattedTime(this.order.startDate))
            Span(CommonConstants.DATE_SPLIT)
            Span(this.getFormattedTime(this.order.endDate))
          }.fontSize($r('app.float.smaller_font_size'))
          .fontColor($r('app.color.order_time_span_font_color'))
        }.alignItems(HorizontalAlign.Start)
      }.width('100%')

      Text() {
        Span(this.order.status === OrderStatus.PAYING || this.order.status === OrderStatus.CLOSED ?
          $r('app.string.wait_payment_text') : $r('app.string.actual_payment_text'))
        Span(this.order.payment.toString())
      }.fontSize($r('app.float.small_font_size'))
      .fontColor(this.order.status === OrderStatus.PAYING || this.order.status === OrderStatus.CLOSED ?
        $r('app.color.normal_blue_color') : Color.Black)
      .width('100%')
      .textAlign(TextAlign.End)

      this.orderButtons()
    }.width('100%')
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.normal_card_border_radius'))
    .padding({
      left: $r('app.float.normal_card_padding'),
      right: $r('app.float.normal_card_padding'),
      top: $r('app.float.normal_card_vertical_padding'),
      bottom: $r('app.float.normal_card_vertical_padding')
    })
  }
}

@Extend(Button)
function orderButtonStyle(main: boolean) {
  .height($r('app.float.order_oper_buttons_width'))
  .fontColor(main ? Color.White : $r('app.color.normal_other_button_font_color'))
  .backgroundColor(main ? $r('app.color.normal_blue_color') : $r('app.color.normal_other_button_background_color'))
  .fontSize($r('app.float.small_font_size'))
}