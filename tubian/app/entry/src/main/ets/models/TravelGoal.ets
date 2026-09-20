/**
 * 用户出行目标模型（对齐后端 TravelGoal，JSON 为 camelCase）。
 */
export interface Companion {
  type: string; // 老人 / 儿童 / 朋友 ...
  count: number;
}

export type TravelPreference = '准时优先' | '省钱优先' | '少步行' | '少换乘' | '舒适优先';

/** 交通方式偏好 */
export type TransportMode = '公交' | '地铁' | '网约车' | '高铁' | '步行';

/** 出行习惯画像 */
export interface TravelProfile {
  motionSick: boolean;       // 晕车 → 优先地铁/高铁，少公交
  heavyLuggage: boolean;     // 大件行李 → 少步行少换乘
  withElderly: boolean;      // 带老人/小孩 → 优先有座、少步行
  budgetSensitive: boolean;  // 预算敏感 → 优先公交
  timeSensitive: boolean;    // 时间敏感 → 优先网约车/高铁
}

export interface TravelGoal {
  origin: string;
  destination: string;
  departureTime?: string; // "HH:MM"
  deadline: string;       // "HH:MM"
  budget?: number;
  luggage: boolean;
  preference: TravelPreference;
  companions: Companion[];
  acceptRideHail?: boolean;
  transportModes?: TransportMode[];   // 偏好交通方式（空=不限）
  travelProfile?: TravelProfile;      // 出行习惯画像
}

export function emptyGoal(): TravelGoal {
  return {
    origin: '',
    destination: '',
    deadline: '19:00',
    luggage: false,
    preference: '准时优先',
    companions: [],
    transportModes: [],
    travelProfile: {
      motionSick: false,
      heavyLuggage: false,
      withElderly: false,
      budgetSensitive: false,
      timeSensitive: false
    }
  };
}

export const PREFERENCE_OPTIONS: TravelPreference[] =
  ['准时优先', '省钱优先', '少步行', '少换乘', '舒适优先'];

export const TRANSPORT_MODES: TransportMode[] =
  ['公交', '地铁', '网约车', '高铁', '步行'];
