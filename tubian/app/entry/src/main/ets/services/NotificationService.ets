/**
 * 通知提醒：关键节点（出发/换乘/重规划）发送系统通知。
 */
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@kit.BasicServicesKit';

export class NotificationService {
  /** 发送一条普通通知；失败静默（不阻塞流程）。 */
  static async notify(title: string, text: string): Promise<void> {
    try {
      const request: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        }
      };
      await notificationManager.publish(request);
    } catch (e) {
      const err = e as BusinessError;
      console.error(`通知失败: ${err.code} ${err.message}`);
    }
  }
}
