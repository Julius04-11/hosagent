/**
 * 地图页面ViewModel - 管理地图相关的业务逻辑
 * 负责地图数据管理、标记操作、地址收藏、动画状态控制
 */
import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { LocationInfo, MapMarker, CollectItem } from '../model/LocationModel';
import { LocationService } from '../utils/LocationUtils';
import { AnimationUtils } from '../utils/AnimationUtils';

const ANNOTATION_POSITION_TOP = 2;
type MarkerSelectionListener = (markerId: string | null, marker?: MapMarker) => void;

export class MapViewModel {
  // 地图数据状态
  markers: MapMarker[] = [];
  favoriteLocations: CollectItem[] = [];
  currentLocation: LocationInfo | null = null;
  
  // UI状态
  isLoading: boolean = false;
  locationPermissionGranted: boolean = false;
  showLocationBubble: boolean = false;
  isAnimating: boolean = false;
  
  // 地址输入状态
  departureAddress: string = '';
  destinationAddress: string = '';
  
  // MapKit 状态
  mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 22.5431,
        longitude: 114.0579
      },
      zoom: 14
    }
  };
  mapCallback: AsyncCallback<map.MapComponentController> = async (err, controller) => {
    if (err) {
      console.error('地图初始化失败:', JSON.stringify(err));
      return;
    }
    this.mapController = controller;
    this.mapController.setZoomControlsEnabled(false);
    this.mapController.setMyLocationEnabled(false);
    this.mapController.setMyLocationControlsEnabled(false);
    this.mapEventManager = this.mapController.getEventManager();
    this.mapEventManager.on('markerClick', this.handleMarkerClick);
    await this.renderMarkersOnMap();
    if (this.selectedMarkerId) {
      await this.focusMarker(this.selectedMarkerId);
    }
  };
  selectedMarkerId: string | null = null;

  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private markerEntities: Map<string, map.Marker> = new Map();
  private markerSelectionListener?: MarkerSelectionListener;

  private locationService: LocationService = LocationService.getInstance();

  /**
   * 初始化地图数据
   */
  async initialize(): Promise<void> {
    this.loadMockMarkers();
    this.loadFavoriteLocations();
    this.updateMapCenterFromMarkers();
    await this.checkLocationPermission();
    await this.renderMarkersOnMap();
  }

  setMarkerSelectionListener(listener?: MarkerSelectionListener): void {
    this.markerSelectionListener = listener;
  }

  private notifyMarkerSelection(markerId: string | null, markerData?: MapMarker): void {
    if (this.markerSelectionListener) {
      this.markerSelectionListener(markerId, markerData);
    }
  }

  getMarkerById(id: string | null | undefined): MapMarker | undefined {
    if (!id) {
      return undefined;
    }
    return this.markers.find(marker => marker.id === id);
  }

  /**
   * 检查定位权限
   */
  async checkLocationPermission(): Promise<void> {
    try {
      const permission = await this.locationService.checkLocationPermission();
      this.locationPermissionGranted = permission === 'granted';
      
      if (!this.locationPermissionGranted) {
        this.showLocationBubble = true;
      } else {
        await this.getCurrentLocation();
      }
    } catch (error) {
      console.error('检查定位权限失败:', error);
      this.showLocationBubble = true;
    }
  }

  /**
   * 请求定位权限
   */
  async requestLocationPermission(): Promise<boolean> {
    try {
      const success = await this.locationService.requestLocationPermission();
      if (success) {
        this.locationPermissionGranted = true;
        this.showLocationBubble = false;
        await this.getCurrentLocation();
        return true;
      }
      return false;
    } catch (error) {
      console.error('请求定位权限失败:', error);
      return false;
    }
  }

  private updateMapCenterFromMarkers(): void {
    if (this.markers.length === 0) {
      return;
    }
    const firstMarker = this.markers[0];
    this.mapOptions.position = {
      target: {
        latitude: firstMarker.latitude,
        longitude: firstMarker.longitude
      },
      zoom: this.mapOptions.position?.zoom ?? 14
    };
  }

  /**
   * 获取当前位置
   */
  async getCurrentLocation(): Promise<LocationInfo | null> {
    this.isLoading = true;
    try {
      this.currentLocation = await this.locationService.getCurrentLocation();
      if (this.currentLocation) {
        this.animateCameraTo({
          latitude: this.currentLocation.latitude,
          longitude: this.currentLocation.longitude
        }, 15);
      }
      return this.currentLocation;
    } catch (error) {
      console.error('获取位置失败:', error);
      return null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载模拟标记点数据
   */
  loadMockMarkers(): void {
    this.markers = [
      {
        id: '1',
        latitude: 22.5431,
        longitude: 114.0579,
        title: '世界之窗',
        description: '深圳著名主题公园',
        isFavorite: false,
        addTime: '2025-01-15',
        icon: '🏛️',
        color: '#FF6B35'
      } as MapMarker,
      {
        id: '2',
        latitude: 22.5231,
        longitude: 114.0379,
        title: '欢乐谷',
        description: '深圳大型主题乐园',
        isFavorite: true,
        addTime: '2025-01-14',
        icon: '🎢',
        color: '#4ECDC4'
      } as MapMarker,
      {
        id: '3',
        latitude: 22.5631,
        longitude: 114.0779,
        title: '东部华侨城',
        description: '生态旅游度假区',
        isFavorite: false,
        addTime: '2025-01-13',
        icon: '🏞️',
        color: '#45B7D1'
      } as MapMarker,
      {
        id: '4',
        latitude: 22.5031,
        longitude: 114.0179,
        title: '大梅沙海滨公园',
        description: '海滨休闲度假区',
        isFavorite: true,
        addTime: '2025-01-12',
        icon: '🏖️',
        color: '#96CEB4'
      } as MapMarker
    ];
    this.updateMapCenterFromMarkers();
    void this.renderMarkersOnMap();
  }

  /**
   * 加载收藏位置列表
   */
  loadFavoriteLocations(): void {
    this.favoriteLocations = [
      {
        id: '1',
        latitude: 22.5431,
        longitude: 114.0579,
        title: '世界之窗',
        description: '深圳市南山区深南大道9037号',
        addTime: '2025-01-15',
        icon: '🏛️',
        color: '#FF6B35'
      } as CollectItem,
      {
        id: '2',
        latitude: 22.5231,
        longitude: 114.0379,
        title: '欢乐谷',
        description: '深圳市南山区华侨城',
        addTime: '2025-01-14',
        icon: '🎢',
        color: '#4ECDC4'
      } as CollectItem
    ];
  }

  async renderMarkersOnMap(): Promise<void> {
    if (!this.mapController) {
      return;
    }

    const markerIds = new Set(this.markers.map(marker => marker.id));
    for (const entry of this.markerEntities) {
      const id = entry[0];
      const entity = entry[1];
      if (!markerIds.has(id)) {
        entity.remove();
        this.markerEntities.delete(id);
      }
    }

    for (const markerData of this.markers) {
      let markerEntity = this.markerEntities.get(markerData.id);
      if (!markerEntity) {
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: markerData.latitude,
            longitude: markerData.longitude
          },
          visible: true,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          draggable: false,
          clickable: true,
          flat: false,
          zIndex: markerData.isFavorite ? 2 : 1,
          annotations: [{
            content: markerData.title,
            fontSize: 12,
            fontStyle: 1,
            strokeWidth: 3
          }],
          annotationPosition: ANNOTATION_POSITION_TOP
        };
        markerEntity = await this.mapController.addMarker(markerOptions);
        if (!markerEntity) {
          continue;
        }
        markerEntity.setTitle(markerData.id);
        markerEntity.setInfoWindowAnchor(0.5, 1);
        markerEntity.setClickable(true);
        this.markerEntities.set(markerData.id, markerEntity);
      } else {
        markerEntity.setPosition({
          latitude: markerData.latitude,
          longitude: markerData.longitude
        });
      }
      markerEntity.setInfoWindowVisible(this.selectedMarkerId === markerData.id);
    }
  }

  private handleMarkerClick = (marker: map.Marker) => {
    const markerId = marker.getTitle();
    const resolvedId = markerId ?? null;
    this.selectedMarkerId = resolvedId;
    this.updateMarkerInfoWindowVisibility(resolvedId);
    if (resolvedId) {
      marker.setInfoWindowVisible(true);
      this.animateCameraTo(marker.getPosition(), 16);
    }
    const markerData = this.getMarkerById(resolvedId);
    this.notifyMarkerSelection(resolvedId, markerData);
  };

  private updateMarkerInfoWindowVisibility(activeId: string | null): void {
    this.markerEntities.forEach((entity, id) => {
      entity.setInfoWindowVisible(activeId !== null && id === activeId);
    });
  }

  private animateCameraTo(position: mapCommon.LatLng, zoom: number = 15): void {
    if (!this.mapController) {
      return;
    }
    const cameraPosition: mapCommon.CameraPosition = {
      target: position,
      zoom: zoom
    };
    const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.animateCamera(cameraUpdate, 500);
  }

  async focusMarker(markerId: string): Promise<void> {
    const markerData = this.getMarkerById(markerId);
    this.selectedMarkerId = markerId;

    if (!this.mapController) {
      this.notifyMarkerSelection(markerId, markerData);
      return;
    }

    this.updateMarkerInfoWindowVisibility(markerId);
    const markerEntity = this.markerEntities.get(markerId);
    if (markerEntity) {
      markerEntity.setInfoWindowVisible(true);
      this.animateCameraTo(markerEntity.getPosition(), 16);
    } else if (markerData) {
      this.animateCameraTo({
        latitude: markerData.latitude,
        longitude: markerData.longitude
      }, 16);
    }
    this.notifyMarkerSelection(markerId, markerData);
  }
 
  /**
   * 切换收藏状态
   */
  toggleFavorite(markerId: string): void {
    const marker = this.markers.find(m => m.id === markerId);
    if (marker) {
      marker.isFavorite = !marker.isFavorite;
      
      // 同步更新收藏列表
      if (marker.isFavorite) {
        this.addToFavorites(marker);
      } else {
        this.removeFromFavorites(markerId);
      }
      void this.renderMarkersOnMap();
    }
  }

  /**
   * 添加到收藏列表
   */
  private addToFavorites(marker: MapMarker): void {
    const exists = this.favoriteLocations.find(item => item.id === marker.id);
    if (!exists) {
      const collectItem: CollectItem = {
        id: marker.id,
        latitude: marker.latitude,
        longitude: marker.longitude,
        title: marker.title,
        description: marker.description,
        addTime: new Date().toISOString().split('T')[0],
        icon: marker.icon,
        color: marker.color
      };
      this.favoriteLocations.push(collectItem);
    }
  }

  /**
   * 从收藏列表移除
   */
  private removeFromFavorites(markerId: string): void {
    const index = this.favoriteLocations.findIndex(item => item.id === markerId);
    if (index !== -1) {
      this.favoriteLocations.splice(index, 1);
    }
  }

  /**
   * 添加新标记
   */
  async addMarker(): Promise<MapMarker | null> {
    if (!this.currentLocation) {
      return null;
    }
    
    const newMarker: MapMarker = {
      id: Date.now().toString(),
      latitude: this.currentLocation.latitude + (Math.random() - 0.5) * 0.01,
      longitude: this.currentLocation.longitude + (Math.random() - 0.5) * 0.01,
      title: `标记点 ${this.markers.length + 1}`,
      description: '用户添加的标记点',
      isFavorite: false,
      addTime: new Date().toISOString().split('T')[0],
      icon: '📍',
      color: '#64748b'
    };
    
    this.markers.push(newMarker);
    this.updateMapCenterFromMarkers();
    await this.renderMarkersOnMap();
    await this.focusMarker(newMarker.id);
    return newMarker;
  }

  /**
   * 地址交换动画
   */
  async swapAddresses(uiContext: UIContext): Promise<void> {
    if (this.isAnimating) return;
    
    this.isAnimating = true;
    
    try {
      // 使用AnimationUtils实现地址交换动画
      await AnimationUtils.swapAddresses(
        uiContext,
        { text: this.departureAddress },
        { text: this.destinationAddress },
        500
      );
      
      // 交换地址
      const temp = this.departureAddress;
      this.departureAddress = this.destinationAddress;
      this.destinationAddress = temp;
    } finally {
      this.isAnimating = false;
    }
  }

  /**
   * 设置出发地
   */
  setDepartureAddress(address: string): void {
    this.departureAddress = address;
  }

  /**
   * 设置目的地
   */
  setDestinationAddress(address: string): void {
    this.destinationAddress = address;
  }

  /**
   * 隐藏位置气泡
   */
  hideLocationBubble(): void {
    this.showLocationBubble = false;
  }

  /**
   * 显示位置气泡
   */
  showLocationBubbleDialog(): void {
    this.showLocationBubble = true;
  }
}

