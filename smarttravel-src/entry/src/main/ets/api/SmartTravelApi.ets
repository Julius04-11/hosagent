import { HttpService, HttpResponseData } from '../services/HttpService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SmartTravelApi';
const DOMAIN = 0xFF00;

/**
 * 攻略数据接口
 */
export interface GuideData {
  id: string;
  title: string;
  content: string;
  images: string[];
  author: string;
  createTime: string;
}

/**
 * 景点数据接口
 */
export interface AttractionData {
  id: string;
  name: string;
  description: string;
  location: {
    latitude: number;
    longitude: number;
  };
  rating: number;
  images: string[];
}

/**
 * 酒店数据接口
 */
export interface HotelData {
  id: string;
  name: string;
  address: string;
  price: number;
  rating: number;
  facilities: string[];
}

/**
 * 用户数据接口
 */
export interface UserData {
  id: string;
  username: string;
  avatar: string;
  email: string;
}

/**
 * API 响应格式
 */
export interface ApiResponse<T = any> {
  code: number;
  message: string;
  data: T;
}

/**
 * SmartTravel API 服务
 * 封装所有业务 API 请求
 */
export class SmartTravelApi {
  private static instance: SmartTravelApi;
  private httpService: HttpService;

  private constructor() {
    this.httpService = HttpService.getInstance();
    // 设置基础 URL（从环境变量或配置文件读取）
    this.httpService.setBaseUrl('https://api.smarttravel.com');
    // 设置默认请求头
    this.httpService.setDefaultHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): SmartTravelApi {
    if (!SmartTravelApi.instance) {
      SmartTravelApi.instance = new SmartTravelApi();
    }
    return SmartTravelApi.instance;
  }

  /**
   * 设置认证令牌
   */
  public setAuthToken(token: string): void {
    this.httpService.setDefaultHeaders({
      'Authorization': `Bearer ${token}`
    });
    hilog.info(DOMAIN, TAG, 'Auth token set');
  }

  // ==================== 攻略相关 API ====================

