import { rcp } from '@kit.RemoteCommunicationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RcpService } from '../services/RcpService';
import {
  ResponseCache,
  ResponseCachingInterceptor,
  LoggingInterceptor,
  AuthenticationInterceptor,
  RetryInterceptor
} from '../interceptors/RcpInterceptors';

const TAG = 'SmartTravelRcpApi';
const DOMAIN = 0xFF00;

/**
 * API 响应接口
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * 用户信息接口
 */
export interface UserInfo {
  userId?: string;
  userName?: string;
  userGender?: string;
  userAge?: number;
  userEmail?: string;
  userPhone?: string;
  userAvatar?: string;
}

/**
 * SmartTravel RCP API 服务
 * 使用 RCP 实现高级网络请求功能
 * 
 * 功能特性：
 * - 响应缓存
 * - 请求日志
 * - 自动认证
 * - 失败重试
 * - PATCH 请求支持
 * - 多表单提交
 */
export class SmartTravelRcpApi {
  private static instance: SmartTravelRcpApi;
  private rcpService: RcpService;
  private session: rcp.Session | null = null;
  private cache: ResponseCache;
  private authInterceptor: AuthenticationInterceptor;

  private constructor() {
    this.rcpService = RcpService.getInstance();
    this.cache = new ResponseCache();
    this.authInterceptor = new AuthenticationInterceptor();
    this.initSessionWithInterceptors();
  }

  public static getInstance(): SmartTravelRcpApi {
    if (!SmartTravelRcpApi.instance) {
      SmartTravelRcpApi.instance = new SmartTravelRcpApi();
    }
    return SmartTravelRcpApi.instance;
  }

  /**
   * 初始化带拦截器的会话
   */
  private initSessionWithInterceptors(): void {
    try {
      const sessionConfig: rcp.SessionConfiguration = {
        baseAddress: 'https://api.smarttravel.com',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        // 配置拦截器链
        interceptors: [
          new LoggingInterceptor(),              // 日志拦截器
          this.authInterceptor,                   // 认证拦截器
          new ResponseCachingInterceptor(this.cache), // 缓存拦截器
          new RetryInterceptor(3, 1000)          // 重试拦截器（最多3次，间隔1秒）
        ],
        requestConfiguration: {
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          },
          transfer: {
            timeout: {
              connectMs: 10000,
              transferMs: 60000
            }
          }
        }
      };

      this.session = rcp.createSession(sessionConfig);
      hilog.info(DOMAIN, TAG, 'Session with interceptors initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize session: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 设置认证令牌
   */
  public setAuthToken(token: string): void {
    this.authInterceptor.setAuthToken(token);
  }

  /**
   * 清除认证令牌
   */
  public clearAuthToken(): void {
    this.authInterceptor.clearAuthToken();
  }

  /**
   * 清除缓存
   */
  public clearCache(): void {
    this.cache.clearCache();
    hilog.info(DOMAIN, TAG, 'Cache cleared');
  }

  /**
   * 获取缓存大小
   */
  public getCacheSize(): number {
    return this.cache.getCacheSize();
  }

  // ==================== 用户相关 API ====================

  /**
   * 用户登录
   */
  public async login(username: string, password: string): Promise<{ token: string; user: UserInfo }> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Login: ${username}`);

      const request = new rcp.Request(
        '/auth/login',
        'POST',
        { 'Content-Type': 'application/json' },
        { username, password }
      );

      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<{ token: string; user: UserInfo }>;

      if (result.code === 0) {
        this.setAuthToken(result.data.token);
        return result.data;
      } else {
        throw new Error(result.message || 'Login failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Login failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 更新用户信息（使用 PATCH）
   * PATCH 请求只更新部分字段
   */
  public async updateUserInfo(userId: string, updates: Partial<UserInfo>): Promise<UserInfo> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Update user info: ${userId}`);

      const request = new rcp.Request(
        `/users/${userId}`,
        'PATCH',
        { 'Content-Type': 'application/json' },
        updates
      );

      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<UserInfo>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Update failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Update user info failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 获取用户信息
   */
  public async getUserInfo(userId: string): Promise<UserInfo> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Get user info: ${userId}`);

      const request = new rcp.Request(`/users/${userId}`, 'GET');
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<UserInfo>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Get user info failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Get user info failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 攻略相关 API ====================

  /**
   * 获取攻略列表（使用缓存）
   */
  public async getGuideList(page: number = 1, pageSize: number = 10): Promise<any[]> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Get guide list: page=${page}, pageSize=${pageSize}`);

