import { mapCommon, MapComponent } from '@kit.MapKit';
import { promptAction, router } from '@kit.ArkUI';
import geoLocationManager from '@ohos.geoLocationManager';
import { MapConstants } from '../../constants/MapConstants';
import { SearchNearby } from '../../components/SearchNearby';
import { MetroInfo } from '../../model/MetroStationModel';
import { MarkerViewModel } from '../../viewmodel/MarkerViewModel';
import { AddressDialog } from '../../components/AddressDialog';
import { CollectListDialog } from '../../components/CollectListDialog';
import { CollectedMarker } from '../../model/CollectMarkerModel';
import { addFavorite, ensureFavoritesStorage, removeFavorite } from '../../utils/FavoritesStorage';
import { StyleConstants } from '../../constants/StyleConstants';

interface ActivityMapCenter {
  latitude: number;
  longitude: number;
}

interface ActivityMapRouterParams {
  metros?: MetroInfo[];
  center?: ActivityMapCenter;
}

interface GeoLocationError {
  code?: number;
  message?: string;
}

interface ReverseGeoCodeAddress {
  country?: string;
  administrativeArea?: string;
  locality?: string;
  subLocality?: string;
  placeName?: string;
}

/**
 * 活动地图页面
 * 显示活动位置及周边配套设施
 */
@Entry
@Component
export struct ActivityMapPage {
  @State metros: MetroInfo[] = [];
  @State showAddressDialog: boolean = false;
  @State showCollectDialog: boolean = false;
  @State currentMarker: CollectedMarker | undefined = undefined;
  @StorageLink('activity_map_favorites') favorites: CollectedMarker[] = [];
  private markerVM: MarkerViewModel = MarkerViewModel.instance;

  aboutToAppear() {
    ensureFavoritesStorage();
    // 从路由参数获取地铁站信息
    const params = router.getParams() as ActivityMapRouterParams | undefined;
    if (params?.metros) {
      this.metros = params.metros;
      this.markerVM.metros = params.metros;
    }
    if (params?.center) {
      this.markerVM.setCenter(params.center.latitude, params.center.longitude);
    }
    this.markerVM.setMapLongClickHandler(this.handleMapLongClick);
    this.markerVM.setMapLoadedHandler(this.onMapLoaded);
    this.markerVM.renderCollectedMarkers(this.favorites);
  }

