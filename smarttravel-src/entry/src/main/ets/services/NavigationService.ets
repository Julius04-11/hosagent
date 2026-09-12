/**
 * 导航服务类
 * 
 * 功能：
 * 1. 路线规划（驾车、步行、骑行、公交）
 * 2. 路线搜索与优化
 * 3. 实时导航引导
 * 4. 路况信息查询
 * 5. 导航语音播报
 * 6. 偏航重新规划
 * 
 * 使用场景：
 * - 景点路线规划
 * - 实时导航到酒店
 * - 公交路线查询
 * - 步行导航
 * 
 * @author SmartTravel Team
 * @since 2024-01-01
 */

import map from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import hilog from '@ohos.hilog';
import { MapService } from './MapService';

const TAG = 'NavigationService';
const DOMAIN = 0xFF00;

/**
 * 交通方式
 */
export enum TravelMode {
  DRIVING = 'DRIVING', // 驾车
  WALKING = 'WALKING', // 步行
  BICYCLING = 'BICYCLING', // 骑行
  TRANSIT = 'TRANSIT' // 公交
}

/**
 * 路线规划请求
 */
export interface RouteRequest {
  origin: map.LatLng; // 起点
  destination: map.LatLng; // 终点
  waypoints?: map.LatLng[]; // 途径点
  travelMode: TravelMode; // 交通方式
  avoidHighways?: boolean; // 避开高速
  avoidTolls?: boolean; // 避开收费站
  avoidFerries?: boolean; // 避开轮渡
}

/**
 * 路线结果
 */
export interface RouteResult {
  routes: Route[]; // 路线列表
  status: string; // 状态
}

/**
 * 路线信息
 */
export interface Route {
  summary: string; // 摘要
  legs: RouteLeg[]; // 路段
  bounds: map.LatLngBounds; // 边界
  copyrights: string; // 版权
  warnings: string[]; // 警告
  waypointOrder: number[]; // 途径点顺序
  overviewPolyline: string; // 总体折线（编码）
}

/**
 * 路段信息
 */
export interface RouteLeg {
  distance: Distance; // 距离
  duration: Duration; // 时长
  startAddress: string; // 起点地址
  endAddress: string; // 终点地址
  startLocation: map.LatLng; // 起点坐标
  endLocation: map.LatLng; // 终点坐标
  steps: RouteStep[]; // 步骤
}

/**
 * 路线步骤
 */
export interface RouteStep {
  distance: Distance; // 距离
  duration: Duration; // 时长
  startLocation: map.LatLng; // 起点坐标
  endLocation: map.LatLng; // 终点坐标
  instruction: string; // 指令
  maneuver: string; // 动作
  polyline: string; // 折线（编码）
  travelMode: TravelMode; // 交通方式
}

/**
 * 距离信息
 */
export interface Distance {
  value: number; // 值（米）
  text: string; // 文本（如"1.2公里"）
}

/**
 * 时长信息
 */
export interface Duration {
  value: number; // 值（秒）
  text: string; // 文本（如"15分钟"）
}

/**
 * 导航状态
 */
export enum NavigationStatus {
  IDLE = 'IDLE', // 空闲
  PLANNING = 'PLANNING', // 规划中
  NAVIGATING = 'NAVIGATING', // 导航中
  ARRIVED = 'ARRIVED', // 已到达
  REROUTING = 'REROUTING', // 重新规划中
  ERROR = 'ERROR' // 错误
}

/**
 * 导航信息
 */
export interface NavigationInfo {
  currentStep: RouteStep | null; // 当前步骤
  nextStep: RouteStep | null; // 下一步骤
  remainingDistance: number; // 剩余距离（米）
  remainingTime: number; // 剩余时间（秒）
  currentLocation: map.LatLng; // 当前位置
  distanceToNextTurn: number; // 到下一个转弯的距离（米）
  instruction: string; // 当前指令
}

/**
 * 导航服务类
 */
export class NavigationService {
  private static instance: NavigationService;
  private currentRoute: Route | null = null;
  private currentLegIndex: number = 0;
  private currentStepIndex: number = 0;
  private navigationStatus: NavigationStatus = NavigationStatus.IDLE;
  private navigationCallback: ((info: NavigationInfo) => void) | null = null;
  private locationCallback: ((location: geoLocationManager.Location) => void) | null = null;

  /**
   * 获取单例实例
   */
  public static getInstance(): NavigationService {
    if (!NavigationService.instance) {
      NavigationService.instance = new NavigationService();
    }
    return NavigationService.instance;
  }

  // ==================== 路线规划 ====================

