/**
 * 地图服务类
 * 
 * 功能：
 * 1. 地图初始化与配置
 * 2. 地图控制（缩放、移动、旋转、倾斜）
 * 3. 标记点管理（添加、删除、更新）
 * 4. 路线绘制（折线、多边形）
 * 5. 坐标转换（WGS84 <-> GCJ02）
 * 6. 地图样式设置
 * 7. 地图事件监听
 * 
 * 使用场景：
 * - 景点位置展示
 * - 酒店位置标记
 * - 旅游路线规划
 * - 实时位置追踪
 * 
 * @author SmartTravel Team
 * @since 2024-01-01
 */

import map from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import hilog from '@ohos.hilog';

const TAG = 'MapService';
const DOMAIN = 0xFF00;

/**
 * 地图配置选项
 */
export interface MapOptions {
  center?: map.LatLng; // 中心点坐标
  zoom?: number; // 缩放级别 (3-20)
  bearing?: number; // 方位角 (0-360)
  tilt?: number; // 倾斜角 (0-60)
  mapType?: map.MapType; // 地图类型
  showCompass?: boolean; // 显示指南针
  showScale?: boolean; // 显示比例尺
  showZoomControls?: boolean; // 显示缩放控件
  showMyLocation?: boolean; // 显示我的位置
  enableRotate?: boolean; // 允许旋转
  enableScroll?: boolean; // 允许滚动
  enableZoom?: boolean; // 允许缩放
  enableTilt?: boolean; // 允许倾斜
}

/**
 * 标记点选项
 */
export interface MarkerOptions {
  position: map.LatLng; // 位置
  title?: string; // 标题
  snippet?: string; // 描述
  icon?: string; // 图标路径
  draggable?: boolean; // 可拖动
  visible?: boolean; // 可见性
  zIndex?: number; // 层级
  anchorU?: number; // 锚点U (0-1)
  anchorV?: number; // 锚点V (0-1)
  alpha?: number; // 透明度 (0-1)
  rotation?: number; // 旋转角度 (0-360)
}

/**
 * 折线选项
 */
export interface PolylineOptions {
  points: map.LatLng[]; // 点集合
  color?: string; // 颜色
  width?: number; // 宽度
  geodesic?: boolean; // 大地曲线
  visible?: boolean; // 可见性
  zIndex?: number; // 层级
  startCap?: map.Cap; // 起点样式
  endCap?: map.Cap; // 终点样式
  pattern?: map.PatternItem[]; // 虚线样式
}

/**
 * 多边形选项
 */
export interface PolygonOptions {
  points: map.LatLng[]; // 点集合
  strokeColor?: string; // 边框颜色
  strokeWidth?: number; // 边框宽度
  fillColor?: string; // 填充颜色
  visible?: boolean; // 可见性
  zIndex?: number; // 层级
}

/**
 * 圆形选项
 */
export interface CircleOptions {
  center: map.LatLng; // 中心点
  radius: number; // 半径 (米)
  strokeColor?: string; // 边框颜色
  strokeWidth?: number; // 边框宽度
  fillColor?: string; // 填充颜色
  visible?: boolean; // 可见性
  zIndex?: number; // 层级
}

/**
 * 坐标类型
 */
export enum CoordinateType {
  WGS84 = 'WGS84', // GPS坐标系
  GCJ02 = 'GCJ02', // 国测局坐标系（火星坐标）
  BD09 = 'BD09' // 百度坐标系
}

/**
 * 地图服务类
 */
export class MapService {
  private static instance: MapService;
  private mapController: map.MapComponentController | null = null;
  private markers: Map<string, map.Marker> = new Map();
  private polylines: Map<string, map.Polyline> = new Map();
  private polygons: Map<string, map.Polygon> = new Map();
  private circles: Map<string, map.Circle> = new Map();

  /**
   * 获取单例实例
   */
  public static getInstance(): MapService {
    if (!MapService.instance) {
      MapService.instance = new MapService();
    }
    return MapService.instance;
  }

  /**
   * 设置地图控制器
   */
  public setMapController(controller: map.MapComponentController): void {
    this.mapController = controller;
    hilog.info(DOMAIN, TAG, 'Map controller set successfully');
  }

