import { preferences } from '@kit.ArkData';
import { UserBehavior, UserProfile, Recommendation, RecommendationContext, 
         BehaviorType, PreferenceType, AIRecommendationConfig, RecommendationLocation } from '../model/UserBehaviorModel';
import { ActivityDetail } from '../model/ActivityModel';
// import { LocationService } from '../utils/LocationUtils'; // 暂时未使用

/**
 * AI个性化推荐引擎
 * 基于用户行为分析和机器学习算法提供个性化推荐
 */
export class AIRecommendationEngine {
  private static instance: AIRecommendationEngine;
  private userProfiles: Map<string, UserProfile> = new Map();
  private config: AIRecommendationConfig;
  // private locationService: LocationService; // 暂时未使用

  private constructor() {
    this.config = {
      enablePersonalization: true,
      enableContextAwareness: true,
      enableCollaborativeFiltering: true,
      minConfidenceThreshold: 0.3,
      maxRecommendations: 10,
      diversityWeight: 0.2
    };
    // this.locationService = LocationService.getInstance(); // 暂时未使用
    this.loadUserProfiles();
  }

  public static getInstance(): AIRecommendationEngine {
    if (!AIRecommendationEngine.instance) {
      AIRecommendationEngine.instance = new AIRecommendationEngine();
    }
    return AIRecommendationEngine.instance;
  }

  // 记录用户行为
  public async recordUserBehavior(behavior: UserBehavior): Promise<void> {
    try {
      const profile = await this.getUserProfile(behavior.userId);
      
      // 添加行为记录
      profile.behaviorHistory.push(behavior);
      
      // 限制历史记录数量，保留最近1000条
      if (profile.behaviorHistory.length > 1000) {
        profile.behaviorHistory = profile.behaviorHistory.slice(-1000);
      }
      
      // 更新用户偏好权重
      await this.updateUserPreferences(profile, behavior);
      
      // 保存更新后的用户画像
      await this.saveUserProfile(profile);
      
      console.log(`用户行为已记录: ${behavior.behaviorType} - ${behavior.targetType}`);
    } catch (error) {
      console.error('记录用户行为失败:', error);
    }
  }

  // 获取个性化推荐
  public async getPersonalizedRecommendations(
    userId: string, 
    context: RecommendationContext,
    availableActivities: ActivityDetail[]
  ): Promise<Recommendation[]> {
    try {
      const profile = await this.getUserProfile(userId);
      const recommendations: Recommendation[] = [];

      // 为每个可用活动计算推荐分数
      for (const activity of availableActivities) {
        const score = await this.calculateRecommendationScore(profile, activity, context);
        
        if (score >= this.config.minConfidenceThreshold) {
          const location: RecommendationLocation = {
            latitude: 22.5431, // 模拟位置，实际应从活动数据获取
            longitude: 114.0579,
            address: '深圳市'
          };
          
          const recommendation: Recommendation = {
            id: `rec_${activity.activityId}_${Date.now()}`,
            targetId: activity.activityId.toString(),
            targetType: this.mapActivityToPreferenceType(activity),
            title: activity.title,
            description: this.generateRecommendationDescription(activity, score),
            imageUrl: activity.carouselImages[0] || '',
            score: score,
            reason: this.generateRecommendationReason(profile, activity, score),
            category: this.getActivityCategory(activity),
            location: location,
            tags: this.generateActivityTags(activity)
          };
          
          recommendations.push(recommendation);
        }
      }

      // 按推荐分数排序
      recommendations.sort((a, b) => b.score - a.score);

      // 应用多样性过滤
      const diversifiedRecommendations = this.applyDiversityFilter(recommendations);

      // 返回前N个推荐
      return diversifiedRecommendations.slice(0, this.config.maxRecommendations);
    } catch (error) {
      console.error('获取个性化推荐失败:', error);
      return [];
    }
  }

  // 计算推荐分数
  private async calculateRecommendationScore(
    profile: UserProfile,
    activity: ActivityDetail,
    context: RecommendationContext
  ): Promise<number> {
    let score = 0;

    // 1. 基于用户偏好的分数
    if (this.config.enablePersonalization) {
      const preferenceScore = this.calculatePreferenceScore(profile, activity);
      score += preferenceScore * 0.4;
    }

    // 2. 基于上下文的分数
    if (this.config.enableContextAwareness) {
      const contextScore = this.calculateContextScore(activity, context);
      score += contextScore * 0.3;
    }

    // 3. 基于协同过滤的分数
    if (this.config.enableCollaborativeFiltering) {
      const collaborativeScore = await this.calculateCollaborativeScore(activity);
      score += collaborativeScore * 0.2;
    }

    // 4. 基于活动热度的分数
    const popularityScore = this.calculatePopularityScore(activity);
    score += popularityScore * 0.1;

    return Math.min(score, 1.0);
  }

  // 计算偏好分数
  private calculatePreferenceScore(profile: UserProfile, activity: ActivityDetail): number {
    const activityType = this.mapActivityToPreferenceType(activity);
    const preference = profile.preferences.find(p => p.type === activityType);
    
    if (!preference) {
      return 0.5; // 默认分数
    }

    return preference.weight * preference.confidence;
  }

