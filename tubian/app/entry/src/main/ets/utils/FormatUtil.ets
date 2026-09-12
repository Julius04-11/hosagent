/**
 * 文本格式化工具。
 */

/** 156 -> "156元" */
export function formatCost(cost: number): string {
  return `${Math.round(cost)}元`;
}

/** 108 -> "1小时48分"；45 -> "45分钟" */
export function formatDuration(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}分钟`;
  }
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m === 0 ? `${h}小时` : `${h}小时${m}分`;
}

/** 850 -> "850米"；12600 -> "12.6公里" */
export function formatDistance(meters: number): string {
  if (meters >= 1000) {
    return `${(meters / 1000).toFixed(1)}公里`;
  }
  return `${meters}米`;
}

/** 0.95 -> "95%" */
export function formatProbability(p: number): string {
  return `${Math.round(p * 100)}%`;
}

/** "+42" / "-8" 带符号费用变化 */
export function formatCostDelta(delta: number): string {
  return delta >= 0 ? `+${Math.round(delta)}元` : `-${Math.round(-delta)}元`;
}