  aboutToDisappear() {
    this.markerVM.setMapLongClickHandler(undefined);
    this.markerVM.setMapLoadedHandler(undefined);
    this.markerVM.clearUserMarkers();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 地图组件
      MapComponent({ mapOptions: this.markerVM.mapOptions, mapCallback: this.markerVM.mapCallback })
        .height(MapConstants.MAPCOMPONENT_HEIGHT)
        .width(MapConstants.FULL_SIZE)

      // 标题栏
      this.titleBuilder()

      // 附近列表
      if (this.metros.length > 0) {
        SearchNearby({ metros: this.metros })
          .position({ bottom: 0 })
      }

      // 收藏按钮
      Button('⭐ 收藏列表')
        .backgroundColor('#0A59F7')
        .fontColor(Color.White)
        .borderRadius(StyleConstants.FLOATING_BUTTON_RADIUS)
        .padding({
          left: StyleConstants.FLOATING_BUTTON_PADDING,
          right: StyleConstants.FLOATING_BUTTON_PADDING
        })
        .height(48)
        .onClick(() => {
          this.showCollectDialog = true;
        })
        .position({ right: MapConstants.PADDING_LARGE, bottom: this.metros.length > 0 ? 220 : 40 })

      // 地址弹框
      AddressDialog({
        visible: $showAddressDialog,
        marker: this.currentMarker,
        onCollect: this.collectCurrentMarker,
        onClose: this.closeAddressDialog
      })

      // 收藏列表弹框
      CollectListDialog({
        visible: $showCollectDialog,
        favorites: $favorites,
        onClose: this.closeCollectDialog,
        onSelect: this.handleSelectFavorite,
        onRemove: this.handleRemoveFavorite
      })
    }
    .width(MapConstants.FULL_SIZE)
    .height(MapConstants.FULL_SIZE)
  }

  @Builder
  titleBuilder() {
    RelativeContainer() {
      Column() {
        Text('⬅️')
          .fontSize(20)
          .onClick(() => {
            router.back();
          })
      }
      .height(MapConstants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })

      Text('活动位置')
        .fontSize(MapConstants.FONT_SIZE_LARGE)
        .fontWeight(FontWeight.Medium)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.markerVM.moveToCenter();
        })
    }
    .width(MapConstants.TITLE_WIDTH)
    .height(MapConstants.TITLE_HEIGHT)
    .backgroundColor(Color.White)
    .borderRadius(MapConstants.BORDER_RADIUS)
    .padding({ left: MapConstants.PADDING, right: MapConstants.PADDING })
    .margin({
      left: MapConstants.PADDING_LARGE,
      right: MapConstants.PADDING_LARGE,
      top: 50
    })
  }

  async handleMapLongClick(position: mapCommon.LatLng): Promise<void> {
    const markerId = `${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const marker: CollectedMarker = {
      id: markerId,
      latitude: position.latitude,
      longitude: position.longitude,
      simpleAddress: '正在获取地址...',
      detailAddress: '正在尝试获取详细地址',
      createdAt: Date.now()
    };
    this.currentMarker = marker;
    await this.markerVM.addUserMarker(position, '自定义标记');
    this.showAddressDialog = true;
    try {
      const addressInfo = await this.reverseGeocode(position);
      if (addressInfo && this.currentMarker) {
        const simpleAddress = this.buildSimpleAddress(addressInfo);
        const detailAddress = addressInfo.placeName || simpleAddress;
        const updatedMarker: CollectedMarker = {
          id: this.currentMarker.id,
          latitude: this.currentMarker.latitude,
          longitude: this.currentMarker.longitude,
          simpleAddress: simpleAddress || '未命名地址',
          detailAddress: detailAddress || '未提供详细地址',
          createdAt: this.currentMarker.createdAt
        };
        this.currentMarker = updatedMarker;
      }
    } catch (geoError) {
      const errorMessage = typeof geoError === 'string' ? geoError : (geoError as GeoLocationError)?.message ?? '';
      console.error(`反向地理编码失败: ${errorMessage}`);
      promptAction.showToast({ message: '无法获取该位置的地址信息' });
    }
  }

  async reverseGeocode(position: mapCommon.LatLng): Promise<ReverseGeoCodeAddress | undefined> {
    return new Promise<ReverseGeoCodeAddress | undefined>((resolve, reject) => {
      const request: geoLocationManager.ReverseGeoCodeRequest = {
        latitude: position.latitude,
        longitude: position.longitude,
        maxItems: 1
      };
      geoLocationManager.getAddressesFromLocation(
        request,
        (error: GeoLocationError | undefined, data: ReadonlyArray<ReverseGeoCodeAddress>) => {
        if (error) {
          reject(error);
          return;
        }
        if (data && data.length > 0) {
          resolve(data[0]);
        } else {
          resolve(undefined);
        }
      });
    });
  }

  buildSimpleAddress(addressInfo: ReverseGeoCodeAddress | undefined): string {
    if (!addressInfo) {
      return '';
    }
    const segments: string[] = [];
    if (addressInfo.country) {
      segments.push(addressInfo.country);
    }
    if (addressInfo.administrativeArea) {
      segments.push(addressInfo.administrativeArea);
    }
    if (addressInfo.locality) {
      segments.push(addressInfo.locality);
    }
    if (addressInfo.subLocality) {
      segments.push(addressInfo.subLocality);
    }
    return segments.join('') || addressInfo.placeName || '';
  }

  collectCurrentMarker = (): void => {
    if (!this.currentMarker) {
      return;
    }
    const markerToSave: CollectedMarker = {
      id: this.currentMarker.id,
      latitude: this.currentMarker.latitude,
      longitude: this.currentMarker.longitude,
      simpleAddress: this.currentMarker.simpleAddress,
      detailAddress: this.currentMarker.detailAddress,
      createdAt: Date.now()
    };
    addFavorite(markerToSave);
    promptAction.showToast({ message: '已加入收藏' });
    this.showAddressDialog = false;
    this.markerVM.renderCollectedMarkers(this.favorites);
  }

  closeAddressDialog = (): void => {
    this.showAddressDialog = false;
    this.currentMarker = undefined;
  }

  handleSelectFavorite = (marker: CollectedMarker): void => {
    this.showCollectDialog = false;
    this.markerVM.moveTo(marker.latitude, marker.longitude, 18);
    this.markerVM.addUserMarker({ latitude: marker.latitude, longitude: marker.longitude }, marker.simpleAddress || '收藏位置');
  }

  handleRemoveFavorite = (marker: CollectedMarker): void => {
    removeFavorite(marker.id);
    promptAction.showToast({ message: '已移除收藏' });
    this.markerVM.renderCollectedMarkers(this.favorites);
  }

  closeCollectDialog = (): void => {
    this.showCollectDialog = false;
  }

  onMapLoaded = (): void => {
    this.markerVM.renderCollectedMarkers(this.favorites);
  }
}

