import { hilog } from '@kit.PerformanceAnalysisKit';
import { batteryInfo } from '@kit.BasicServicesKit';

const TAG = '[LiveViewOptimizer]';
const DOMAIN = 0x0000;

/**
 * 数据变化检测器
 * 用于检测数据是否发生变化，减少不必要的更新
 */
export class DataChangeDetector {
  private lastData: string = '';
  
  /**
   * 检查数据是否发生变化
   * @param newData 新数据（支持任意可序列化对象）
   * @returns 是否发生变化
   */
  hasChanged(newData: object): boolean {
    const newDataStr = JSON.stringify(newData);
    if (newDataStr !== this.lastData) {
      this.lastData = newDataStr;
      hilog.info(DOMAIN, TAG, 'Data changed, will update');
      return true;
    }
    hilog.info(DOMAIN, TAG, 'Data unchanged, skip update');
    return false;
  }
  
  /**
   * 重置检测器
   */
  reset(): void {
    this.lastData = '';
  }
}

/**
 * 智能更新策略
 * 根据电量和更新频率控制更新行为
 */
export class SmartUpdateStrategy {
  private lastUpdateTime: number = 0;
  private minInterval: number = 3000; // 最小更新间隔（毫秒）
  private batteryLevel: number = 100;
  
  /**
   * 检查是否应该更新
   * @returns 是否应该更新
   */
  shouldUpdate(): boolean {
    const now = Date.now();
    const timeSinceLastUpdate = now - this.lastUpdateTime;
    
    // 检查是否达到最小更新间隔
    if (timeSinceLastUpdate < this.minInterval) {
      hilog.info(DOMAIN, TAG, `Update too frequent, skip (${timeSinceLastUpdate}ms)`);
      return false;
    }
    
    this.lastUpdateTime = now;
    return true;
  }
  
  /**
   * 根据电量调整更新间隔
   * @param batteryLevel 当前电量（0-100）
   * @returns 推荐的更新间隔（毫秒）
   */
  getUpdateInterval(batteryLevel: number): number {
    this.batteryLevel = batteryLevel;
    
    if (batteryLevel < 20) {
      // 低电量：30秒更新
      hilog.info(DOMAIN, TAG, 'Low battery, using 30s interval');
      return 30000;
    } else if (batteryLevel < 50) {
      // 中等电量：10秒更新
      hilog.info(DOMAIN, TAG, 'Medium battery, using 10s interval');
      return 10000;
    } else {
      // 高电量：5秒更新
      hilog.info(DOMAIN, TAG, 'High battery, using 5s interval');
      return 5000;
    }
  }
  
  /**
   * 获取当前设备电量
   * @returns 电量百分比（0-100）
   */
  async getBatteryLevel(): Promise<number> {
    try {
      const level = batteryInfo.batterySOC;
      hilog.info(DOMAIN, TAG, `Current battery level: ${level}%`);
      return level;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get battery level: ${err}`);
      return 100; // 获取失败时默认返回100%
    }
  }
  
  /**
   * 重置策略
   */
  reset(): void {
    this.lastUpdateTime = 0;
    this.minInterval = 3000;
    this.batteryLevel = 100;
  }
}

/**
 * 更新频率建议接口
 */
export interface UpdateFrequencyAdvice {
  description: string;
  interval: number;
  shouldOptimize: boolean;
}

/**
 * 功耗优化器
 * 提供功耗优化建议和策略
 */
export class PowerOptimizer {
  /**
   * 检查是否在后台运行
   * @returns 是否在后台
   */
  static isInBackground(): boolean {
    // 这里简化处理，实际应该检查应用状态
    // const processInfo = await appManager.getRunningProcessInformation();
    // return processInfo[0]?.state === appManager.ProcessState.STATE_BACKGROUND;
    return false;
  }
  
  /**
   * 根据电量获取更新频率建议
   * @param batteryLevel 电量百分比
   * @returns 更新频率建议（描述和间隔）
   */
  static getUpdateFrequencyAdvice(batteryLevel: number): UpdateFrequencyAdvice {
    if (batteryLevel < 20) {
      const advice: UpdateFrequencyAdvice = {
        description: '低电量模式：降低更新频率以节省电量',
        interval: 30000,
        shouldOptimize: true
      };
      return advice;
    } else if (batteryLevel < 50) {
      const advice: UpdateFrequencyAdvice = {
        description: '平衡模式：适中的更新频率',
        interval: 10000,
        shouldOptimize: true
      };
      return advice;
    } else {
      const advice: UpdateFrequencyAdvice = {
        description: '标准模式：正常更新频率',
        interval: 5000,
        shouldOptimize: false
      };
      return advice;
    }
  }
}
