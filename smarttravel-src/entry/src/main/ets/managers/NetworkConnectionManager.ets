import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NetworkService, NetworkInfo, NetworkConnectivity, NetworkType } from '../services/NetworkService';

const TAG = 'NetworkConnectionManager';
const DOMAIN = 0xFF00;

/**
 * 网络状态变化回调
 */
export type NetworkChangeCallback = (info: NetworkInfo) => void;

/**
 * 网络连接管理器
 * 负责监听默认网络变化、管理网络状态订阅
 */
export class NetworkConnectionManager {
  private static instance: NetworkConnectionManager;
  private netConnection: connection.NetConnection | null = null;
  private networkService: NetworkService;
  private changeCallbacks: Set<NetworkChangeCallback> = new Set();
  private currentNetworkInfo: NetworkInfo | null = null;
  private isListening: boolean = false;

  private constructor() {
    this.networkService = NetworkService.getInstance();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): NetworkConnectionManager {
    if (!NetworkConnectionManager.instance) {
      NetworkConnectionManager.instance = new NetworkConnectionManager();
    }
    return NetworkConnectionManager.instance;
  }

  /**
   * 开始监听默认网络变化
   */
  public startListening(): void {
    if (this.isListening) {
      hilog.warn(DOMAIN, TAG, 'Already listening to network changes');
      return;
    }

    try {
      // 创建默认网络连接对象
      this.netConnection = connection.createNetConnection();

      // 监听网络可用事件
      this.netConnection.on('netAvailable', (netHandle: connection.NetHandle) => {
        hilog.info(DOMAIN, TAG, `Network available: ${netHandle.netId}`);
        this.handleNetworkChange(netHandle);
      });

      // 监听网络能力变化事件
      this.netConnection.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
        hilog.info(DOMAIN, TAG, `Network capabilities changed`);
        // 直接调用更新，不需要 netHandle
        this.updateCurrentNetworkInfo();
      });

      // 监听网络不可用事件
      this.netConnection.on('netUnavailable', () => {
        hilog.warn(DOMAIN, TAG, 'Network unavailable');
        this.handleNetworkUnavailable();
      });

      // 监听网络丢失事件
      this.netConnection.on('netLost', (netHandle: connection.NetHandle) => {
        hilog.warn(DOMAIN, TAG, `Network lost: ${netHandle.netId}`);
        this.handleNetworkLost(netHandle);
      });

