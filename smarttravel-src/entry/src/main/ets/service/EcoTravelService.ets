import { preferences } from '@kit.ArkData';
import { CarbonFootprintRecord, EcoGoal, EcoPoints, EcoSuggestion, GreenAttraction, 
         EcoAccommodation, EcoTransportation, EcoStats, EcoReport, EcoChallenge, 
         UserEcoChallengeProgress, EcoActionType, CarbonFootprintType, EcoLevel } from '../model/EcoTravelModel';

/**
 * 环保旅行服务
 * 提供碳足迹追踪、环保建议等功能
 */
export class EcoTravelService {
  private static instance: EcoTravelService;
  private carbonRecords: Map<string, CarbonFootprintRecord> = new Map();
  private ecoGoals: Map<string, EcoGoal> = new Map();
  private ecoPoints: Map<string, EcoPoints> = new Map();
  private ecoSuggestions: Map<string, EcoSuggestion> = new Map();
  private greenAttractions: Map<string, GreenAttraction> = new Map();
  private ecoAccommodations: Map<string, EcoAccommodation> = new Map();
  private ecoTransportations: Map<string, EcoTransportation> = new Map();
  private ecoStats: Map<string, EcoStats> = new Map();
  private ecoChallenges: Map<string, EcoChallenge> = new Map();
  private userChallengeProgress: Map<string, UserEcoChallengeProgress> = new Map();

  private constructor() {
    this.loadMockData();
  }

  public static getInstance(): EcoTravelService {
    if (!EcoTravelService.instance) {
      EcoTravelService.instance = new EcoTravelService();
    }
    return EcoTravelService.instance;
  }

