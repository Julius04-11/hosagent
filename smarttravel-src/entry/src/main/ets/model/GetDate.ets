import { DateUtils } from '../utils/DateUtils';
import { MonthItem, DayItem, MonthData } from './CalendarDataType';

/**
 * 获取日期数据的工具类
 */
export class GetDate {
  /**
   * 生成未来N个月的月份列表
   * @param monthCount 月份数量
   * @returns MonthItem[]
   */
  static getMonthList(monthCount: number = 12): MonthItem[] {
    const monthList: MonthItem[] = [];
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth() + 1;

    for (let i = 0; i < monthCount; i++) {
      let year = currentYear;
      let month = currentMonth + i;
      
      // 处理月份进位
      while (month > 12) {
        month -= 12;
        year += 1;
      }
      
      monthList.push(new MonthItem(year, month));
    }
    
    return monthList;
  }

  /**
   * 获取指定月份的日期数据
   * @param year 年份
   * @param month 月份
   * @param selectedRange 已选择的日期范围
   * @returns MonthData
   */
  static getMonthData(
    year: number,
    month: number,
    selectedRange?: {
      startYear: number,
      startMonth: number,
      startDay: number,
      endYear: number,
      endMonth: number,
      endDay: number
    }
  ): MonthData {
    const daysInMonth = DateUtils.getDaysInMonth(year, month);
    const firstDayOfWeek = DateUtils.getFirstDayOfMonth(year, month);
    const days: DayItem[] = [];
    
    // 添加上个月的日期（填充空白）
    const prevMonth = month === 1 ? 12 : month - 1;
    const prevYear = month === 1 ? year - 1 : year;
    const daysInPrevMonth = DateUtils.getDaysInMonth(prevYear, prevMonth);
    
    for (let i = firstDayOfWeek - 1; i >= 0; i--) {
      const day = daysInPrevMonth - i;
      days.push({
        day: day,
        isCurrentMonth: false,
        isSelected: false,
        isInRange: false,
        isToday: false,
        isDisabled: true
      });
    }
    
    // 添加当前月的日期
    const today = new Date();
    const currentDate = DateUtils.getCurrentDate();
    
    for (let day = 1; day <= daysInMonth; day++) {
      const isToday = DateUtils.isToday(year, month, day);
      let isSelected = false;
      let isInRange = false;
      
      // 检查是否在选择范围内
      if (selectedRange) {
        const { startYear, startMonth, startDay, endYear, endMonth, endDay } = selectedRange;
        
        // 检查是否是起始或结束日期
        if ((year === startYear && month === startMonth && day === startDay) ||
            (year === endYear && month === endMonth && day === endDay)) {
          isSelected = true;
        }
        
        // 检查是否在范围内
        if (startYear && startMonth && startDay && endYear && endMonth && endDay) {
          isInRange = DateUtils.isDayInRange(
            startMonth, startDay,
            endMonth, endDay,
            month, day
          );
        }
      }
      
      // 判断是否禁用（过去的日期）
      const isDisabled = DateUtils.isDayEarlierThan(
        currentDate.month, currentDate.day,
        month, day
      );
      
      days.push({
        day: day,
        isCurrentMonth: true,
        isSelected: isSelected,
        isInRange: isInRange,
        isToday: isToday,
        isDisabled: isDisabled
      });
    }
    
    // 添加下个月的日期（填充剩余空白，凑满6行）
    const remainingDays = 42 - days.length; // 6行 x 7天 = 42天
    for (let day = 1; day <= remainingDays; day++) {
      days.push({
        day: day,
        isCurrentMonth: false,
        isSelected: false,
        isInRange: false,
        isToday: false,
        isDisabled: true
      });
    }
    
    return {
      year: year,
      month: month,
      days: days
    };
  }

  /**
   * 获取未来日期
   * @param daysFromNow 从今天开始的天数
   * @returns { year: number, month: number, day: number }
   */
  static getFutureDate(daysFromNow: number): { year: number, month: number, day: number } {
    const date = new Date();
    date.setDate(date.getDate() + daysFromNow);
    return {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate()
    };
  }
}
