import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapConstants } from '../constants/MapConstants';
import { MetroInfo } from '../model/MetroStationModel';
import { CollectedMarker } from '../model/CollectMarkerModel';

/**
 * 地图标记视图模型
 * 管理地图标记、相机位置和事件监听
 */
@Observed
export class MarkerViewModel {
  @Track center: mapCommon.LatLng = {
    latitude: 22.540503,
    longitude: 113.934528  // 深圳世界之窗默认位置
  };
  @Track metros: MetroInfo[] = [];
  @Track searchMarkers: map.Marker[] = [];
  @Track userMarkers: map.Marker[] = [];
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private longClickHandler?: (position: mapCommon.LatLng) => void;
  private mapLoadedHandler?: () => void;
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
      this.mapEventManager.on('mapLongClick', this.mapLongClickCallback);
    }
  };
  
  // 地图加载回调
  mapLoadCallback = () => {
    this.setMarkers();
    if (this.mapLoadedHandler) {
      this.mapLoadedHandler();
    }
  };
  
  // marker点击回调
  markerClickCallback = (marker: map.Marker) => {
    this.moveCamera(marker);
  };

  // 地图长按回调
  mapLongClickCallback = (position: mapCommon.LatLng) => {
    if (this.longClickHandler) {
      this.longClickHandler(position);
    }
  };

  // 移动相机位置
  moveCamera(marker: map.Marker) {
    if (!this.mapController) {
      return;
    }
    let target = marker.getPosition();
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 18
    };
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, MapConstants.MOVECAMERA_DURATION);
  }

  // 移动到中心位置
  moveToCenter() {
    if (!this.mapController) {
      return;
    }
    let cameraPosition: mapCommon.CameraPosition = {
      target: this.center,
      zoom: 16
    };
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, MapConstants.MOVECAMERA_DURATION);
  }

  // 设置筛选Marker
  async setMarkers() {
    if (!this.mapController) {
      return;
    }

    this.init();

    this.searchMarkers.length = 0;
    for (let i = 0; i < this.metros.length; i++) {
      let metro = this.metros[i];
      // 使用emoji作为标记图标，避免依赖资源文件
      let markerOptions: mapCommon.MarkerOptions = {
        position: metro.location,
        title: metro.name,
        clickable: true,
        draggable: false,
        flat: true,
        zIndex: 1
      };
      let marker = await this.mapController.addMarker(markerOptions);
      this.searchMarkers.push(marker);
    }
  }

  // Marker初始化 - 添加目的地标记
  init() {
    if (!this.mapController) {
      return;
    }
    let markerOptions: mapCommon.MarkerOptions = {
      position: this.center,
      title: '目的地',
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: false,
      flat: false,
      zIndex: 2
    };
    this.mapController.addMarker(markerOptions);
  }

  // 设置中心位置
  setCenter(latitude: number, longitude: number) {
    this.center = {
      latitude: latitude,
      longitude: longitude
    };
    if (this.mapOptions) {
      this.mapOptions.position = {
        target: this.center,
        zoom: 16
      };
    }
  }

  // 注册地图长按事件回调
  setMapLongClickHandler(handler?: (position: mapCommon.LatLng) => void) {
    this.longClickHandler = handler;
  }

  // 注册地图加载完成回调
  setMapLoadedHandler(handler?: () => void) {
    this.mapLoadedHandler = handler;
  }

  // 清理用户自定义标记
  clearUserMarkers() {
    if (!this.mapController) {
      return;
    }
    for (let marker of this.userMarkers) {
      marker.remove();
    }
    this.userMarkers.length = 0;
  }

  // 添加自定义标记
  async addUserMarker(position: mapCommon.LatLng, title: string = '自定义位置') {
    if (!this.mapController) {
      return;
    }
    this.clearUserMarkers();
    let markerOptions: mapCommon.MarkerOptions = {
      position: position,
      title: title,
      clickable: true,
      draggable: false,
      flat: true,
      zIndex: 2
    };
    let marker = await this.mapController.addMarker(markerOptions);
    this.userMarkers.push(marker);
    this.moveTo(position.latitude, position.longitude, 18);
  }

  // 批量展示收藏标记
  async renderCollectedMarkers(markers: CollectedMarker[]) {
    if (!this.mapController) {
      return;
    }
    this.clearUserMarkers();
    for (let collected of markers) {
      let markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: collected.latitude,
          longitude: collected.longitude
        },
        title: collected.simpleAddress,
        clickable: true,
        draggable: false,
        flat: true,
        zIndex: 2
      };
      let marker = await this.mapController.addMarker(markerOptions);
      this.userMarkers.push(marker);
    }
  }

  // 移动到指定坐标
  moveTo(latitude: number, longitude: number, zoom: number = 17) {
    if (!this.mapController) {
      return;
    }
    let cameraPosition: mapCommon.CameraPosition = {
      target: { latitude, longitude },
      zoom: zoom
    };
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, MapConstants.MOVECAMERA_DURATION);
  }

  private static markerVM: MarkerViewModel;

  public static get instance() {
    if (!MarkerViewModel.markerVM) {
      MarkerViewModel.markerVM = new MarkerViewModel();
    }
    return MarkerViewModel.markerVM;
  }
}