  // 记录碳足迹
  public async recordCarbonFootprint(record: Omit<CarbonFootprintRecord, 'id' | 'timestamp'>): Promise<CarbonFootprintRecord> {
    try {
      const newRecord: CarbonFootprintRecord = {
        ...record,
        id: `carbon_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        timestamp: Date.now()
      };

      this.carbonRecords.set(newRecord.id, newRecord);
      await this.saveCarbonRecordsToStorage();
      
      // 更新用户统计
      await this.updateUserStats(newRecord.userId);
      
      console.log(`记录碳足迹: ${newRecord.carbonEmission}kg CO2`);
      return newRecord;
    } catch (error) {
      console.error('记录碳足迹失败:', error);
      throw error;
    }
  }

  // 计算交通碳排放
  public calculateTransportationCarbon(
    transportationType: EcoActionType,
    distance: number,
    passengers: number = 1
  ): number {
    const carbonFactors: Record<EcoActionType, number> = {
      [EcoActionType.WALKING]: 0,
      [EcoActionType.CYCLING]: 0,
      [EcoActionType.PUBLIC_TRANSPORT]: 0.05, // kg CO2/km
      [EcoActionType.ELECTRIC_VEHICLE]: 0.08,
      [EcoActionType.CARPOOLING]: 0.12,
      [EcoActionType.OFFSET_CARBON]: 0,
      [EcoActionType.PLASTIC_FREE]: 0,
      [EcoActionType.LOCAL_FOOD]: 0,
      [EcoActionType.GREEN_ACCOMMODATION]: 0,
      [EcoActionType.WASTE_REDUCTION]: 0
    };

    const factor = carbonFactors[transportationType] || 0;
    return (distance * factor) / passengers;
  }

  // 计算住宿碳排放
  public calculateAccommodationCarbon(
    accommodationType: string,
    nights: number,
    guests: number = 1
  ): number {
    const carbonFactors: Record<string, number> = {
      'hotel': 15, // kg CO2/guest/night
      'hostel': 8,
      'bnb': 10,
      'camping': 2,
      'green_hotel': 5
    };

    const factor = carbonFactors[accommodationType] || 15;
    return nights * factor * guests;
  }

  // 计算食物碳排放
  public calculateFoodCarbon(
    mealType: string,
    isLocal: boolean = false,
    isVegetarian: boolean = false
  ): number {
    let baseCarbon = 0;
    
    switch (mealType) {
      case 'breakfast':
        baseCarbon = 1.5;
        break;
      case 'lunch':
        baseCarbon = 2.5;
        break;
      case 'dinner':
        baseCarbon = 3.0;
        break;
      default:
        baseCarbon = 2.0;
    }

    // 本地食物减少20%碳排放
    if (isLocal) {
      baseCarbon *= 0.8;
    }

    // 素食减少50%碳排放
    if (isVegetarian) {
      baseCarbon *= 0.5;
    }

    return baseCarbon;
  }

  // 获取环保建议
  public async getEcoSuggestions(userId: string, limit: number = 10): Promise<EcoSuggestion[]> {
    try {
      const userStats = this.ecoStats.get(userId);
      const userLevel = userStats?.ecoLevel || EcoLevel.BEGINNER;
      
      // 根据用户等级和统计信息推荐建议
      const suggestions = Array.from(this.ecoSuggestions.values())
        .filter(suggestion => {
          // 根据用户等级过滤难度
          const levelOrder = [EcoLevel.BEGINNER, EcoLevel.INTERMEDIATE, EcoLevel.ADVANCED, EcoLevel.EXPERT];
          const userLevelIndex = levelOrder.indexOf(userLevel);
          const suggestionLevelIndex = levelOrder.indexOf(suggestion.difficulty);
          
          return suggestionLevelIndex <= userLevelIndex + 1; // 允许推荐稍高难度的建议
        })
        .sort((a, b) => {
          // 按影响程度和用户需求排序
          const scoreA = a.impact * (1 - a.effort / 5);
          const scoreB = b.impact * (1 - b.effort / 5);
          return scoreB - scoreA;
        })
        .slice(0, limit);

      return suggestions;
    } catch (error) {
      console.error('获取环保建议失败:', error);
      return [];
    }
  }

  // 获取绿色景点
  public async getGreenAttractions(
    latitude: number,
    longitude: number,
    radius: number = 10000
  ): Promise<GreenAttraction[]> {
    try {
      const attractions = Array.from(this.greenAttractions.values())
        .filter(attraction => {
          const distance = this.calculateDistance(
            latitude,
            longitude,
            attraction.location.latitude,
            attraction.location.longitude
          );
          return distance <= radius;
        })
        .sort((a, b) => b.rating - a.rating);

      return attractions;
    } catch (error) {
      console.error('获取绿色景点失败:', error);
      return [];
    }
  }

  // 获取环保住宿
  public async getEcoAccommodations(
    latitude: number,
    longitude: number,
    radius: number = 20000
  ): Promise<EcoAccommodation[]> {
    try {
      const accommodations = Array.from(this.ecoAccommodations.values())
        .filter(accommodation => {
          const distance = this.calculateDistance(
            latitude,
            longitude,
            accommodation.location.latitude,
            accommodation.location.longitude
          );
          return distance <= radius;
        })
        .sort((a, b) => b.rating - a.rating);

      return accommodations;
    } catch (error) {
      console.error('获取环保住宿失败:', error);
      return [];
    }
  }

  // 获取环保交通方式
  public async getEcoTransportations(): Promise<EcoTransportation[]> {
    try {
      return Array.from(this.ecoTransportations.values())
        .sort((a, b) => a.carbonEmissionPerKm - b.carbonEmissionPerKm);
    } catch (error) {
      console.error('获取环保交通方式失败:', error);
      return [];
    }
  }

  // 创建环保目标
  public async createEcoGoal(goal: Omit<EcoGoal, 'id' | 'currentProgress' | 'isCompleted'>): Promise<EcoGoal> {
    try {
      const newGoal: EcoGoal = {
        ...goal,
        id: `goal_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        currentProgress: 0,
        isCompleted: false
      };

      this.ecoGoals.set(newGoal.id, newGoal);
      await this.saveEcoGoalsToStorage();
      
      console.log(`创建环保目标: ${newGoal.title}`);
      return newGoal;
    } catch (error) {
      console.error('创建环保目标失败:', error);
      throw error;
    }
  }

  // 更新环保目标进度
  public async updateEcoGoalProgress(goalId: string, progress: number): Promise<boolean> {
    try {
      const goal = this.ecoGoals.get(goalId);
      if (!goal) {
        return false;
      }

      goal.currentProgress = progress;
      
      if (progress >= goal.target && !goal.isCompleted) {
        goal.isCompleted = true;
        goal.completedAt = Date.now();
        
        // 奖励用户
        await this.awardEcoPoints(goal.userId, goal.reward);
      }
      
      this.ecoGoals.set(goalId, goal);
      await this.saveEcoGoalsToStorage();
      
      return true;
    } catch (error) {
      console.error('更新环保目标进度失败:', error);
      return false;
    }
  }

  // 奖励环保积分
  private async awardEcoPoints(userId: string, reward: { points: number; badge?: string }): Promise<void> {
    let ecoPoints = this.ecoPoints.get(userId);
    
    if (!ecoPoints) {
      ecoPoints = {
        userId: userId,
        totalPoints: 0,
        level: EcoLevel.BEGINNER,
        badges: [],
        achievements: [],
        lastUpdated: Date.now()
      };
    }
    
    ecoPoints.totalPoints += reward.points;
    
    if (reward.badge && !ecoPoints.badges.includes(reward.badge)) {
      ecoPoints.badges.push(reward.badge);
    }
    
    // 更新等级
    ecoPoints.level = this.calculateEcoLevel(ecoPoints.totalPoints);
    ecoPoints.lastUpdated = Date.now();
    
    this.ecoPoints.set(userId, ecoPoints);
    await this.saveEcoPointsToStorage();
  }

