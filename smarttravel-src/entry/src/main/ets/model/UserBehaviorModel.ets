/**
 * 用户行为分析数据模型
 * 用于AI个性化推荐系统
 */

// 用户偏好类型
export enum PreferenceType {
  SCENIC_SPOTS = 'scenic_spots',
  CULTURAL_EXPERIENCE = 'cultural_experience',
  NATURE_EXPLORATION = 'nature_exploration',
  ENTERTAINMENT = 'entertainment',
  FOOD = 'food',
  SHOPPING = 'shopping',
  ADVENTURE = 'adventure',
  RELAXATION = 'relaxation'
}

// 用户行为类型
export enum BehaviorType {
  VIEW = 'view',
  CLICK = 'click',
  FAVORITE = 'favorite',
  SHARE = 'share',
  BOOK = 'book',
  REVIEW = 'review',
  SEARCH = 'search'
}

// 位置信息接口
export interface LocationInfo {
  latitude: number;
  longitude: number;
}

// 行为上下文接口
export interface BehaviorContext {
  weather?: string;
  timeOfDay?: string;
  dayOfWeek?: string;
  season?: string;
}

// 用户行为记录
export interface UserBehavior {
  id: string;
  userId: string;
  behaviorType: BehaviorType;
  targetId: string; // 活动或景点ID
  targetType: PreferenceType;
  timestamp: number;
  location?: LocationInfo;
  duration?: number; // 停留时长（秒）
  rating?: number; // 评分 1-5
  context?: BehaviorContext;
}

// 用户偏好权重
export interface UserPreference {
  type: PreferenceType;
  weight: number; // 0-1之间的权重
  confidence: number; // 0-1之间的置信度
  lastUpdated: number;
}

// 用户人口统计信息接口
export interface UserDemographics {
  age?: number;
  gender?: string;
  location?: string;
}

// 预算范围接口
export interface BudgetRange {
  min: number;
  max: number;
}

// 旅行模式接口
export interface TravelPatterns {
  preferredTimeSlots: string[];
  averageTripDuration: number;
  budgetRange: BudgetRange;
}

// 用户画像
export interface UserProfile {
  userId: string;
  preferences: UserPreference[];
  behaviorHistory: UserBehavior[];
  demographics?: UserDemographics;
  travelPatterns?: TravelPatterns;
  lastUpdated: number;
}

// 推荐位置信息接口
export interface RecommendationLocation {
  latitude: number;
  longitude: number;
  address: string;
}

// 推荐结果
export interface Recommendation {
  id: string;
  targetId: string;
  targetType: PreferenceType;
  title: string;
  description: string;
  imageUrl: string;
  score: number; // 推荐分数 0-1
  reason: string; // 推荐理由
  category: string;
  location: RecommendationLocation;
  price?: number;
  rating?: number;
  tags: string[];
}

// 推荐上下文
export interface RecommendationContext {
  currentLocation?: LocationInfo;
  timeOfDay: string;
  weather?: string;
  season: string;
  budget?: number;
  timeAvailable?: number; // 可用时间（小时）
  companions?: number; // 同行人数
}

// AI推荐引擎配置
export interface AIRecommendationConfig {
  enablePersonalization: boolean;
  enableContextAwareness: boolean;
  enableCollaborativeFiltering: boolean;
  minConfidenceThreshold: number;
  maxRecommendations: number;
  diversityWeight: number;
}
