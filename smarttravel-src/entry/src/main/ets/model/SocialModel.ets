/**
 * 社交化旅行数据模型
 * 用于实现用户社交互动功能
 */

// 用户状态
export enum UserStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  TRAVELING = 'traveling',
  BUSY = 'busy'
}

// 社交关系类型
export enum SocialRelationType {
  FRIEND = 'friend',
  FOLLOWING = 'following',
  FOLLOWER = 'follower',
  BLOCKED = 'blocked'
}

// 旅行分享类型
export enum ShareType {
  LOCATION = 'location',
  PHOTO = 'photo',
  CHECKIN = 'checkin',
  REVIEW = 'review',
  ITINERARY = 'itinerary',
  LIVE = 'live'
}

// 用户信息
export interface SocialUser {
  userId: string;
  username: string;
  nickname: string;
  avatar: string;
  status: UserStatus;
  location?: {
    latitude: number;
    longitude: number;
    address: string;
    lastUpdate: number;
  };
  bio?: string;
  followersCount: number;
  followingCount: number;
  travelPoints: number; // 旅行积分
  level: number; // 用户等级
  badges: string[]; // 徽章
  joinDate: number;
  lastActive: number;
}

// 社交关系
export interface SocialRelation {
  id: string;
  userId: string;
  targetUserId: string;
  relationType: SocialRelationType;
  createdAt: number;
  isMutual: boolean;
}

// 旅行分享
export interface TravelShare {
  id: string;
  userId: string;
  shareType: ShareType;
  title: string;
  content: string;
  images: string[];
  location?: {
    latitude: number;
    longitude: number;
    address: string;
    name: string;
  };
  activityId?: string;
  tags: string[];
  likes: number;
  comments: number;
  shares: number;
  isPublic: boolean;
  createdAt: number;
  updatedAt: number;
}

// 评论
export interface Comment {
  id: string;
  shareId: string;
  userId: string;
  content: string;
  parentId?: string; // 回复的评论ID
  likes: number;
  createdAt: number;
  updatedAt: number;
}

// 点赞
export interface Like {
  id: string;
  shareId: string;
  userId: string;
  createdAt: number;
}

// 旅行挑战
export interface TravelChallenge {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  target: number; // 目标数量
  unit: string; // 单位
  reward: {
    points: number;
    badge?: string;
  };
  startDate: number;
  endDate: number;
  participants: string[]; // 参与用户ID列表
  isActive: boolean;
}

// 用户挑战进度
export interface UserChallengeProgress {
  userId: string;
  challengeId: string;
  currentProgress: number;
  completedAt?: number;
  isCompleted: boolean;
  joinedAt: number;
}

// 附近用户
export interface NearbyUser {
  user: SocialUser;
  distance: number; // 距离（米）
  lastSeen: number;
  isOnline: boolean;
}

// 旅行群组
export interface TravelGroup {
  id: string;
  name: string;
  description: string;
  avatar: string;
  creatorId: string;
  members: string[]; // 成员用户ID列表
  maxMembers: number;
  isPublic: boolean;
  tags: string[];
  location?: {
    latitude: number;
    longitude: number;
    address: string;
  };
  createdAt: number;
  lastActivity: number;
}

// 群组消息
export interface GroupMessage {
  id: string;
  groupId: string;
  userId: string;
  content: string;
  messageType: 'text' | 'image' | 'location' | 'share';
  metadata?: any;
  createdAt: number;
}

// 实时位置分享
export interface LiveLocationShare {
  id: string;
  userId: string;
  location: {
    latitude: number;
    longitude: number;
    address: string;
    accuracy: number;
  };
  startTime: number;
  endTime?: number;
  isActive: boolean;
  sharedWith: string[]; // 分享给的用户ID列表
}

// 旅行匹配
export interface TravelMatch {
  id: string;
  userId: string;
  matchedUserId: string;
  compatibility: number; // 匹配度 0-1
  commonInterests: string[];
  suggestedActivities: string[];
  createdAt: number;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
}

// 社交统计
export interface SocialStats {
  userId: string;
  totalShares: number;
  totalLikes: number;
  totalComments: number;
  totalFollowers: number;
  totalFollowing: number;
  travelStreak: number; // 连续旅行天数
  longestTrip: number; // 最长旅行天数
  countriesVisited: number;
  citiesVisited: number;
  lastUpdated: number;
}
