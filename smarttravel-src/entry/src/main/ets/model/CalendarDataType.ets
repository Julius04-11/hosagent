/**
 * 日历数据类型定义
 */

// 日期项
export interface DayItem {
  day: number;        // 日期
  isCurrentMonth: boolean; // 是否是当前月
  isSelected: boolean;     // 是否被选中
  isInRange: boolean;      // 是否在选择范围内
  isToday: boolean;        // 是否是今天
  isDisabled: boolean;     // 是否禁用
}

// 月份数据
export interface MonthData {
  year: number;       // 年份
  month: number;      // 月份 (1-12)
  days: DayItem[];    // 日期列表
}

// 日期范围
export interface DateRange {
  startYear: number;
  startMonth: number;
  startDay: number;
  endYear: number;
  endMonth: number;
  endDay: number;
}

// 月份项（用于LazyForEach）
export class MonthItem {
  year: number;
  num: number;        // 月份编号 (1-12)
  
  constructor(year: number, num: number) {
    this.year = year;
    this.num = num;
  }
}

// 日历配置
export interface CalendarConfig {
  minDate?: Date;     // 最小可选日期
  maxDate?: Date;     // 最大可选日期
  selectRange: boolean; // 是否选择日期范围
  showToday: boolean;  // 是否高亮今天
  monthsToShow: number; // 显示的月份数量
}

// 默认日历配置
export const DEFAULT_CALENDAR_CONFIG: CalendarConfig = {
  selectRange: true,
  showToday: true,
  monthsToShow: 12
};
