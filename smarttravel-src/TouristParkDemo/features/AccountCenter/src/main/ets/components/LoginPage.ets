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

import { CommonConstants } from '@oh/common';
import { promptAction } from '@kit.ArkUI';
import { AccountInfo } from '@oh/common';
import { AccountTable } from '@oh/common'
import Logger from '@oh/common/src/main/ets/utils/Logger';
import { common } from '@kit.AbilityKit';


@Builder
export function LoginPageBuilder(){
  LoginPage()
}

@Entry
@Component
export struct LoginPage {
  @State message: string = 'Login';
  @State phone: string = '';
  @State code: string = '';
  @State account: string = '';
  @State password: string = '';
  @State isShadow: boolean = false;
  @State optType: number = 0 //0：登录  1：注册
  @State accountList: AccountInfo[] = []
  @State submitCode: string = '';
  @Consume('pageStack') pageStack: NavPathStack;
  private context: Context = this.getUIContext().getHostContext() as common.Context;
  private accountTable = new AccountTable(this.context, () => {

  });

  aboutToAppear() {
    this.accountTable.getRdbStore(this.context, () => {
      this.accountTable.query((result: AccountInfo[]) => {
        this.accountList = result;
      });
    });
  }

  @Builder
  divideLine() {
    Line()
      .width(CommonConstants.FULL_PARENT)
      .height($r('app.float.line_height'))
      .backgroundColor($r('app.color.line_color'))
      .margin({
        left: $r('app.float.line_margin'),
        right: $r('app.float.line_margin')
      })
  }

