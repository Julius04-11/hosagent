/**
 * 风险等级 -> 颜色/文案映射（对齐《开发文档》§5.2 色彩规范）。
 */
import { RiskLevel } from '../models/RoutePlan';

export function riskColor(level: RiskLevel): string {
  switch (level) {
    case '低':
      return '#16A34A'; // 绿
    case '中':
      return '#F97316'; // 橙
    case '高':
      return '#DC2626'; // 红
    default:
      return '#6B7280';
  }
}

export function riskText(level: RiskLevel): string {
  switch (level) {
    case '低':
      return '风险低';
    case '中':
      return '有一定风险';
    case '高':
      return '风险较高';
    default:
      return level;
  }
}
