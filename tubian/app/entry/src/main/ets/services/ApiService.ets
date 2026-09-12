/**
 * 后端接口请求封装。
 * 优先走 HTTP；网络异常时回退到内置 Mock（《开发文档》§12.1 Mock 阶段 / §13 异常兜底）。
 * Mock 路线根据解析出的起终点动态生成，而非写死。
 */
import http from '@ohos.net.http';
import { TravelGoal, emptyGoal } from '../models/TravelGoal';
import { RoutePlan } from '../models/RoutePlan';
import { JourneyState } from '../models/JourneyState';
import { ReplanResult, LocationData, WeatherData } from '../models/ReplanResult';
import { parseChineseTime } from '../utils/TimeUtil';
import { getCoords, haversine } from '../utils/GeoUtil';

// 真机联调时改为局域网 IP，例如 http://192.168.1.100:8000
const BASE_URL = 'http://127.0.0.1:8000';

// —— 接口契约（ArkTS 要求显式声明 interface） ——
export interface ParseGoalResult {
  goal: TravelGoal;
  missingFields: string[];
}

export interface PlanRouteResult {
  mainPlan: RoutePlan;
  backupPlans: RoutePlan[];
  riskTips: string[];
}

export interface UpdateStatusResult {
  currentState: JourneyState;
  nextAction: string;
  needReplan: boolean;
  reason: string;
  distanceToDestination?: number;
  offRoute?: boolean;
}

export interface ReplanContext {
  weather?: WeatherData;
  departLateMinutes?: number;
  location?: LocationData;
  now?: string;
}

// —— 请求体 ——
interface ParseGoalRequestBody {
  text: string;
}

interface PlanRouteRequestBody {
  goal: TravelGoal;
  location?: LocationData;
}

interface UpdateStatusRequestBody {
  goal: TravelGoal;
  plan: RoutePlan;
  location?: LocationData;
  now?: string;
}

interface ReplanRequestBody {
  goal: TravelGoal;
  currentPlan: RoutePlan;
  context: ReplanContext;
}

interface ApiEnvelope {
  success: boolean;
  data: Object;
  message: string;
}

// —— 内置 Mock 数据（根据起终点动态生成） ——
function mockTransit(origin: string, destination: string): RoutePlan {
  const near = `${destination}附近`;
  return {
    planId: 'plan_0', type: '主方案', eta: '18:22', cost: 6,
    durationMinutes: 52, walkDistanceMeters: 700, transferCount: 1,
    riskLevel: '低', onTimeProbability: 0.9,
    segments: [
      { mode: '地铁', from: `${origin}站`, to: near, startTime: '17:30', endTime: '18:10', durationMinutes: 40, distanceMeters: 12000, cost: 6 },
      { mode: '步行', from: near, to: destination, startTime: '18:10', endTime: '18:22', durationMinutes: 12, distanceMeters: 700, cost: 0 }
    ],
    reason: '地铁直达附近，费用低，步行约 700 米。'
  };
}

function mockRideHail(origin: string, destination: string): RoutePlan {
  return {
    planId: 'plan_1', type: '主方案', eta: '17:40', cost: 45,
    durationMinutes: 30, walkDistanceMeters: 30, transferCount: 0,
    riskLevel: '低', onTimeProbability: 0.95,
    segments: [
      { mode: '网约车', from: origin, to: destination, startTime: '17:10', endTime: '17:40', durationMinutes: 30, distanceMeters: 15000, cost: 45 }
    ],
    reason: '网约车直达，步行少，费用约 45 元。'
  };
}

function mockParse(text: string): ParseGoalResult {
  const goal: TravelGoal = emptyGoal();
  const from = text.match(/从(.+?)(?:去|到|出发)/);
  const to = text.match(/(?:去|到|前往)(.+?)(?=看|听|参加|，|。|$)/);
  const budget = text.match(/预算\s*(\d+)/);
  goal.origin = from ? from[1] : '';
  goal.destination = to ? to[1] : '';
  goal.deadline = parseChineseTime(text);
  goal.budget = budget ? Number(budget[1]) : 300;
  goal.luggage = /行李|行李箱|背包/.test(text);
  goal.preference = /省钱/.test(text) ? '省钱优先' : '准时优先';
  const missing: string[] = [];
  if (goal.origin.length === 0) {
    missing.push('origin');
  }
  if (goal.destination.length === 0) {
    missing.push('destination');
  }
  const result: ParseGoalResult = { goal: goal, missingFields: missing };
  return result;
}

