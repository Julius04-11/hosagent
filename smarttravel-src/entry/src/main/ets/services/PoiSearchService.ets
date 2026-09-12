/**
 * POI搜索服务类
 * 
 * 功能：
 * 1. 关键词搜索（景点、酒店、餐厅等）
 * 2. 周边搜索（附近的POI）
 * 3. 区域搜索（指定范围内的POI）
 * 4. POI详情查询
 * 5. 地理编码（地址转坐标）
 * 6. 逆地理编码（坐标转地址）
 * 
 * 使用场景：
 * - 搜索附近的景点
 * - 查找酒店位置
 * - 搜索餐厅
 * - 地址解析
 * 
 * @author SmartTravel Team
 * @since 2024-01-01
 */

import map from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import hilog from '@ohos.hilog';
import { MapService } from './MapService';

const TAG = 'PoiSearchService';
const DOMAIN = 0xFF00;

/**
 * POI类型
 */
export enum PoiType {
  SCENIC_SPOT = 'SCENIC_SPOT', // 景点
  HOTEL = 'HOTEL', // 酒店
  RESTAURANT = 'RESTAURANT', // 餐厅
  SHOPPING = 'SHOPPING', // 购物
  PARKING = 'PARKING', // 停车场
  GAS_STATION = 'GAS_STATION', // 加油站
  HOSPITAL = 'HOSPITAL', // 医院
  BANK = 'BANK', // 银行
  ATM = 'ATM', // ATM
  TOILET = 'TOILET', // 厕所
  BUS_STATION = 'BUS_STATION', // 公交站
  SUBWAY_STATION = 'SUBWAY_STATION', // 地铁站
  ALL = 'ALL' // 全部
}

/**
 * 搜索请求
 */
export interface PoiSearchRequest {
  keyword?: string; // 关键词
  location?: map.LatLng; // 中心位置
  radius?: number; // 搜索半径（米）
  types?: PoiType[]; // POI类型
  bounds?: map.LatLngBounds; // 搜索范围
  pageSize?: number; // 每页数量
  pageNum?: number; // 页码
}

/**
 * 搜索结果
 */
export interface PoiSearchResult {
  pois: PoiInfo[]; // POI列表
  total: number; // 总数
  pageNum: number; // 当前页
  pageSize: number; // 每页数量
  hasMore: boolean; // 是否还有更多
}

/**
 * POI信息
 */
export interface PoiInfo {
  id: string; // ID
  name: string; // 名称
  type: PoiType; // 类型
  location: map.LatLng; // 位置
  address: string; // 地址
  distance?: number; // 距离（米）
  phone?: string; // 电话
  rating?: number; // 评分
  priceLevel?: number; // 价格等级
  openingHours?: string; // 营业时间
  photos?: string[]; // 照片
  website?: string; // 网站
  description?: string; // 描述
}

/**
 * 地理编码请求
 */
export interface GeocodeRequest {
  address: string; // 地址
  city?: string; // 城市
}

/**
 * 地理编码结果
 */
export interface GeocodeResult {
  location: map.LatLng; // 坐标
  formattedAddress: string; // 格式化地址
  addressComponents: AddressComponents; // 地址组件
}

/**
 * 地址组件
 */
export interface AddressComponents {
  country?: string; // 国家
  province?: string; // 省份
  city?: string; // 城市
  district?: string; // 区县
  street?: string; // 街道
  streetNumber?: string; // 门牌号
}

/**
 * 逆地理编码请求
 */
export interface ReverseGeocodeRequest {
  location: map.LatLng; // 坐标
}

/**
 * 逆地理编码结果
 */
export interface ReverseGeocodeResult {
  formattedAddress: string; // 格式化地址
  addressComponents: AddressComponents; // 地址组件
  pois?: PoiInfo[]; // 附近的POI
}

/**
 * POI搜索服务类
 */
export class PoiSearchService {
  private static instance: PoiSearchService;

  /**
   * 获取单例实例
   */
  public static getInstance(): PoiSearchService {
    if (!PoiSearchService.instance) {
      PoiSearchService.instance = new PoiSearchService();
    }
    return PoiSearchService.instance;
  }

  // ==================== POI搜索 ====================

