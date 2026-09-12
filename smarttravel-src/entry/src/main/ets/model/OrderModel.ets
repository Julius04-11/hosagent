/**
 * 订单相关Model - 用于酒店入住评价功能
 */

import { OrderItem, OrderStatus, OrderType } from '../viewmodel/OrderViewModel';

// 酒店订单接口（扩展自OrderItem）
export interface HotelOrder extends OrderItem {
  hotelName: string;
  roomType: string;
  checkInDate: string;
  checkOutDate: string;
  guestCount: number;
  hasReview?: boolean;  // 是否已评价
}

// 使用@Observed装饰器的响应式订单类，支持状态自动更新
@Observed
export class ObservableOrder {
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
  checkInDate?: string;
  checkOutDate?: string;
  travelDate?: string;
  hotelName: string;
  roomType: string;
  guestCount: number;
  hasReview: boolean;

  constructor(order: OrderItem, hotelName?: string, roomType?: string, hasReview?: boolean) {
    this.orderId = order.orderId;
    this.type = order.type;
    this.title = order.title;
    this.description = order.description;
    this.image = order.image;
    this.status = order.status;
    this.price = order.price;
    this.quantity = order.quantity;
    this.totalAmount = order.totalAmount;
    this.createTime = order.createTime;
    this.updateTime = order.updateTime;
    this.checkInDate = order.checkInDate;
    this.checkOutDate = order.checkOutDate;
    this.travelDate = order.travelDate;
    this.hotelName = hotelName || order.title;
    this.roomType = roomType || order.description;
    this.guestCount = order.quantity;
    this.hasReview = hasReview || false;
  }

  // 更新订单状态
  updateStatus(newStatus: OrderStatus): void {
    this.status = newStatus;
    this.updateTime = Date.now();
  }

  // 标记已评价
  markAsReviewed(): void {
    this.hasReview = true;
    this.updateTime = Date.now();
  }
}

// 分组订单接口
export interface GroupedOrder {
  date: string;          // 预订日期
  orders: HotelOrder[]; // 该日期下的订单列表
}

// 评价评分接口
export interface ReviewScore {
  score: number;        // 1-5分
}

// 评价标签选项
export const REVIEW_TAGS = [
  '环境优美',
  '服务周到',
  '设施完善',
  '位置便利',
  '性价比高',
  '干净整洁',
  '早餐丰富',
  '停车方便'
];