function mockUpdateStatus(goal: TravelGoal, plan: RoutePlan, location?: LocationData): UpdateStatusResult {
  if (!location) {
    const result: UpdateStatusResult = {
      currentState: '乘车', nextAction: '乘车中，注意下一站下车出口', needReplan: false, reason: ''
    };
    return result;
  }
  const lastSeg = plan.segments[plan.segments.length - 1];
  const destCoords = getCoords(lastSeg.to);
  const destD = destCoords ? haversine(location.lat, location.lng, destCoords.lat, destCoords.lng) : -1;

  // 换乘点邻近
  for (let i = 0; i < plan.segments.length - 1; i++) {
    const tc = getCoords(plan.segments[i].to);
    if (tc && haversine(location.lat, location.lng, tc.lat, tc.lng) < 600) {
      const r: UpdateStatusResult = {
        currentState: '到站换乘',
        nextAction: `已到换乘点，下一步换乘${plan.segments[i + 1].mode}`,
        needReplan: false, reason: '',
        distanceToDestination: destD >= 0 ? Math.round(destD) : undefined
      };
      return r;
    }
  }

  // 偏离路线
  let nearest = Number.MAX_VALUE;
  for (let i = 0; i < plan.segments.length; i++) {
    const c = getCoords(plan.segments[i].from);
    if (c) {
      nearest = Math.min(nearest, haversine(location.lat, location.lng, c.lat, c.lng));
    }
  }
  if (destCoords) {
    nearest = Math.min(nearest, haversine(location.lat, location.lng, destCoords.lat, destCoords.lng));
  }
  if (nearest > 3000) {
    const r: UpdateStatusResult = {
      currentState: '前往目的地',
      nextAction: `当前偏离原路线约 ${Math.round(nearest)} 米，建议重新规划`,
      needReplan: true, reason: '当前定位偏离原路线', offRoute: true,
      distanceToDestination: destD >= 0 ? Math.round(destD) : undefined
    };
    return r;
  }

  // 目的地邻近
  if (destD >= 0 && destD < 500) {
    const r: UpdateStatusResult = {
      currentState: '已抵达', nextAction: '已抵达目的地，本次行程结束',
      needReplan: false, reason: '', distanceToDestination: Math.round(destD)
    };
    return r;
  }
  if (destD >= 0 && destD < 1500) {
    const r: UpdateStatusResult = {
      currentState: '入场或入住准备', nextAction: '已接近目的地，准备入场或入住',
      needReplan: false, reason: '', distanceToDestination: Math.round(destD)
    };
    return r;
  }

  const originCoords = getCoords(plan.segments[0].from);
  if (originCoords && haversine(location.lat, location.lng, originCoords.lat, originCoords.lng) < 800) {
    const r: UpdateStatusResult = {
      currentState: '出发准备', nextAction: '你还在出发地附近，建议尽快出发',
      needReplan: false, reason: '', distanceToDestination: destD >= 0 ? Math.round(destD) : undefined
    };
    return r;
  }

  const r: UpdateStatusResult = {
    currentState: '前往目的地',
    nextAction: destD >= 0 ? `正在前往目的地，还剩约 ${Math.round(destD)} 米` : '正在前往目的地',
    needReplan: false, reason: '',
    distanceToDestination: destD >= 0 ? Math.round(destD) : undefined
  };
  return r;
}

function mockReplan(goal: TravelGoal, plan: RoutePlan): ReplanResult {
  const newPlan: RoutePlan = mockRideHail(goal.origin, goal.destination);
  newPlan.type = '重规划方案';
  const result: ReplanResult = {
    trigger: '天气恶劣且步行距离过长',
    oldPlanStatus: '风险升高',
    newPlan: newPlan,
    extraCost: 39,
    action: '建议切换方案，并按新方案出发',
    explanation: `原计划预计 ${plan.eta} 到达，天气恶劣且步行距离过长。建议切换为网约车方案，预计 ${newPlan.eta} 到达，费用增加约 39 元。`,
    riskLevel: '低'
  };
  return result;
}

export class ApiService {
  /** POST /api/parse-goal */
  static async parseGoal(text: string): Promise<ParseGoalResult> {
    try {
      const body: ParseGoalRequestBody = { text: text };
      return await ApiService.post('/api/parse-goal', body) as ParseGoalResult;
    } catch (e) {
      return mockParse(text);
    }
  }

  /** POST /api/plan-route */
  static async planRoute(goal: TravelGoal, location?: LocationData): Promise<PlanRouteResult> {
    try {
      const body: PlanRouteRequestBody = { goal: goal, location: location };
      return await ApiService.post('/api/plan-route', body) as PlanRouteResult;
    } catch (e) {
      const main = goal.luggage ? mockRideHail(goal.origin, goal.destination) : mockTransit(goal.origin, goal.destination);
      const backup = goal.luggage ? mockTransit(goal.origin, goal.destination) : mockRideHail(goal.origin, goal.destination);
      backup.type = 'Plan B';
      backup.reason = '针对「晚点或赶不上」的备选方案。';
      const result: PlanRouteResult = { mainPlan: main, backupPlans: [backup], riskTips: [] };
      return result;
    }
  }

  /** POST /api/update-status */
  static async updateStatus(goal: TravelGoal, plan: RoutePlan, location?: LocationData, now?: string): Promise<UpdateStatusResult> {
    try {
      const body: UpdateStatusRequestBody = { goal: goal, plan: plan, location: location, now: now };
      return await ApiService.post('/api/update-status', body) as UpdateStatusResult;
    } catch (e) {
      return mockUpdateStatus(goal, plan, location);
    }
  }

  /** POST /api/replan */
  static async replan(goal: TravelGoal, plan: RoutePlan, context: ReplanContext): Promise<ReplanResult | null> {
    try {
      const body: ReplanRequestBody = { goal: goal, currentPlan: plan, context: context };
      const data = await ApiService.post('/api/replan', body);
      if (data === null) {
        return null;
      }
      return data as ReplanResult;
    } catch (e) {
      return mockReplan(goal, plan);
    }
  }

  private static async post(path: string, body: Object): Promise<Object> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(BASE_URL + path, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(body),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 4000,
        readTimeout: 4000
      });
      const envelope = JSON.parse(resp.result as string) as ApiEnvelope;
      if (!envelope.success) {
        throw new Error(envelope.message);
      }
      return envelope.data;
    } finally {
      httpRequest.destroy();
    }
  }
}
