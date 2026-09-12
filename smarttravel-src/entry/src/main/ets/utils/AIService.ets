import { HttpUtil } from './HttpUtil';

/**
 * AI服务类 - 集成智能推荐和对话功能
 */
export class AIService {
  // AI API基础URL（可替换为实际的AI服务地址）
  private static AI_BASE_URL = 'https://api.openai.com/v1';
  private static API_KEY = 'YOUR_API_KEY_HERE'; // 请替换为实际API Key

  /**
   * 智能推荐景点
   * @param userPreferences 用户偏好
   * @returns 推荐结果
   */
  static async getAttractionRecommendations(userPreferences: {
    location: string;
    interests: string[];
    budget: string;
  }): Promise<string[]> {
    try {
      const prompt = `用户位置：${userPreferences.location}，兴趣：${userPreferences.interests.join('、')}，预算：${userPreferences.budget}。请推荐5个适合的深圳景点。`;
      
      const result = await this.callAI(prompt);
      return this.parseRecommendations(result);
    } catch (error) {
      console.error('AI推荐失败:', error);
      return [];
    }
  }

  /**
   * 智能客服对话
   * @param userMessage 用户消息
   * @returns AI回复
   */
  static async chatWithAI(userMessage: string): Promise<string> {
    try {
      const prompt = `你是一个智慧旅游助手，用户问：${userMessage}`;
      return await this.callAI(prompt);
    } catch (error) {
      console.error('AI对话失败:', error);
      return '抱歉，服务暂时不可用';
    }
  }

  /**
   * 调用AI接口（通用方法）
   */
  private static async callAI(prompt: string): Promise<string> {
    // 示例：调用OpenAI API
    const requestData = {
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7
    };

    // 注意：实际使用时需要配置正确的API URL和认证
    const response = await HttpUtil.post<any>('/chat/completions', requestData);
    return response.choices[0].message.content;
  }

  /**
   * 解析推荐结果
   */
  private static parseRecommendations(aiResponse: string): string[] {
    const lines = aiResponse.split('\n').filter(line => line.trim().length > 0);
    return lines.slice(0, 5);
  }
}
