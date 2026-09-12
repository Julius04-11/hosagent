import { HttpUtil } from '../utils/HttpUtil';

/**
 * 旅游API接口类
 */
export class TravelApi {
  
  // 获取景点列表
  static async getAttractions(cityId: string): Promise<any[]> {
    return await HttpUtil.get(`/attractions?cityId=${cityId}`);
  }

  // 获取景点详情
  static async getAttractionDetail(id: string): Promise<any> {
    return await HttpUtil.get(`/attractions/${id}`);
  }

  // 获取活动列表
  static async getActivities(params?: {
    cityId?: string;
    category?: string;
    page?: number;
  }): Promise<any> {
    const queryParams = new URLSearchParams(params as any).toString();
    return await HttpUtil.get(`/activities?${queryParams}`);
  }

  // 活动报名
  static async signUpActivity(activityId: string, userInfo: {
    name: string;
    phone: string;
    idCard?: string;
  }): Promise<any> {
    return await HttpUtil.post(`/activities/${activityId}/signup`, userInfo);
  }

  // 获取酒店列表
  static async getHotels(params: {
    cityId: string;
    checkIn: string;
    checkOut: string;
    page?: number;
  }): Promise<any> {
    return await HttpUtil.post('/hotels/search', params);
  }

  // 创建酒店订单
  static async createHotelOrder(orderData: {
    hotelId: string;
    roomType: string;
    checkIn: string;
    checkOut: string;
    contact: Object;
  }): Promise<any> {
    return await HttpUtil.post('/hotels/orders', orderData);
  }

  // 获取用户订单列表
  static async getMyOrders(userId: string): Promise<any[]> {
    return await HttpUtil.get(`/users/${userId}/orders`);
  }

  // 提交评价
  static async submitReview(reviewData: {
    targetId: string;
    targetType: string;
    rating: number;
    content: string;
    images?: string[];
  }): Promise<any> {
    return await HttpUtil.post('/reviews', reviewData);
  }

  // 搜索
  static async search(keyword: string, type?: string): Promise<any[]> {
    return await HttpUtil.get(`/search?q=${keyword}&type=${type || 'all'}`);
  }

  // 获取用户信息
  static async getUserInfo(userId: string): Promise<any> {
    return await HttpUtil.get(`/users/${userId}`);
  }

  // 更新用户信息
  static async updateUserInfo(userId: string, userInfo: Object): Promise<any> {
    return await HttpUtil.post(`/users/${userId}`, userInfo);
  }
}
