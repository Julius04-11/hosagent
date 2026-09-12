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

import { MapComponent, mapCommon, map, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { Permissions } from '@kit.AbilityKit';
import Logger from '@ohos/common/src/main/ets/utils/Logger';
import { common, Want } from '@kit.AbilityKit';
import { CustomDialogExample2 } from './MainPage';

@Builder
export function MapPageBuilder() {
  MapPage()
}

class routeObj {
  distance: number | undefined = 0;
  distanceDescription: string | undefined = "";
  duration: number | undefined = 0;
  durationDescription: string | undefined = '';
  durationInTraffic: number | undefined = 0;
  durationInTrafficDescription: string | undefined = '';
}

@Entry
@Component
export struct MapPage {
  @State distinction: string = '';
  @State distinclat: number = 0;
  @State distinclon: number = 0;
  @State dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample2({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      },
      distinction: this.distinction,
      distinclat: this.distinclat,
      distinclon: this.distinclon
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
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -80 },
    customStyle: false,
    cornerRadius: 20,
    width: '100%',
    height: 200,
    backgroundColor: Color.Transparent,
  })

  onCancel() {
    Logger.info('Callback when the first button is clicked')
  }

  onAccept() {
    Logger.info('Callback when the second button is clicked')
  }

  existApp() {
    Logger.info('Click the callback in the blank area')
  }

  private TAG = "HuaweiMapDemo";
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  @State longitude: number = 0
  @State latitude: number = 0
  @State localArea: string = '';
  private marker?: map.Marker;
  @Consume('pageStack') pageStack: NavPathStack;
  @State showMap: Boolean = false;
  @State routes: routeObj[] = [];
  @State points: Array<mapCommon.LatLng> = [];
  permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
  private mapPolyline?: map.MapPolyline;
  @State private mapOption?: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 39.91,
        longitude: 116.40
      },
      zoom: 15
    }
  };
  polylineOption: mapCommon.MapPolylineOptions = {
    points: [],
    clickable: true,
    startCap: mapCommon.CapStyle.BUTT,
    endCap: mapCommon.CapStyle.BUTT,
    geodesic: false,
    jointType: mapCommon.JointType.BEVEL,
    visible: true,
    color: 0xff00ffff,
    width: 15,
    zIndex: 10,
    gradient: false
  }
  drivingRouteParams: navi.DrivingRouteParams = {
    origins: [{
      "latitude": 31.982129213545843,
      "longitude": 120.27745557768591
    }],
    destination: {
      "latitude": 31.982129213545843,
      "longitude": 120.27745557768591
    },
    waypoints: [],
    language: "zh_CN"
  };

  aboutToDisappear(): void {
    this.dialogController = null // 将dialogController置空
  }

  aboutToAppear() {
    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.latitude,
            longitude: this.longitude
          },
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false
        };

        let polygonOptions: mapCommon.MapPolygonOptions = {
          points: [
            { latitude: 31.92076, longitude: 118.884807 },
            { latitude: 31.920765, longitude: 118.901785 },
            { latitude: 31.875771, longitude: 118.885653 },
            { latitude: 31.895816, longitude: 118.851926 },
            { latitude: 31.92315, longitude: 118.849931 },
            { latitude: 31.925617, longitude: 118.882312 }
          ],
          holes: [],
          clickable: true,
          fillColor: 0x00000000,
          geodesic: false,
          strokeColor: 0xff000000,
          jointType: mapCommon.JointType.DEFAULT,
          patterns: [],
          strokeWidth: 10,
          visible: true,
          zIndex: 0
        };
        await this.mapController.addPolygon(polygonOptions);

        // 创建Marker
        this.marker = await this.mapController.addMarker(markerOptions);
        this.marker.setTitle('初始位置')
        this.marker.setSnippet("这是子标题")
        this.marker.setClickable(true)

        this.addBasicPoints()
        this.mapController.on("mapLoad", () => {
          Logger.info(this.TAG, `on-mapLoad`);
        });

        this.mapController.on("markerClick", (marker) => {
          Logger.info(`on-markerClick marker = ${marker.getId()}`);
          this.distinction = marker.getTitle()
          this.distinclat = marker.getPosition().latitude
          this.distinclon = marker.getPosition().longitude
          if (this.dialogController != null) {
            this.dialogController.open()
          }
        });
      }
    };
  }

  async addBasicPoints() {
    let markerOptions3: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.891836,
        longitude: 118.876121
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.startIcon')
    };
    // 创建Marker3
    let marker3 = await this.mapController?.addMarker(markerOptions3) as map.Marker;
    marker3.setTitle('白龙凹瀑布')
    marker3.setSnippet("保护区")
    marker3.setClickable(true)

    let markerOptions4: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.897369,
        longitude: 118.870861
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.startIcon')
    };
    // 创建Marker3
    let marker4 = await this.mapController?.addMarker(markerOptions4) as map.Marker;
    marker4.setTitle('仙人洞')
    marker4.setSnippet("保护区")
    marker4.setClickable(true)

    let markerOptions5: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.893923,
        longitude: 118.870747
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.startIcon')
    };
    // 创建Marker3
    let marker5 = await this.mapController?.addMarker(markerOptions5) as map.Marker;
    marker5.setTitle('樱花园')
    marker5.setSnippet("保护区")
    marker5.setClickable(true)


    let markerOptions6: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.895872,
        longitude: 118.882666
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.startIcon')
    };
    // 创建Marker3
    let marker6 = await this.mapController?.addMarker(markerOptions6) as map.Marker;
    marker6.setTitle('方山祖龙须')
    marker6.setSnippet("保护区")
    marker6.setClickable(true)

    let markerOptions7: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.901373,
        longitude: 118.877293
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.startIcon')
    };
    // 创建Marker3
    let marker7 = await this.mapController?.addMarker(markerOptions7) as map.Marker;
    marker7.setTitle('玻璃眺台')
    marker7.setSnippet("保护区")
    marker7.setClickable(true)
  }

  async addPoint() {
    let markerOptions2: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.904083,
        longitude: 118.88457
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: true,
      icon: $r('app.media.middle_img')
    };

    let marker2: map.Marker = await this.mapController?.addMarker(markerOptions2) as map.Marker;
    marker2.setTitle('方山地址公园游客中心')
    marker2.setSnippet('经度' + markerOptions2.position.latitude + "，纬度" + markerOptions2.position.longitude)
    marker2.setClickable(true)
  }

  @Builder
  Title() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
        Image($r('app.media.icon_more_dark_theme'))
          .height('10%')
          .aspectRatio(1)
          .width('10%')
          .onClick(() => {
            this.addPoint();
          })

        Flex({ justifyContent: FlexAlign.Center }) {
          Text('乐园地图')
            .fontSize(25)
        }
        .height('50')

        Text('路径规划')
          .height('10%')
          .aspectRatio(1)
          .fontSize(18)
          .width('50%')
          .onClick(() => {
            this.getRoutes();
          })

      }
      .height('24vp')
      .width('100%')
      .margin({ bottom: '18vp' })


      Row() {
        Text('导航')
          .height('20')
          .aspectRatio(1)
          .fontSize(18)
          .width('200')
          .onClick(() => {
            let petalMapWant: Want = {
              bundleName: 'com.huawei.hmos.maps.app',
              uri: 'maps://navigation',
              parameters: {
                linkSource: 'com.example.touristparkdemo',
                destinationLatitude: 31.904083,
                destinationLongitude: 118.88457,
                destinationName: '方山国家地址公园地质科普馆',
                vehicleType: 0
              }
            }
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            context.startAbility(petalMapWant);
          })
      }
      .height('20vp')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('10%')
    .padding({ top: '12vp', left: '8' })
  }

  async getRoutes() {
    try {
      let result: navi.RouteResult;
      this.drivingRouteParams.origins = this.marker?.getPosition() ? [this.marker?.getPosition()] : [];
      this.drivingRouteParams.destination = { latitude: 31.904083, longitude: 118.88457 };
      result = await navi.getDrivingRoutes(this.drivingRouteParams);
      result.routes[0].steps.forEach(async (step) => {
        this.routes.push({
          distance: step.distance,
          distanceDescription: step.distanceDescription,
          duration: step.duration,
          durationDescription: step.durationDescription,
          durationInTraffic: step.durationInTraffic,
          durationInTrafficDescription: step.durationInTrafficDescription,
        })
        step.roads.forEach((road) => {
          road.polyline.forEach((polyline) => {
            this.points.push(polyline)
          })
        })
      })
      const points = result.routes[0].overviewPolyline == null ? this.points : result.routes[0].overviewPolyline;
      if (points.length >= 1000) {
        this.polylineOption.points = points.filter((item, index) => index % 50 === 0 || index === points.length - 1);
      } else {
        this.polylineOption.points = points.filter((item, index) => index % 2 === 0 || index === points.length - 1);
      }
      if (this.mapPolyline) {
        this.mapPolyline.setPoints(this.polylineOption.points);
      } else {
        this.mapPolyline = await this.mapController?.addPolyline(this.polylineOption)
      }
    } catch (err) {
      Logger.error("naviDemo", "getDrivingRoutes fail err =" + JSON.stringify(err));
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.Title()
        Stack() {
          // 调用MapComponent组件初始化地图
          MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback });
        }
        .padding('12vp')
      }.height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.latitude = AppStorage.get('latitude') as number;
      this.longitude = AppStorage.get('longitude') as number;
      this.mapOption = {
        position: {
          target: {
            latitude: this.latitude,
            longitude: this.longitude
          },
          zoom: 13
        },
        minZoom: 1,
        maxZoom: 20,
        mapType: mapCommon.MapType.TERRAIN,
      }
    })
  }
}