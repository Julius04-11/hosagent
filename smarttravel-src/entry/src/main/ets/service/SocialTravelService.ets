import { preferences } from '@kit.ArkData';
import { SocialUser, SocialRelation, TravelShare, Comment, Like, TravelChallenge, 
         UserChallengeProgress, NearbyUser, TravelGroup, GroupMessage, 
         LiveLocationShare, TravelMatch, SocialStats, SocialRelationType, 
         ShareType, UserStatus } from '../model/SocialModel';
import { LocationService } from '../utils/LocationUtils';

/**
 * 社交化旅行服务
 * 提供用户社交互动功能
 */
export class SocialTravelService {
  private static instance: SocialTravelService;
  private currentUser: SocialUser | null = null;
  private socialUsers: Map<string, SocialUser> = new Map();
  private socialRelations: Map<string, SocialRelation> = new Map();
  private travelShares: Map<string, TravelShare> = new Map();
  private comments: Map<string, Comment> = new Map();
  private likes: Map<string, Like> = new Map();
  private challenges: Map<string, TravelChallenge> = new Map();
  private userChallengeProgress: Map<string, UserChallengeProgress> = new Map();
  private travelGroups: Map<string, TravelGroup> = new Map();
  private groupMessages: Map<string, GroupMessage> = new Map();
  private liveLocationShares: Map<string, LiveLocationShare> = new Map();
  private travelMatches: Map<string, TravelMatch> = new Map();
  private locationService: LocationService;

  private constructor() {
    this.locationService = LocationService.getInstance();
    this.loadMockData();
  }

  public static getInstance(): SocialTravelService {
    if (!SocialTravelService.instance) {
      SocialTravelService.instance = new SocialTravelService();
    }
    return SocialTravelService.instance;
  }

  // 初始化当前用户
  public async initializeCurrentUser(userId: string): Promise<SocialUser> {
    try {
      // 尝试从本地加载用户数据
      const savedUser = await this.loadUserFromStorage(userId);
      if (savedUser) {
        this.currentUser = savedUser;
      } else {
        // 创建新用户
        this.currentUser = await this.createNewUser(userId);
        await this.saveUserToStorage(this.currentUser);
      }
      
      return this.currentUser;
    } catch (error) {
      console.error('初始化当前用户失败:', error);
      throw error;
    }
  }

  // 创建新用户
  private async createNewUser(userId: string): Promise<SocialUser> {
    const currentLocation = await this.locationService.getCurrentLocation();
    
    const newUser: SocialUser = {
      userId: userId,
      username: `user_${userId.slice(-6)}`,
      nickname: '旅行者',
      avatar: 'https://via.placeholder.com/100x100/1e40af/ffffff?text=U',
      status: UserStatus.ONLINE,
      location: currentLocation ? {
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        address: currentLocation.address || '未知位置',
        lastUpdate: Date.now()
      } : undefined,
      bio: '热爱旅行的探索者',
      followersCount: 0,
      followingCount: 0,
      travelPoints: 0,
      level: 1,
      badges: ['新手旅行者'],
      joinDate: Date.now(),
      lastActive: Date.now()
    };

    this.socialUsers.set(userId, newUser);
    return newUser;
  }

