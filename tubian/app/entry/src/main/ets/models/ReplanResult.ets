/**
 * 重规划结果模型（对齐后端 ReplanResult）。
 */
import { RoutePlan, RiskLevel } from './RoutePlan';

export interface ReplanResult {
  trigger: string;
  oldPlanStatus: string;
  newPlan: RoutePlan;
  extraCost: number;
  action: string;
  explanation: string;
  riskLevel: RiskLevel;
}

/** 定位/天气数据模型（供服务层使用）。 */
export interface LocationData {
  lat: number;
  lng: number;
  accuracy?: number;
  timestamp?: number;
}

export interface WeatherData {
  city: string;
  weather: string;
  temperature?: number;
  warning?: string;
}
