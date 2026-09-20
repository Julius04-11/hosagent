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

export class LocationService {
  /** 最近一次定位失败的错误信息（供 UI 展示）。 */
  static lastError: string = '';

  /** 申请定位权限（真机首次定位前调用）。 */
  static async requestPermission(context: common.Context): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const perms: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

      // 预检查：若已授权则直接返回，避免重复弹窗
      const tokenId = context.applicationInfo.accessTokenId;
      const alreadyGranted = perms.some((p: Permissions) =>
        atManager.checkAccessTokenSync(tokenId, p) === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );
      if (alreadyGranted) {
        return true;
      }

      const result = await atManager.requestPermissionsFromUser(context, perms);
      // 用户在弹窗中可选"精确位置"或"大致位置"，任一授权即视为通过
      // （精确=两权限均授；大致=仅 APPROXIMATELY_LOCATION 授）
      const granted = result.authResults.length > 0 &&
        result.authResults.some((r: number) => r === 0);
      return granted;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`权限申请失败: ${err.code} ${err.message}`);
      return false;
    }
  }

  /** 只读检查定位权限是否已授予（不弹窗，供设置页展示状态）。 */
  static checkPermission(context: common.Context): boolean {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const tokenId = context.applicationInfo.accessTokenId;
      const perms: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
      return perms.some((p: Permissions) =>
        atManager.checkAccessTokenSync(tokenId, p) === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );
    } catch (e) {
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

  /** 获取当前位置；失败返回 null，并把错误码写入 lastError（中文可操作提示，供 UI 直接展示）。 */
  static async getCurrentLocation(): Promise<LocationData | null> {
    if (!LocationService.isLocationEnabled()) {
      LocationService.lastError = '定位服务未开启，请下拉控制中心打开"位置信息"开关';
      console.error(`定位未开启`);
      return null;
    }

    try {
      // 出行规划+动态跟踪场景：优先快速首定，导航场景匹配行程跟踪
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION
      };
      const location = await geoLocationManager.getCurrentLocation(request);
      LocationService.lastError = '';
      return {
        lat: location.latitude,
        lng: location.longitude,
        accuracy: location.accuracy,
        timestamp: Date.now()
      };
    } catch (e) {
      const err = e as BusinessError;
      if (err.code === 201) {
        // 权限被拒绝
        LocationService.lastError = '定位权限未授权，请在系统设置中允许应用使用位置信息';
      } else if (err.code === 3301100) {
        // 定位开关被关闭（获取中途关闭）
        LocationService.lastError = '定位服务未开启，请下拉控制中心打开"位置信息"开关';
      } else if (err.code === 3301000 || err.code === 3301200) {
        // 定位失败/拿不到结果
        LocationService.lastError = '暂时无法获取位置，请到开阔区域后重试';
      } else {
        LocationService.lastError = `定位失败(code=${err.code})`;
      }
      console.error(`定位失败: ${err.code} ${err.message}`);
      return null;
    }
  }
}
