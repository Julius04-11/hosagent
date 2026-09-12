import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager } from '@kit.AbilityKit';
import { LocationInfo, LocationPermissionStatus, LocationServiceStatus } from '../model/LocationModel';

export class LocationService {
  private static instance: LocationService;
  private currentLocation: LocationInfo | null = null;
  private permissionStatus: LocationPermissionStatus = LocationPermissionStatus.NOT_DETERMINED;

  private constructor() {}

  public static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  // 检查定位权限
  public async checkLocationPermission(): Promise<LocationPermissionStatus> {
    try {
      // 获取tokenID
      let tokenID: number;
      try {
        const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
        tokenID = bundleInfo.appInfo.accessTokenId;
      } catch (err) {
        console.error('获取bundle信息失败:', err);
        this.permissionStatus = LocationPermissionStatus.DENIED;
        return this.permissionStatus;
      }

      // 检查权限状态
      const grantStatus = await abilityAccessCtrl.createAtManager().checkAccessToken(tokenID, 'ohos.permission.LOCATION');
      this.permissionStatus = grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ? LocationPermissionStatus.GRANTED : LocationPermissionStatus.DENIED;
      return this.permissionStatus;
    } catch (error) {
      console.error('检查定位权限失败:', error);
      this.permissionStatus = LocationPermissionStatus.DENIED;
      return this.permissionStatus;
    }
  }

  // 请求定位权限
  public async requestLocationPermission(): Promise<boolean> {
    try {
      // 使用正确的权限请求方法
      // 使用正确的权限请求方法 - 需要传入context
      const permission = await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(getContext(), ['ohos.permission.LOCATION']);
      if (permission && permission.authResults && permission.authResults[0] === 0) {
        this.permissionStatus = LocationPermissionStatus.GRANTED;
        return true;
      } else {
        this.permissionStatus = LocationPermissionStatus.DENIED;
        return false;
      }
    } catch (error) {
      console.error('请求定位权限失败:', error);
      this.permissionStatus = LocationPermissionStatus.DENIED;
      return false;
    }
  }

  // 获取当前位置
  public async getCurrentLocation(): Promise<LocationInfo | null> {
    try {
      if (this.permissionStatus !== LocationPermissionStatus.GRANTED) {
        console.warn('定位权限未授予');
        return null;
      }

      const location = await geoLocationManager.getCurrentLocation();
      this.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        address: '当前位置',
        city: '深圳市',
        province: '广东省',
        country: '中国',
        accuracy: location.accuracy,
        timestamp: Date.now()
      };
      
      return this.currentLocation;
    } catch (error) {
      console.error('获取位置失败:', error);
      // 返回模拟位置
      this.currentLocation = {
        latitude: 22.5431,
        longitude: 114.0579,
        address: '深圳市南山区',
        city: '深圳市',
        province: '广东省',
        country: '中国',
        accuracy: 10,
        timestamp: Date.now()
      };
      return this.currentLocation;
    }
  }

  // 获取位置服务状态
  public async getLocationServiceStatus(): Promise<LocationServiceStatus> {
    try {
      const isLocationEnabled = await geoLocationManager.isLocationEnabled();
      if (!isLocationEnabled) {
        return LocationServiceStatus.LOCATION_DISABLED;
      }

      if (this.permissionStatus === LocationPermissionStatus.DENIED) {
        return LocationServiceStatus.PERMISSION_DENIED;
      }

      return LocationServiceStatus.AVAILABLE;
    } catch (error) {
      console.error('获取位置服务状态失败:', error);
      return LocationServiceStatus.UNAVAILABLE;
    }
  }

  // 计算两点间距离（米）
  public calculateDistance(
    lat1: number, 
    lon1: number, 
    lat2: number, 
    lon2: number
  ): number {
    const R = 6371000; // 地球半径（米）
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // 角度转弧度
  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  // 获取当前位置
  public getCurrentLocationSync(): LocationInfo | null {
    return this.currentLocation;
  }

  // 获取权限状态
  public getPermissionStatus(): LocationPermissionStatus {
    return this.permissionStatus;
  }

  // 清除位置信息
  public clearLocation(): void {
    this.currentLocation = null;
  }
}