  /**
   * 获取攻略列表
   */
  public async getGuideList(page: number = 1, pageSize: number = 10): Promise<GuideData[]> {
    try {
      const response = await this.httpService.get<ApiResponse<GuideData[]>>(
        `/guides?page=${page}&pageSize=${pageSize}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get guide list: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取攻略详情
   */
  public async getGuideDetail(id: string): Promise<GuideData> {
    try {
      const response = await this.httpService.get<ApiResponse<GuideData>>(`/guides/${id}`);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get guide detail: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 搜索攻略
   */
  public async searchGuides(keyword: string): Promise<GuideData[]> {
    try {
      const response = await this.httpService.get<ApiResponse<GuideData[]>>(
        `/guides/search?keyword=${encodeURIComponent(keyword)}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search guides: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 景点相关 API ====================

  /**
   * 获取景点列表
   */
  public async getAttractionList(city?: string): Promise<AttractionData[]> {
    try {
      const url = city ? `/attractions?city=${encodeURIComponent(city)}` : '/attractions';
      const response = await this.httpService.get<ApiResponse<AttractionData[]>>(url);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get attraction list: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取景点详情
   */
  public async getAttractionDetail(id: string): Promise<AttractionData> {
    try {
      const response = await this.httpService.get<ApiResponse<AttractionData>>(`/attractions/${id}`);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get attraction detail: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 搜索附近景点
   */
  public async searchNearbyAttractions(
    latitude: number,
    longitude: number,
    radius: number = 5000
  ): Promise<AttractionData[]> {
    try {
      const response = await this.httpService.get<ApiResponse<AttractionData[]>>(
        `/attractions/nearby?lat=${latitude}&lng=${longitude}&radius=${radius}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search nearby attractions: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 酒店相关 API ====================

  /**
   * 搜索酒店
   */
  public async searchHotels(
    city: string,
    checkInDate: string,
    checkOutDate: string
  ): Promise<HotelData[]> {
    try {
      const response = await this.httpService.get<ApiResponse<HotelData[]>>(
        `/hotels/search?city=${encodeURIComponent(city)}&checkIn=${checkInDate}&checkOut=${checkOutDate}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to search hotels: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取酒店详情
   */
  public async getHotelDetail(id: string): Promise<HotelData> {
    try {
      const response = await this.httpService.get<ApiResponse<HotelData>>(`/hotels/${id}`);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get hotel detail: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 检查酒店房间可用性
   */
  public async checkHotelAvailability(
    hotelId: string,
    checkInDate: string,
    checkOutDate: string,
    roomType?: string
  ): Promise<{ available: boolean; rooms: any[] }> {
    try {
      const response = await this.httpService.get<ApiResponse<{ available: boolean; rooms: any[] }>>(
        `/hotels/${hotelId}/availability?checkIn=${checkInDate}&checkOut=${checkOutDate}${roomType ? '&roomType=' + roomType : ''}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to check availability: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 创建酒店预订订单
   */
  public async createHotelBooking(bookingData: {
    hotelId: string;
    hotelName: string;
    roomType: string;
    checkInDate: string;
    checkOutDate: string;
    guestName: string;
    guestPhone: string;
    nights: number;
    totalPrice: number;
  }): Promise<{ orderId: string; orderNo: string }> {
    try {
      const response = await this.httpService.post<ApiResponse<{ orderId: string; orderNo: string }>>(
        '/hotels/bookings',
        bookingData
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to create booking: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取酒店预订订单详情
   */
  public async getBookingDetail(orderId: string): Promise<any> {
    try {
      const response = await this.httpService.get<ApiResponse<any>>(`/hotels/bookings/${orderId}`);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get booking detail: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 取消酒店预订
   */
  public async cancelBooking(orderId: string, reason?: string): Promise<boolean> {
    try {
      const response = await this.httpService.post<ApiResponse<boolean>>(
        `/hotels/bookings/${orderId}/cancel`,
        { reason }
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to cancel booking: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 用户相关 API ====================

  /**
   * 用户登录
   */
  public async login(username: string, password: string): Promise<{ token: string; user: UserData }> {
    try {
      const response = await this.httpService.post<ApiResponse<{ token: string; user: UserData }>>(
        '/auth/login',
        { username, password }
      );
      const result = this.handleApiResponse(response);
      // 自动设置令牌
      this.setAuthToken(result.token);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to login: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 用户注册
   */
  public async register(username: string, password: string, email: string): Promise<UserData> {
    try {
      const response = await this.httpService.post<ApiResponse<UserData>>(
        '/auth/register',
        { username, password, email }
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to register: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取用户信息
   */
  public async getUserInfo(): Promise<UserData> {
    try {
      const response = await this.httpService.get<ApiResponse<UserData>>('/user/info');
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get user info: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 更新用户信息
   */
  public async updateUserInfo(data: Partial<UserData>): Promise<UserData> {
    try {
      const response = await this.httpService.put<ApiResponse<UserData>>('/user/info', data);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to update user info: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 上传用户头像
   */
  public async uploadAvatar(filePath: string): Promise<string> {
    try {
      const response = await this.httpService.uploadFile('/user/avatar', filePath, 'avatar');
      const result = this.handleApiResponse<{ url: string }>(response);
      return result.url;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to upload avatar: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 收藏相关 API ====================

  /**
   * 添加收藏
   */
  public async addFavorite(type: 'guide' | 'attraction' | 'hotel', id: string): Promise<boolean> {
    try {
      const response = await this.httpService.post<ApiResponse<boolean>>(
        '/favorites',
        { type, id }
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to add favorite: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 移除收藏
   */
  public async removeFavorite(type: 'guide' | 'attraction' | 'hotel', id: string): Promise<boolean> {
    try {
      const response = await this.httpService.delete<ApiResponse<boolean>>(
        `/favorites/${type}/${id}`
      );
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to remove favorite: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取收藏列表
   */
  public async getFavorites(type?: 'guide' | 'attraction' | 'hotel'): Promise<any[]> {
    try {
      const url = type ? `/favorites?type=${type}` : '/favorites';
      const response = await this.httpService.get<ApiResponse<any[]>>(url);
      return this.handleApiResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get favorites: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 私有方法 ====================

  /**
   * 处理 API 响应
   */
  private handleApiResponse<T>(response: HttpResponseData<ApiResponse<T>>): T {
    const { data, statusCode } = response;

    // 检查 HTTP 状态码
    if (statusCode < 200 || statusCode >= 300) {
      throw new Error(`HTTP Error: ${statusCode}`);
    }

    // 检查业务状态码
    if (data.code !== 0 && data.code !== 200) {
      throw new Error(data.message || 'API Error');
    }

    return data.data;
  }
}

/**
 * 创建 API 服务实例
 */
export function createSmartTravelApi(): SmartTravelApi {
  return SmartTravelApi.getInstance();
}