  build() {
    NavDestination() {
      GridRow({
        breakpoints: {
          value: ['200vp', '300vp', '400vp', '500vp', '600vp'],
          reference: BreakpointsReference.WindowSize
        }
      }) {
        GridCol({
          span: {
            xs: 12, // 在最小宽度类型设备上，栅格子组件占据的栅格容器12列，一行显示1列
            sm: 12, // 在小宽度类型设备上，栅格子组件占据的栅格容器12列，一行显示1列
            md: 12, // 在中等宽度类型设备上，栅格子组件占据的栅格容器12列，一行显示1列
            lg: 10, // 在大宽度类型设备上，栅格子组件占据的栅格容器3列，一行显示4列
            xl: 10, // 在特大宽度类型设备上，栅格子组件占据的栅格容器2列，一行显示6列
            xxl: 8 // 在超大宽度类型设备上，栅格子组件占据的栅格容器12列，一行显示6列
          },
          offset: {
            xs: 0,
            sm: 0,
            md: 0,
            lg: 1,
            xl: 1,
            xxl: 2,
          }
        }) {
          Stack({ alignContent: Alignment.TopStart }) {
            Column() {
              Image($r('app.media.startIcon'))
                .width($r('app.float.logo_image_size'))
                .height($r('app.float.logo_image_size'))
                .margin({
                  top: $r('app.float.logo_margin_top'),
                  bottom: $r('app.float.logo_margin_bottom')
                })
              Text(this.optType === 0 ? $r('app.string.login_page') : $r('app.string.register_page'))
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
                .margin({
                  bottom: this.optType === 0 ? 0 : $r('app.float.login_more_margin_bottom'),
                  top: this.optType === 0 ? 0 : $r('app.float.login_more_margin_top')
                })
              if (this.optType === 0) {
                Text($r('app.string.login_more'))
                  .fontSize($r('app.float.normal_text_size'))
                  .fontColor($r('app.color.login_more_text_color'))
                  .margin({
                    bottom: $r('app.float.login_more_margin_bottom'),
                    top: $r('app.float.login_more_margin_top')
                  })
              }

              Column() {
                if (this.optType !== 0) {
                  TextInput({ placeholder: $r('app.string.phone_number') })
                    .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                    .inputStyle()
                    .onChange((value: string) => {
                      this.phone = value;
                    })
                  this.divideLine();
                  Row() {
                    TextInput({ placeholder: $r('app.string.verify_code') })
                      .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
                      .width(`calc(100% - 80vp)`)
                      .inputStyle()
                      .onChange((value: string) => {
                        this.code = value;
                      })
                    Text('验证码')
                      .width(80)
                      .blueTextStyle()
                      .onClick(() => {
                        if (this.phone === '') {
                          promptAction.showToast({
                            message: '请输入手机号码！',
                            duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                          })
                          return
                        }
                        let index = Math.floor(Math.random() * 3); //输出一个0到2之间的随机整数
                        this.submitCode = CommonConstants.VERIFY_NUMBER_LIST[index]
                        Logger.info(this.submitCode)
                        promptAction.showToast({
                          message: '验证码已生成，请在控制台中查看',
                          duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                        })
                      })

                  }
                  .width(CommonConstants.FULL_PARENT)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                TextInput({ placeholder: $r('app.string.account'), text: this.account })
                  .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                  .inputStyle()
                  .id('account')
                  .onChange((value: string) => {
                    this.account = value;
                  })
                this.divideLine()
                TextInput({ placeholder: $r('app.string.password'), text: this.password })
                  .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
                  .type(InputType.Password)
                  .inputStyle()
                  .id('password')
                  .onChange((value: string) => {
                    this.password = value;
                  })
              }
              .padding({
                top: $r('app.float.background_text_margin'),
                bottom: $r('app.float.background_text_margin')
              })
              .width(CommonConstants.FULL_PARENT)
              .backgroundColor($r('app.color.start_window_background'))
              .borderRadius($r('app.float.background_border_radius'))

              if (this.optType === 0) {
                Row() {
                  Text($r('app.string.message_login')).blueTextStyle()
                    .onClick(() => {
                      // this.pageStack.pushPathByName(CommonConstants.APP_VERIFY_PAGE_URL,
                      //   new RouterParams('verifyLogin'))
                    })
                  Text($r('app.string.forgot_password')).blueTextStyle()
                    .onClick(() => {
                      // this.pageStack.pushPathByName(CommonConstants.APP_VERIFY_PAGE_URL, new routerParams('forgotPwd'))
                    })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width(CommonConstants.FULL_PARENT)
                .margin({ top: $r('app.float.forgot_margin_top') })
              }

              Blank()
              if (this.optType === 0) {
                Button($r('app.string.login'), { type: ButtonType.Capsule })
                  .width(CommonConstants.BUTTON_WIDTH)
                  .height($r('app.float.login_button_height'))
                  .fontSize($r('app.float.normal_text_size'))
                  .fontWeight(FontWeight.Medium)
                  .enabled(isLoginClickable(this.account, this.password))
                  .backgroundColor(isLoginClickable(this.account, this.password) ? $r('app.color.login_button_color') :
                  $r('app.color.login_button_disable'))
                  .fontColor(isLoginClickable(this.account, this.password) ? Color.White :
                  $r('app.color.login_font_disable'))
                  .margin({
                    top: $r('app.float.login_button_margin_top'),
                    bottom: '20vp'
                  })
                  .onClick(() => {
                    //判断数据库中是否存在
                    if (this.accountList.length > 0) {
                      //判断用户名和密码是否正确
                      let index =
                        this.accountList.findIndex(v => (v.account === this.account || v.phone === this.account) &&
                          v.password === this.password)
                      if (index > -1) {
                        AppStorage.set<string>('userAccount', this.accountList[index].account);
                        this.pageStack.clear()
                      } else {
                        promptAction.showToast({
                          message: '请输入正确的用户名或密码！',
                          duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                        })
                      }

                    } else {
                      promptAction.showToast({
                        message: '账户尚未注册,请先注册！',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                      })
                    }
                  })
              } else {
                Button($r('app.string.register'), { type: ButtonType.Capsule })
                  .width(CommonConstants.BUTTON_WIDTH)
                  .height($r('app.float.login_button_height'))
                  .fontSize($r('app.float.normal_text_size'))
                  .fontWeight(FontWeight.Medium)
                  .enabled(isRegisterClickable(this.phone, this.code, this.account, this.password))
                  .backgroundColor(isRegisterClickable(this.phone, this.code, this.account, this.password) ?
                  $r('app.color.login_button_color') : $r('app.color.login_button_disable'))
                  .fontColor(isRegisterClickable(this.phone, this.code, this.account, this.password) ? Color.White :
                  $r('app.color.login_font_disable'))
                  .margin({
                    top: $r('app.float.login_button_margin_top'),
                    bottom: $r('app.float.login_button_margin_bottom')
                  })
                  .onClick(() => {
                    if (this.code !== this.submitCode) {
                      promptAction.showToast({
                        message: '验证码不正确！',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                      })
                      return;
                    }

                    //判断用户名在数据库中是否存在，
                    if (this.accountList.length > 0) {
                      let index = this.accountList.findIndex(v => v.account === this.account || v.phone === this.phone)
                      if (index > -1) {
                        promptAction.showToast({
                          message: '用户名或手机号已被注册！',
                          duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                        })
                      } else {
                        //写入数据库
                        let accountInfo = new AccountInfo()
                        accountInfo.phone = this.phone
                        accountInfo.account = this.account
                        accountInfo.password = this.password
                        this.accountTable.insertData(accountInfo, (id: number) => {
                          accountInfo.id = id;
                          this.accountList.push(accountInfo);
                        });
                        promptAction.showToast({
                          message: '注册成功,请登录',
                          duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                        })
                        this.optType = 0
                        this.account = ''
                        this.password = ''
                        //用户名获得焦点
                        focusControl.requestFocus('account')
                      }
                    } else {
                      //写入数据库
                      let accountInfo = new AccountInfo()
                      accountInfo.phone = this.phone
                      accountInfo.account = this.account
                      accountInfo.password = this.password
                      this.accountTable.insertData(accountInfo, (id: number) => {
                        accountInfo.id = id;
                        this.accountList.push(accountInfo);
                      });
                      promptAction.showToast({
                        message: '注册成功,请登录',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME
                      })
                      this.optType = 0
                      this.account = ''
                      this.password = ''
                      //用户名获得焦点
                      focusControl.requestFocus('account')
                    }
                  })


              }

              if (this.optType === 0) {
                Text($r('app.string.register_account'))
                  .fontColor($r('app.color.login_blue_text_color'))
                  .fontSize($r('app.float.normal_text_size'))
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: '80vp' })
                  .onClick(() => {
                    this.optType = 1
                    this.account = ''
                    this.password = ''
                    //用户名获得焦点
                    focusControl.requestFocus('account')
                  })
              }
            }
            .backgroundColor($r('app.color.background'))
            .height(CommonConstants.FULL_PARENT)
            .width(CommonConstants.FULL_PARENT)
            .justifyContent(FlexAlign.Center)
            .padding({
              left: $r('app.float.login_padding'),
              right: $r('app.float.login_padding'),
              bottom: $r('app.float.login_page_padding_bottom')
            })

          }
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }.hideTitleBar(true)
  }
}


@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .backgroundColor(($r('app.color.start_window_background')))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .padding({
    left: $r('app.float.input_padding'),
    right: $r('app.float.input_padding')
  })
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
  .margin({
    left: $r('app.float.forgot_margin'),
    right: $r('app.float.forgot_margin')
  })
}

function isLoginClickable(account: string, password: string): boolean {
  return account !== '' && password !== '';
}

function isRegisterClickable(phone: string, code: string, account: string, password: string): boolean {
  return phone !== '' && code !== '' && account !== '' && password !== '';
}