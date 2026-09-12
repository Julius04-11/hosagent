import { Prompt } from '@kit.ArkUI';

/**
 * 签到功能工具类
 */
export class SignInUtils {
  
  /**
   * 处理签到功能
   */
  static handleSignIn(): void {
    const today = new Date().toDateString();
    const lastSignIn = AppStorage.get('lastSignInDate') as string;
    
    if (lastSignIn === today) {
      Prompt.showToast({ message: '今日已签到！' });
      return;
    }
    
    // 模拟签到奖励
    const rewards = ['10积分', '5积分', '优惠券', '15积分', '20积分'];
    const randomReward = rewards[Math.floor(Math.random() * rewards.length)];
    
    AppStorage.setOrCreate('lastSignInDate', today);
    Prompt.showToast({ message: `签到成功！获得 ${randomReward}` });
  }

  /**
   * 检查今日是否已签到
   */
  static hasSignedInToday(): boolean {
    const today = new Date().toDateString();
    const lastSignIn = AppStorage.get('lastSignInDate') as string;
    return lastSignIn === today;
  }

  /**
   * 获取连续签到天数
   */
  static getConsecutiveSignInDays(): number {
    const consecutiveDays = AppStorage.get('consecutiveSignInDays') as number;
    return consecutiveDays || 0;
  }

  /**
   * 更新连续签到天数
   */
  static updateConsecutiveSignInDays(): void {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    const lastSignIn = AppStorage.get('lastSignInDate') as string;
    const consecutiveDays = AppStorage.get('consecutiveSignInDays') as number || 0;
    
    if (lastSignIn === yesterday.toDateString()) {
      // 连续签到
      AppStorage.setOrCreate('consecutiveSignInDays', consecutiveDays + 1);
    } else if (lastSignIn !== today.toDateString()) {
      // 中断签到，重新开始
      AppStorage.setOrCreate('consecutiveSignInDays', 1);
    }
  }
}
