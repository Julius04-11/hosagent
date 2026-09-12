/**
 * 位置信息数据模型
 */
export interface LocationInfo {
  latitude: number;
  longitude: number;
  address?: string;
  city?: string;
  province?: string;
  country?: string;
  accuracy?: number;
  timestamp?: number;
}

/**
 * 地图标记数据模型
 */
export interface MapMarker {
  id: string;
  latitude: number;
  longitude: number;
  title: string;
  description: string;
  isFavorite: boolean;
  addTime: string;
  icon: string;
  color: string;
}

/**
 * 收藏项目数据模型
 */
export interface CollectItem {
  id: string;
  latitude: number;
  longitude: number;
  title: string;
  description: string;
  addTime: string;
  icon: string;
  color: string;
}

/**
 * 收藏标记数据模型
 */
export interface CollectedMarker {
  id: string;
  latitude: number;
  longitude: number;
  simpleAddress: string;
  detailAddress: string;
  createdAt: number;
}

/**
 * 标记类别枚举
 */
export enum MarkerCategory {
  ATTRACTION = 'attraction',
  RESTAURANT = 'restaurant',
  HOTEL = 'hotel',
  SHOPPING = 'shopping',
  TRANSPORT = 'transport'
}

/**
 * 位置权限状态枚举
 */
export enum LocationPermissionStatus {
  GRANTED = 'granted',
  DENIED = 'denied',
  NEVER_ASK_AGAIN = 'never_ask_again',
  NOT_DETERMINED = 'not_determined'
}

/**
 * 位置服务状态枚举
 */
export enum LocationServiceStatus {
  AVAILABLE = 'available',
  UNAVAILABLE = 'unavailable',
  LOCATION_DISABLED = 'location_disabled',
  PERMISSION_DENIED = 'permission_denied'
}

/**
 * 地图配置接口
 */
export interface MapConfig {
  center: LocationInfo;
  zoom: number;
  markers: MapMarker[];
}

/**
 * 搜索历史项
 */
export interface SearchHistoryItem {
  id: string;
  keyword: string;
  timestamp: number;
  location?: LocationInfo;
}