import { commonEventManager } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[LiveViewUpdateService]';
const DOMAIN = 0x0000;

/**
 * 旅游实况窗数据接口
 */
export interface TravelLiveViewData {
  title: string;
  distance: string;
  destination: string;
  eta: string;
}

/**
 * 实况窗更新服务
 * 用于发布实况窗更新事件
 */
export class LiveViewUpdateService {
  /**
   * 发布实况窗更新事件
   * @param data 实况窗数据
   */
  static publishUpdate(data: TravelLiveViewData): void {
    try {
      const options: commonEventManager.CommonEventPublishData = {
        data: 'live_view_update',
        bundleName: 'com.example.smarttravel',
        parameters: {
          'liveViewData': data
        }
      };
      
      commonEventManager.publish('smart_travel_live_view', options, (error) => {
        if (error) {
          hilog.error(DOMAIN, TAG, `Failed to publish event: ${error.message}`);
        } else {
          hilog.info(DOMAIN, TAG, 'Event published successfully');
        }
      });
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Publish failed: ${error.message}`);
    }
  }
}