  // 计算上下文分数
  private calculateContextScore(activity: ActivityDetail, context: RecommendationContext): number {
    let score = 0.5; // 基础分数

    // 时间匹配
    if (context.timeOfDay === 'morning' && this.isMorningActivity(activity)) {
      score += 0.2;
    } else if (context.timeOfDay === 'evening' && this.isEveningActivity(activity)) {
      score += 0.2;
    }

    // 天气匹配
    if (context.weather === 'sunny' && this.isOutdoorActivity(activity)) {
      score += 0.2;
    } else if (context.weather === 'rainy' && this.isIndoorActivity(activity)) {
      score += 0.2;
    }

    // 季节匹配
    if (this.isSeasonalActivity(activity, context.season)) {
      score += 0.1;
    }

    return Math.min(score, 1.0);
  }

  // 计算协同过滤分数
  private async calculateCollaborativeScore(activity: ActivityDetail): Promise<number> {
    // 模拟协同过滤算法
    // 实际实现中，这里会分析相似用户的行为模式
    const similarUsers = await this.findSimilarUsers(activity);
    return similarUsers.length > 0 ? 0.7 : 0.3;
  }

  // 计算热度分数
  private calculatePopularityScore(_activity: ActivityDetail): number {
    // 基于活动的参与度和评价计算热度
    // 这里使用模拟数据
    return Math.random() * 0.5 + 0.3;
  }

  // 更新用户偏好
  private async updateUserPreferences(profile: UserProfile, behavior: UserBehavior): Promise<void> {
    const preferenceType = behavior.targetType;
    let preference = profile.preferences.find(p => p.type === preferenceType);

    if (!preference) {
      preference = {
        type: preferenceType,
        weight: 0.1,
        confidence: 0.1,
        lastUpdated: Date.now()
      };
      profile.preferences.push(preference);
    }

    // 根据行为类型调整权重
    const weightAdjustment = this.getWeightAdjustment(behavior.behaviorType);
    preference.weight = Math.min(preference.weight + weightAdjustment, 1.0);
    
    // 更新置信度
    preference.confidence = this.calculateConfidence(profile, preferenceType);
    preference.lastUpdated = Date.now();
  }

  // 获取权重调整值
  private getWeightAdjustment(behaviorType: BehaviorType): number {
    switch (behaviorType) {
      case BehaviorType.FAVORITE:
        return 0.1;
      case BehaviorType.BOOK:
        return 0.15;
      case BehaviorType.REVIEW:
        return 0.08;
      case BehaviorType.CLICK:
        return 0.05;
      case BehaviorType.VIEW:
        return 0.02;
      default:
        return 0.01;
    }
  }

  // 计算置信度
  private calculateConfidence(profile: UserProfile, preferenceType: PreferenceType): number {
    const behaviors = profile.behaviorHistory.filter(b => b.targetType === preferenceType);
    const recentBehaviors = behaviors.filter(b => Date.now() - b.timestamp < 30 * 24 * 60 * 60 * 1000); // 30天内
    
    return Math.min(recentBehaviors.length / 10, 1.0);
  }

  // 应用多样性过滤
  private applyDiversityFilter(recommendations: Recommendation[]): Recommendation[] {
    const diversified: Recommendation[] = [];
    const usedCategories = new Set<string>();

    for (const rec of recommendations) {
      if (!usedCategories.has(rec.category) || diversified.length < 3) {
        diversified.push(rec);
        usedCategories.add(rec.category);
      }
    }

    return diversified;
  }

  // 辅助方法
  private mapActivityToPreferenceType(activity: ActivityDetail): PreferenceType {
    // 根据活动标题和描述映射到偏好类型
    const title = activity.title.toLowerCase();
    if (title.includes('文化') || title.includes('历史')) {
      return PreferenceType.CULTURAL_EXPERIENCE;
    } else if (title.includes('自然') || title.includes('公园') || title.includes('山')) {
      return PreferenceType.NATURE_EXPLORATION;
    } else if (title.includes('美食') || title.includes('餐厅')) {
      return PreferenceType.FOOD;
    } else if (title.includes('购物') || title.includes('商场')) {
      return PreferenceType.SHOPPING;
    } else if (title.includes('娱乐') || title.includes('游戏')) {
      return PreferenceType.ENTERTAINMENT;
    } else {
      return PreferenceType.SCENIC_SPOTS;
    }
  }

  private generateRecommendationDescription(activity: ActivityDetail, score: number): string {
    const scoreText = score > 0.8 ? '强烈推荐' : score > 0.6 ? '推荐' : '可能感兴趣';
    return `${scoreText}：${activity.title}`;
  }

  private generateRecommendationReason(_profile: UserProfile, _activity: ActivityDetail, score: number): string {
    const reasons: string[] = [];
    
    if (score > 0.7) {
      reasons.push('符合您的兴趣偏好');
    }
    if (score > 0.5) {
      reasons.push('当前时间适合游览');
    }
    if (score > 0.6) {
      reasons.push('其他用户评价较高');
    }

    return reasons.join('，') || '为您精心推荐';
  }

