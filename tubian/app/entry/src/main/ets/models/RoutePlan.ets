/**
 * 路线方案模型（对齐后端 RoutePlan / RouteSegment，JSON 为 camelCase）。
 */
export type SegmentMode = '高铁' | '地铁' | '公交' | '步行' | '网约车';
export type PlanType = '主方案' | 'Plan B' | '重规划方案';
export type RiskLevel = '低' | '中' | '高';

export interface RouteSegment {
  mode: SegmentMode;
  from: string;
  to: string;
  startTime?: string;
  endTime?: string;
  durationMinutes: number;
  distanceMeters?: number;
  cost?: number;
  note?: string;
}

export interface RoutePlan {
  planId: string;
  type: PlanType;
  eta: string;
  cost: number;
  durationMinutes: number;
  walkDistanceMeters: number;
  transferCount: number;
  riskLevel: RiskLevel;
  onTimeProbability: number;
  segments: RouteSegment[];
  reason: string;
}

/** 从后端 JSON 对象转成 RoutePlan（运行时做一次字段校验兜底）。 */
export function toRoutePlan(o: object): RoutePlan {
  return o as RoutePlan;
}
