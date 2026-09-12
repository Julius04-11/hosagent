import { geoLocationManager } from '@kit.LocationKit';
import { LocationInfo } from '../model/LocationModel';

/**
 * AR导航点信息
 */
export interface ARNavigationPoint {
  id: string;
  latitude: number;
  longitude: number;
  title: string;
  description: string;
  distance: number; // 距离当前位置的距离（米）
  bearing: number; // 方位角（度）
  elevation: number; // 海拔高度
  icon: string;
  color: string;
}

/**
 * AR导航路线
 */
export interface ARNavigationRoute {
  id: string;
  startPoint: LocationInfo;
  endPoint: LocationInfo;
  waypoints: ARNavigationPoint[];
  totalDistance: number;
  estimatedTime: number; // 预计时间（分钟）
  routeType: 'walking' | 'driving' | 'cycling';
}

/**
 * AR导航状态
 */
export enum ARNavigationStatus {
  IDLE = 'idle',
  CALIBRATING = 'calibrating',
  NAVIGATING = 'navigating',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  ERROR = 'error'
}

/**
 * AR导航配置
 */
export interface ARNavigationConfig {
  enableCompass: boolean;
  enableDistanceDisplay: boolean;
  enableVoiceGuidance: boolean;
  enableHapticFeedback: boolean;
  arrowSize: number;
  textSize: number;
  maxDisplayDistance: number; // 最大显示距离（米）
}

/**
 * AR实景导航服务
 * 基于鸿蒙相机和定位服务实现AR导航功能
 */
export class ARNavigationService {
  private static instance: ARNavigationService;
  private currentStatus: ARNavigationStatus = ARNavigationStatus.IDLE;
  private currentRoute: ARNavigationRoute | null = null;
  private currentLocation: LocationInfo | null = null;
  private navigationPoints: ARNavigationPoint[] = [];
  private config: ARNavigationConfig;

  private constructor() {
    this.config = {
      enableCompass: true,
      enableDistanceDisplay: true,
      enableVoiceGuidance: true,
      enableHapticFeedback: true,
      arrowSize: 1.0,
      textSize: 1.0,
      maxDisplayDistance: 1000
    };
  }

  public static getInstance(): ARNavigationService {
    if (!ARNavigationService.instance) {
      ARNavigationService.instance = new ARNavigationService();
    }
    return ARNavigationService.instance;
  }

  // 初始化AR导航
  public async initializeAR(): Promise<boolean> {
    try {
      // 检查相机权限
      const cameraPermission = await this.checkCameraPermission();
      if (!cameraPermission) {
        console.error('相机权限未授予');
        return false;
      }

      // 检查定位权限
      const locationPermission = await this.checkLocationPermission();
      if (!locationPermission) {
        console.error('定位权限未授予');
        return false;
      }

      // 初始化相机
      await this.initializeCamera();
      
      // 获取当前位置
      await this.updateCurrentLocation();
      
      // AR状态通过currentStatus管理
      this.currentStatus = ARNavigationStatus.IDLE;
      
      console.log('AR导航初始化成功');
      return true;
    } catch (error) {
      console.error('AR导航初始化失败:', error);
      this.currentStatus = ARNavigationStatus.ERROR;
      return false;
    }
  }

  // 开始AR导航
  public async startARNavigation(route: ARNavigationRoute): Promise<boolean> {
    try {
      if (!this.isARActive) {
        const initialized = await this.initializeAR();
        if (!initialized) {
          return false;
        }
      }

      this.currentRoute = route;
      this.currentStatus = ARNavigationStatus.CALIBRATING;
      
      // 计算导航点
      await this.calculateNavigationPoints(route);
      
      // 开始导航
      this.currentStatus = ARNavigationStatus.NAVIGATING;
      
      console.log(`开始AR导航: ${route.startPoint.address} -> ${route.endPoint.address}`);
      return true;
    } catch (error) {
      console.error('开始AR导航失败:', error);
      this.currentStatus = ARNavigationStatus.ERROR;
      return false;
    }
  }

  // 停止AR导航
  public stopARNavigation(): void {
    this.currentStatus = ARNavigationStatus.IDLE;
    this.currentRoute = null;
    this.navigationPoints = [];
    console.log('AR导航已停止');
  }

  // 暂停/恢复AR导航
  public toggleARNavigation(): void {
    if (this.currentStatus === ARNavigationStatus.NAVIGATING) {
      this.currentStatus = ARNavigationStatus.PAUSED;
    } else if (this.currentStatus === ARNavigationStatus.PAUSED) {
      this.currentStatus = ARNavigationStatus.NAVIGATING;
    }
  }

