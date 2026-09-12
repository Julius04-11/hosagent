import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[BackgroundTaskService]';
const DOMAIN = 0x0000;

/**
 * 后台任务服务
 * 用于管理后台长时任务
 */
export class BackgroundTaskService {
  /**
   * 开启后台长时任务
   * @param context 上下文
   */
  static async startBackgroundTask(context: common.UIAbilityContext): Promise<void> {
    try {
      // 创建WantAgent
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      
      const wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
      
      // 开启后台任务
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.LOCATION,
        wantAgentObj
      );
      
      hilog.info(DOMAIN, TAG, 'Background task started');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Failed to start background task: ${error.message}`);
      throw new Error(`Failed to start background task: ${error.message}`);
    }
  }
  
  /**
   * 停止后台长时任务
   * @param context 上下文
   */
  static async stopBackgroundTask(context: common.UIAbilityContext): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      hilog.info(DOMAIN, TAG, 'Background task stopped');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Failed to stop background task: ${error.message}`);
    }
  }
}
