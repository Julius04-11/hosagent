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
import { CommonConstants } from '../constants/CommonConstants';
import { CUSTOM_TABS, OrderTabModel } from '../model/DataModel';
import { OrderView } from '../views/OrderView';

@Entry
@Component
struct OrderPage {
  @State selectedIndex: number = 0;
  @State indicatorLeftMargin: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  private tabPosWidthMap: Map<string, Record<string, number>> = new Map();
  private uiContext: UIContext = this.getUIContext();
  private tabsController: TabsController = new TabsController();
  private scroller: Scroller = new Scroller();
  private stackPadding: number = CommonConstants.STACK_PADDING;
  private underlineDistance: number = 0;

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_nav_back'))
          .width($r('app.float.normal_oper_icon_len'))
          .aspectRatio(1)
          .margin({ right: $r('app.float.normal_8_margin') })
        Text($r('app.string.order_list_title'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(FontWeight.Bold)
      }.width('100%')

      Stack({ alignContent: Alignment.TopStart }) {
        List({ initialIndex: 0, scroller: this.scroller }) {
          ForEach(CUSTOM_TABS, (tab: OrderTabModel, index: number) => {
            ListItem() {
              Row() {
                Text(tab.title)
                  .fontSize($r('app.float.normal_font_size'))
                  .lineHeight($r('app.float.order_tab_font_line_height'))
                  .fontColor(this.selectedIndex === tab.index ? $r('app.color.normal_blue_color') : Color.Black)
              }
              .width('25%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.selectedIndex = tab.index;
                this.tabsController.changeIndex(this.selectedIndex);
              })
              .id(tab.index.toString())
              .onAreaChange((oldValue: Area, newValue: Area) => {
                // This is to initialize properties such as the left boundary distance when the Tab bar is first loaded,
                // making it easier to make judgments when the Tab moves later.
                if (newValue.globalPosition.x !== undefined) {
                  let width = Number.parseFloat(newValue.width.toString());
                  let globalX = Number.parseFloat(newValue.globalPosition.x.toString());
                  if (newValue.position.x !== undefined && this.selectedIndex === tab.index &&
                    this.indicatorLeftMargin === 0) {
                    let positionX = Number.parseFloat(newValue.position.x.toString());
                    this.underlineDistance = (width - CommonConstants.UNDERLINE_WIDTH) / 2;
                    this.indicatorLeftMargin = Number.isNaN(positionX) ? 0 : positionX + this.underlineDistance;
                  }
                  this.tabPosWidthMap.set(tab.index.toString(), { 'left': globalX, 'width': width });
                }
              })
            }
          }, (tab: OrderTabModel) => tab.title.toString())
        }.width('100%')
        .height($r('app.float.order_tab_bar_height'))
        .listDirection(Axis.Horizontal)
        .onScrollFrameBegin((offset: number, state: ScrollState) => {
          this.indicatorLeftMargin -= offset;
          return { offsetRemain: offset };
        })

        Column()
          .width($r('app.float.order_tab_underline_width'))
          .height($r('app.float.order_tab_underline_height'))
          .backgroundColor($r('app.color.normal_blue_color'))
          .margin({ left: this.indicatorLeftMargin, top: $r('app.float.order_tab_bar_height') })

        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          ForEach(CUSTOM_TABS, (tab: OrderTabModel, index: number) => {
            TabContent() {
              OrderView({ orderTabType: tab, selectedIndex: this.selectedIndex })
            }
          }, (tab: OrderTabModel) => tab.title.toString())
        }
        .tabIndex(0)
        .barHeight(0)
        .width('100%')
        .margin({ top: $r('app.float.order_tabs_top_margin') })
        .scrollable(false)
        .backgroundColor(Color.Transparent)
        .animationDuration(CommonConstants.NORMAL_ANIMATE_DURATION)
        .onChange((index: number) => {
          this.selectedIndex = index;
          // After the tab switch is completed, slide it to the previous tab and then trigger the animation effect.
          this.scroller.scrollToIndex(index - 1, true);
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          // This callback is triggered when the transition animation begins. The underline slides along with the page.
          this.selectedIndex = targetIndex;
          let targetIndexInfo = this.getTextInfo(targetIndex.toString());
          this.startAnimateTo(CommonConstants.NORMAL_ANIMATE_DURATION, targetIndexInfo.left - this.stackPadding);
        })
        .onAnimationEnd((index: number, event: TabsAnimationEvent) => {
          // The callback is triggered when the transition animation ends. The underline animation stops.
          let targetIndexInfo = this.getTextInfo(index.toString());
          this.startAnimateTo(0, targetIndexInfo.left - this.stackPadding);
        })
      }.width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .padding({
      top: this.topRectHeight,
      bottom: this.bottomRectHeight,
      left: $r('app.float.normal_card_padding'),
      right: $r('app.float.normal_card_padding')
    })
    .backgroundColor($r('app.color.main_screen_background'))
  }

  private getTextInfo(keyId: string): Record<string, number> {
    let posWidth = this.tabPosWidthMap.get(keyId);
    if (posWidth) {
      return posWidth;
    }
    return { 'left': 0, 'width': 0 };
  }

  private startAnimateTo(duration: number, leftMargin: number) {
    this.uiContext.animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
      this.indicatorLeftMargin = leftMargin + this.underlineDistance;
    });
  }
}