  /**
   * 获取地图控制器
   */
  public getMapController(): map.MapComponentController | null {
    return this.mapController;
  }

  // ==================== 地图控制 ====================

  /**
   * 移动地图到指定位置
   */
  public async moveCamera(
    latitude: number,
    longitude: number,
    zoom?: number,
    duration?: number
  ): Promise<void> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const position: map.LatLng = { latitude, longitude };
      const cameraUpdate = map.newLatLng(position);
      
      if (zoom !== undefined) {
        const zoomUpdate = map.newLatLngZoom(position, zoom);
        await this.mapController.moveCamera(zoomUpdate, duration);
      } else {
        await this.mapController.moveCamera(cameraUpdate, duration);
      }

      hilog.info(DOMAIN, TAG, `Moved camera to (${latitude}, ${longitude}), zoom: ${zoom}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to move camera: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 设置缩放级别
   */
  public async setZoom(zoom: number, duration?: number): Promise<void> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const cameraUpdate = map.zoomTo(zoom);
      await this.mapController.moveCamera(cameraUpdate, duration);
      hilog.info(DOMAIN, TAG, `Set zoom level to ${zoom}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to set zoom: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 放大地图
   */
  public async zoomIn(duration?: number): Promise<void> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const cameraUpdate = map.zoomIn();
      await this.mapController.moveCamera(cameraUpdate, duration);
      hilog.info(DOMAIN, TAG, 'Zoomed in');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to zoom in: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 缩小地图
   */
  public async zoomOut(duration?: number): Promise<void> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const cameraUpdate = map.zoomOut();
      await this.mapController.moveCamera(cameraUpdate, duration);
      hilog.info(DOMAIN, TAG, 'Zoomed out');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to zoom out: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 调整地图以显示所有标记点
   */
  public async fitBounds(
    points: map.LatLng[],
    padding?: number,
    duration?: number
  ): Promise<void> {
    if (!this.mapController || points.length === 0) {
      return;
    }

    try {
      // 计算边界
      let minLat = points[0].latitude;
      let maxLat = points[0].latitude;
      let minLng = points[0].longitude;
      let maxLng = points[0].longitude;

      points.forEach(point => {
        minLat = Math.min(minLat, point.latitude);
        maxLat = Math.max(maxLat, point.latitude);
        minLng = Math.min(minLng, point.longitude);
        maxLng = Math.max(maxLng, point.longitude);
      });

      const southwest: map.LatLng = { latitude: minLat, longitude: minLng };
      const northeast: map.LatLng = { latitude: maxLat, longitude: maxLng };
      const bounds: map.LatLngBounds = { southwest, northeast };

      const paddingValue = padding || 100;
      const cameraUpdate = map.newLatLngBounds(bounds, paddingValue);
      await this.mapController.moveCamera(cameraUpdate, duration);

      hilog.info(DOMAIN, TAG, `Fit bounds for ${points.length} points`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to fit bounds: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 标记点管理 ====================

  /**
   * 添加标记点
   */
  public async addMarker(id: string, options: MarkerOptions): Promise<map.Marker | null> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const markerOptions: map.MarkerOptions = {
        position: options.position,
        title: options.title,
        snippet: options.snippet,
        draggable: options.draggable ?? false,
        visible: options.visible ?? true,
        zIndex: options.zIndex ?? 0,
        alpha: options.alpha ?? 1.0,
        rotation: options.rotation ?? 0
      };

      // 如果有自定义图标
      if (options.icon) {
        markerOptions.icon = options.icon;
      }

      // 如果有锚点
      if (options.anchorU !== undefined && options.anchorV !== undefined) {
        markerOptions.anchorU = options.anchorU;
        markerOptions.anchorV = options.anchorV;
      }

      const marker = await this.mapController.addMarker(markerOptions);
      this.markers.set(id, marker);

      hilog.info(DOMAIN, TAG, `Added marker: ${id} at (${options.position.latitude}, ${options.position.longitude})`);
      return marker;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to add marker: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除标记点
   */
  public async removeMarker(id: string): Promise<void> {
    const marker = this.markers.get(id);
    if (marker && this.mapController) {
      try {
        await this.mapController.removeMarker(marker);
        this.markers.delete(id);
        hilog.info(DOMAIN, TAG, `Removed marker: ${id}`);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to remove marker: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 清除所有标记点
   */
  public async clearMarkers(): Promise<void> {
    if (!this.mapController) {
      return;
    }

    try {
      for (const [id, marker] of this.markers) {
        await this.mapController.removeMarker(marker);
      }
      this.markers.clear();
      hilog.info(DOMAIN, TAG, 'Cleared all markers');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to clear markers: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取标记点
   */
  public getMarker(id: string): map.Marker | undefined {
    return this.markers.get(id);
  }

  /**
   * 获取所有标记点
   */
  public getAllMarkers(): Map<string, map.Marker> {
    return this.markers;
  }

  // ==================== 路线绘制 ====================

  /**
   * 添加折线
   */
  public async addPolyline(id: string, options: PolylineOptions): Promise<map.Polyline | null> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const polylineOptions: map.PolylineOptions = {
        points: options.points,
        color: options.color || '#FF0000FF',
        width: options.width || 10,
        geodesic: options.geodesic ?? false,
        visible: options.visible ?? true,
        zIndex: options.zIndex ?? 0
      };

      if (options.startCap) {
        polylineOptions.startCap = options.startCap;
      }
      if (options.endCap) {
        polylineOptions.endCap = options.endCap;
      }
      if (options.pattern) {
        polylineOptions.pattern = options.pattern;
      }

      const polyline = await this.mapController.addPolyline(polylineOptions);
      this.polylines.set(id, polyline);

      hilog.info(DOMAIN, TAG, `Added polyline: ${id} with ${options.points.length} points`);
      return polyline;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to add polyline: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除折线
   */
  public async removePolyline(id: string): Promise<void> {
    const polyline = this.polylines.get(id);
    if (polyline && this.mapController) {
      try {
        await this.mapController.removePolyline(polyline);
        this.polylines.delete(id);
        hilog.info(DOMAIN, TAG, `Removed polyline: ${id}`);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to remove polyline: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 清除所有折线
   */
  public async clearPolylines(): Promise<void> {
    if (!this.mapController) {
      return;
    }

    try {
      for (const [id, polyline] of this.polylines) {
        await this.mapController.removePolyline(polyline);
      }
      this.polylines.clear();
      hilog.info(DOMAIN, TAG, 'Cleared all polylines');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to clear polylines: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 添加多边形
   */
  public async addPolygon(id: string, options: PolygonOptions): Promise<map.Polygon | null> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const polygonOptions: map.PolygonOptions = {
        points: options.points,
        strokeColor: options.strokeColor || '#FF0000FF',
        strokeWidth: options.strokeWidth || 10,
        fillColor: options.fillColor || '#550000FF',
        visible: options.visible ?? true,
        zIndex: options.zIndex ?? 0
      };

      const polygon = await this.mapController.addPolygon(polygonOptions);
      this.polygons.set(id, polygon);

      hilog.info(DOMAIN, TAG, `Added polygon: ${id} with ${options.points.length} points`);
      return polygon;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to add polygon: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除多边形
   */
  public async removePolygon(id: string): Promise<void> {
    const polygon = this.polygons.get(id);
    if (polygon && this.mapController) {
      try {
        await this.mapController.removePolygon(polygon);
        this.polygons.delete(id);
        hilog.info(DOMAIN, TAG, `Removed polygon: ${id}`);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to remove polygon: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 添加圆形
   */
  public async addCircle(id: string, options: CircleOptions): Promise<map.Circle | null> {
    if (!this.mapController) {
      throw new Error('Map controller not initialized');
    }

    try {
      const circleOptions: map.CircleOptions = {
        center: options.center,
        radius: options.radius,
        strokeColor: options.strokeColor || '#FF0000FF',
        strokeWidth: options.strokeWidth || 10,
        fillColor: options.fillColor || '#550000FF',
        visible: options.visible ?? true,
        zIndex: options.zIndex ?? 0
      };

      const circle = await this.mapController.addCircle(circleOptions);
      this.circles.set(id, circle);

      hilog.info(DOMAIN, TAG, `Added circle: ${id} at (${options.center.latitude}, ${options.center.longitude}), radius: ${options.radius}m`);
      return circle;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to add circle: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除圆形
   */
  public async removeCircle(id: string): Promise<void> {
    const circle = this.circles.get(id);
    if (circle && this.mapController) {
      try {
        await this.mapController.removeCircle(circle);
        this.circles.delete(id);
        hilog.info(DOMAIN, TAG, `Removed circle: ${id}`);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to remove circle: ${JSON.stringify(error)}`);
      }
    }
  }

  // ==================== 坐标转换 ====================

  /**
   * WGS84转GCJ02 (GPS坐标转火星坐标)
   */
  public static wgs84ToGcj02(latitude: number, longitude: number): map.LatLng {
    // 简化版坐标转换算法
    // 实际应用中建议使用专业的坐标转换库
    const a = 6378245.0; // 长半轴
    const ee = 0.00669342162296594323; // 偏心率平方

    let dLat = MapService.transformLat(longitude - 105.0, latitude - 35.0);
    let dLng = MapService.transformLng(longitude - 105.0, latitude - 35.0);
    const radLat = latitude / 180.0 * Math.PI;
    let magic = Math.sin(radLat);
    magic = 1 - ee * magic * magic;
    const sqrtMagic = Math.sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * Math.PI);
    dLng = (dLng * 180.0) / (a / sqrtMagic * Math.cos(radLat) * Math.PI);

    return {
      latitude: latitude + dLat,
      longitude: longitude + dLng
    };
  }

  /**
   * GCJ02转WGS84 (火星坐标转GPS坐标)
   */
  public static gcj02ToWgs84(latitude: number, longitude: number): map.LatLng {
    const gcj = MapService.wgs84ToGcj02(latitude, longitude);
    return {
      latitude: latitude * 2 - gcj.latitude,
      longitude: longitude * 2 - gcj.longitude
    };
  }

  private static transformLat(x: number, y: number): number {
    let ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x));
    ret += (20.0 * Math.sin(6.0 * x * Math.PI) + 20.0 * Math.sin(2.0 * x * Math.PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(y * Math.PI) + 40.0 * Math.sin(y / 3.0 * Math.PI)) * 2.0 / 3.0;
    ret += (160.0 * Math.sin(y / 12.0 * Math.PI) + 320 * Math.sin(y * Math.PI / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  private static transformLng(x: number, y: number): number {
    let ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x));
    ret += (20.0 * Math.sin(6.0 * x * Math.PI) + 20.0 * Math.sin(2.0 * x * Math.PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(x * Math.PI) + 40.0 * Math.sin(x / 3.0 * Math.PI)) * 2.0 / 3.0;
    ret += (150.0 * Math.sin(x / 12.0 * Math.PI) + 300.0 * Math.sin(x / 30.0 * Math.PI)) * 2.0 / 3.0;
    return ret;
  }

  // ==================== 距离计算 ====================

  /**
   * 计算两点间距离（米）
   */
  public static calculateDistance(point1: map.LatLng, point2: map.LatLng): number {
    const R = 6371000; // 地球半径（米）
    const lat1 = point1.latitude * Math.PI / 180;
    const lat2 = point2.latitude * Math.PI / 180;
    const deltaLat = (point2.latitude - point1.latitude) * Math.PI / 180;
    const deltaLng = (point2.longitude - point1.longitude) * Math.PI / 180;

    const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
      Math.cos(lat1) * Math.cos(lat2) *
      Math.sin(deltaLng / 2) * Math.sin(deltaLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  /**
   * 格式化距离显示
   */
  public static formatDistance(distance: number): string {
    if (distance < 1000) {
      return `${Math.round(distance)}米`;
    } else {
      return `${(distance / 1000).toFixed(1)}公里`;
    }
  }

  // ==================== 清理资源 ====================

  /**
   * 清除所有覆盖物
   */
  public async clearAll(): Promise<void> {
    await this.clearMarkers();
    await this.clearPolylines();
    for (const [id, polygon] of this.polygons) {
      await this.removePolygon(id);
    }
    for (const [id, circle] of this.circles) {
      await this.removeCircle(id);
    }
    hilog.info(DOMAIN, TAG, 'Cleared all overlays');
  }

  /**
   * 销毁服务
   */
  public destroy(): void {
    this.clearAll();
    this.mapController = null;
    hilog.info(DOMAIN, TAG, 'MapService destroyed');
  }
}