  private getActivityCategory(activity: ActivityDetail): string {
    return this.mapActivityToPreferenceType(activity);
  }

  private generateActivityTags(activity: ActivityDetail): string[] {
    const tags: string[] = [];
    const title = activity.title.toLowerCase();
    
    if (title.includes('文化')) tags.push('文化体验');
    if (title.includes('自然')) tags.push('自然风光');
    if (title.includes('美食')) tags.push('美食探索');
    if (title.includes('历史')) tags.push('历史古迹');
    if (title.includes('现代')) tags.push('现代建筑');
    
    return tags.length > 0 ? tags : ['热门推荐'];
  }

  private isMorningActivity(activity: ActivityDetail): boolean {
    const title = activity.title.toLowerCase();
    return title.includes('晨练') || title.includes('日出') || title.includes('早市');
  }

  private isEveningActivity(activity: ActivityDetail): boolean {
    const title = activity.title.toLowerCase();
    return title.includes('夜景') || title.includes('夜市') || title.includes('演出');
  }

  private isOutdoorActivity(activity: ActivityDetail): boolean {
    const title = activity.title.toLowerCase();
    return title.includes('公园') || title.includes('山') || title.includes('海') || title.includes('户外');
  }

  private isIndoorActivity(activity: ActivityDetail): boolean {
    const title = activity.title.toLowerCase();
    return title.includes('博物馆') || title.includes('商场') || title.includes('室内');
  }

  private isSeasonalActivity(activity: ActivityDetail, season: string): boolean {
    const title = activity.title.toLowerCase();
    switch (season) {
      case 'spring':
        return title.includes('花') || title.includes('春');
      case 'summer':
        return title.includes('海') || title.includes('夏');
      case 'autumn':
        return title.includes('叶') || title.includes('秋');
      case 'winter':
        return title.includes('雪') || title.includes('冬');
      default:
        return false;
    }
  }

  private async findSimilarUsers(_activity: ActivityDetail): Promise<string[]> {
    // 模拟查找相似用户
    return ['user1', 'user2'];
  }

  // 数据持久化方法
  private async loadUserProfiles(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'user_profiles');
      const profilesData = await dataPreferences.get('profiles', '{}');
      const profiles: Record<string, UserProfile> = JSON.parse(profilesData as string);
      
      const profileEntries: [string, UserProfile][] = Object.entries(profiles);
      for (let i = 0; i < profileEntries.length; i++) {
        const entry: [string, UserProfile] = profileEntries[i];
        const userId: string = entry[0];
        const profile: UserProfile = entry[1];
        this.userProfiles.set(userId, profile);
      }
    } catch (error) {
      console.error('加载用户画像失败:', error);
    }
  }

  private async saveUserProfile(profile: UserProfile): Promise<void> {
    try {
      this.userProfiles.set(profile.userId, profile);
      
      const dataPreferences = await preferences.getPreferences(getContext(), 'user_profiles');
      const profiles: Record<string, UserProfile> = {};
      
      const profileEntries = Array.from(this.userProfiles.entries());
      for (let i = 0; i < profileEntries.length; i++) {
        const entry = profileEntries[i];
        const userId = entry[0];
        const userProfile = entry[1];
        profiles[userId] = userProfile;
      }
      
      await dataPreferences.put('profiles', JSON.stringify(profiles));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存用户画像失败:', error);
    }
  }

  private async getUserProfile(userId: string): Promise<UserProfile> {
    let profile = this.userProfiles.get(userId);
    
    if (!profile) {
      profile = {
        userId: userId,
        preferences: [],
        behaviorHistory: [],
        lastUpdated: Date.now()
      };
      this.userProfiles.set(userId, profile);
    }
    
    return profile;
  }

  // 公共方法
  public async clearUserData(userId: string): Promise<void> {
    this.userProfiles.delete(userId);
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'user_profiles');
      await dataPreferences.delete('profiles');
      await dataPreferences.flush();
    } catch (error) {
      console.error('清除用户数据失败:', error);
    }
  }

  public getConfig(): AIRecommendationConfig {
    return this.config;
  }

  public updateConfig(newConfig: Partial<AIRecommendationConfig>): void {
    const updatedConfig: AIRecommendationConfig = {
      enablePersonalization: newConfig.enablePersonalization ?? this.config.enablePersonalization,
      enableContextAwareness: newConfig.enableContextAwareness ?? this.config.enableContextAwareness,
      enableCollaborativeFiltering: newConfig.enableCollaborativeFiltering ?? this.config.enableCollaborativeFiltering,
      minConfidenceThreshold: newConfig.minConfidenceThreshold ?? this.config.minConfidenceThreshold,
      maxRecommendations: newConfig.maxRecommendations ?? this.config.maxRecommendations,
      diversityWeight: newConfig.diversityWeight ?? this.config.diversityWeight
    };
    this.config = updatedConfig;
  }
}
