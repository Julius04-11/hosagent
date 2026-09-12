/*
 *
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 */

export class DateUtils {
  static isDayBetween(currentMonth: number, currentDay: number, startMonth: number, startDay: number, endMonth: number,
    endDay: number): boolean {
    return DateUtils.isDayLaterThan(currentMonth, currentDay, startMonth, startDay) &&
    DateUtils.isDayLaterThan(endMonth, endDay, currentMonth, currentDay);
  }

  static isDayLaterThan(currentMonth: number, currentDay: number, targetMonth: number, targetDay: number) {
    return currentMonth === targetMonth ? currentDay > targetDay : currentMonth > targetMonth;
  }

  // 计算住几晚
  static calculateDays(startMonth: number, startDay: number, endMonth: number, endDay: number): number {
    let year = new Date().getFullYear();
    let startDate = new Date(year, startMonth - 1, startDay);
    let endDate = new Date(year, endMonth - 1, endDay);
    // 如果结束日期早于开始日期，说明跨年了
    if (endDate < startDate) {
      // 增加一年
      let nextYear = year + 1;
      let newEndDate = new Date(nextYear, endMonth - 1, endDay);
      let diffTime = newEndDate.getTime() - startDate.getTime();
      return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    } else {
      let diffTime = endDate.getTime() - startDate.getTime();
      return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }
  }

  static formatMonth(month: number): string {
    return month.toString().padStart(2, '0');
  }
}

