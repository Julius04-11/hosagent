/**
 * 首选项数据库管理器 - 使用方舟ArkData键值型数据库
 * 用于存储用户偏好设置、应用配置等简单数据
 */
import { preferences } from '@kit.ArkData';

export class PreferencesManager {
  private static instance: PreferencesManager;
  private dataPreferences: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'SmartTravelPreferences';

  private constructor() {}

  public static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }

  /**
   * 初始化首选项数据库
   */
  async initialize(context: Context): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, this.PREFERENCES_NAME);
      console.info('[PreferencesManager] 首选项数据库初始化成功');
    } catch (error) {
      console.error('[PreferencesManager] 初始化失败:', error);
      throw new Error('PreferencesManager initialization failed');
    }
  }

  /**
   * 保存字符串数据
   */
  async putString(key: string, value: string): Promise<void> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      await this.dataPreferences.put(key, value);
      await this.dataPreferences.flush();
      console.info(`[PreferencesManager] 保存字符串: ${key}`);
    } catch (error) {
      console.error(`[PreferencesManager] 保存失败: ${key}`, error);
      throw new Error(`Failed to save preference: ${key}`);
    }
  }

  /**
   * 获取字符串数据
   */
  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      const value = await this.dataPreferences.get(key, defaultValue);
      return value as string;
    } catch (error) {
      console.error(`[PreferencesManager] 获取失败: ${key}`, error);
      return defaultValue;
    }
  }

  /**
   * 保存数字数据
   */
  async putNumber(key: string, value: number): Promise<void> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      await this.dataPreferences.put(key, value);
      await this.dataPreferences.flush();
      console.info(`[PreferencesManager] 保存数字: ${key} = ${value}`);
    } catch (error) {
      console.error(`[PreferencesManager] 保存失败: ${key}`, error);
      throw new Error(`Failed to save preference: ${key}`);
    }
  }

  /**
   * 获取数字数据
   */
  async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      const value = await this.dataPreferences.get(key, defaultValue);
      return value as number;
    } catch (error) {
      console.error(`[PreferencesManager] 获取失败: ${key}`, error);
      return defaultValue;
    }
  }

  /**
   * 保存布尔数据
   */
  async putBoolean(key: string, value: boolean): Promise<void> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      await this.dataPreferences.put(key, value);
      await this.dataPreferences.flush();
      console.info(`[PreferencesManager] 保存布尔值: ${key} = ${value}`);
    } catch (error) {
      console.error(`[PreferencesManager] 保存失败: ${key}`, error);
      throw new Error(`Failed to save preference: ${key}`);
    }
  }

  /**
   * 获取布尔数据
   */
  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      const value = await this.dataPreferences.get(key, defaultValue);
      return value as boolean;
    } catch (error) {
      console.error(`[PreferencesManager] 获取失败: ${key}`, error);
      return defaultValue;
    }
  }

  /**
   * 删除指定键的数据
   */
  async delete(key: string): Promise<void> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      await this.dataPreferences.delete(key);
      await this.dataPreferences.flush();
      console.info(`[PreferencesManager] 删除: ${key}`);
    } catch (error) {
      console.error(`[PreferencesManager] 删除失败: ${key}`, error);
      throw new Error(`Failed to delete preference: ${key}`);
    }
  }

  /**
   * 清空所有数据
   */
  async clear(): Promise<void> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      await this.dataPreferences.clear();
      await this.dataPreferences.flush();
      console.info('[PreferencesManager] 清空所有数据');
    } catch (error) {
      console.error('[PreferencesManager] 清空失败', error);
      throw new Error('Failed to clear preferences');
    }
  }

  /**
   * 检查是否存在某个键
   */
  async has(key: string): Promise<boolean> {
    if (!this.dataPreferences) {
      throw new Error('首选项数据库未初始化');
    }
    try {
      return await this.dataPreferences.has(key);
    } catch (error) {
      console.error(`[PreferencesManager] 检查键失败: ${key}`, error);
      return false;
    }
  }
}
