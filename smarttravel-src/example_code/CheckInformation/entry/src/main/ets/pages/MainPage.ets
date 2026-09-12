/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { checkIDCardNo, checkPhoneNo } from '../utils/CheckMethods';
import { StyleConstants } from '../constants/StyleConstants';
import { PromptAction, UIContext } from '@kit.ArkUI';

let uiContext = new UIContext();

@Entry
@Component
struct Index {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State isNameCorrect: boolean = true;
  @State isPhoneNoCorrect: boolean = true;
  @State isAgree: boolean = false;
  @State name: string = '';
  @State phoneNo: string = '';
  @State idCardNo: string = '';
  private promptAction: PromptAction = uiContext.getPromptAction();

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(StyleConstants.WIDTH_40)
          .margin({ right: StyleConstants.MARGIN_RIGHT_8 });
        Text($r('app.string.add_new'))
          .fontWeight(StyleConstants.FONT_WEIGHT_700)
          .fontSize(StyleConstants.FONT_SIZE_20)
          .lineHeight(StyleConstants.LINE_HEIGHT_27);
      }.width(StyleConstants.FULL)
      .height(StyleConstants.HEIGHT_56);

      Row() {
        Image($r('app.media.icon'))
          .width(StyleConstants.WIDTH_16)
          .margin({ right: StyleConstants.MARGIN_RIGHT_7 });
        Text($r('app.string.tips'))
          .layoutWeight(StyleConstants.LAYOUT_WEIGHT)
          .fontColor($r('app.color.orange_font'))
          .fontSize(StyleConstants.FONT_SIZE_12)
          .lineHeight(StyleConstants.LINE_HEIGHT_18)
          .textOverflow({ overflow: TextOverflow.Clip });
      }
      .width(StyleConstants.FULL)
      // .height(StyleConstants.HEIGHT_56)
      .padding({
        left: StyleConstants.PADDING_LEFT_14,
        right: StyleConstants.PADDING_RIGHT_14,
        top: StyleConstants.PADDING_TOP_10,
        bottom: StyleConstants.PADDING_BOTTOM_10
      })
      .margin({ top: StyleConstants.MARGIN_TOP_12, bottom: StyleConstants.MARGIN_BOTTOM_12 })
      .borderRadius(StyleConstants.BORDER_RADIUS_12)
      .backgroundColor($r('app.color.light_orange_background'))
      .alignItems(VerticalAlign.Top);

      Column() {
        Row() {
          Text($r('app.string.name'))
            .fontSize(StyleConstants.FONT_SIZE_18)
            .fontWeight(StyleConstants.FONT_WEIGHT_400)
            .width(StyleConstants.WIDTH_90);
          TextInput({ placeholder: $r('app.string.input_name'), text: $$this.name })
            .margin({ left: StyleConstants.MARGIN_LEFT_MINUS_12 })
            .width(StyleConstants.EIGHTY_PERCENT)
            .fontColor(this.isNameCorrect ? $r('app.color.black_font_color') : $r('app.color.red_font_line_color'))
            .backgroundColor(Color.White)
            .onFocus(() => {
              this.isNameCorrect = true;
            });
        }
        .width(StyleConstants.FULL)
        .height(StyleConstants.HEIGHT_60)
        .borderRadius({ topLeft: StyleConstants.BORDER_RADIUS_16, topRight: StyleConstants.BORDER_RADIUS_16 })
        .padding({ left: StyleConstants.PADDING_LEFT_16, right: StyleConstants.PADDING_RIGHT_16 })
        .backgroundColor(Color.White);

        Divider()
          .strokeWidth(StyleConstants.ZERO_POINT_FIVE)
          .width(StyleConstants.FULL)
          .margin({ left: StyleConstants.MARGIN_LEFT_12, right: StyleConstants.MARGIN_RIGHT_12 })
          .color(this.isNameCorrect ? $r('sys.color.mask_fourth') : $r('app.color.red_font_line_color'));

        Row() {
          Text($r('app.string.phone_no'))
            .fontSize(StyleConstants.FONT_SIZE_18)
            .fontWeight(StyleConstants.FONT_WEIGHT_400)
            .width(StyleConstants.WIDTH_90);
          TextInput({ placeholder: $r('app.string.input_phone_no'), text: $$this.phoneNo })
            .margin({ left: StyleConstants.MARGIN_LEFT_MINUS_12 })
            .width(StyleConstants.EIGHTY_PERCENT)
            .fontColor(this.isPhoneNoCorrect ? $r('app.color.black_font_color') : $r('app.color.red_font_line_color'))
            .backgroundColor(Color.White)
            .onFocus(() => {
              this.isPhoneNoCorrect = true;
            });
        }
        .width(StyleConstants.FULL)
        .height(StyleConstants.HEIGHT_60)
        .padding({ left: StyleConstants.PADDING_LEFT_16, right: StyleConstants.PADDING_RIGHT_16 })
        .backgroundColor(Color.White);

        Divider()
          .strokeWidth(StyleConstants.ZERO_POINT_FIVE)
          .width(StyleConstants.FULL)
          .margin({ left: StyleConstants.MARGIN_LEFT_12, right: StyleConstants.MARGIN_RIGHT_12 })
          .color(this.isPhoneNoCorrect ? $r('sys.color.mask_fourth') : $r('app.color.red_font_line_color'));

        Row() {
          Text($r('app.string.card_type'))
            .fontSize(StyleConstants.FONT_SIZE_18)
            .fontWeight(StyleConstants.FONT_WEIGHT_400)
            .width(StyleConstants.WIDTH_90);
          Text($r('app.string.id_card'))
            .margin({ left: StyleConstants.MARGIN_LEFT_6 })// .width(StyleConstants.EIGHTY_PERCENT)
            .backgroundColor(Color.White);
        }
        .width(StyleConstants.FULL)
        .height(StyleConstants.HEIGHT_60)
        .padding({ left: StyleConstants.PADDING_LEFT_16, right: StyleConstants.PADDING_RIGHT_16 })
        .backgroundColor(Color.White);

        Divider()
          .strokeWidth(StyleConstants.ZERO_POINT_FIVE)
          .width(StyleConstants.FULL)
          .margin({ left: StyleConstants.MARGIN_LEFT_12, right: StyleConstants.MARGIN_RIGHT_12 });

        Row() {
          Text($r('app.string.card_no'))
            .fontSize(StyleConstants.FONT_SIZE_18)
            .fontWeight(StyleConstants.FONT_WEIGHT_400)
            .width(StyleConstants.WIDTH_90);
          TextInput({ placeholder: $r('app.string.input_card_no'), text: $$this.idCardNo })
            .margin({ left: StyleConstants.MARGIN_LEFT_MINUS_12 })
            .width(StyleConstants.EIGHTY_PERCENT)
            .fontColor(this.isNameCorrect ? $r('app.color.black_font_color') : $r('app.color.red_font_line_color'))
            .backgroundColor(Color.White)
            .onFocus(() => {
              this.isNameCorrect = true;
            });
        }
        .width(StyleConstants.FULL)
        .height(StyleConstants.HEIGHT_60)
        .borderRadius({ bottomLeft: StyleConstants.BORDER_RADIUS_16, bottomRight: StyleConstants.BORDER_RADIUS_16 })
        .padding({ left: StyleConstants.PADDING_LEFT_16, right: StyleConstants.PADDING_RIGHT_16 })
        .backgroundColor(Color.White);

        Divider()
          .strokeWidth(StyleConstants.ZERO_POINT_FIVE)
          .width(StyleConstants.FULL)
          .margin({ left: StyleConstants.MARGIN_LEFT_12, right: StyleConstants.MARGIN_RIGHT_12 })
          .color(this.isNameCorrect ? Color.White : $r('app.color.red_font_line_color'));
      }.width(StyleConstants.FULL)
      .borderRadius(StyleConstants.BORDER_RADIUS_16)
      .backgroundColor(Color.White);

      Row() {
        Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
          .width(StyleConstants.WIDTH_20)
          .margin({ left: StyleConstants.MARGIN_LEFT_10 })
          .select($$this.isAgree);
        Text($r('app.string.i_agree'))
          .fontColor($r('app.color.font_color_light_black'))
          .fontSize(StyleConstants.FONT_SIZE_17)
          .lineHeight(StyleConstants.LINE_HEIGHT_20);
      }.width(StyleConstants.FULL)
      .margin({ top: StyleConstants.MARGIN_TOP_16 })
      .onClick(() => {
        this.isAgree = !this.isAgree;
      });

      Button($r('app.string.confirm'))
        .width(StyleConstants.FULL)
        .height(StyleConstants.HEIGHT_40)
        .margin({ top: StyleConstants.MARGIN_TOP_280 })
        .fontColor(this.isAgree ? Color.White : $r('app.color.button_disabled_font_color'))
        .backgroundColor(this.isAgree ? $r('app.color.button_normal_background_color') :
        $r('app.color.button_disabled_background_color'))
        .onClick(() => {
          if (!this.isAgree) {
            this.promptAction.showToast({
              message: $r('app.string.check_real_name_notice')
            });
            return;
          }
          if (!checkIDCardNo(this.idCardNo.trim())) {
            this.isNameCorrect = false;
            this.isPhoneNoCorrect = true;
            this.promptAction.showToast({
              message: $r('app.string.input_id_card_no_error_error')
            });
            return;
          }
          if (!checkPhoneNo(this.phoneNo.trim())) {
            this.isPhoneNoCorrect = false;
            this.promptAction.showToast({
              message: $r('app.string.input_phone_no_error')
            });
            return;
          }
          this.promptAction.showToast({
            message: $r('app.string.success')
          });
          return;
        });
    }
    .height(StyleConstants.FULL)
    .width(StyleConstants.FULL)
    .backgroundColor($r('app.color.gray_background'))
    .padding({
      bottom: this.getUIContext().px2vp(this.bottomRectHeight),
      top: this.getUIContext().px2vp(this.topRectHeight),
      left: StyleConstants.PADDING_LEFT_16,
      right: StyleConstants.PADDING_RIGHT_16
    });
  }
}