  /**
   * 规划路线
   */
  public async planRoute(request: RouteRequest): Promise<RouteResult | null> {
    this.navigationStatus = NavigationStatus.PLANNING;
    hilog.info(DOMAIN, TAG, `Planning route from (${request.origin.latitude}, ${request.origin.longitude}) to (${request.destination.latitude}, ${request.destination.longitude})`);

    try {
      // 模拟路线规划（实际应调用地图服务API）
      const route = await this.simulateRoutePlanning(request);
      
      const result: RouteResult = {
        routes: [route],
        status: 'OK'
      };

      this.currentRoute = route;
      this.currentLegIndex = 0;
      this.currentStepIndex = 0;
      this.navigationStatus = NavigationStatus.IDLE;

      hilog.info(DOMAIN, TAG, `Route planned successfully, total distance: ${route.legs[0].distance.text}, duration: ${route.legs[0].duration.text}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to plan route: ${JSON.stringify(error)}`);
      this.navigationStatus = NavigationStatus.ERROR;
      return null;
    }
  }

  /**
   * 模拟路线规划（实际应调用地图API）
   */
  private async simulateRoutePlanning(request: RouteRequest): Promise<Route> {
    const distance = MapService.calculateDistance(request.origin, request.destination);
    const steps: RouteStep[] = [];

    // 创建简单的直线路线
    const stepCount = Math.max(3, Math.floor(distance / 500)); // 每500米一个步骤
    const latStep = (request.destination.latitude - request.origin.latitude) / stepCount;
    const lngStep = (request.destination.longitude - request.origin.longitude) / stepCount;

    for (let i = 0; i < stepCount; i++) {
      const startLat = request.origin.latitude + latStep * i;
      const startLng = request.origin.longitude + lngStep * i;
      const endLat = request.origin.latitude + latStep * (i + 1);
      const endLng = request.origin.longitude + lngStep * (i + 1);

      const stepDistance = MapService.calculateDistance(
        { latitude: startLat, longitude: startLng },
        { latitude: endLat, longitude: endLng }
      );

      const instruction = this.generateInstruction(i, stepCount, request.travelMode);

      steps.push({
        distance: {
          value: stepDistance,
          text: MapService.formatDistance(stepDistance)
        },
        duration: {
          value: Math.round(stepDistance / this.getSpeed(request.travelMode)),
          text: this.formatDuration(Math.round(stepDistance / this.getSpeed(request.travelMode)))
        },
        startLocation: { latitude: startLat, longitude: startLng },
        endLocation: { latitude: endLat, longitude: endLng },
        instruction: instruction,
        maneuver: i === 0 ? 'depart' : (i === stepCount - 1 ? 'arrive' : 'turn-slight-right'),
        polyline: '',
        travelMode: request.travelMode
      });
    }

    const totalDistance = distance;
    const totalDuration = Math.round(totalDistance / this.getSpeed(request.travelMode));

    const leg: RouteLeg = {
      distance: {
        value: totalDistance,
        text: MapService.formatDistance(totalDistance)
      },
      duration: {
        value: totalDuration,
        text: this.formatDuration(totalDuration)
      },
      startAddress: '起点',
      endAddress: '终点',
      startLocation: request.origin,
      endLocation: request.destination,
      steps: steps
    };

    const route: Route = {
      summary: `${this.getTravelModeName(request.travelMode)}路线`,
      legs: [leg],
      bounds: {
        southwest: {
          latitude: Math.min(request.origin.latitude, request.destination.latitude),
          longitude: Math.min(request.origin.longitude, request.destination.longitude)
        },
        northeast: {
          latitude: Math.max(request.origin.latitude, request.destination.latitude),
          longitude: Math.max(request.origin.longitude, request.destination.longitude)
        }
      },
      copyrights: 'SmartTravel Map Data',
      warnings: [],
      waypointOrder: [],
      overviewPolyline: ''
    };

    return route;
  }

  /**
   * 获取交通方式速度（米/秒）
   */
  private getSpeed(mode: TravelMode): number {
    switch (mode) {
      case TravelMode.DRIVING:
        return 13.9; // 50公里/小时
      case TravelMode.WALKING:
        return 1.4; // 5公里/小时
      case TravelMode.BICYCLING:
        return 4.2; // 15公里/小时
      case TravelMode.TRANSIT:
        return 8.3; // 30公里/小时
      default:
        return 1.4;
    }
  }

  /**
   * 获取交通方式名称
   */
  private getTravelModeName(mode: TravelMode): string {
    switch (mode) {
      case TravelMode.DRIVING:
        return '驾车';
      case TravelMode.WALKING:
        return '步行';
      case TravelMode.BICYCLING:
        return '骑行';
      case TravelMode.TRANSIT:
        return '公交';
      default:
        return '未知';
    }
  }

  /**
   * 生成导航指令
   */
  private generateInstruction(stepIndex: number, totalSteps: number, mode: TravelMode): string {
    if (stepIndex === 0) {
      return `从起点出发，沿当前道路${this.getTravelModeName(mode)}`;
    } else if (stepIndex === totalSteps - 1) {
      return '到达目的地';
    } else {
      const directions = ['直行', '右转', '左转', '向右前方行驶', '向左前方行驶'];
      return directions[stepIndex % directions.length];
    }
  }

