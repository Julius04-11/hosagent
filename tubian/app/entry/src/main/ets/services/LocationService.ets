/**
 * 定位服务：封装 HarmonyOS 定位能力 + 运行时权限申请。
 * 动态跟踪通过「轮询 getCurrentLocation()」实现（连续定位订阅 on/off 因
 * SDK 版本签名差异易编译失败，故改用轮询，逻辑简单且跨版本稳定）。
 */
import geoLocationManager from '@ohos.geoLocationManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import { LocationData } from '../models/ReplanResult';

export interface LocationResult {
  loc: LocationData;
  isMock: boolean;
}

export class LocationService {
  /** 最近一次定位失败的错误信息（供 UI 展示）。 */
  static lastError: string = '';

  /** 申请定位权限（真机首次定位前调用）。 */
  static async requestPermission(context: common.Context): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const perms: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
      const result = await atManager.requestPermissionsFromUser(context, perms);
      const granted = result.authResults.length > 0 &&
        result.authResults.every((r: number) => r === 0);
      return granted;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`权限申请失败: ${err.code} ${err.message}`);
      return false;
    }
  }

  /** 定位服务是否已开启。 */
  static isLocationEnabled(): boolean {
    try {
      return geoLocationManager.isLocationEnabled();
    } catch (e) {
      return false;
    }
  }

  /** 获取当前位置；失败返回 null，并把错误码写入 lastError。 */
  static async getCurrentLocation(): Promise<LocationData | null> {
    try {
      const location = await geoLocationManager.getCurrentLocation();
      LocationService.lastError = '';
      return {
        lat: location.latitude,
        lng: location.longitude,
        accuracy: location.accuracy,
        timestamp: Date.now()
      };
    } catch (e) {
      const err = e as BusinessError;
      LocationService.lastError = `code=${err.code} ${err.message}`;
      console.error(`定位失败: ${LocationService.lastError}`);
      return null;
    }
  }

  /** 获取定位；真实定位失败时回退到 Mock 定位（保证演示可用）。 */
  static async getLocationOrMock(): Promise<LocationResult> {
    const loc = await LocationService.getCurrentLocation();
    if (loc) {
      const r: LocationResult = { loc: loc, isMock: false };
      return r;
    }
    const r: LocationResult = { loc: LocationService.mockLocation(), isMock: true };
    return r;
  }

  /** Mock 位置（杭州东站附近），用于预览器/演示。 */
  static mockLocation(): LocationData {
    return { lat: 30.291, lng: 120.211, accuracy: 30, timestamp: Date.now() };
  }
}
