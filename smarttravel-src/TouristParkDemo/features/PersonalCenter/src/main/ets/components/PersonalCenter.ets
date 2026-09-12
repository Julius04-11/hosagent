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

const LIST_SPACE: number = 16; // 列表默认间隔
const LAYOUT_WEIGHT: number = 1; // 自动分配剩余空间
@Observed
class SettingMenu {
  public id: string; // 唯一id
  public image: Resource; // 菜单图标
  public text: string; // 菜单文本
  public content: string;
  public type: number;
  constructor(id: string, image: Resource, text: string, content: string, type: number) {
    this.id = id;
    this.image = image;
    this.text = text;
    this.content = content;
    this.type = type;
  }
}
@Component
export struct SettingItemView {
  private image: string | Resource = ''; // 功能菜单图标
  private text: string | Resource = ''; // 功能菜单文本
  private content: string = '';
  private type: number = 0; // 功能菜单文本
  build() {
    Row() {
      Row() {
        Text(this.text)
          .fontSize(16)
          .fontColor("#99182431")
          .margin({ left: 12 })
          .layoutWeight(LAYOUT_WEIGHT)
          .lineHeight(22)
          .width('50%')
        if (this.type == 1) {
          Image(this.image)
            .width(40)
            .height(40)
            .align(Alignment.Start)// .opacity($r('app.float.setting_menu_arrow_opacity'))
            .objectFit(ImageFit.Contain)
        } else if (this.type == 2) {
          Text(this.content)
            .fontSize(14)
            .fontColor("#99182431")
            .layoutWeight(LAYOUT_WEIGHT)
            .margin({ left: 70 })
            .lineHeight(22)
            .textAlign(TextAlign.Center)
        } else {
          TextInput({ placeholder: '请填写' })
            .fontSize(14)
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14 })
            .fontColor(Color.Grey)
            .margin({ left: 70 })
            .layoutWeight(LAYOUT_WEIGHT)
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Center)
        }
      }
      .width("100%")
      .height(48)
      .padding({
        left: 12,
        right: 12
      })
      .alignItems(VerticalAlign.Center)
    }
    .width("100%")
    .height(48)
    .alignSelf(ItemAlign.Center)
  }
}


@Builder
export function PersonalCenterBuilder(){
  PersonalCenter()
}

@Entry
@Component
struct PersonalCenter {
  @Consume('pageStack') pageStack: NavPathStack;
  @State basicMenuGroup: SettingMenu[] = [
    new SettingMenu('album', $r('app.media.ic_person'), '头像', '', 1),
    new SettingMenu('collection', $r('app.media.ic_album'), '昵称', '111', 2),
    new SettingMenu('wallet', $r('app.media.ic_album'), '姓名', '', 0),
    new SettingMenu('card', $r('app.media.ic_album'), '身份证号', '', 0),
    new SettingMenu('年龄', $r('app.media.ic_album'), '年龄', '', 0),
    new SettingMenu('性别', $r('app.media.ic_album'), '性别', '女', 2),
    new SettingMenu('地区', $r('app.media.ic_album'), '地区', '', 0)
  ]; // 基础功能分组
  @State otherMenuGroup: SettingMenu[] = [
    new SettingMenu('学历', $r('app.media.ic_album'), '学历', '', 0),
    new SettingMenu('职业', $r('app.media.ic_album'), '职业', '', 0),
    new SettingMenu('爱好', $r('app.media.ic_album'), '爱好', '', 0)
  ]; // 其他功能分组
  build() {
    NavDestination() {
      Column() {
        Column() {
          List() {
            ListItem() {
              // 创建基础功能分组
              Row() {
                List() {
                  ForEach(this.basicMenuGroup,
                    (item: SettingMenu) => {
                      ListItem() {
                        SettingItemView({
                          image: item.image,
                          text: item.text,
                          content: item.content,
                          type: item.type
                        })
                      }
                    },
                    (item: SettingMenu) => item.id.toString())
                }
                .height(345)
                .divider({
                  strokeWidth: 1,
                  color: "#0c000000",
                  startMargin: 46,
                  endMargin: 24
                })
              }
              .height(350)
              .alignItems(VerticalAlign.Center)
              .margin({ bottom: 12 })
              .borderRadius(24)
              .backgroundColor("#FFFFFF")
            }

            ListItem() {
              // 创建其他功能分组
              List({ space: LIST_SPACE }) {
                ForEach(this.otherMenuGroup,
                  (item: SettingMenu) => {
                    ListItem() {
                      SettingItemView({ image: item.image, text: item.text })
                    }
                    .height(56)
                    .borderRadius(24)
                    .backgroundColor("#FFFFFF")
                  },
                  (item: SettingMenu) => item.id.toString())
              }
            }
          }
          .layoutWeight(LAYOUT_WEIGHT)
          .margin({ top: 10 })

          Button("保存").width('100%').backgroundColor(Color.Blue)
        }
        .backgroundColor('#F1F3F5')
        .width("100%")
        .height("100%")
        .padding({
          left: 12,
          right: 12
        })
        .alignItems(HorizontalAlign.Center)
        .height('90%')
      }
      .width('100%').height('100%')
    }
    .title('个人资料')
  }
}