  /**
   * 关键词搜索
   */
  public async searchByKeyword(request: PoiSearchRequest): Promise<PoiSearchResult> {
    hilog.info(DOMAIN, TAG, `Searching POI by keyword: ${request.keyword}`);

    try {
      // 模拟POI搜索（实际应调用地图API）
      const pois = await this.simulatePoiSearch(request);

      const pageSize = request.pageSize || 20;
      const pageNum = request.pageNum || 1;
      const startIndex = (pageNum - 1) * pageSize;
      const endIndex = startIndex + pageSize;

      const result: PoiSearchResult = {
        pois: pois.slice(startIndex, endIndex),
        total: pois.length,
        pageNum: pageNum,
        pageSize: pageSize,
        hasMore: endIndex < pois.length
      };

      hilog.info(DOMAIN, TAG, `Found ${result.pois.length} POIs`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search POI: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 周边搜索
   */
  public async searchNearby(request: PoiSearchRequest): Promise<PoiSearchResult> {
    if (!request.location) {
      throw new Error('Location is required for nearby search');
    }

    hilog.info(DOMAIN, TAG, `Searching nearby POI at (${request.location.latitude}, ${request.location.longitude})`);

    try {
      // 模拟周边搜索
      const pois = await this.simulateNearbySearch(request);

      // 计算距离并排序
      pois.forEach(poi => {
        if (request.location) {
          poi.distance = MapService.calculateDistance(request.location, poi.location);
        }
      });

      pois.sort((a, b) => (a.distance || 0) - (b.distance || 0));

      const pageSize = request.pageSize || 20;
      const pageNum = request.pageNum || 1;
      const startIndex = (pageNum - 1) * pageSize;
      const endIndex = startIndex + pageSize;

      const result: PoiSearchResult = {
        pois: pois.slice(startIndex, endIndex),
        total: pois.length,
        pageNum: pageNum,
        pageSize: pageSize,
        hasMore: endIndex < pois.length
      };

      hilog.info(DOMAIN, TAG, `Found ${result.pois.length} nearby POIs`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search nearby POI: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 区域搜索
   */
  public async searchInBounds(request: PoiSearchRequest): Promise<PoiSearchResult> {
    if (!request.bounds) {
      throw new Error('Bounds is required for region search');
    }

    hilog.info(DOMAIN, TAG, 'Searching POI in bounds');

    try {
      const pois = await this.simulatePoiSearch(request);

      // 过滤在区域内的POI
      const poisInBounds = pois.filter(poi => {
        if (!request.bounds) return false;
        return poi.location.latitude >= request.bounds.southwest.latitude &&
          poi.location.latitude <= request.bounds.northeast.latitude &&
          poi.location.longitude >= request.bounds.southwest.longitude &&
          poi.location.longitude <= request.bounds.northeast.longitude;
      });

      const pageSize = request.pageSize || 20;
      const pageNum = request.pageNum || 1;
      const startIndex = (pageNum - 1) * pageSize;
      const endIndex = startIndex + pageSize;

      const result: PoiSearchResult = {
        pois: poisInBounds.slice(startIndex, endIndex),
        total: poisInBounds.length,
        pageNum: pageNum,
        pageSize: pageSize,
        hasMore: endIndex < poisInBounds.length
      };

      hilog.info(DOMAIN, TAG, `Found ${result.pois.length} POIs in bounds`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search POI in bounds: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取POI详情
   */
  public async getPoiDetail(poiId: string): Promise<PoiInfo | null> {
    hilog.info(DOMAIN, TAG, `Getting POI detail: ${poiId}`);

    try {
      // 模拟获取POI详情（实际应调用地图API）
      const poi = await this.simulateGetPoiDetail(poiId);
      return poi;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get POI detail: ${JSON.stringify(error)}`);
      return null;
    }
  }

  // ==================== 地理编码 ====================

  /**
   * 地理编码（地址转坐标）
   */
  public async geocode(request: GeocodeRequest): Promise<GeocodeResult | null> {
    hilog.info(DOMAIN, TAG, `Geocoding address: ${request.address}`);

    try {
      // 模拟地理编码（实际应调用地图API）
      const result = await this.simulateGeocode(request);
      hilog.info(DOMAIN, TAG, `Geocoded to (${result.location.latitude}, ${result.location.longitude})`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to geocode: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 逆地理编码（坐标转地址）
   */
  public async reverseGeocode(request: ReverseGeocodeRequest): Promise<ReverseGeocodeResult | null> {
    hilog.info(DOMAIN, TAG, `Reverse geocoding location: (${request.location.latitude}, ${request.location.longitude})`);

    try {
      // 使用系统逆地理编码API
      const geoRequest: geoLocationManager.ReverseGeoCodeRequest = {
        latitude: request.location.latitude,
        longitude: request.location.longitude,
        maxItems: 1
      };

      const addresses = await geoLocationManager.getAddressesFromLocation(geoRequest);
      
      if (addresses && addresses.length > 0) {
        const address = addresses[0];
        const result: ReverseGeocodeResult = {
          formattedAddress: this.formatAddress(address),
          addressComponents: {
            country: address.countryName || undefined,
            province: address.administrativeArea || undefined,
            city: address.locality || undefined,
            district: address.subLocality || undefined,
            street: address.roadName || undefined,
            streetNumber: address.subRoadName || undefined
          }
        };

        hilog.info(DOMAIN, TAG, `Reverse geocoded to: ${result.formattedAddress}`);
        return result;
      }

      return null;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to reverse geocode: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 格式化地址
   */
  private formatAddress(address: geoLocationManager.GeoAddress): string {
    const parts: string[] = [];

    if (address.countryName) parts.push(address.countryName);
    if (address.administrativeArea) parts.push(address.administrativeArea);
    if (address.locality) parts.push(address.locality);
    if (address.subLocality) parts.push(address.subLocality);
    if (address.roadName) parts.push(address.roadName);
    if (address.subRoadName) parts.push(address.subRoadName);

    return parts.join('');
  }

  // ==================== 模拟数据 ====================

  /**
   * 模拟POI搜索
   */
  private async simulatePoiSearch(request: PoiSearchRequest): Promise<PoiInfo[]> {
    const mockPois: PoiInfo[] = [
      {
        id: 'poi_001',
        name: '西湖风景区',
        type: PoiType.SCENIC_SPOT,
        location: { latitude: 30.2594, longitude: 120.1492 },
        address: '浙江省杭州市西湖区龙井路1号',
        phone: '0571-87977767',
        rating: 4.8,
        priceLevel: 0,
        openingHours: '全天开放',
        description: '国家AAAAA级旅游景区'
      },
      {
        id: 'poi_002',
        name: '雷峰塔',
        type: PoiType.SCENIC_SPOT,
        location: { latitude: 30.2312, longitude: 120.1481 },
        address: '浙江省杭州市西湖区南山路15号',
        phone: '0571-87988881',
        rating: 4.5,
        priceLevel: 2,
        openingHours: '08:00-17:30',
        description: '西湖十景之一'
      },
      {
        id: 'poi_003',
        name: '杭州香格里拉饭店',
        type: PoiType.HOTEL,
        location: { latitude: 30.2553, longitude: 120.1445 },
        address: '浙江省杭州市西湖区北山路78号',
        phone: '0571-87977951',
        rating: 4.7,
        priceLevel: 4,
        description: '五星级酒店'
      },
      {
        id: 'poi_004',
        name: '楼外楼',
        type: PoiType.RESTAURANT,
        location: { latitude: 30.2548, longitude: 120.1453 },
        address: '浙江省杭州市西湖区孤山路30号',
        phone: '0571-87969682',
        rating: 4.6,
        priceLevel: 3,
        openingHours: '11:00-14:00, 17:00-21:00',
        description: '百年老字号'
      },
      {
        id: 'poi_005',
        name: '灵隐寺',
        type: PoiType.SCENIC_SPOT,
        location: { latitude: 30.2414, longitude: 120.0968 },
        address: '浙江省杭州市西湖区灵隐路法云弄1号',
        phone: '0571-87968665',
        rating: 4.7,
        priceLevel: 1,
        openingHours: '07:00-18:00',
        description: '中国佛教禅宗十刹之一'
      }
    ];

    // 根据关键词过滤
    let filteredPois = mockPois;
    if (request.keyword) {
      filteredPois = mockPois.filter(poi => 
        poi.name.includes(request.keyword!) || 
        poi.address.includes(request.keyword!)
      );
    }

    // 根据类型过滤
    if (request.types && request.types.length > 0 && !request.types.includes(PoiType.ALL)) {
      filteredPois = filteredPois.filter(poi => request.types!.includes(poi.type));
    }

    // 根据半径过滤
    if (request.location && request.radius) {
      filteredPois = filteredPois.filter(poi => {
        const distance = MapService.calculateDistance(request.location!, poi.location);
        return distance <= request.radius!;
      });
    }

    return filteredPois;
  }

  /**
   * 模拟周边搜索
   */
  private async simulateNearbySearch(request: PoiSearchRequest): Promise<PoiInfo[]> {
    return this.simulatePoiSearch(request);
  }

  /**
   * 模拟获取POI详情
   */
  private async simulateGetPoiDetail(poiId: string): Promise<PoiInfo> {
    const mockPois = await this.simulatePoiSearch({});
    const poi = mockPois.find(p => p.id === poiId);
    
    if (poi) {
      return poi;
    }

    throw new Error(`POI not found: ${poiId}`);
  }

  /**
   * 模拟地理编码
   */
  private async simulateGeocode(request: GeocodeRequest): Promise<GeocodeResult> {
    // 模拟地理编码结果
    return {
      location: { latitude: 30.2741, longitude: 120.1551 },
      formattedAddress: request.address,
      addressComponents: {
        country: '中国',
        province: '浙江省',
        city: '杭州市',
        district: '西湖区',
        street: '文三路',
        streetNumber: '508号'
      }
    };
  }

  /**
   * 销毁服务
   */
  public destroy(): void {
    hilog.info(DOMAIN, TAG, 'PoiSearchService destroyed');
  }
}