      const request = new rcp.Request(`/guides?page=${page}&pageSize=${pageSize}`, 'GET');
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<any[]>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Get guide list failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Get guide list failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 搜索攻略
   */
  public async searchGuides(keyword: string): Promise<any[]> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Search guides: ${keyword}`);

      const request = new rcp.Request(`/guides/search?keyword=${encodeURIComponent(keyword)}`, 'GET');
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<any[]>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Search failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search guides failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 酒店相关 API ====================

  /**
   * 搜索酒店
   */
  public async searchHotels(params: {
    city: string;
    checkInDate: string;
    checkOutDate: string;
    guests?: number;
  }): Promise<any[]> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Search hotels: ${params.city}`);

      const queryString = new URLSearchParams({
        city: params.city,
        checkIn: params.checkInDate,
        checkOut: params.checkOutDate,
        guests: String(params.guests || 1)
      }).toString();

      const request = new rcp.Request(`/hotels/search?${queryString}`, 'GET');
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<any[]>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Search hotels failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search hotels failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 创建酒店预订（使用多表单）
   */
  public async createHotelBooking(bookingData: {
    hotelId: string;
    roomType: string;
    checkInDate: string;
    checkOutDate: string;
    guestName: string;
    guestPhone: string;
    specialRequests?: string;
  }): Promise<{ orderId: string; orderNo: string }> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Create hotel booking: ${bookingData.hotelId}`);

      // 使用多表单提交
      const formData: Record<string, string> = {
        hotelId: bookingData.hotelId,
        roomType: bookingData.roomType,
        checkInDate: bookingData.checkInDate,
        checkOutDate: bookingData.checkOutDate,
        guestName: bookingData.guestName,
        guestPhone: bookingData.guestPhone
      };

      if (bookingData.specialRequests) {
        formData.specialRequests = bookingData.specialRequests;
      }

      const multiForm = new rcp.MultipartForm(formData);
      const request = new rcp.Request('/hotels/bookings', 'POST', {}, multiForm);
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<{ orderId: string; orderNo: string }>;

      if (result.code === 0) {
        return result.data;
      } else {
        throw new Error(result.message || 'Create booking failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Create hotel booking failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 文件上传 API ====================

  /**
   * 上传头像
   */
  public async uploadAvatar(filePath: string): Promise<string> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Upload avatar: ${filePath}`);

      const multiForm = new rcp.MultipartForm({
        'avatar': {
          contentType: 'image/jpeg',
          remoteFileName: filePath.split('/').pop() || 'avatar.jpg',
          contentOrPath: filePath
        }
      });

      const request = new rcp.Request('/users/avatar', 'POST', {}, multiForm);
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<{ url: string }>;

      if (result.code === 0) {
        return result.data.url;
      } else {
        throw new Error(result.message || 'Upload avatar failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Upload avatar failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 上传攻略图片（多图）
   */
  public async uploadGuideImages(filePaths: string[]): Promise<string[]> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      hilog.info(DOMAIN, TAG, `Upload ${filePaths.length} images`);

      const formData: Record<string, string | rcp.MultipartFormValue> = {};

      filePaths.forEach((filePath, index) => {
        formData[`image${index}`] = {
          contentType: 'image/jpeg',
          remoteFileName: filePath.split('/').pop() || `image${index}.jpg`,
          contentOrPath: filePath
        };
      });

      const multiForm = new rcp.MultipartForm(formData);
      const request = new rcp.Request('/guides/images', 'POST', {}, multiForm);
      const response = await this.session.fetch(request);
      const result = response.result as ApiResponse<{ urls: string[] }>;

      if (result.code === 0) {
        return result.data.urls;
      } else {
        throw new Error(result.message || 'Upload images failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Upload guide images failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  // ==================== 工具方法 ====================

  /**
   * 健康检查
   */
  public async healthCheck(): Promise<boolean> {
    if (!this.session) {
      throw new Error('Session not initialized');
    }

    try {
      const request = new rcp.Request('/health', 'GET');
      const response = await this.session.fetch(request);
      return response.statusCode === 200;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Health check failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
}
