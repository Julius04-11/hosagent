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

import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constants/CommonConstants';
import { MetroInfo } from '../model/MetroStationModel';

@Observed
export class MarkerViewModel {
  @Track center: mapCommon.LatLng = {
    latitude: 32.02065982629459,
    longitude: 118.788899213002
  };
  @Track metros: MetroInfo[] = [];
  @Track searchMarkers: map.Marker[] = [];
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  mapOptions?: mapCommon.MapOptions = {
    position: {
      target: this.center,
      zoom: 16
    }
  };
  mapCallback?: AsyncCallback<map.MapComponentController> = async (err, mapController) => {
    if (!err) {
      this.mapController = mapController;
      this.mapController.setZoomControlsEnabled(false);
      this.mapController.setMyLocationEnabled(false);
      this.mapController.setMyLocationControlsEnabled(false);
      this.mapEventManager = this.mapController.getEventManager();
      this.mapEventManager.on('mapLoad', this.mapLoadCallback);
      this.mapEventManager.on('markerClick', this.markerClickCallback);
    }
  };
  // 地图加载回调
  mapLoadCallback = () => {
    this.setMarkers();
  };
  // marker点击回调
  markerClickCallback = (marker: map.Marker) => {
    this.moveCamera(marker);
  };

  // 移动相机位置
  moveCamera(marker: map.Marker) {
    if (!this.mapController) {
      return;
    }
    let target = marker.getPosition()
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 18
    };
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, CommonConstants.MOVECAMERA_DURATION);
  }

  moveToCenter() {
    if (!this.mapController) {
      return;
    }
    let cameraPosition: mapCommon.CameraPosition = {
      target: this.center,
      zoom: 16
    };
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, CommonConstants.MOVECAMERA_DURATION);
  }

  // 设置筛选Marker
  async setMarkers() {
    if (!this.mapController) {
      return;
    }

    this.init();

    this.searchMarkers.length = 0;
    for (let i = 0; i < this.metros.length; i++) {
      let metro = this.metros[i]
      let markerOptions: mapCommon.MarkerOptions = {
        position: metro.location,
        icon: $r('app.media.ic_location_blue'),
        clickable: true,
        draggable: false,
        flat: true,
        zIndex: 1
      }
      let marker = await this.mapController.addMarker(markerOptions);
      this.searchMarkers.push(marker);
    }
  }

  // Marker初始化
  init() {
    if (!this.mapController) {
      return;
    }
    let markerOptions: mapCommon.MarkerOptions = {
      position: this.center,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      zIndex: 2
    }
    this.mapController.addMarker(markerOptions);
  }

  private static markerVM: MarkerViewModel;

  public static get instance() {
    if (!MarkerViewModel.markerVM) {
      MarkerViewModel.markerVM = new MarkerViewModel();
    }
    return MarkerViewModel.markerVM;
  }
}