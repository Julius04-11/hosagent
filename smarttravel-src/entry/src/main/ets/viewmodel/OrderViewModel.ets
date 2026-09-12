/**
 * 订单管理ViewModel - 管理订单相关的业务逻辑
 * 负责订单管理模型、酒店订单列表、用户评价管理、订单状态跟踪
 */

// 订单状态枚举
export enum OrderStatus {
  PENDING = 'pending',           // 待支付
  PAID = 'paid',                 // 已支付
  CONFIRMED = 'confirmed',      // 已确认
  COMPLETED = 'completed',       // 已完成
  CANCELLED = 'cancelled',       // 已取消
  REFUNDED = 'refunded'          // 已退款
}

// 订单类型枚举
export enum OrderType {
  HOTEL = 'hotel',
  ACTIVITY = 'activity',
  TRANSPORT = 'transport',
  PACKAGE = 'package'
}

// 联系信息接口
export interface ContactInfo {
  name: string;
  phone: string;
  email?: string;
}

// 位置信息接口
export interface LocationInfo {
  address: string;
  latitude?: number;
  longitude?: number;
}

// 订单统计信息接口
export interface OrderStatistics {
  total: number;
  pending: number;
  paid: number;
  completed: number;
  cancelled: number;
}

// 订单项接口
export interface OrderItem {
  orderId: string;
  type: OrderType;
  title: string;
  description: string;
  image: string;
  status: OrderStatus;
  price: number;
  quantity: number;
  totalAmount: number;
  createTime: number;
  updateTime: number;
  checkInDate?: string;         // 入住日期（酒店）
  checkOutDate?: string;         // 退房日期（酒店）
  travelDate?: string;           // 出行日期（活动/交通）
  contactInfo?: ContactInfo;
  location?: LocationInfo;
}

// 用户评价接口
export interface UserReview {
  reviewId: string;
  orderId: string;
  userId: string;
  rating: number;                // 1-5分
  content: string;
  images?: string[];
  tags?: string[];
  createTime: number;
  helpfulCount?: number;         // 有用数
}

// 订单筛选条件
export interface OrderFilter {
  status?: OrderStatus[];
  type?: OrderType[];
  startDate?: number;
  endDate?: number;
  keyword?: string;
}

export class OrderViewModel {
  // 订单列表
  orders: OrderItem[] = [];
  
  // 筛选后的订单列表
  filteredOrders: OrderItem[] = [];
  
  // 用户评价列表
  reviews: UserReview[] = [];
  
  // UI状态
  isLoading: boolean = false;
  currentFilter: OrderFilter = {};
  
  /**
   * 初始化订单数据
   */
  async initialize(): Promise<void> {
    await this.loadOrders();
    await this.loadReviews();
  }

