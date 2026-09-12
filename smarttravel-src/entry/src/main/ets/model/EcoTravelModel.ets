/**
 * 环保旅行数据模型
 * 用于实现可持续发展旅行功能
 */

// 环保行为类型
export enum EcoActionType {
  WALKING = 'walking',
  CYCLING = 'cycling',
  PUBLIC_TRANSPORT = 'public_transport',
  ELECTRIC_VEHICLE = 'electric_vehicle',
  CARPOOLING = 'carpooling',
  OFFSET_CARBON = 'offset_carbon',
  PLASTIC_FREE = 'plastic_free',
  LOCAL_FOOD = 'local_food',
  GREEN_ACCOMMODATION = 'green_accommodation',
  WASTE_REDUCTION = 'waste_reduction'
}

// 碳足迹计算类型
export enum CarbonFootprintType {
  TRANSPORTATION = 'transportation',
  ACCOMMODATION = 'accommodation',
  FOOD = 'food',
  ACTIVITIES = 'activities',
  SHOPPING = 'shopping'
}

// 环保等级
export enum EcoLevel {
  BEGINNER = 'beginner',
  INTERMEDIATE = 'intermediate',
  ADVANCED = 'advanced',
  EXPERT = 'expert'
}

// 碳足迹记录
export interface CarbonFootprintRecord {
  id: string;
  userId: string;
  type: CarbonFootprintType;
  action: EcoActionType;
  distance?: number; // 距离（公里）
  duration?: number; // 时长（小时）
  amount?: number; // 数量
  unit: string; // 单位
  carbonEmission: number; // 碳排放量（kg CO2）
  timestamp: number;
  location?: {
    latitude: number;
    longitude: number;
    address: string;
  };
  metadata?: any; // 额外数据
}

// 环保目标
export interface EcoGoal {
  id: string;
  userId: string;
  title: string;
  description: string;
  type: EcoActionType;
  target: number; // 目标值
  unit: string; // 单位
  currentProgress: number; // 当前进度
  startDate: number;
  endDate: number;
  isCompleted: boolean;
  completedAt?: number;
  reward: {
    points: number;
    badge?: string;
  };
}

// 环保积分
export interface EcoPoints {
  userId: string;
  totalPoints: number;
  level: EcoLevel;
  badges: string[];
  achievements: string[];
  lastUpdated: number;
}

// 环保建议
export interface EcoSuggestion {
  id: string;
  title: string;
  description: string;
  category: EcoActionType;
  difficulty: EcoLevel;
  impact: number; // 环保影响程度 1-5
  effort: number; // 实施难度 1-5
  savings: {
    carbon: number; // 节省碳排放（kg CO2）
    money: number; // 节省费用（元）
  };
  tips: string[];
  relatedActivities?: string[]; // 相关活动ID
}

// 绿色景点
export interface GreenAttraction {
  id: string;
  name: string;
  description: string;
  location: {
    latitude: number;
    longitude: number;
    address: string;
  };
  ecoFeatures: string[]; // 环保特色
  certifications: string[]; // 环保认证
  carbonFootprint: number; // 碳排放量（kg CO2/人/天）
  rating: number; // 环保评级 1-5
  images: string[];
  activities: string[]; // 可进行的环保活动
  tips: string[]; // 环保建议
}

// 环保住宿
export interface EcoAccommodation {
  id: string;
  name: string;
  type: 'hotel' | 'hostel' | 'bnb' | 'camping';
  location: {
    latitude: number;
    longitude: number;
    address: string;
  };
  ecoFeatures: string[]; // 环保设施
  certifications: string[]; // 环保认证
  carbonFootprint: number; // 碳排放量（kg CO2/人/晚）
  rating: number; // 环保评级 1-5
  price: number; // 价格（元/晚）
  images: string[];
  amenities: string[]; // 设施
}

// 环保交通方式
export interface EcoTransportation {
  id: string;
  name: string;
  type: EcoActionType;
  carbonEmissionPerKm: number; // 每公里碳排放（kg CO2）
  costPerKm: number; // 每公里费用（元）
  speed: number; // 平均速度（km/h）
  availability: number; // 可用性 0-1
  description: string;
  pros: string[];
  cons: string[];
}

// 环保统计
export interface EcoStats {
  userId: string;
  totalCarbonSaved: number; // 总节省碳排放（kg CO2）
  totalMoneySaved: number; // 总节省费用（元）
  totalEcoActions: number; // 总环保行为次数
  currentStreak: number; // 当前连续环保天数
  longestStreak: number; // 最长连续环保天数
  ecoLevel: EcoLevel;
  achievements: string[];
  lastUpdated: number;
}

// 环保报告
export interface EcoReport {
  id: string;
  userId: string;
  period: {
    start: number;
    end: number;
  };
  totalCarbonEmission: number; // 总碳排放（kg CO2）
  totalCarbonSaved: number; // 总节省碳排放（kg CO2）
  carbonReductionRate: number; // 碳减排率
  ecoActions: EcoActionType[];
  topEcoActions: {
    action: EcoActionType;
    count: number;
    carbonSaved: number;
  }[];
  recommendations: EcoSuggestion[];
  achievements: string[];
  generatedAt: number;
}

// 环保挑战
export interface EcoChallenge {
  id: string;
  title: string;
  description: string;
  type: EcoActionType;
  target: number; // 目标值
  unit: string; // 单位
  duration: number; // 持续时间（天）
  difficulty: EcoLevel;
  reward: {
    points: number;
    badge?: string;
  };
  participants: string[]; // 参与用户ID列表
  isActive: boolean;
  startDate: number;
  endDate: number;
  requirements: string[]; // 参与要求
}

// 用户环保挑战进度
export interface UserEcoChallengeProgress {
  userId: string;
  challengeId: string;
  currentProgress: number;
  isCompleted: boolean;
  completedAt?: number;
  joinedAt: number;
  lastActivity: number;
}
