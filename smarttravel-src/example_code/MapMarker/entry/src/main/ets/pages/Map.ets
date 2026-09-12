/*
 *
 *     Copyright (c) 2025 Huawei Device Co., Ltd.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *
 */

import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { ShopDetail } from '../components/ShopDetail';
import { TopContent } from '../components/TopContent';

@Entry
@Component
struct Map {
  @State clickedShop: number = 1;
  @State fontSizeValue: number = 15;
  private mapOptions?: mapCommon.MapOptions;
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;
  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: 31.891836,
          longitude: 118.876121
        },
        zoom: 15
      }
    }
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.addMarkers()
        this.clickMarker()
      }
    }
  }

  async addMarkers() {
    let markerOptions: mapCommon.MarkerOptions = {
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
      annotations: [{
        // 定义标题内容
        content: '元师傅汉堡',
        fontStyle: 1,
        strokeWidth: 3,
        fontSize: 12
      }],
      annotationPosition: 2,
      icon: 'humer.png'
    };
    let marker = await this.mapController?.addMarker(markerOptions);
    marker?.setClickable(true);
    marker?.setTitle('0');
    marker?.setInfoWindowAnchor(0.5, 1);
    let markerOptions1: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.897369,
        longitude: 118.870861
      },
      rotation: 0,
      visible: true,
      zIndex: 1,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      annotations: [
        {
          // 定义标题内容
          content: '山下寿司',
          fontStyle: 1,
          strokeWidth: 3,
          fontSize: 12
        }],
      // 图标存放在resources/rawfile，icon参数传入rawfile文件夹下的相对路径
      annotationPosition: 2,
      icon: 'sushis.png'
    };
    let marker1 = await this.mapController?.addMarker(markerOptions1);
    marker1?.setClickable(true);
    marker1?.setInfoWindowAnchor(0.5, 1);
    marker1?.setInfoWindowVisible(true);
    marker1?.setTitle('1');

    let markerOptions2: mapCommon.MarkerOptions = {
      position: {
        latitude: 31.897369,
        longitude: 118.879861
      },
      rotation: 0,
      visible: true,
      zIndex: 2,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      annotations: [
        {
          // 定义标题内容
          content: '周家酸菜鱼',
          fontStyle: 1,
          strokeWidth: 3,
          fontSize: 12
        }],
      // 图标存放在resources/rawfile，icon参数传入rawfile文件夹下的相对路径
      annotationPosition: 2,
      icon: 'fishes.png'
    };
    let marker2 = await this.mapController?.addMarker(markerOptions2);
    marker2?.setClickable(true);
    marker2?.setInfoWindowAnchor(0.5, 1);
    marker2?.setTitle('2');
  }

  async clickMarker() {
    this.mapController?.on('markerClick', (marker) => {
      marker.setInfoWindowVisible(true)
      this.clickedShop = marker.getZIndex()
    });
  }

  build() {
    Stack() {
      Stack() {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.callback,
          customInfoWindow: this.customInfoWindow
        })
          .width('100%')
          .height('100%');
        ShopDetail({
          clickedShop: this.clickedShop
        })
      }
      .width('100%')
      .align(Alignment.Bottom)

      TopContent()
    }
    .height('100%')
    .align(Alignment.Top)
  }

  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker) {
      Column() {
        Image($r('app.media.hum_choose'))
          .width(50)
          .visibility($$.marker.getZIndex() === 0 ? Visibility.Visible : Visibility.None)
        Image($r('app.media.sushi_choose'))
          .width(50)
          .visibility($$.marker.getZIndex() === 1 ? Visibility.Visible : Visibility.None)
        Image($r('app.media.fish_choose'))
          .width(50)
          .visibility($$.marker.getZIndex() === 2 ? Visibility.Visible : Visibility.None)
      }
    }
  }
}