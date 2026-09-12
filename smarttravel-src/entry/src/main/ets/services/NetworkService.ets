import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'NetworkService';
const DOMAIN = 0xFF00;

/**
 * 网络连通性状态
 */
export enum NetworkConnectivity {
  VALIDATED = 'VALIDATED',           // 已验证，可访问互联网
  NOT_VALIDATED = 'NOT_VALIDATED',   // 未验证，不可访问互联网
  CHECKING = 'CHECKING',             // 正在验证中
  UNAVAILABLE = 'UNAVAILABLE'        // 网络不可用
}

/**
 * 网络类型
 */
export enum NetworkType {
  CELLULAR = 'CELLULAR',  // 蜂窝网络
  WIFI = 'WIFI',          // Wi-Fi网络
  ETHERNET = 'ETHERNET',  // 以太网
  UNKNOWN = 'UNKNOWN'     // 未知类型
}

/**
 * 网络信息
 */
export interface NetworkInfo {
  netId: number;
  type: NetworkType;
  connectivity: NetworkConnectivity;
  isMetered: boolean;      // 是否计费
  linkSpeed?: number;      // 链接速度
  signalStrength?: number; // 信号强度
}

/**
 * 网络服务工具类
 * 提供网络状态查询、DNS解析、网络能力检测等功能
 */
export class NetworkService {
  private static instance: NetworkService;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): NetworkService {
    if (!NetworkService.instance) {
      NetworkService.instance = new NetworkService();
    }
    return NetworkService.instance;
  }

  /**
   * 获取默认网络信息（同步）
   */
  public getDefaultNetworkInfo(): NetworkInfo | null {
    try {
      const netHandle = connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        hilog.warn(DOMAIN, TAG, 'No default network available');
        return {
          netId: 0,
          type: NetworkType.UNKNOWN,
          connectivity: NetworkConnectivity.UNAVAILABLE,
          isMetered: false
        };
      }

      const caps = connection.getNetCapabilitiesSync(netHandle);
      const type = this.parseNetworkType(caps.bearerTypes);
      const connectivity = this.parseConnectivity(caps.networkCap);
      const isMetered = !caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_METERED);

      hilog.info(DOMAIN, TAG, `Default network: ${netHandle.netId}, type: ${type}, connectivity: ${connectivity}`);

      return {
        netId: netHandle.netId,
        type,
        connectivity,
        isMetered
      };
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get default network info: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 获取默认网络信息（异步）
   */
  public async getDefaultNetworkInfoAsync(): Promise<NetworkInfo | null> {
    try {
      const netHandle = await connection.getDefaultNet();
      if (!netHandle || netHandle.netId === 0) {
        hilog.warn(DOMAIN, TAG, 'No default network available');
        return {
          netId: 0,
          type: NetworkType.UNKNOWN,
          connectivity: NetworkConnectivity.UNAVAILABLE,
          isMetered: false
        };
      }

      const caps = await connection.getNetCapabilities(netHandle);
      const type = this.parseNetworkType(caps.bearerTypes);
      const connectivity = this.parseConnectivity(caps.networkCap);
      const isMetered = !caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_METERED);

      return {
        netId: netHandle.netId,
        type,
        connectivity,
        isMetered
      };
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get default network info async: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 获取所有网络信息
   */
  public async getAllNetworks(): Promise<NetworkInfo[]> {
    try {
      const netHandles = await connection.getAllNets();
      const networks: NetworkInfo[] = [];

      for (const handle of netHandles) {
        try {
          const caps = await connection.getNetCapabilities(handle);
          const type = this.parseNetworkType(caps.bearerTypes);
          const connectivity = this.parseConnectivity(caps.networkCap);
          const isMetered = !caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_METERED);

          networks.push({
            netId: handle.netId,
            type,
            connectivity,
            isMetered
          });
        } catch (err) {
          hilog.error(DOMAIN, TAG, `Failed to get capabilities for network ${handle.netId}`);
        }
      }

      hilog.info(DOMAIN, TAG, `Total ${networks.length} networks available`);
      return networks;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get all networks: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 判断默认网络是否可访问互联网
   */
  public isInternetAvailable(): boolean {
    const info = this.getDefaultNetworkInfo();
    return info !== null && info.connectivity === NetworkConnectivity.VALIDATED;
  }

  /**
   * 判断是否在计费网络（蜂窝网络）
   */
  public isMeteredNetwork(): boolean {
    const info = this.getDefaultNetworkInfo();
    return info !== null && info.isMetered;
  }

  /**
   * 判断是否在 Wi-Fi 网络
   */
  public isWiFiNetwork(): boolean {
    const info = this.getDefaultNetworkInfo();
    return info !== null && info.type === NetworkType.WIFI;
  }

  /**
   * DNS解析：获取域名所有IP地址
   */
  public async resolveHostname(hostname: string): Promise<connection.NetAddress[]> {
    try {
      hilog.info(DOMAIN, TAG, `Resolving hostname: ${hostname}`);
      const addresses = await connection.getAddressesByName(hostname);
      hilog.info(DOMAIN, TAG, `Resolved ${addresses.length} addresses for ${hostname}`);
      return addresses;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to resolve hostname ${hostname}: ${JSON.stringify(err)}`);
      return [];
    }
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
   * 获取网络能力描述（调试用）
   */
  public async getNetworkCapabilitiesDescription(netHandle: connection.NetHandle): Promise<string> {
    try {
      const caps = await connection.getNetCapabilities(netHandle);
      const descriptions: string[] = [];

      // 网络类型
      if (caps.bearerTypes?.includes(connection.NetBearType.BEARER_CELLULAR)) {
        descriptions.push('蜂窝网络');
      }
      if (caps.bearerTypes?.includes(connection.NetBearType.BEARER_WIFI)) {
        descriptions.push('Wi-Fi网络');
      }
      if (caps.bearerTypes?.includes(connection.NetBearType.BEARER_ETHERNET)) {
        descriptions.push('以太网');
      }

      // 网络能力
      if (caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_INTERNET)) {
        descriptions.push('可访问互联网');
      }
      if (caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        descriptions.push('已验证连通性');
      }
      if (caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_METERED)) {
        descriptions.push('未计费');
      }
      if (caps.networkCap?.includes(connection.NetCap.NET_CAPABILITY_NOT_VPN)) {
        descriptions.push('非VPN');
      }

      return descriptions.join(', ');
    } catch (err) {
      return '获取失败';
    }
  }
}
