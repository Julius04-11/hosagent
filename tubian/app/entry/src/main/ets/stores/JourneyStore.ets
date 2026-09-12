/**
 * 全局行程状态（单例，对齐《开发文档》§7.1）。
 * 页面在 aboutToAppear 中读取，拷贝到本地 @State 后展示。
 */
import { TravelGoal } from '../models/TravelGoal';
import { RoutePlan } from '../models/RoutePlan';
import { JourneyState } from '../models/JourneyState';
import { ReplanResult, LocationData } from '../models/ReplanResult';

export class JourneyStore {
  goal?: TravelGoal = undefined;
  mainPlan?: RoutePlan = undefined;
  backupPlans: RoutePlan[] = [];
  currentPlan?: RoutePlan = undefined;
  currentState: JourneyState = '出发准备';
  replanResult?: ReplanResult = undefined;
  currentCity: string = '杭州';          // 用户当前城市（可更改）
  location?: LocationData = undefined;   // 真实定位坐标
  locationEnabled: boolean = false;
  notificationEnabled: boolean = false;
  loading: boolean = false;
  errorMessage?: string = undefined;
}

const store: JourneyStore = new JourneyStore();

export function getJourneyStore(): JourneyStore {
  return store;
}
