/**
 * 数据库扩展 - 补充缺失的表结构
 * 包含评论、订单、行程、用户设置、搜索历史等表
 */

// 评论记录表
export interface ReviewRecord {
  id?: number;
  userId: string;
  itemId: string;
  itemType: 'restaurant' | 'hotel' | 'attraction' | 'activity';
  rating: number; // 1-5星
  content: string;
  images?: string; // JSON数组
  helpful: number; // 有用数
  createdAt: number;
}

// 订单记录表
export interface OrderRecord {
  id?: number;
  userId: string;
  orderNo: string;
  itemId: string;
  itemType: 'hotel' | 'ticket' | 'tour';
  itemTitle: string;
  quantity: number;
  price: number;
  totalAmount: number;
  status: 'pending' | 'paid' | 'cancelled' | 'completed';
  paymentMethod?: string;
  contactName: string;
  contactPhone: string;
  createdAt: number;
  updatedAt: number;
}

// 行程记录表
export interface ItineraryRecord {
  id?: number;
  userId: string;
  title: string;
  destinations: string; // JSON数组
  startDate: number;
  endDate: number;
  days: number;
  budget?: number;
  status: 'planning' | 'confirmed' | 'ongoing' | 'completed';
  notes?: string;
  createdAt: number;
  updatedAt: number;
}

// 用户设置表
export interface UserSettings {
  id?: number;
  userId: string;
  language: 'zh' | 'en';
  theme: 'light' | 'dark' | 'auto';
  notificationsEnabled: boolean;
  locationEnabled: boolean;
  autoPlayVideo: boolean;
  dataS
