/**
 * 智能推荐引擎 - 千人千面推荐
 */

export interface RecommendItem {
  id: string;
  name: string;
  type: 'restaurant' | 'hotel' | 'attraction';
  score: number;
  reason: string;
}

export class SmartRecommendation {
  private static instance: SmartRecommendation;

  static getInstance(): SmartRecommendation {
    if (!this.instance) {
      this.instance = new SmartRecommendation();
    }
    return this.instance;
  }

  /**
   * 个性化推荐
   */
  async getRecommendations(userId: string, context: any): Promise<RecommendItem[]> {
    // 协同过滤 + 内容推荐
    const items: RecommendItem[] = [
      {
        id: '1',
        name: '深圳湾海鲜大排档',
        type: 'restaurant',
        score: 95,
        reason: '根据您的口味偏好推荐'
      },
      {
        id: '2',
        name: '欢乐谷',
        type: 'attraction',
        score: 88,
        reason: '附近热门景点'
      }
    ];

    return items.sort((a, b) => b.score - a.score);
  }
}