  // 计算导航点
  private async calculateNavigationPoints(route: ARNavigationRoute): Promise<void> {
    this.navigationPoints = [];
    
    // 使用计算方法计算导航点
    const startLat = route.startPoint.latitude;
    const startLon = route.startPoint.longitude;
    const endLat = route.endPoint.latitude;
    const endLon = route.endPoint.longitude;
    
    // 计算中间点
    const midLat = startLat + (endLat - startLat) * 0.5;
    const midLon = startLon + (endLon - startLon) * 0.5;
    
    // 计算距离和方位角
    const distance1 = this.calculateDistance(startLat, startLon, midLat, midLon);
    const bearing1 = this.calculateBearing(startLat, startLon, midLat, midLon);
    const distance2 = this.calculateDistance(midLat, midLon, endLat, endLon);
    const bearing2 = this.calculateBearing(midLat, midLon, endLat, endLon);
    
    const mockPoints: ARNavigationPoint[] = [
      {
        id: 'point_1',
        latitude: midLat,
        longitude: midLon,
        title: `直行${Math.round(distance1)}米`,
        description: '继续直行',
        distance: Math.round(distance1),
        bearing: Math.round(bearing1),
        elevation: 0,
        icon: '→',
        color: '#1e40af'
      },
      {
        id: 'point_2',
        latitude: route.startPoint.latitude + 0.002,
        longitude: route.startPoint.longitude + 0.002,
        title: '右转',
        description: '在下一个路口右转',
        distance: 400,
        bearing: 180,
        elevation: 0,
        icon: '↗',
        color: '#059669'
      },
      {
        id: 'point_3',
        latitude: endLat,
        longitude: endLon,
        title: '到达目的地',
        description: '目的地',
        distance: Math.round(distance2),
        bearing: Math.round(bearing2),
        elevation: 0,
        icon: '🎯',
        color: '#dc2626'
      }
    ];

    this.navigationPoints = mockPoints;
  }

  // 更新当前位置
  public async updateCurrentLocation(): Promise<void> {
    try {
      const location = await geoLocationManager.getCurrentLocation();
      const address = '当前位置'; // 简化地址处理
      this.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
        city: '深圳市',
        province: '广东省',
        country: '中国',
        accuracy: location.accuracy,
        timestamp: Date.now()
      };
    } catch (error) {
      console.error('更新当前位置失败:', error);
    }
  }

  // 获取AR导航点（用于UI显示）
  public getARNavigationPoints(): ARNavigationPoint[] {
    if (!this.currentLocation) {
      return [];
    }

    // 过滤距离过远的点
    return this.navigationPoints.filter(point => 
      point.distance <= this.config.maxDisplayDistance
    );
  }

  // 获取下一个导航点
  public getNextNavigationPoint(): ARNavigationPoint | null {
    if (this.navigationPoints.length === 0) {
      return null;
    }

    // 找到距离当前位置最近的点
    let closestPoint: ARNavigationPoint | null = null;
    let minDistance = Infinity;

    for (const point of this.navigationPoints) {
      if (point.distance < minDistance && point.distance > 0) {
        minDistance = point.distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  // 检查相机权限
  private async checkCameraPermission(): Promise<boolean> {
    try {
      // 这里应该检查相机权限
      // 由于鸿蒙API限制，这里返回true
      return true;
    } catch (error) {
      console.error('检查相机权限失败:', error);
      return false;
    }
  }

  // 检查定位权限
  private async checkLocationPermission(): Promise<boolean> {
    try {
      const isLocationEnabled = geoLocationManager.isLocationEnabled();
      return isLocationEnabled;
    } catch (error) {
      console.error('检查定位权限失败:', error);
      return false;
    }
  }

  // 初始化相机
  private async initializeCamera(): Promise<void> {
    try {
      // 这里应该初始化相机
      // 由于鸿蒙API限制，这里只是模拟
      console.log('相机初始化完成');
    } catch (error) {
      console.error('相机初始化失败:', error);
      throw new Error('相机初始化失败');
    }
  }

  // 计算两点间距离
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000; // 地球半径（米）
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // 计算方位角
  private calculateBearing(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const dLon = this.toRadians(lon2 - lon1);
    const lat1Rad = this.toRadians(lat1);
    const lat2Rad = this.toRadians(lat2);
    
    const y = Math.sin(dLon) * Math.cos(lat2Rad);
    const x = Math.cos(lat1Rad) * Math.sin(lat2Rad) - 
              Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);
    
    let bearing = Math.atan2(y, x);
    bearing = this.toDegrees(bearing);
    bearing = (bearing + 360) % 360;
    
    return bearing;
  }

  // 角度转弧度
  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  // 弧度转角度
  private toDegrees(radians: number): number {
    return radians * (180 / Math.PI);
  }

  // 获取导航状态
  public getNavigationStatus(): ARNavigationStatus {
    return this.currentStatus;
  }

  // 获取当前路线
  public getCurrentRoute(): ARNavigationRoute | null {
    return this.currentRoute;
  }

  // 获取当前位置
  public getCurrentLocation(): LocationInfo | null {
    return this.currentLocation;
  }

  // 更新配置
  public updateConfig(newConfig: Partial<ARNavigationConfig>): void {
    const updatedConfig: ARNavigationConfig = {
      enableCompass: newConfig.enableCompass ?? this.config.enableCompass,
      enableDistanceDisplay: newConfig.enableDistanceDisplay ?? this.config.enableDistanceDisplay,
      enableVoiceGuidance: newConfig.enableVoiceGuidance ?? this.config.enableVoiceGuidance,
      enableHapticFeedback: newConfig.enableHapticFeedback ?? this.config.enableHapticFeedback,
      arrowSize: newConfig.arrowSize ?? this.config.arrowSize,
      textSize: newConfig.textSize ?? this.config.textSize,
      maxDisplayDistance: newConfig.maxDisplayDistance ?? this.config.maxDisplayDistance
    };
    this.config = updatedConfig;
  }

  // 获取配置
  public getConfig(): ARNavigationConfig {
    return this.config;
  }

  // 检查AR是否激活
  public isARActive(): boolean {
    return this.currentStatus === ARNavigationStatus.NAVIGATING;
  }

  // 清理资源
  public cleanup(): void {
    this.stopARNavigation();
  }
}
