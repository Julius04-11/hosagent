import { liveViewManager } from '@kit.LiveViewKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[LiveViewUtil]';
const DOMAIN = 0x0000;

/**
 * 实况窗工具类
 * 用于创建和管理实况窗
 */
export class LiveViewUtil {
  private sequence: number = 0;
  
  /**
   * 创建实况窗
   * @param title 标题
   * @param content 内容
   * @param icon 图标
   * @param context 上下文
   */
  async createLiveView(
    title: string,
    content: string,
    icon: string,
    context: common.UIAbilityContext
  ): Promise<void> {
    try {
      this.sequence++;
      
      const liveView: liveViewManager.LiveView = {
        id: 0,
        sequence: this.sequence,
        event: 'NAVIGATION',
        liveViewData: {
          capsule: {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: icon,
            backgroundColor: '#FF1976D2',
            title: title
          },
          primary: {
            title: title,
            content: [{ text: content }],
            liveViewLockScreenAbilityName: 'LiveViewExtAbility',
            liveViewLockScreenAbilityParameters: {
              initialData: JSON.stringify({ title, content })
            },
            keepTime: 0,
            clickAction: await this.buildWantAgent(context)
          }
        }
      };
      
      await liveViewManager.startLiveView(liveView);
      hilog.info(DOMAIN, TAG, 'Live view created successfully');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Failed to create live view: ${error.message}`);
      throw new Error(`Failed to create live view: ${error.message}`);
    }
  }
  
  /**
   * 构建WantAgent用于点击跳转
   * @param context 上下文
   * @returns WantAgent对象
   */
  private async buildWantAgent(context: common.UIAbilityContext): Promise<WantAgent> {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: context.abilityInfo.bundleName,
        abilityName: context.abilityInfo.name
      }],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    
    return await wantAgent.getWantAgent(wantAgentInfo);
  }
  
  /**
   * 停止实况窗
   * @param context 上下文
   */
  async stopLiveView(context: common.UIAbilityContext): Promise<void> {
    try {
      this.sequence++;
      
      const liveView: liveViewManager.LiveView = {
        id: 0,
        sequence: this.sequence,
        event: 'NAVIGATION',
        liveViewData: {
          capsule: {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: '',
            backgroundColor: '#FF1976D2',
            title: ''
          },
          primary: {
            title: '',
            content: [{ text: '' }],
            liveViewLockScreenAbilityName: 'LiveViewExtAbility',
            keepTime: 0,
            clickAction: await this.buildWantAgent(context)
          }
        }
      };
      
      await liveViewManager.stopLiveView(liveView);
      this.sequence = 0;
      hilog.info(DOMAIN, TAG, 'Live view stopped successfully');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Failed to stop live view: ${error.message}`);
    }
  }
}
