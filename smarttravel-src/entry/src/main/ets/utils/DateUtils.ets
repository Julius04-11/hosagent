/**
 * 日期信息接口
 */
export interface DateInfo {
  year: number;
  month: number;
  day: number;
}

/**
 * 日期处理工具类
 * 提供日期比较、格式化、日期范围计算等功能
 */
export class DateUtils {
  /**
   * 判断某一天是否晚于基准日期
   * @param baseMonth 基准月份
   * @param baseDay 基准日期
   * @param targetMonth 目标月份
   * @param targetDay 目标日期
   * @returns boolean 是否晚于基准日期
   */
  static isDayLaterThan(baseMonth: number, baseDay: number, targetMonth: number, targetDay: number): boolean {
    if (targetMonth > baseMonth) {
      return true;
    }
    if (targetMonth === baseMonth && targetDay > baseDay) {
      return true;
    }
    return false;
  }

  /**
   * 判断某一天是否早于基准日期
   * @param baseMonth 基准月份
   * @param baseDay 基准日期
   * @param targetMonth 目标月份
   * @param targetDay 目标日期
   * @returns boolean 是否早于基准日期
   */
  static isDayEarlierThan(baseMonth: number, baseDay: number, targetMonth: number, targetDay: number): boolean {
    if (targetMonth < baseMonth) {
      return true;
    }
    if (targetMonth === baseMonth && targetDay < baseDay) {
      return true;
    }
    return false;
  }

  /**
   * 判断某一天是否在日期范围内
   * @param startMonth 起始月份
   * @param startDay 起始日期
   * @param endMonth 结束月份
   * @param endDay 结束日期
   * @param targetMonth 目标月份
   * @param targetDay 目标日期
   * @returns boolean 是否在范围内
   */
  static isDayInRange(
    startMonth: number,
    startDay: number,
    endMonth: number,
    endDay: number,
    targetMonth: number,
    targetDay: number
  ): boolean {
    const afterStart = DateUtils.isDayLaterThan(startMonth, startDay, targetMonth, targetDay) ||
      (startMonth === targetMonth && startDay === targetDay);
    const beforeEnd = DateUtils.isDayEarlierThan(endMonth, endDay, targetMonth, targetDay) ||
      (endMonth === targetMonth && endDay === targetDay);
    return afterStart && beforeEnd;
  }

  /**
   * 获取当前日期
   * @returns { year: number, month: number, day: number }
   */
  static getCurrentDate(): DateInfo {
    const now = new Date();
    return {
      year: now.getFullYear(),
      month: now.getMonth() + 1,
      day: now.getDate()
    };
  }

  /**
   * 获取某月的天数
   * @param year 年份
   * @param month 月份 (1-12)
   * @returns number 天数
   */
  static getDaysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate();
  }

  /**
   * 获取某月第一天是星期几
   * @param year 年份
   * @param month 月份 (1-12)
   * @returns number 星期几 (0-6, 0表示星期日)
   */
  static getFirstDayOfMonth(year: number, month: number): number {
    return new Date(year, month - 1, 1).getDay();
  }

  /**
   * 格式化日期为 YYYY/MM/DD
   * @param year 年份
   * @param month 月份
   * @param day 日期
   * @returns string 格式化的日期字符串
   */
  static formatDate(year: number, month: number, day: number): string {
    const monthStr = month < 10 ? `0${month}` : `${month}`;
    const dayStr = day < 10 ? `0${day}` : `${day}`;
    return `${year}/${monthStr}/${dayStr}`;
  }

  /**
   * 格式化日期为 MM月DD日
   * @param month 月份
   * @param day 日期
   * @returns string 格式化的日期字符串
   */
  static formatMonthDay(month: number, day: number): string {
    return `${month}月${day}日`;
  }

  /**
   * 计算两个日期之间的天数差
   * @param startMonth 起始月份
   * @param startDay 起始日期
   * @param endMonth 结束月份
   * @param endDay 结束日期
   * @param year 年份（默认当前年）
   * @returns number 天数差
   */
  static getDaysDifference(
    startMonth: number,
    startDay: number,
    endMonth: number,
    endDay: number,
    year?: number
  ): number {
    const currentYear = year || new Date().getFullYear();
    const startDate = new Date(currentYear, startMonth - 1, startDay);
    const endDate = new Date(currentYear, endMonth - 1, endDay);
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  /**
   * 获取日期字符串
   * @param date Date对象
   * @returns string YYYY-MM-DD格式
   */
  static getDateString(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 添加天数到日期
   * @param date 基准日期
   * @param days 要添加的天数
   * @returns Date 新日期
   */
  static addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  /**
   * 解析日期字符串
   * @param dateString YYYY/MM/DD 或 YYYY-MM-DD 格式
   * @returns { year: number, month: number, day: number } | null
   */
  static parseDateString(dateString: string): DateInfo | null {
    const parts = dateString.split(/[\/\-]/);
    if (parts.length !== 3) {
      return null;
    }
    const year = parseInt(parts[0]);
    const month = parseInt(parts[1]);
    const day = parseInt(parts[2]);
    
    if (isNaN(year) || isNaN(month) || isNaN(day)) {
      return null;
    }
    
    return { year, month, day };
  }

  /**
   * 判断是否是今天
   * @param year 年份
   * @param month 月份
   * @param day 日期
   * @returns boolean
   */
  static isToday(year: number, month: number, day: number): boolean {
    const today = new Date();
    return year === today.getFullYear() &&
           month === today.getMonth() + 1 &&
           day === today.getDate();
  }

  /**
   * 判断日期是否有效
   * @param year 年份
   * @param month 月份
   * @param day 日期
   * @returns boolean
   */
  static isValidDate(year: number, month: number, day: number): boolean {
    if (month < 1 || month > 12) {
      return false;
    }
    const daysInMonth = DateUtils.getDaysInMonth(year, month);
    return day >= 1 && day <= daysInMonth;
  }

  /**
   * 获取星期几的中文名称
   * @param dayOfWeek 0-6 (0是星期日)
   * @returns string
   */
  static getWeekdayName(dayOfWeek: number): string {
    const names = ['日', '一', '二', '三', '四', '五', '六'];
    return names[dayOfWeek] || '';
  }

  /**
   * 获取月份名称
   * @param month 月份 (1-12)
   * @returns string
   */
  static getMonthName(month: number): string {
    const months = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return months[month - 1] || '';
  }
}