  // 计算环保等级
  private calculateEcoLevel(points: number): EcoLevel {
    if (points >= 1000) return EcoLevel.EXPERT;
    if (points >= 500) return EcoLevel.ADVANCED;
    if (points >= 200) return EcoLevel.INTERMEDIATE;
    return EcoLevel.BEGINNER;
  }

  // 获取用户环保统计
  public async getUserEcoStats(userId: string): Promise<EcoStats | null> {
    try {
      let stats = this.ecoStats.get(userId);
      
      if (!stats) {
        // 创建新的统计记录
        stats = {
          userId: userId,
          totalCarbonSaved: 0,
          totalMoneySaved: 0,
          totalEcoActions: 0,
          currentStreak: 0,
          longestStreak: 0,
          ecoLevel: EcoLevel.BEGINNER,
          achievements: [],
          lastUpdated: Date.now()
        };
        
        this.ecoStats.set(userId, stats);
      }
      
      return stats;
    } catch (error) {
      console.error('获取用户环保统计失败:', error);
      return null;
    }
  }

  // 更新用户统计
  private async updateUserStats(userId: string): Promise<void> {
    try {
      const userRecords = Array.from(this.carbonRecords.values())
        .filter(record => record.userId === userId);
      
      let stats = this.ecoStats.get(userId);
      if (!stats) {
        stats = {
          userId: userId,
          totalCarbonSaved: 0,
          totalMoneySaved: 0,
          totalEcoActions: 0,
          currentStreak: 0,
          longestStreak: 0,
          ecoLevel: EcoLevel.BEGINNER,
          achievements: [],
          lastUpdated: Date.now()
        };
      }
      
      // 计算总节省碳排放
      stats.totalCarbonSaved = userRecords.reduce((sum, record) => {
        // 这里应该根据环保行为类型计算节省的碳排放
        return sum + record.carbonEmission * 0.3; // 假设节省30%
      }, 0);
      
      // 计算总节省费用
      stats.totalMoneySaved = userRecords.reduce((sum, record) => {
        // 这里应该根据环保行为类型计算节省的费用
        return sum + record.carbonEmission * 2; // 假设每kg CO2节省2元
      }, 0);
      
      // 计算总环保行为次数
      stats.totalEcoActions = userRecords.length;
      
      // 更新等级
      const ecoPoints = this.ecoPoints.get(userId);
      if (ecoPoints) {
        stats.ecoLevel = ecoPoints.level;
      }
      
      stats.lastUpdated = Date.now();
      this.ecoStats.set(userId, stats);
      await this.saveEcoStatsToStorage();
    } catch (error) {
      console.error('更新用户统计失败:', error);
    }
  }