  // 发布旅行分享
  public async publishTravelShare(share: Omit<TravelShare, 'id' | 'createdAt' | 'updatedAt' | 'likes' | 'comments' | 'shares'>): Promise<TravelShare> {
    try {
      const newShare: TravelShare = {
        ...share,
        id: `share_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      this.travelShares.set(newShare.id, newShare);
      await this.saveSharesToStorage();
      
      // 更新用户统计
      await this.updateUserStats(newShare.userId, 'shares', 1);
      
      console.log(`用户 ${newShare.userId} 发布了新的旅行分享`);
      return newShare;
    } catch (error) {
      console.error('发布旅行分享失败:', error);
      throw error;
    }
  }

  // 获取动态流
  public async getFeed(userId: string, limit: number = 20, offset: number = 0): Promise<TravelShare[]> {
    try {
      const userRelations = this.getUserRelations(userId);
      const followingIds = userRelations
        .filter(rel => rel.relationType === SocialRelationType.FOLLOWING)
        .map(rel => rel.targetUserId);
      
      // 包含自己的分享
      followingIds.push(userId);
      
      const allShares = Array.from(this.travelShares.values())
        .filter(share => followingIds.includes(share.userId) && share.isPublic)
        .sort((a, b) => b.createdAt - a.createdAt);
      
      return allShares.slice(offset, offset + limit);
    } catch (error) {
      console.error('获取动态流失败:', error);
      return [];
    }
  }

  // 点赞分享
  public async likeShare(shareId: string, userId: string): Promise<boolean> {
    try {
      const likeId = `like_${shareId}_${userId}`;
      
      // 检查是否已经点赞
      if (this.likes.has(likeId)) {
        return false;
      }

      const like: Like = {
        id: likeId,
        shareId: shareId,
        userId: userId,
        createdAt: Date.now()
      };

      this.likes.set(likeId, like);
      
      // 更新分享的点赞数
      const share = this.travelShares.get(shareId);
      if (share) {
        share.likes += 1;
        this.travelShares.set(shareId, share);
        await this.saveSharesToStorage();
      }
      
      console.log(`用户 ${userId} 点赞了分享 ${shareId}`);
      return true;
    } catch (error) {
      console.error('点赞失败:', error);
      return false;
    }
  }

  // 取消点赞
  public async unlikeShare(shareId: string, userId: string): Promise<boolean> {
    try {
      const likeId = `like_${shareId}_${userId}`;
      
      if (!this.likes.has(likeId)) {
        return false;
      }

      this.likes.delete(likeId);
      
      // 更新分享的点赞数
      const share = this.travelShares.get(shareId);
      if (share) {
        share.likes = Math.max(0, share.likes - 1);
        this.travelShares.set(shareId, share);
        await this.saveSharesToStorage();
      }
      
      console.log(`用户 ${userId} 取消点赞分享 ${shareId}`);
      return true;
    } catch (error) {
      console.error('取消点赞失败:', error);
      return false;
    }
  }

  // 添加评论
  public async addComment(shareId: string, userId: string, content: string, parentId?: string): Promise<Comment> {
    try {
      const comment: Comment = {
        id: `comment_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        shareId: shareId,
        userId: userId,
        content: content,
        parentId: parentId,
        likes: 0,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      this.comments.set(comment.id, comment);
      
      // 更新分享的评论数
      const share = this.travelShares.get(shareId);
      if (share) {
        share.comments += 1;
        this.travelShares.set(shareId, share);
        await this.saveSharesToStorage();
      }
      
      console.log(`用户 ${userId} 评论了分享 ${shareId}`);
      return comment;
    } catch (error) {
      console.error('添加评论失败:', error);
      throw error;
    }
  }

  // 获取分享的评论
  public async getShareComments(shareId: string): Promise<Comment[]> {
    try {
      return Array.from(this.comments.values())
        .filter(comment => comment.shareId === shareId)
        .sort((a, b) => a.createdAt - b.createdAt);
    } catch (error) {
      console.error('获取评论失败:', error);
      return [];
    }
  }

  // 关注用户
  public async followUser(userId: string, targetUserId: string): Promise<boolean> {
    try {
      const relationId = `relation_${userId}_${targetUserId}`;
      
      // 检查是否已经关注
      if (this.socialRelations.has(relationId)) {
        return false;
      }

      const relation: SocialRelation = {
        id: relationId,
        userId: userId,
        targetUserId: targetUserId,
        relationType: SocialRelationType.FOLLOWING,
        createdAt: Date.now(),
        isMutual: false
      };

      this.socialRelations.set(relationId, relation);
      
      // 更新用户关注数
      const user = this.socialUsers.get(userId);
      if (user) {
        user.followingCount += 1;
        this.socialUsers.set(userId, user);
      }
      
      // 更新被关注用户的粉丝数
      const targetUser = this.socialUsers.get(targetUserId);
      if (targetUser) {
        targetUser.followersCount += 1;
        this.socialUsers.set(targetUserId, targetUser);
      }
      
      console.log(`用户 ${userId} 关注了用户 ${targetUserId}`);
      return true;
    } catch (error) {
      console.error('关注用户失败:', error);
      return false;
    }
  }

  // 取消关注
  public async unfollowUser(userId: string, targetUserId: string): Promise<boolean> {
    try {
      const relationId = `relation_${userId}_${targetUserId}`;
      
      if (!this.socialRelations.has(relationId)) {
        return false;
      }

      this.socialRelations.delete(relationId);
      
      // 更新用户关注数
      const user = this.socialUsers.get(userId);
      if (user) {
        user.followingCount = Math.max(0, user.followingCount - 1);
        this.socialUsers.set(userId, user);
      }
      
      // 更新被关注用户的粉丝数
      const targetUser = this.socialUsers.get(targetUserId);
      if (targetUser) {
        targetUser.followersCount = Math.max(0, targetUser.followersCount - 1);
        this.socialUsers.set(targetUserId, targetUser);
      }
      
      console.log(`用户 ${userId} 取消关注用户 ${targetUserId}`);
      return true;
    } catch (error) {
      console.error('取消关注失败:', error);
      return false;
    }
  }

  // 获取附近用户
  public async getNearbyUsers(userId: string, radius: number = 5000): Promise<NearbyUser[]> {
    try {
      const currentUser = this.socialUsers.get(userId);
      if (!currentUser || !currentUser.location) {
        return [];
      }

      const nearbyUsers: NearbyUser[] = [];
      
      for (const [id, user] of this.socialUsers) {
        if (id === userId || !user.location) continue;
        
        const distance = this.calculateDistance(
          currentUser.location.latitude,
          currentUser.location.longitude,
          user.location.latitude,
          user.location.longitude
        );
        
        if (distance <= radius) {
          nearbyUsers.push({
            user: user,
            distance: distance,
            lastSeen: user.lastActive,
            isOnline: user.status === UserStatus.ONLINE
          });
        }
      }
      
      return nearbyUsers.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('获取附近用户失败:', error);
      return [];
    }
  }

  // 创建旅行挑战
  public async createTravelChallenge(challenge: Omit<TravelChallenge, 'id' | 'participants'>): Promise<TravelChallenge> {
    try {
      const newChallenge: TravelChallenge = {
        ...challenge,
        id: `challenge_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        participants: [],
        isActive: true
      };

      this.challenges.set(newChallenge.id, newChallenge);
      await this.saveChallengesToStorage();
      
      console.log(`创建了新的旅行挑战: ${newChallenge.title}`);
      return newChallenge;
    } catch (error) {
      console.error('创建旅行挑战失败:', error);
      throw error;
    }
  }

  // 参与挑战
  public async joinChallenge(userId: string, challengeId: string): Promise<boolean> {
    try {
      const challenge = this.challenges.get(challengeId);
      if (!challenge || !challenge.isActive) {
        return false;
      }

      // 检查是否已经参与
      if (challenge.participants.includes(userId)) {
        return false;
      }

      challenge.participants.push(userId);
      this.challenges.set(challengeId, challenge);
      
      // 创建用户挑战进度
      const progress: UserChallengeProgress = {
        userId: userId,
        challengeId: challengeId,
        currentProgress: 0,
        isCompleted: false,
        joinedAt: Date.now()
      };
      
      this.userChallengeProgress.set(`${userId}_${challengeId}`, progress);
      await this.saveChallengesToStorage();
      
      console.log(`用户 ${userId} 参与了挑战 ${challengeId}`);
      return true;
    } catch (error) {
      console.error('参与挑战失败:', error);
      return false;
    }
  }

  // 更新挑战进度
  public async updateChallengeProgress(userId: string, challengeId: string, progress: number): Promise<boolean> {
    try {
      const progressKey = `${userId}_${challengeId}`;
      const userProgress = this.userChallengeProgress.get(progressKey);
      
      if (!userProgress) {
        return false;
      }

      userProgress.currentProgress = progress;
      
      const challenge = this.challenges.get(challengeId);
      if (challenge && progress >= challenge.target) {
        userProgress.isCompleted = true;
        userProgress.completedAt = Date.now();
        
        // 奖励用户
        await this.awardUser(userId, challenge.reward);
      }
      
      this.userChallengeProgress.set(progressKey, userProgress);
      await this.saveChallengesToStorage();
      
      return true;
    } catch (error) {
      console.error('更新挑战进度失败:', error);
      return false;
    }
  }

  // 奖励用户
  private async awardUser(userId: string, reward: { points: number; badge?: string }): Promise<void> {
    const user = this.socialUsers.get(userId);
    if (user) {
      user.travelPoints += reward.points;
      
      if (reward.badge && !user.badges.includes(reward.badge)) {
        user.badges.push(reward.badge);
      }
      
      this.socialUsers.set(userId, user);
      await this.saveUserToStorage(user);
    }
  }

  // 获取用户关系
  private getUserRelations(userId: string): SocialRelation[] {
    return Array.from(this.socialRelations.values())
      .filter(rel => rel.userId === userId);
  }

  // 更新用户统计
  private async updateUserStats(userId: string, statType: string, increment: number): Promise<void> {
    // 这里可以实现更复杂的统计逻辑
    console.log(`更新用户 ${userId} 的 ${statType} 统计: +${increment}`);
  }

  // 计算两点间距离
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000; // 地球半径（米）
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // 角度转弧度
  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  // 加载模拟数据
  private loadMockData(): void {
    // 创建一些模拟用户
    const mockUsers: SocialUser[] = [
      {
        userId: 'user_001',
        username: 'traveler_alice',
        nickname: '爱丽丝',
        avatar: 'https://via.placeholder.com/100x100/ff6b6b/ffffff?text=A',
        status: UserStatus.ONLINE,
        location: {
          latitude: 22.5431,
          longitude: 114.0579,
          address: '深圳市南山区',
          lastUpdate: Date.now()
        },
        bio: '热爱摄影的旅行者',
        followersCount: 156,
        followingCount: 89,
        travelPoints: 1250,
        level: 3,
        badges: ['摄影达人', '城市探索者'],
        joinDate: Date.now() - 86400000 * 30,
        lastActive: Date.now()
      },
      {
        userId: 'user_002',
        username: 'explorer_bob',
        nickname: '鲍勃',
        avatar: 'https://via.placeholder.com/100x100/4ecdc4/ffffff?text=B',
        status: UserStatus.TRAVELING,
        location: {
          latitude: 22.5531,
          longitude: 114.0679,
          address: '世界之窗',
          lastUpdate: Date.now()
        },
        bio: '户外探险爱好者',
        followersCount: 89,
        followingCount: 45,
        travelPoints: 890,
        level: 2,
        badges: ['户外达人'],
        joinDate: Date.now() - 86400000 * 15,
        lastActive: Date.now()
      }
    ];

    // 添加到用户映射
    mockUsers.forEach(user => {
      this.socialUsers.set(user.userId, user);
    });

    // 创建一些模拟分享
    const mockShares: TravelShare[] = [
      {
        id: 'share_001',
        userId: 'user_001',
        shareType: ShareType.CHECKIN,
        title: '在深圳湾公园打卡',
        content: '今天天气真好，深圳湾公园的景色太美了！',
        images: ['https://via.placeholder.com/300x200/ff6b6b/ffffff?text=深圳湾公园'],
        location: {
          latitude: 22.5431,
          longitude: 114.0579,
          address: '深圳湾公园',
          name: '深圳湾公园'
        },
        tags: ['深圳', '公园', '打卡'],
        likes: 23,
        comments: 5,
        shares: 2,
        isPublic: true,
        createdAt: Date.now() - 3600000,
        updatedAt: Date.now() - 3600000
      }
    ];

    // 添加到分享映射
    mockShares.forEach(share => {
      this.travelShares.set(share.id, share);
    });
  }

  // 数据持久化方法
  private async saveUserToStorage(user: SocialUser): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'social_users');
      await dataPreferences.put(user.userId, JSON.stringify(user));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存用户数据失败:', error);
    }
  }

  private async loadUserFromStorage(userId: string): Promise<SocialUser | null> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'social_users');
      const userData = await dataPreferences.get(userId, '');
      return userData ? JSON.parse(userData) : null;
    } catch (error) {
      console.error('加载用户数据失败:', error);
      return null;
    }
  }

  private async saveSharesToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'travel_shares');
      const sharesArray = Array.from(this.travelShares.values());
      await dataPreferences.put('shares', JSON.stringify(sharesArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存分享数据失败:', error);
    }
  }

  private async saveChallengesToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'travel_challenges');
      const challengesArray = Array.from(this.challenges.values());
      await dataPreferences.put('challenges', JSON.stringify(challengesArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存挑战数据失败:', error);
    }
  }

  // 公共方法
  public getCurrentUser(): SocialUser | null {
    return this.currentUser;
  }

  public getUserById(userId: string): SocialUser | undefined {
    return this.socialUsers.get(userId);
  }

  public getShareById(shareId: string): TravelShare | undefined {
    return this.travelShares.get(shareId);
  }

  public getChallengeById(challengeId: string): TravelChallenge | undefined {
    return this.challenges.get(challengeId);
  }
}