  /**
   * 格式化时长
   */
  private formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);

    if (hours > 0) {
      return `${hours}小时${minutes}分钟`;
    } else if (minutes > 0) {
      return `${minutes}分钟`;
    } else {
      return `${seconds}秒`;
    }
  }

  // ==================== 实时导航 ====================

  /**
   * 开始导航
   */
  public startNavigation(callback: (info: NavigationInfo) => void): void {
    if (!this.currentRoute) {
      hilog.error(DOMAIN, TAG, 'No route available for navigation');
      return;
    }

    this.navigationStatus = NavigationStatus.NAVIGATING;
    this.navigationCallback = callback;
    this.currentLegIndex = 0;
    this.currentStepIndex = 0;

    // 开始位置监听
    this.startLocationTracking();

    hilog.info(DOMAIN, TAG, 'Navigation started');
  }

  /**
   * 停止导航
   */
  public stopNavigation(): void {
    this.navigationStatus = NavigationStatus.IDLE;
    this.navigationCallback = null;
    this.stopLocationTracking();
    hilog.info(DOMAIN, TAG, 'Navigation stopped');
  }

  /**
   * 开始位置追踪
   */
  private startLocationTracking(): void {
    const request: geoLocationManager.ContinuousLocationRequest = {
      interval: 1, // 1秒更新一次
      locationScenario: geoLocationManager.LocationScenario.NAVIGATION
    };

    this.locationCallback = (location: geoLocationManager.Location) => {
      this.onLocationUpdate(location);
    };

    try {
      geoLocationManager.on('locationChange', request, this.locationCallback);
      hilog.info(DOMAIN, TAG, 'Location tracking started');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to start location tracking: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 停止位置追踪
   */
  private stopLocationTracking(): void {
    if (this.locationCallback) {
      try {
        geoLocationManager.off('locationChange', this.locationCallback);
        hilog.info(DOMAIN, TAG, 'Location tracking stopped');
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to stop location tracking: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 位置更新回调
   */
  private onLocationUpdate(location: geoLocationManager.Location): void {
    if (!this.currentRoute || !this.navigationCallback) {
      return;
    }

    const currentLocation: map.LatLng = {
      latitude: location.latitude,
      longitude: location.longitude
    };

    // 获取当前路段和步骤
    const currentLeg = this.currentRoute.legs[this.currentLegIndex];
    const currentStep = currentLeg.steps[this.currentStepIndex];
    const nextStep = this.currentStepIndex < currentLeg.steps.length - 1 
      ? currentLeg.steps[this.currentStepIndex + 1] 
      : null;

    // 计算到当前步骤终点的距离
    const distanceToStepEnd = MapService.calculateDistance(
      currentLocation,
      currentStep.endLocation
    );

    // 判断是否到达当前步骤终点
    if (distanceToStepEnd < 20) { // 20米内认为到达
      this.currentStepIndex++;
      
      // 判断是否到达目的地
      if (this.currentStepIndex >= currentLeg.steps.length) {
        this.navigationStatus = NavigationStatus.ARRIVED;
        hilog.info(DOMAIN, TAG, 'Arrived at destination');
      }
    }

    // 计算剩余距离和时间
    let remainingDistance = 0;
    let remainingTime = 0;
    
    for (let i = this.currentStepIndex; i < currentLeg.steps.length; i++) {
      remainingDistance += currentLeg.steps[i].distance.value;
      remainingTime += currentLeg.steps[i].duration.value;
    }

    // 构建导航信息
    const navigationInfo: NavigationInfo = {
      currentStep: currentStep,
      nextStep: nextStep,
      remainingDistance: remainingDistance,
      remainingTime: remainingTime,
      currentLocation: currentLocation,
      distanceToNextTurn: distanceToStepEnd,
      instruction: currentStep.instruction
    };

    // 回调导航信息
    this.navigationCallback(navigationInfo);

    hilog.debug(DOMAIN, TAG, `Navigation update: ${currentStep.instruction}, remaining: ${MapService.formatDistance(remainingDistance)}`);
  }

  // ==================== 工具方法 ====================

  /**
   * 获取当前路线
   */
  public getCurrentRoute(): Route | null {
    return this.currentRoute;
  }

  /**
   * 获取导航状态
   */
  public getNavigationStatus(): NavigationStatus {
    return this.navigationStatus;
  }

  /**
   * 清除路线
   */
  public clearRoute(): void {
    this.currentRoute = null;
    this.currentLegIndex = 0;
    this.currentStepIndex = 0;
    this.navigationStatus = NavigationStatus.IDLE;
    hilog.info(DOMAIN, TAG, 'Route cleared');
  }

  /**
   * 获取路线概览点集合
   */
  public getRouteOverviewPoints(): map.LatLng[] {
    if (!this.currentRoute) {
      return [];
    }

    const points: map.LatLng[] = [];
    this.currentRoute.legs.forEach(leg => {
      leg.steps.forEach(step => {
        points.push(step.startLocation);
      });
      // 添加最后一个步骤的终点
      if (leg.steps.length > 0) {
        points.push(leg.steps[leg.steps.length - 1].endLocation);
      }
    });

    return points;
  }

  /**
   * 销毁服务
   */
  public destroy(): void {
    this.stopNavigation();
    this.clearRoute();
    hilog.info(DOMAIN, TAG, 'NavigationService destroyed');
  }
}
