/**
 * 用户出行目标模型（对齐后端 TravelGoal，JSON 为 camelCase）。
 */
export interface Companion {
  type: string; // 老人 / 儿童 / 朋友 ...
  count: number;
}

export type TravelPreference = '准时优先' | '省钱优先' | '少步行' | '少换乘' | '舒适优先';

export interface TravelGoal {
  origin: string;
  destination: string;
  departureTime?: string; // "HH:MM"
  deadline: string;       // "HH:MM"
  budget?: number;
  luggage: boolean;
  preference: TravelPreference;
  companions: Companion[];
}

export function emptyGoal(): TravelGoal {
  return {
    origin: '',
    destination: '',
    deadline: '19:00',
    luggage: false,
    preference: '准时优先',
    companions: []
  };
}

export const PREFERENCE_OPTIONS: TravelPreference[] =
  ['准时优先', '省钱优先', '少步行', '少换乘', '舒适优先'];
