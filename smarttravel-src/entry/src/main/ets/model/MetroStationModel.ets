import { mapCommon } from '@kit.MapKit';

/**
 * 地铁站信息模型
 */
export interface MetroInfo {
  siteId: string;
  name: string;
  address: string;
  location: mapCommon.LatLng;
  distance: number;
}