  // 生成环保报告
  public async generateEcoReport(
    userId: string,
    startDate: number,
    endDate: number
  ): Promise<EcoReport> {
    try {
      const userRecords = Array.from(this.carbonRecords.values())
        .filter(record => 
          record.userId === userId && 
          record.timestamp >= startDate && 
          record.timestamp <= endDate
        );
      
      const totalCarbonEmission = userRecords.reduce((sum, record) => sum + record.carbonEmission, 0);
      const totalCarbonSaved = totalCarbonEmission * 0.3; // 假设节省30%
      const carbonReductionRate = totalCarbonSaved / totalCarbonEmission;
      
      // 统计环保行为类型
      const actionCounts: Record<EcoActionType, number> = {} as Record<EcoActionType, number>;
      userRecords.forEach(record => {
        actionCounts[record.action] = (actionCounts[record.action] || 0) + 1;
      });
      
      const topEcoActions = Object.entries(actionCounts)
        .map(([action, count]) => ({
          action: action as EcoActionType,
          count: count,
          carbonSaved: count * 0.5 // 假设每次行为节省0.5kg CO2
        }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 5);
      
      const report: EcoReport = {
        id: `report_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        userId: userId,
        period: { start: startDate, end: endDate },
        totalCarbonEmission: totalCarbonEmission,
        totalCarbonSaved: totalCarbonSaved,
        carbonReductionRate: carbonReductionRate,
        ecoActions: Object.keys(actionCounts) as EcoActionType[],
        topEcoActions: topEcoActions,
        recommendations: await this.getEcoSuggestions(userId, 5),
        achievements: [],
        generatedAt: Date.now()
      };
      
      return report;
    } catch (error) {
      console.error('生成环保报告失败:', error);
      throw error;
    }
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
    // 加载环保建议
    const mockSuggestions: EcoSuggestion[] = [
      {
        id: 'suggestion_001',
        title: '选择公共交通',
        description: '使用地铁、公交等公共交通工具，减少个人碳排放',
        category: EcoActionType.PUBLIC_TRANSPORT,
        difficulty: EcoLevel.BEGINNER,
        impact: 4,
        effort: 2,
        savings: {
          carbon: 2.5,
          money: 15
        },
        tips: [
          '提前查看公交线路',
          '使用交通卡享受优惠',
          '避开高峰期出行'
        ]
      },
      {
        id: 'suggestion_002',
        title: '选择绿色住宿',
        description: '选择有环保认证的酒店或民宿',
        category: EcoActionType.GREEN_ACCOMMODATION,
        difficulty: EcoLevel.INTERMEDIATE,
        impact: 3,
        effort: 3,
        savings: {
          carbon: 5.0,
          money: 20
        },
        tips: [
          '查看酒店的环保认证',
          '选择节能环保的设施',
          '减少房间清洁频率'
        ]
      }
    ];

    mockSuggestions.forEach(suggestion => {
      this.ecoSuggestions.set(suggestion.id, suggestion);
    });

    // 加载绿色景点
    const mockGreenAttractions: GreenAttraction[] = [
      {
        id: 'attraction_001',
        name: '深圳湾公园',
        description: '生态湿地公园，拥有丰富的自然景观',
        location: {
          latitude: 22.5431,
          longitude: 114.0579,
          address: '深圳市南山区深圳湾公园'
        },
        ecoFeatures: ['湿地保护', '鸟类栖息地', '生态教育'],
        certifications: ['绿色景区认证'],
        carbonFootprint: 0.5,
        rating: 4.5,
        images: ['https://via.placeholder.com/300x200/059669/ffffff?text=深圳湾公园'],
        activities: ['观鸟', '生态摄影', '自然教育'],
        tips: ['不要打扰野生动物', '带走垃圾', '使用环保用品']
      }
    ];

    mockGreenAttractions.forEach(attraction => {
      this.greenAttractions.set(attraction.id, attraction);
    });

    // 加载环保交通方式
    const mockEcoTransportations: EcoTransportation[] = [
      {
        id: 'transport_001',
        name: '步行',
        type: EcoActionType.WALKING,
        carbonEmissionPerKm: 0,
        costPerKm: 0,
        speed: 5,
        availability: 1,
        description: '最环保的出行方式',
        pros: ['零碳排放', '有益健康', '免费'],
        cons: ['速度慢', '距离限制']
      },
      {
        id: 'transport_002',
        name: '自行车',
        type: EcoActionType.CYCLING,
        carbonEmissionPerKm: 0,
        costPerKm: 0.5,
        speed: 15,
        availability: 0.8,
        description: '绿色环保的出行方式',
        pros: ['零碳排放', '锻炼身体', '灵活便捷'],
        cons: ['受天气影响', '需要体力']
      },
      {
        id: 'transport_003',
        name: '地铁',
        type: EcoActionType.PUBLIC_TRANSPORT,
        carbonEmissionPerKm: 0.05,
        costPerKm: 0.3,
        speed: 40,
        availability: 0.9,
        description: '高效环保的公共交通',
        pros: ['碳排放低', '速度快', '准时'],
        cons: ['拥挤', '固定路线']
      }
    ];

    mockEcoTransportations.forEach(transportation => {
      this.ecoTransportations.set(transportation.id, transportation);
    });
  }

  // 数据持久化方法
  private async saveCarbonRecordsToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'carbon_records');
      const recordsArray = Array.from(this.carbonRecords.values());
      await dataPreferences.put('records', JSON.stringify(recordsArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存碳足迹记录失败:', error);
    }
  }

  private async saveEcoGoalsToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'eco_goals');
      const goalsArray = Array.from(this.ecoGoals.values());
      await dataPreferences.put('goals', JSON.stringify(goalsArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存环保目标失败:', error);
    }
  }

  private async saveEcoPointsToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'eco_points');
      const pointsArray = Array.from(this.ecoPoints.values());
      await dataPreferences.put('points', JSON.stringify(pointsArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存环保积分失败:', error);
    }
  }

  private async saveEcoStatsToStorage(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'eco_stats');
      const statsArray = Array.from(this.ecoStats.values());
      await dataPreferences.put('stats', JSON.stringify(statsArray));
      await dataPreferences.flush();
    } catch (error) {
      console.error('保存环保统计失败:', error);
    }
  }

  // 公共方法
  public getEcoPoints(userId: string): EcoPoints | undefined {
    return this.ecoPoints.get(userId);
  }

  public getEcoGoal(goalId: string): EcoGoal | undefined {
    return this.ecoGoals.get(goalId);
  }

  public getCarbonRecord(recordId: string): CarbonFootprintRecord | undefined {
    return this.carbonRecords.get(recordId);
  }
}
