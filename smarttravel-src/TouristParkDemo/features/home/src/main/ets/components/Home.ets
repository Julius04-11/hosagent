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

import { homeTabSecond, mainTabFirst, playBookData, swiperImage } from '../viewmodel/HomeData';
import { BreakpointConstants, ILocalData, MemberShipData, StyleConstants } from '@ohos/common';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CustomDialogExample } from './CustomDialogExample';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import Logger from '@ohos/common/src/main/ets/utils/Logger';
import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';


@Builder
export function HomeBuilder() {
  Home()
}

@Entry
@Component
export struct Home {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State localLifeList: ILocalData[] = [];
  @State titleIndex: number = 0;
  @State flag: boolean = false;
  @State activityTitleIndex: number = 0;
  @State noticeInfo: string = '乐园公告';
  @StorageLink('selectCity') city: string = "";
  @StorageLink('selectParkName') parkName: string = '';
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State localArea: string = ''
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('state') state: boolean = false;
  scroller: Scroller = new Scroller();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.onCancel()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      Logger.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      Logger.info("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: 0 },
    customStyle: false,
    cornerRadius: 20,
    width: '100%',
    height: '100%',
  })
  permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
  private arr: number[] = []
  @State videoSrc: Resource = $rawfile('video.mp4')
  private controller: TabsController = new TabsController()
  @State currentIndex: number = 0

  onCancel() {
    this.dialogController.close();
  }

  existApp() {
    this.dialogController.close();
  }

  // 校验应用是否被授予定位权限，可以通过调用checkAccessToken()方法来校验当前是否已经授权。
  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }

  // 校验应用是否被授予定位权限，可以通过调用checkAccessToken()方法来校验当前是否已经授权。
  async checkPermissions(context: common.UIAbilityContext): Promise<void> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(this.permissions[0]);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 已经授权，可以继续访问目标操作
      this.getLocationInfo()
    } else {
      // 申请麦克风权限
      this.reqPermissionsFromUser(this.permissions, context)
    }
  }

  //如果没有被授予定位权限，动态向用户申请授权
  reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          // 用户授权，可以继续访问目标操作
          this.getLocationInfo()
        } else {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          return;
        }
      }
      // 授权成功
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    })
  }

  getLocationInfo() {
    let requestInfo: geoLocationManager.LocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'timeInterval': 0,
      'distanceInterval': 0,
      'maxAccuracy': 0
    };
    let locationChange = async (location: geoLocationManager.Location): Promise<void> => {
      Logger.info('locationChanger: data: ' + JSON.stringify(location));
      //逆地理编码
      try {
        let isAvailable = geoLocationManager.isGeocoderAvailable();
        if (isAvailable) {
          let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
            { "latitude": location.latitude, "longitude": location.longitude, "maxItems": 1 };
          this.latitude = location.latitude
          this.longitude = location.longitude

          let wgs84Position: mapCommon.LatLng = {
            latitude: this.latitude,
            longitude: this.longitude
          };
          let result: mapCommon.LatLng;
          result =
            await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          AppStorage.setOrCreate('latitude', result.latitude)
          AppStorage.setOrCreate('longitude', result.longitude)
          try {
            geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
              if (err) {
                Logger.info('getAddressesFromLocation err: ' + JSON.stringify(err));
                geoLocationManager.off('locationChange', locationChange);
              } else {
                Logger.info('getAddressesFromLocation data: ' + JSON.stringify(data));
                geoLocationManager.off('locationChange', locationChange);
              }
            });
          } catch (err) {
            Logger.error("errCode:" + (err).code + ",errMessage:" + (err).message);
            geoLocationManager.off('locationChange', locationChange);
          }
        }
      } catch (err) {
        Logger.error("errCode:" + (err).code + ",errMessage:" + (err).message);
        geoLocationManager.off('locationChange', locationChange);
      }
    };
    geoLocationManager.on('locationChange', requestInfo, locationChange);
  }

  aboutToAppear() {
    this.checkPermissions(this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.city = '南京'
    this.parkName = '欢乐世界'

    for (let i = 0; i < 20; i++) {
      this.arr.push(i)
    }
    this.city = AppStorage.get('selectCity') as string;
    this.parkName = AppStorage.get('selectParkName') as string;
    AppStorage.setOrCreate('state', true)
    AppStorage.get('state')
  }

  invokeScan() {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    // 启动扫码，拉起扫码界面
    try {
      let context = this.getUIContext().getHostContext();
      scanBarcode.startScanForResult(context, options).then((result: scanBarcode.ScanResult) => {
        // 收到扫码结果后返回
        hilog.info(0x0001, '[Scan CPSample]', 'Promise scan result: %{public}s', JSON.stringify(result));
      }).catch((error: BusinessError) => {
        hilog.error(0x0001, '[Scan CPSample]', 'Promise error: %{public}s', JSON.stringify(error));
      });
    } catch (error) {
      hilog.error(0x0001, '[Scan CPSample]', 'failReason: %{public}s', JSON.stringify(error));
    }
  }

  @Builder
  SearchTitle() {
    Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
      Row() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {

          Text(this.city + '市')
            .fontSize('13vp')
            .fontColor(this.flag === false ? Color.White : Color.Black)
            .fontWeight(FontWeight.Bold)
            .margin({
              bottom: '16vp',
              right: '10vp'
            })
          Row() {
            Text(this.parkName)
              .fontSize('17vp')
              .fontColor(this.flag === false ? Color.White : Color.Black)
              .fontWeight(FontWeight.Bold)
              .margin({
                right: '7vp'
              })
            Image($r('app.media.ic_public_chevron_up_round_bottom2'))
              .height('15vp')
              .width('15vp')
              .aspectRatio(1)
              .margin({
                top: '10vp'
              })
              .onClick(() => {
                this.dialogController.open()
              })
          }
        }
        .margin({
          left: '10vp',
          right: '5vp'
        })
      }


      Row() {
        Image($r('app.media.ic_search'))
          .width('16vp')
          .height('16vp')
          .visibility(Visibility.Visible)
          .margin({
            left: '15vp',
            right: '10vp'
          })
          .onClick(() => {
            this.invokeScan();
          })
        Text('搜索...')
          .fontSize('18vp')
          .fontColor(Color.Gray)

      }
      .height('45vp')
      .width('55%')
      .borderRadius($r('app.float.vp_twenty_four'))
      .backgroundColor(this.flag === false ? Color.White : '#F7F7F7')
      .margin({
        left: '10vp',
        right: '10vp'
      })

      Column() {
        Image($r('app.media.ic_public_headphones_mic_border_white'))
          .width('29vp')
          .height('29vp')
          .aspectRatio(1)
          .alignSelf(ItemAlign.Center)
          .visibility(this.flag === false ? Visibility.Visible : Visibility.None)
        Image($r('app.media.ic_public_headphones_mic_border'))
          .width('29vp')
          .height('29vp')
          .aspectRatio(1)
          .alignSelf(ItemAlign.Center)
          .visibility(this.flag === false ? Visibility.None : Visibility.Visible)
        Text('客服')
          .fontSize('13vp')
          .fontColor(this.flag === false ? Color.White : Color.Black)
          .alignSelf(ItemAlign.Center)
      }.margin({
        left: '6vp',
        right: '12vp'
      })
    }
    .backgroundColor(this.flag === false ? '#00ffffff' : Color.White)
    .height('60vp')
    .width(StyleConstants.FULL_WIDTH)
    .margin({
      bottom: '8vp'
    })
    .width(StyleConstants.FULL_WIDTH)
    .padding({ top: $r('app.float.vp_twelve'), bottom: $r('app.float.vp_twelve') })
  }

  @Builder
  customSwiper() {
    Swiper() {
      ForEach(swiperImage, (item: Resource) => {
        Image(item)
          .width('100%')
          .autoResize(true)
      }, (item: Resource) => JSON.stringify(item))
    }
    .autoPlay(true)
    .itemSpace(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 : '14vp')
    .width('100%')
    .indicator(false)
    .displayCount(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 3 :
      (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? 2 : 1))
  }

  @Builder
  builderTab(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Image(button.img)
        .width('36vp')
        .height('36vp')
        .objectFit(ImageFit.Fill)
      Text(button.title)
        .fontSize(13)
        .textAlign(TextAlign.Center)
        .margin({ top: '5' })
    }
    .height(StyleConstants.FULL_HEIGHT)
    .onClick(() => {
      this.pageStack.pushPathByName(button.action, button.index)
    })
  }

  @Builder
  TextImgButton(button: MemberShipData) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      Text(button.title)
        .fontColor(Color.White)
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .margin({ left: '15', top: '15' })
        .fontWeight(FontWeight.Bold)

      Blank()

      Text(button.subTitle)
        .fontColor(Color.White)
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .margin({ left: '15', bottom: '15' })
    }
    .backgroundImage(button.bgImg)
    .backgroundImageSize(ImageSize.FILL)
    .height(122)
    .width('95%')
    .borderRadius('10vp')
    .onClick(() => {
      this.pageStack.pushPathByName(button.action, null)
    })
  }

  @Builder
  BasicFunctionService() {
    Grid() {
      ForEach(mainTabFirst, (item: MemberShipData, index: number) => {
        GridItem() {
          this.builderTab(item)
        }
      }, (index: string) => index)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .width('100%')
    .height(80)
    .margin({
      top: 10
    })
  }

  @Builder
  ListFunctionService() {
    Grid() {
      ForEach(homeTabSecond, (item: MemberShipData, index: number) => {
        GridItem() {
          this.builderTab(item)
        }
        .width('20%')
      }, (index: string) => index)
    }
    .rowsTemplate('1fr')
    .width('100%')
    .scrollBar(BarState.Off)
    .height(80)
  }

  @Builder
  VideoImageTabBuilder(index: number) {
    if (this.currentIndex === index) {
      Image($r('app.media.tab'))
        .width(70)
        .height(40)
        .objectFit(ImageFit.Fill)
        .border({ color: Color.Blue, width: '2', style: BorderStyle.Solid })
        .borderRadius('5')


    } else {
      Image($r('app.media.tab'))
        .width(70)
        .height(40)
        .objectFit(ImageFit.Fill)
        .borderRadius('5')
    }
  }

  @Builder
  TabContentImageBuilder(index: number) {
    Column() {
      Video({
        src: this.videoSrc,
        previewUri: $r('app.media.video')
      })
        .borderRadius({ topRight: 20, topLeft: 20 })
        .objectFit(ImageFit.Fill)
        .height('88%')

      Text('这里是视频介绍这里是视频介绍' + index)
        .fontColor(Color.Black)
        .fontSize(15)
        .margin({ left: '12vp', top: '7vp', bottom: '7vp' })
        .alignSelf(ItemAlign.Start)
        .height('12%')
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll(this.scroller) {
          Stack({ alignContent: Alignment.Top }) {
            Image($r('app.media.bg'))
              .width('100%')
              .height('100%')
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            // this.customSwiper()

            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
              Column() {
                Blank().height('348vp')
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
                Flex({ direction: FlexDirection.Column }) {
                  Flex({ direction: FlexDirection.Column }) {
                    this.BasicFunctionService()
                    this.ListFunctionService()
                  }
                  .margin({ left: '7vp', right: '7vp' })
                  .padding({ left: '13vp', right: '13vp', top: '10vp' })

                  Stack({ alignContent: Alignment.TopStart }) {
                    Image($r('app.media.open'))
                      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
                      .height(72)
                      .width(354)
                    Text('今日开放时间')
                      .fontColor(Color.White)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .margin({ left: '17vp', top: '18vp', bottom: '7vp' })
                      .alignSelf(ItemAlign.Start)
                    Text('10:00-22:00')
                      .fontColor(Color.White)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .margin({ left: '17vp', top: '38vp', bottom: '7vp' })
                      .alignSelf(ItemAlign.Start)
                  }
                }
                .height(225)
                .width(354)
                .backgroundColor(Color.White)
                .borderRadius(20)

                Flex({
                  direction: FlexDirection.Column,
                  alignItems: ItemAlign.Start,
                  justifyContent: FlexAlign.Start
                }) {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {

                    Row({ space: 5 }) {
                      Image($r('app.media.smile'))
                        .width('27')
                        .margin({ top: '18vp', left: '16vp' })

                      Text('乐园公告')
                        .fontColor(Color.Black)
                        .fontSize(20)
                        .margin({ top: '17vp', left: '5vp' })
                    }

                    Text('1/1条')
                      .padding({
                        top: '9vp',
                        bottom: '9vp',
                        right: '27vp',
                        left: '27vp'
                      })
                      .borderRadius({ topRight: 20, bottomLeft: 20 })
                      .fontColor(Color.White)
                      .backgroundColor('#3F8FFE')

                  }

                  Row({ space: 5 }) {
                    Text('入园须知')
                      .fontColor('#9c000000')
                      .margin({ top: '10vp', left: '16vp' })
                    Image($r('app.media.ic_right_arrow'))
                      .width('16')
                      .margin({ top: '10vp' })
                  }
                }
                .linearGradient({
                  colors: [[0x88B5F6, 0.0], [0xACCEFF, 1.0]]
                })
                .borderRadius('20vp')
                .width(354)
                .padding({ left: '15vp' })
                .height(92)
                .margin({ top: '45vp' })
                .onClick(() => {
                  this.pageStack.pushPathByName("Notice", null);
                })

                Text('游园攻略')
                  .fontColor(Color.Black)
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: '7vp', top: '37vp', bottom: '20vp' })
                  .alignSelf(ItemAlign.Start)

                Grid() {
                  ForEach(playBookData, (item: MemberShipData, index: number) => {
                    GridItem() {
                      this.TextImgButton(item)
                    }
                  }, (index: string) => index)
                }
                .columnsTemplate('1fr 1fr')
                .rowsTemplate('1fr 1fr')
                .width('100%')
                .height(264)

                Text('品牌故事')
                  .fontColor(Color.Black)
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: '7vp', top: '22vp', bottom: '20vp' })
                  .alignSelf(ItemAlign.Start)

                Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
                  TabContent() {
                    this.TabContentImageBuilder(1)
                  }.tabBar(this.VideoImageTabBuilder(0))


                  TabContent() {
                    this.TabContentImageBuilder(2)
                  }.tabBar(this.VideoImageTabBuilder(1))

                  TabContent() {
                    this.TabContentImageBuilder(3)
                  }.tabBar(this.VideoImageTabBuilder(2))

                  TabContent() {
                    this.TabContentImageBuilder(4)
                  }.tabBar(this.VideoImageTabBuilder(3))
                }
                .backgroundColor(Color.White)
                .borderRadius('20')
                .margin({ bottom: '60vp' })
                .width('350vp')
                .animationDuration(300)
                .height('42%')
                .onTabBarClick((index: number) => {
                  this.currentIndex = index
                })
                .onChange((index: number) => {
                  this.currentIndex = index
                })
              }
            }
            .padding({ left: $r('app.float.vp_twelve'), right: $r('app.float.vp_twelve') })
          }
        }
        .scrollBar(BarState.Off)

        .backgroundColor('#00f1f3f5')
        .onDidScroll((): void => {

          let yOffset = this.scroller.currentOffset().yOffset
          if (yOffset > 260 && yOffset !== undefined) {
            this.flag = true; // 当滚动条向下移动时，将文本颜色设为白色
            AppStorage.setOrCreate('state', true)
          } else {
            this.flag = false; // 当滚动条向上移动或不动时，将文本颜色设为黑色
            AppStorage.setOrCreate('state', false)
          }
        })

        this.SearchTitle()
      }
    }
  }
}