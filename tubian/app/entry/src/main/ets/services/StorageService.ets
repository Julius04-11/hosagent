/**
 * 本地存储：Preferences 保存最近行程与偏好（需求文档 §9.2 / §12.3 数据存储原则）。
 */
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';

const STORE_NAME = 'tubian_prefs';

export class StorageService {
  private static async getPrefs(context: common.UIAbilityContext) {
    return preferences.getPreferences(context, STORE_NAME);
  }

  static async save(context: common.UIAbilityContext, key: string, value: string): Promise<void> {
    try {
      const prefs = await StorageService.getPrefs(context);
      await prefs.put(key, value);
      await prefs.flush();
    } catch (e) {
      const err = e as BusinessError;
      console.error(`存储失败: ${err.code} ${err.message}`);
    }
  }

  static async read(context: common.UIAbilityContext, key: string, def: string = ''): Promise<string> {
    try {
      const prefs = await StorageService.getPrefs(context);
      const v = await prefs.get(key, def);
      return v as string;
    } catch (e) {
      return def;
    }
  }

  static async clear(context: common.UIAbilityContext): Promise<void> {
    try {
      const prefs = await StorageService.getPrefs(context);
      await prefs.clear();
    } catch (e) {
      const err = e as BusinessError;
      console.error(`清除失败: ${err.code} ${err.message}`);
    }
  }
}
