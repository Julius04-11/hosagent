/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { MapComponent } from '@kit.MapKit';
import { map, mapCommon, navi } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MarkerType, StyleConstants } from '../constants/StyleConstants';
import { CollectListDialog } from '../components/CollectListDialog';
import { AddressDialog } from '../components/AddressDialog';

@Entry
@Component
struct MapPage {
  @State latitude: number = StyleConstants.LATITUDE
  @State longitude: number = StyleConstants.LONGITUDE
  @Provide collectArr: MarkerType[] = []
  @Provide showAddressDialog: boolean = false
  @Provide showCollectListDialog: boolean = false
  @Provide currmarker: MarkerType = new MarkerType('', '', '', { latitude: 0, longitude: 0 }, false, '', '', '')
  private mapController?: map.MapComponentController
  private mapEventManager?: map.MapEventManager
  markerClickCallback = (marker: map.Marker) => {
    this.moveCamera(marker)
    this.currmarker.markerId = marker.getId()
    this.currmarker.isCollect = false
    for (let i = 0; i < this.collectArr.length; i++) {
      if (this.currmarker.markerId === this.collectArr[i].markerId) {
        this.currmarker.isCollect = true
        break
      }
    }
    this.currmarker.location = marker.getPosition()
    let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
      {
        'latitude': marker.getPosition().latitude,
        'longitude': marker.getPosition().longitude,
        'maxItems': 1
      }
    try {
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, async (err, data) => {
        if (err) {
          hilog.error(0x0000, 'test', 'getAddressesFromLocation: err=' + JSON.stringify(err))
        }
        if (data) {
          this.currmarker.detailAddress = data[0].placeName as string
          this.currmarker.simpleAddress =
            `${data[0].countryName}${data[0].administrativeArea}${data[0].locality}${data[0].subLocality}`
          await this.commutingCalculate(marker.getPosition().latitude, marker.getPosition().longitude)
        }
      })
    } catch (err) {
      hilog.error(0x0000, 'test', 'errCode:' + err.code + ', message:' + err.message)
    }
    this.showAddressDialog = true
  }
  mapLongClickcallback = (position: mapCommon.LatLng) => {
    this.currmarker = new MarkerType('', '', '', { latitude: 0, longitude: 0 }, false, '', '', '')
    this.currmarker.isCollect = false
    this.currmarker.location = position
    let markerOptions: mapCommon.MarkerOptions = {
      position: { latitude: position.latitude, longitude: position.longitude },
      icon: $r('app.media.ic_location_blue'),
      clickable: true,
      draggable: false,
      flat: true,
      zIndex: 1
    }
    this.mapController?.addMarker(markerOptions).then((marker: map.Marker) => {
      this.currmarker.markerId = marker.getId()
    })

    let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
      {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'maxItems': 1
      }
    try {
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, async (err, data) => {
        if (err) {
          hilog.error(0x0000, 'test', 'getAddressesFromLocation: err=' + JSON.stringify(err))
        }
        if (data) {
          this.currmarker.detailAddress = data[0].placeName as string
          this.currmarker.simpleAddress =
            `${data[0].countryName}${data[0].administrativeArea}${data[0].locality}${data[0].subLocality}`
          await this.commutingCalculate(position.latitude, position.longitude)
          hilog.info(0x0000, 'test', 'getAddressesFromLocation: data=' + JSON.stringify(data))
        }
      })
    } catch (err) {
      hilog.error(0x0000, 'test', 'errCode:' + err.code + ', message:' + err.message)
    }
    this.showAddressDialog = true
  }

  secondToTime(seconds: number): string {
    let hourUnit = 60 * 60
    let hour: number = Math.floor(seconds / hourUnit)
    let minute: number = Math.floor((seconds - hour * hourUnit) / 60)
    let hourStr: string = `${hour.toString()}`
    let minuteStr: string = `${minute.toString()}`
    if (hour > 0) {
      return `${hourStr}小时${minuteStr}分钟`
    }
    if (minute > 0) {
      return `${minuteStr}分钟`
    } else {
      return '1分钟'
    }
  }

  async commutingCalculate(markerLatitude: number, markerLongitude: number) {
    let params: navi.DrivingRouteParams = {

      origins: [{
        'latitude': this.latitude,
        'longitude': this.longitude
      }],

      destination: {
        'latitude': markerLatitude,
        'longitude': markerLongitude
      },
      language: 'zh_CN'
    }

    try {
      let result = await navi.getWalkingRoutes(params)
      let distance = result.routes[0].steps[0].distance as number
      this.currmarker.currDisance = distance >= 1000 ? `${(distance / 1000).toFixed(1)}公里` : `${distance}米`
      let time = result.routes[0].steps[0].duration as number
      this.currmarker.walkingTime = this.secondToTime(time)
    } catch (error) {
      let err: BusinessError = error as BusinessError
      hilog.error(0x0000, 'test',
        `error in getting driving routes. Code is ${err.code}, message is ${err.message}`)
    }
  }

  async moveCamera(marker: map.Marker) {
    if (!this.mapController) {
      return
    }
    let target = marker.getPosition()
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 18
    }
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, 500)
  }

  center: mapCommon.LatLng = {
    latitude: this.latitude,
    longitude: this.longitude
  }
  mapOptions?: mapCommon.MapOptions = {
    position: {
      target: this.center,
      zoom: 16
    }
  }
  mapCallback?: AsyncCallback<map.MapComponentController> = async (err, mapController) => {
    if (!err) {
      this.mapController = mapController
      this.mapController.setZoomControlsEnabled(false)
      this.mapController.setMyLocationEnabled(false)
      this.mapController.setMyLocationControlsEnabled(false)
      this.mapEventManager = this.mapController.getEventManager()

      let mapLoadCallback = async () => {
        this.setMarkers()
      }

      this.mapEventManager.on('mapLoad', mapLoadCallback)
      this.mapEventManager.on('markerClick', this.markerClickCallback)
      this.mapEventManager.on('mapLongClick', this.mapLongClickcallback)
    }
  }

  init() {
    if (!this.mapController) {
      return
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
    this.mapController.addMarker(markerOptions)
  }

  async setMarkers() {
    if (!this.mapController) {
      return
    }
    this.init()
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.mapCallback
        })
          .width('100%')
          .height('100%')

        if (this.showAddressDialog) {
          AddressDialog()
        }

        if (this.showCollectListDialog) {
          CollectListDialog()
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
