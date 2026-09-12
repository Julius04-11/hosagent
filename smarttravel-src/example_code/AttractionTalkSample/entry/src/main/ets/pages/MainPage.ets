/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { ExhibitionRecommendationsComponent } from '../component/ExhibitionRecommendations';
import { FeatureItemComponent } from '../component/FeatureItemComponent';
import { RecentExhibitionComponent } from '../component/RecentExhibition';
import { ScenicSpotSeriesCardComponent } from '../component/ScenicSpotSeriesCard';
import { AttractionsAlbumParam } from '../model/AttractionsAlbumParam';
import { FEATURE_ITEMS } from '../model/FeatureItems';
import { SelfGuidedItem, SELF_GUIDED_DATA } from '../model/SelfGuidedData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct MainPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private controller: TabsController = new TabsController();
  @State navPathStack: NavPathStack = new NavPathStack();
  @State selectedIndex: number = 0;
  @State isShow: boolean = false;
  @State sheetHeight: number = 765;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  /**
   * 自定义tabToolBar
   * @param index
   * @param iconSelected
   * @param navName
   */
  @Builder
  customTabToolBar(index: number, iconSelected: Resource, iconUnselected: Resource, navName: string) {
    Column() {
      Image(this.selectedIndex === index ? iconSelected : iconUnselected)
        .width('25')
        .height('25')
        .fillColor(this.selectedIndex === index ? 'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.6)');

      Text(navName)
        .width(70)
        .height(24)
        .fontSize(10)
        .fontWeight(400)
        .lineHeight(12)
        .textAlign(TextAlign.Center)
        .fontColor(this.selectedIndex === index ? 'rgb(10, 89, 247)' : 'rgba(0, 0, 0, 0.6)');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  selfGuidedBuilder() {
    Column() {
      Row() {
        Image($r('app.media.handle'))
          .width('46')
          .height('15')
          .borderRadius(16);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center);

      Row() {
        Text($r('app.string.self_guided'))
          .fontWeight(700)
          .fontSize(20)
          .lineHeight(27)
          .align(Alignment.Start);
      }
      .width('100%')
      .margin({
        top: 10,
        left: 25
      })
      .justifyContent(FlexAlign.Start);

      Column() {
        ForEach(SELF_GUIDED_DATA, (item: SelfGuidedItem) => {
          ScenicSpotSeriesCardComponent({
            cover: item.cover,
            title: item.title,
            description: item.description
          })
            .height('17%')
            .width('100%')
            .margin({
              bottom: 10
            })
            .onClick(() => {
              // 跳转传递参数构造
              let attractionsAlbumParam: AttractionsAlbumParam = {
                id: item.id,
                title: item.title
              };

              this.isShow = false;

              // 跳转对应景点专辑
              this.navPathStack.pushPath({
                name: 'AttractionsAlbumPage',
                param: attractionsAlbumParam
              });

              hilog.info(0X0000, 'MainPage', `*** 跳转景点专辑包装参数： ${JSON.stringify(attractionsAlbumParam)}`);
            });
        }, (item: SelfGuidedItem, index: number) => {
          return index + '_' + JSON.stringify(item);
        });
      }
      .margin({
        top: 20,
        right: 12,
        left: 12
      })
      .justifyContent(FlexAlign.Center);
    }
    .borderRadius(32);
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.selectedIndex, controller: this.controller }) {
        // 首页
        TabContent() {
          Stack({ alignContent: Alignment.Top }) {
            // 顶部背景图
            Image($r('app.media.temple_of_heaven'))
              .width('100%')
              .height(250);

            // 功能导航区域
            Stack({ alignContent: Alignment.Start }) {
              FeatureItemComponent({
                featureImage: FEATURE_ITEMS[0].image,
                featureName: FEATURE_ITEMS[0].title
              })
                .width(50)
                .height(50)
                .margin({
                  bottom: 20,
                  left: 18
                })
                .onClick(() => {
                  this.isShow = true;
                })
                .bindSheet($$this.isShow, this.selfGuidedBuilder(), {
                  height: this.sheetHeight,
                });

              FeatureItemComponent({
                featureImage: FEATURE_ITEMS[1].image,
                featureName: FEATURE_ITEMS[1].title
              })
                .width(50)
                .height(50)
                .margin({
                  bottom: 20,
                  left: 94
                });

              FeatureItemComponent({
                featureImage: FEATURE_ITEMS[2].image,
                featureName: FEATURE_ITEMS[2].title
              })
                .width(50)
                .height(50)
                .margin({
                  bottom: 20,
                  left: 168
                });

              FeatureItemComponent({
                featureImage: FEATURE_ITEMS[3].image,
                featureName: FEATURE_ITEMS[3].title
              })
                .width(50)
                .height(50)
                .margin({
                  bottom: 20,
                  left: 242
                });

              FeatureItemComponent({
                featureImage: FEATURE_ITEMS[4].image,
                featureName: FEATURE_ITEMS[4].title
              })
                .width(50)
                .height(50)
                .margin({
                  bottom: 20,
                  left: 314
                });
            }
            .width('100%')
            .height(94)
            .margin({
              top: 190
            })
            .backgroundColor('rgb(255, 255, 255)');

            // 最近展览卡片
            RecentExhibitionComponent()
              .width('100%')
              .height('230')
              .margin({
                top: 295
              });

            // 展览推荐
            ExhibitionRecommendationsComponent()
              .width('100%')
              .height('230')
              .margin({
                top: 537
              });

          }
          .width('100%')
          .height('100%');
        }
        .width('100%')
        .height('100%')
        .tabBar(this.customTabToolBar(0, $r('app.media.home_selected'), $r('app.media.home_unselected'),
          `${this.context.resourceManager.getStringSync($r('app.string.home').id)}`));

        // 讲解
        TabContent() {
        }
        .width('100%')
        .height('100%')
        .tabBar(this.customTabToolBar(1, $r('app.media.guide_selected'), $r('app.media.guide_unselected'),
          `${this.context.resourceManager.getStringSync($r('app.string.guide').id)}`));

        // 藏品
        TabContent() {
        }
        .width('100%')
        .height('100%')
        .tabBar(this.customTabToolBar(2, $r('app.media.collection_selected'), $r('app.media.collection_unselected'),
          `${this.context.resourceManager.getStringSync($r('app.string.collection').id)}`));

        // 我的
        TabContent() {
        }
        .width('100%')
        .height('100%')
        .tabBar(this.customTabToolBar(3, $r('app.media.my_selected'), $r('app.media.my_unselected'),
          `${this.context.resourceManager.getStringSync($r('app.string.my').id)}`));
      }
      .barHeight('60')
      .onChange((index: number) => {
        this.selectedIndex = index;
      })
      .onContentWillChange((currentIndex, comingIndex) => {
        if (comingIndex !== 0) {
          return false;
        }
        return true;
      })
      .width('100%')
      .height('100%')
      .padding({
        bottom: this.getUIContext().px2vp(this.bottomRectHeight)
      });
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .backgroundColor('rgb(241, 243, 245)')
    .width('100%')
    .height('100%');
  }
}