      // 注册监听
      this.netConnection.register((err: BusinessError) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to register network listener: ${JSON.stringify(err)}`);
          this.isListening = false;
        } else {
          hilog.info(DOMAIN, TAG, 'Network listener registered successfully');
          this.isListening = true;
          // 立即获取当前网络信息
          this.updateCurrentNetworkInfo();
        }
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to start listening: ${JSON.stringify(err)}`);
      this.isListening = false;
    }
  }

  /**
   * 停止监听网络变化
   */
  public stopListening(): void {
    if (!this.isListening || !this.netConnection) {
      return;
    }

    try {
      // 取消注册
      this.netConnection.unregister((err: BusinessError) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to unregister: ${JSON.stringify(err)}`);
        } else {
          hilog.info(DOMAIN, TAG, 'Network listener unregistered successfully');
        }
      });

      this.netConnection = null;
      this.isListening = false;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to stop listening: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 订阅网络变化通知
   */
  public subscribe(callback: NetworkChangeCallback): void {
    this.changeCallbacks.add(callback);
    hilog.info(DOMAIN, TAG, `Subscribed, total callbacks: ${this.changeCallbacks.size}`);

    // 如果当前有网络信息，立即通知
    if (this.currentNetworkInfo) {
      callback(this.currentNetworkInfo);
    }
  }

  /**
   * 取消订阅网络变化通知
   */
  public unsubscribe(callback: NetworkChangeCallback): void {
    this.changeCallbacks.delete(callback);
    hilog.info(DOMAIN, TAG, `Unsubscribed, remaining callbacks: ${this.changeCallbacks.size}`);
  }

  /**
   * 获取当前网络信息
   */
  public getCurrentNetworkInfo(): NetworkInfo | null {
    return this.currentNetworkInfo;
  }

  /**
   * 手动刷新当前网络信息
   */
  public refreshNetworkInfo(): void {
    this.updateCurrentNetworkInfo();
  }

  /**
   * 处理网络变化
   */
  private async handleNetworkChange(netHandle: connection.NetHandle): Promise<void> {
    try {
      const caps = await connection.getNetCapabilities(netHandle);
      const type = this.parseNetworkType(caps.bearerTypes);
      const connectivity = this.parseConnectivity(caps.networkCap);
      const isMetered = !caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_METERED);

      const newInfo: NetworkInfo = {
        netId: netHandle.netId,
        type,
        connectivity,
        isMetered
      };

      // 检查是否有实质性变化
      if (this.hasNetworkInfoChanged(newInfo)) {
        hilog.info(DOMAIN, TAG, `Network changed: ${JSON.stringify(newInfo)}`);
        this.currentNetworkInfo = newInfo;
        this.notifyCallbacks(newInfo);
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to handle network change: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 处理网络不可用
   */
  private handleNetworkUnavailable(): void {
    const unavailableInfo: NetworkInfo = {
      netId: 0,
      type: NetworkType.UNKNOWN,
      connectivity: NetworkConnectivity.UNAVAILABLE,
      isMetered: false
    };

    this.currentNetworkInfo = unavailableInfo;
    this.notifyCallbacks(unavailableInfo);
  }

  /**
   * 处理网络丢失
   */
  private handleNetworkLost(netHandle: connection.NetHandle): void {
    if (this.currentNetworkInfo?.netId === netHandle.netId) {
      hilog.warn(DOMAIN, TAG, `Current network lost: ${netHandle.netId}`);
      // 尝试获取新的默认网络
      this.updateCurrentNetworkInfo();
    }
  }

  /**
   * 更新当前网络信息
   */
  private updateCurrentNetworkInfo(): void {
    const info = this.networkService.getDefaultNetworkInfo();
    if (info && this.hasNetworkInfoChanged(info)) {
      hilog.info(DOMAIN, TAG, `Network info updated: ${JSON.stringify(info)}`);
      this.currentNetworkInfo = info;
      this.notifyCallbacks(info);
    }
  }

  /**
   * 检查网络信息是否有变化
   */
  private hasNetworkInfoChanged(newInfo: NetworkInfo): boolean {
    if (!this.currentNetworkInfo) {
      return true;
    }

    return this.currentNetworkInfo.netId !== newInfo.netId ||
      this.currentNetworkInfo.type !== newInfo.type ||
      this.currentNetworkInfo.connectivity !== newInfo.connectivity ||
      this.currentNetworkInfo.isMetered !== newInfo.isMetered;
  }

  /**
   * 通知所有订阅者
   */
  private notifyCallbacks(info: NetworkInfo): void {
    this.changeCallbacks.forEach(callback => {
      try {
        callback(info);
      } catch (err) {
        hilog.error(DOMAIN, TAG, `Callback error: ${JSON.stringify(err)}`);
      }
    });
  }

  /**
   * 解析网络类型
   */
  private parseNetworkType(bearerTypes?: number[]): NetworkType {
    if (!bearerTypes || bearerTypes.length === 0) {
      return NetworkType.UNKNOWN;
    }

    if (bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
      return NetworkType.CELLULAR;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
      return NetworkType.WIFI;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
      return NetworkType.ETHERNET;
    }

    return NetworkType.UNKNOWN;
  }

  /**
   * 解析网络连通性状态
   */
  private parseConnectivity(networkCap?: number[]): NetworkConnectivity {
    if (!networkCap || networkCap.length === 0) {
      return NetworkConnectivity.UNAVAILABLE;
    }

    if (networkCap.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY)) {
      return NetworkConnectivity.CHECKING;
    } else if (networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
      return NetworkConnectivity.VALIDATED;
    } else {
      return NetworkConnectivity.NOT_VALIDATED;
    }
  }

  /**
   * 获取网络状态描述文本
   */
  public static getNetworkStatusText(info: NetworkInfo | null): string {
    if (!info || info.connectivity === NetworkConnectivity.UNAVAILABLE) {
      return '网络不可用';
    }

    let typeText: string;
    switch (info.type) {
      case NetworkType.WIFI:
        typeText = 'Wi-Fi';
        break;
      case NetworkType.CELLULAR:
        typeText = '移动网络';
        break;
      case NetworkType.ETHERNET:
        typeText = '以太网';
        break;
      default:
        typeText = '未知网络';
        break;
    }

    let connectivityText: string;
    switch (info.connectivity) {
      case NetworkConnectivity.VALIDATED:
        connectivityText = '已连接';
        break;
      case NetworkConnectivity.NOT_VALIDATED:
        connectivityText = '无互联网';
        break;
      case NetworkConnectivity.CHECKING:
        connectivityText = '检查中';
        break;
      default:
        connectivityText = '未知状态';
        break;
    }

    const meteredText = info.isMetered ? ' (计费)' : '';

    return `${typeText} - ${connectivityText}${meteredText}`;
  }

  /**
   * 获取网络图标
   */
  public static getNetworkIcon(info: NetworkInfo | null): string {
    if (!info || info.connectivity === NetworkConnectivity.UNAVAILABLE) {
      return '📵'; // 无网络
    }

    if (info.connectivity === NetworkConnectivity.CHECKING) {
      return '🔄'; // 检查中
    }

    if (info.connectivity === NetworkConnectivity.NOT_VALIDATED) {
      return '⚠️'; // 无互联网
    }

    // VALIDATED
    if (info.type === NetworkType.WIFI) {
      return '📶';
    } else if (info.type === NetworkType.CELLULAR) {
      return '📱';
    } else if (info.type === NetworkType.ETHERNET) {
      return '🔌';
    } else {
      return '🌐';
    }
  }
}
