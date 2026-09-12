/**
 * 地理坐标工具（客户端 Mock 用，与后端 geo.py 对应）。
 */
export interface Coords {
  lat: number;
  lng: number;
}

export const PLACE_COORDS: Record<string, Coords> = {
  '杭州东站': { lat: 30.291, lng: 120.211 },
  '杭州': { lat: 30.2741, lng: 120.1551 },
  '上海虹桥站': { lat: 31.197, lng: 121.326 },
  '上海': { lat: 31.2304, lng: 121.4737 },
  '演唱会场馆': { lat: 31.231, lng: 121.475 },
  '深圳': { lat: 22.5431, lng: 114.0579 },
  '广州': { lat: 23.1291, lng: 113.2644 },
  '北京': { lat: 39.9042, lng: 116.4074 },
  '南京': { lat: 32.0603, lng: 118.7969 }
};

/** 两点球面距离（米）。 */
export function haversine(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const r = 6371000;
  const p1 = lat1 * Math.PI / 180;
  const p2 = lat2 * Math.PI / 180;
  const dp = (lat2 - lat1) * Math.PI / 180;
  const dl = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dp / 2) * Math.sin(dp / 2) +
    Math.cos(p1) * Math.cos(p2) * Math.sin(dl / 2) * Math.sin(dl / 2);
  return 2 * r * Math.asin(Math.sqrt(a));
}

/** 地点名 -> 坐标（精确优先，最长子串兜底）。 */
export function getCoords(place: string): Coords | null {
  if (place.length === 0) {
    return null;
  }
  if (PLACE_COORDS[place] !== undefined) {
    return PLACE_COORDS[place];
  }
  let best: Coords | null = null;
  let bestLen = 0;
  const keys: string[] = Object.keys(PLACE_COORDS);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (place.includes(key) && key.length > bestLen) {
      best = PLACE_COORDS[key];
      bestLen = key.length;
    }
  }
  return best;
}
