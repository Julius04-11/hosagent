/**
 * 位置服务ViewModel - 管理位置相关的业务逻辑
 * 负责位置服务管理、定位权限管理、周边设施查询、气泡提醒控制
 */
import { LocationInfo, LocationPermissionStatus, LocationServiceStatus } from '../model/LocationModel';
import { LocationService } from '../utils/LocationUtils';

export class LocationViewModel {
  // 位置信息状态
  currentLocation: LocationInfo | null = null;
  nearbyFacilities: LocationInfo[] = [];
  
  // 权限和服务状态
  locationPermissionStatus: LocationPermissionStatus = LocationPermissionStatus.NOT_DETERMINED;
  locationServiceStatus: LocationServiceStatus = LocationServiceStatus.UNAVAILABLE;
  
  // UI状态
  isLoading: boolean = false;
  showLocationBubble: boolean = false;
  bubbleMessage: string = '';
  
  private locationService: LocationService = LocationService.getInstance();

  /**
   * 初始化位置服务
   */
  async initialize(): Promise<void> {
    await this.checkLocationPermission();
    await this.checkLocationServiceStatus();
  }

  /**
   * 检查定位权限
   */
  async checkLocationPermission(): Promise<LocationPermissionStatus> {
    try {
      const permission = await this.locationService.checkLocationPermission();
      this.locationPermissionStatus = permission as LocationPermissionStatus;
      
      if (this.locationPermissionStatus === LocationPermissionStatus.GRANTED) {
        await this.getCurrentLocation();
        this.hideLocationBubble();
      } else {
        this.showLocationBubbleWithMessage('需要开启定位权限以获取周边景点推荐');
      }
      
      return this.locationPermissionStatus;
    } catch (error) {
      console.error('检查定位权限失败:', error);
      this.locationPermissionStatus = LocationPermissionStatus.DENIED;
      this.showLocationBubbleWithMessage('定位权限检查失败');
      return this.locationPermissionStatus;
    }
  }

  /**
   * 请求定位权限
   */
  async requestLocationPermission(): Promise<boolean> {
    try {
      const success = await this.locationService.requestLocationPermission();
      if (success) {
        this.locationPermissionStatus = LocationPermissionStatus.GRANTED;
        this.hideLocationBubble();
        await this.getCurrentLocation();
        return true;
      } else {
        this.locationPermissionStatus = LocationPermissionStatus.DENIED;
        this.showLocationBubbleWithMessage('定位权限被拒绝');
        return false;
      }
    } catch (error) {
      console.error('请求定位权限失败:', error);
      this.locationPermissionStatus = LocationPermissionStatus.DENIED;
      return false;
    }
  }

  /**
   * 检查位置服务状态
   */
  async checkLocationServiceStatus(): Promise<LocationServiceStatus> {
    try {
      // 这里可以添加检查位置服务是否可用的逻辑
      // 目前简化为可用状态
      this.locationServiceStatus = LocationServiceStatus.AVAILABLE;
      return this.locationServiceStatus;
    } catch (error) {
      console.error('检查位置服务状态失败:', error);
      this.locationServiceStatus = LocationServiceStatus.UNAVAILABLE;
      return this.locationServiceStatus;
    }
  }

  /**
   * 获取当前位置
   */
  async getCurrentLocation(): Promise<LocationInfo | null> {
    if (this.locationPermissionStatus !== LocationPermissionStatus.GRANTED) {
      console.warn('定位权限未授予，无法获取位置');
      return null;
    }

    this.isLoading = true;
    try {
      this.currentLocation = await this.locationService.getCurrentLocation();
      return this.currentLocation;
    } catch (error) {
      console.error('获取位置失败:', error);
      this.showLocationBubbleWithMessage('获取位置信息失败，请重试');
      return null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 查询周边设施
   */
  async queryNearbyFacilities(
    category?: string,
    radius?: number
  ): Promise<LocationInfo[]> {
    if (!this.currentLocation) {
      console.warn('当前位置不可用，无法查询周边设施');
      return [];
    }

    this.isLoading = true;
    try {
      // 这里应该调用实际的周边设施查询API
      // 目前使用模拟数据
      this.nearbyFacilities = await this.loadMockNearbyFacilities(
        this.currentLocation,
        category,
        radius
      );
      return this.nearbyFacilities;
    } catch (error) {
      console.error('查询周边设施失败:', error);
      return [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载模拟周边设施数据
   */
  private async loadMockNearbyFacilities(
    center: LocationInfo,
    category?: string,
    radius?: number
  ): Promise<LocationInfo[]> {
    // 模拟异步操作
    return new Promise((resolve) => {
      setTimeout(() => {
        const facilities: LocationInfo[] = [
          {
            latitude: center.latitude + 0.01,
            longitude: center.longitude + 0.01,
            address: '附近餐厅1',
            city: '深圳'
          },
          {
            latitude: center.latitude - 0.01,
            longitude: center.longitude + 0.01,
            address: '附近酒店1',
            city: '深圳'
          },
          {
            latitude: center.latitude + 0.01,
            longitude: center.longitude - 0.01,
            address: '附近景点1',
            city: '深圳'
          }
        ];
        resolve(facilities);
      }, 500);
    });
  }

  /**
   * 显示位置气泡提醒
   */
  showLocationBubbleWithMessage(message: string): void {
    this.bubbleMessage = message;
    this.showLocationBubble = true;
  }

  /**
   * 隐藏位置气泡
   */
  hideLocationBubble(): void {
    this.showLocationBubble = false;
    this.bubbleMessage = '';
  }

  /**
   * 检查是否可以获取位置
   */
  canGetLocation(): boolean {
    return this.locationPermissionStatus === LocationPermissionStatus.GRANTED &&
           this.locationServiceStatus === LocationServiceStatus.AVAILABLE;
  }
}