  /**
   * 加载订单列表
   */
  async loadOrders(): Promise<OrderItem[]> {
    this.isLoading = true;
    try {
      // 这里应该调用实际的API
      // 目前使用模拟数据
      this.orders = await this.loadMockOrders();
      this.applyFilter();
      return this.orders;
    } catch (error) {
      console.error('加载订单失败:', error);
      return [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载模拟订单数据
   */
  private async loadMockOrders(): Promise<OrderItem[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const mockOrders: OrderItem[] = [
          {
            orderId: 'ORD001',
            type: OrderType.HOTEL,
            title: '深圳香格里拉大酒店',
            description: '豪华双床房',
            image: 'https://example.com/hotel1.jpg',
            status: OrderStatus.CONFIRMED,
            price: 688,
            quantity: 1,
            totalAmount: 688,
            createTime: Date.now() - 86400000,
            updateTime: Date.now() - 86400000,
            checkInDate: '2025-01-20',
            checkOutDate: '2025-01-22',
            contactInfo: {
              name: '张三',
              phone: '13800138000',
              email: 'zhangsan@example.com'
            },
            location: {
              address: '深圳市福田区益田路4088号'
            }
          },
          {
            orderId: 'ORD002',
            type: OrderType.ACTIVITY,
            title: '世界之窗国际文化节',
            description: '成人票 x2',
            image: 'https://example.com/activity1.jpg',
            status: OrderStatus.COMPLETED,
            price: 200,
            quantity: 2,
            totalAmount: 400,
            createTime: Date.now() - 172800000,
            updateTime: Date.now() - 86400000,
            travelDate: '2025-01-15',
            contactInfo: {
              name: '李四',
              phone: '13900139000'
            }
          },
          {
            orderId: 'ORD003',
            type: OrderType.TRANSPORT,
            title: '深圳-广州',
            description: '高铁二等座',
            image: 'https://example.com/transport1.jpg',
            status: OrderStatus.PAID,
            price: 79.5,
            quantity: 1,
            totalAmount: 79.5,
            createTime: Date.now() - 3600000,
            updateTime: Date.now() - 3600000,
            travelDate: '2025-01-25',
            contactInfo: {
              name: '王五',
              phone: '13700137000'
            }
          }
        ];
        resolve(mockOrders);
      }, 500);
    });
  }

  /**
   * 加载用户评价
   */
  async loadReviews(): Promise<UserReview[]> {
    try {
      // 这里应该调用实际的API
      this.reviews = await this.loadMockReviews();
      return this.reviews;
    } catch (error) {
      console.error('加载评价失败:', error);
      return [];
    }
  }

  /**
   * 加载模拟评价数据
   */
  private async loadMockReviews(): Promise<UserReview[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const mockReviews: UserReview[] = [
          {
            reviewId: 'REV001',
            orderId: 'ORD002',
            userId: 'user001',
            rating: 5,
            content: '非常棒的活动，体验感很好！',
            images: [],
            tags: ['推荐', '值得一去'],
            createTime: Date.now() - 86400000,
            helpfulCount: 12
          },
          {
            reviewId: 'REV002',
            orderId: 'ORD001',
            userId: 'user002',
            rating: 4,
            content: '酒店环境不错，服务态度很好。',
            images: [],
            tags: ['环境好', '服务好'],
            createTime: Date.now() - 172800000,
            helpfulCount: 8
          }
        ];
        resolve(mockReviews);
      }, 300);
    });
  }

  /**
   * 根据订单ID获取订单详情
   */
  getOrderById(orderId: string): OrderItem | undefined {
    return this.orders.find(order => order.orderId === orderId);
  }

  /**
   * 根据订单ID获取评价
   */
  getReviewByOrderId(orderId: string): UserReview | undefined {
    return this.reviews.find(review => review.orderId === orderId);
  }

  /**
   * 创建订单
      return null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 更新订单状态
   */
  async updateOrderStatus(orderId: string, status: OrderStatus): Promise<boolean> {
    try {
      const order = this.orders.find(o => o.orderId === orderId);
      if (order) {
        order.status = status;
        order.updateTime = Date.now();
        this.applyFilter();
        return true;
      }
      return false;
    } catch (error) {
      console.error('更新订单状态失败:', error);
      return false;
    }
  }

  /**
   * 取消订单
   */
  async cancelOrder(orderId: string): Promise<boolean> {
    return await this.updateOrderStatus(orderId, OrderStatus.CANCELLED);
  }

  /**
   * 提交评价
   */
  async submitReview(review: Partial<UserReview>): Promise<UserReview | null> {
    try {
      const newReview: UserReview = {
        reviewId: `REV${Date.now()}`,
        orderId: review.orderId || '',
        userId: review.userId || '',
        rating: review.rating || 5,
        content: review.content || '',
        images: review.images || [],
        tags: review.tags || [],
        createTime: Date.now(),
        helpfulCount: 0
      };
      
      this.reviews.unshift(newReview);
      return newReview;
    } catch (error) {
      console.error('提交评价失败:', error);
      return null;
    }
  }

  /**
   * 设置筛选条件
   */
  setFilter(filter: OrderFilter): void {
    // Manual property assignment instead of Object.assign
    if (filter.status) this.currentFilter.status = filter.status;
    if (filter.type) this.currentFilter.type = filter.type;
    if (filter.startDate) this.currentFilter.startDate = filter.startDate;
    if (filter.endDate) this.currentFilter.endDate = filter.endDate;
    if (filter.keyword) this.currentFilter.keyword = filter.keyword;
    this.applyFilter();
  }

  /**
   * 应用筛选条件
   */
  private applyFilter(): void {
    let filtered = this.orders.slice();
    
    // 按状态筛选
    if (this.currentFilter.status && this.currentFilter.status.length > 0) {
      filtered = filtered.filter(order => 
        this.currentFilter.status!.includes(order.status)
      );
    }
    
    // 按类型筛选
    if (this.currentFilter.type && this.currentFilter.type.length > 0) {
      filtered = filtered.filter(order => 
        this.currentFilter.type!.includes(order.type)
      );
    }
    
    // 按日期范围筛选
    if (this.currentFilter.startDate) {
      filtered = filtered.filter(order => 
        order.createTime >= this.currentFilter.startDate!
      );
    }
    if (this.currentFilter.endDate) {
      filtered = filtered.filter(order => 
        order.createTime <= this.currentFilter.endDate!
      );
    }
    
    // 按关键词筛选
    if (this.currentFilter.keyword) {
      const keyword = this.currentFilter.keyword.toLowerCase();
      filtered = filtered.filter(order => 
        order.title.toLowerCase().includes(keyword) ||
        order.description.toLowerCase().includes(keyword)
      );
    }
    
    this.filteredOrders = filtered;
  }

  /**
   * 清除筛选条件
   */
  clearFilter(): void {
    this.currentFilter = {};
    this.applyFilter();
  }

  /**
   * 获取订单统计信息
   */
  getOrderStatistics(): OrderStatistics {
    return {
      total: this.orders.length,
      pending: this.orders.filter(o => o.status === OrderStatus.PENDING).length,
      paid: this.orders.filter(o => o.status === OrderStatus.PAID).length,
      completed: this.orders.filter(o => o.status === OrderStatus.COMPLETED).length,
      cancelled: this.orders.filter(o => o.status === OrderStatus.CANCELLED).length
    };
  }
}

