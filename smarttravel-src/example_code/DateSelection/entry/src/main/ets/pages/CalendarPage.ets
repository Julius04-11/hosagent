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

import { DateUtils } from '../util/DateUtils';
import { getMonthDate } from '../model/GetDate';
import { Month, MonthDataSource } from '../model/MonthDataSource';
import { util } from '@kit.ArkTS';

@Builder
export function calendarPageBuilder() {
  CalendarPage();
}

//日历行数
const ROW_NUMBER = 35;

@Preview
@Component
export struct CalendarPage {
  @Consume('NavPathStack') pathStack: NavPathStack;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State contentData: MonthDataSource = new MonthDataSource(); // 列表数据
  @State nextMonth: number = 1; // 初始化下一个月月份
  @State nextYear: number = 1; // 初始化下一个月年份
  @State nextMonthDay: number[] = []; // 初始化下一个月的日期排列数组
  @State currentMonthDay: number[] = []; // 初始化当前月的日期排列数组
  @State currentMonth: number = 1; // 当前月份
  @State currentDay: number = 1; // 当前日
  @State currentYear: number = 1; // 当前年份
  @State currentWeekDay: number = 0; // 当前周几
  @State date: number[] = []; // 当前日期显示的数组
  @State todayDate: number[] = []; // 今日日期显示的数组
  @State startWeekDay: number = 0;
  @State endWeekDay: number = 0;
  @State startMonth: number = -1;
  @State startDay: number = -1;
  @State endMonth: number = -1;
  @State endDay: number = -1;
  @State stayNights: number = 0; // 入住几晚
  private week: string[] = [
    '日',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六'
  ]; // 设置日历周，从周日开始

  // 获取当前月和下个月的日期数据
  aboutToAppear() {
    this.initData();
    // 获取当前月和下个月的日期数据
    let months: Month[] = [
      {
        month: `${this.currentYear}年 ${this.currentMonth}月`,
        num: this.currentMonth,
        days: this.currentMonthDay
      },
      {
        month: `${this.currentYear}年 ${this.nextMonth}月`,
        num: this.nextMonth,
        days: this.nextMonthDay
      }
    ];
    this.contentData.pushData(months);
  }

  // 日期初始化
  initData() {
    // 获取当前日期
    let nowDate = new Date(); // 创建Date对象,设置当前日期和时间
    this.currentMonth = nowDate.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    this.currentDay = nowDate.getDate(); // 获取当前日
    this.currentYear = nowDate.getFullYear(); // 获取当前年份
    this.currentWeekDay = new Date(this.currentYear, this.currentMonth - 1, this.currentDay).getDay(); // 获取当前星期几
    this.date.push(this.currentMonth); // 存入月份信息
    this.date.push(this.currentDay); // 存入日期信息
    this.date.push(this.currentWeekDay); // 存入周信息
    this.todayDate.push(this.currentMonth);
    this.todayDate.push(this.currentDay);
    this.todayDate.push(this.currentWeekDay);
    this.currentMonthDay = getMonthDate(this.currentMonth, this.currentYear);
    // 如果下个月是在下一年，则下个月是1月份，年份要+1
    if (this.currentMonth === 12) {
      this.nextMonth = 1;
      this.nextYear = this.currentYear + 1;
    } else {
      // 如果下个月是还是当前年，则月份+1，年份不变
      this.nextMonth = this.currentMonth + 1;
      this.nextYear = this.currentYear;
    }
    this.nextMonthDay = getMonthDate(this.nextMonth, this.nextYear);
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        this.weekBuilder();
        this.dataBuilder();
        this.buttonBuilder();
      }
      .padding({ top: 12, bottom: 12 })
      .width('100%')
      .height('85%')
      .borderRadius(16)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Center);
    }
    .title($r('app.string.title'))
    .hideToolBar(true)
    .backgroundColor('#FFFFFF')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    });
  }

  // 显示日历布局的每个月上方的年月信息
  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(400)
      .width('100%')
      .height(20)
      .margin({ left: 20 });
  }

  @Builder
  weekBuilder() {
    List() {
      // 一周七天固定
      ForEach(this.week, (weekInfomation: string) => {
        ListItem() {
          Text(weekInfomation)
            .textAlign(TextAlign.Center)
            .width('100%')
            .height('100%')
            .fontColor($r('app.color.week_font_color'));
        }
        .width('14.3%');
      });
    }
    .backgroundColor($r('app.color.background'))
    .width('100%')
    .height(30)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off);
  }

  // 日历日期
  @Builder
  dataBuilder() {
    List() {
      LazyForEach(this.contentData, (monthItem: Month) => {
        // 设置ListItemGroup头部组件，显示年份和月份
        ListItemGroup({ header: this.itemHead(monthItem.month) }) {
          ListItem() {
            Stack() {
              Grid() {
                ForEach(monthItem.days, (day: number) => {
                  GridItem() {
                    Stack() {
                      Text(day.toString())
                        .zIndex(999)//设置组件堆叠顺序
                        .fontSize(16)
                        .fontWeight(400)
                        .fontColor(day === this.startDay && monthItem.num === this.startMonth ||
                          day === this.endDay && monthItem.num === this.endMonth ? Color.White :
                          $r('app.color.date_font_color'))
                        .width('100%')
                        .height('100%')
                        .textAlign(TextAlign.Center)
                        .borderRadius(10)
                        .onClick(() => {
                          if (this.startMonth === -1) {
                            this.startMonth = monthItem.num;
                            this.startDay = day;
                          } else if (this.endMonth === -1) {
                            if (DateUtils.isDayLaterThan(this.startMonth, this.startDay, monthItem.num, day)) {
                              this.startMonth = monthItem.num;
                              this.startDay = day;
                            } else {
                              this.endMonth = monthItem.num;
                              this.endDay = day;
                            }
                          } else {
                            this.startMonth = monthItem.num;
                            this.startDay = day;
                            this.endMonth = -1;
                            this.endDay = -1;
                          }
                          this.startWeekDay = new Date(this.currentYear, monthItem.num - 1, this.startDay).getDay();
                          this.endWeekDay = new Date(this.currentYear, monthItem.num - 1, this.endDay).getDay();
                          if (this.endMonth !== -1 && this.endDay !== -1) {
                            this.stayNights =
                              DateUtils.calculateDays(this.startMonth, this.startDay, this.endMonth,
                                this.endDay);
                          } else {
                            this.stayNights = 0;
                          }
                        });
                      // 日期范围两端日期
                      if (day === this.startDay && monthItem.num === this.startMonth) {
                        Column() {
                          Text();
                          Text($r('app.string.check_in'))
                            .fontSize(12)
                            .fontWeight(400)
                            .fontColor(Color.White)
                            .margin({ top: 40 });
                        }
                        .borderRadius(5)
                        .backgroundColor($r('app.color.selected_background_color'))
                        .width('90%')
                        .height('95%');
                      } else if (day === this.endDay && monthItem.num === this.endMonth) {
                        Column() {
                          Text();
                          Text($r('app.string.check_out'))
                            .fontSize(12)
                            .fontWeight(400)
                            .fontColor(Color.White)
                            .margin({ top: 40 });
                        }
                        .borderRadius(5)
                        .backgroundColor($r('app.color.selected_background_color'))
                        .width('90%')
                        .height('95%');
                      }
                      // 日期范围中间日期
                      else if (this.endMonth !== -1 &&
                      DateUtils.isDayBetween(monthItem.num, day, this.startMonth, this.startDay, this.endMonth,
                        this.endDay)) {
                        Text()
                          .backgroundColor($r('app.color.middle_background_color'))
                          .width('100%')
                          .height('95%');
                      }
                    };
                  }
                  .opacity(day === 0 ? 0 : 1); // 将日期数组中为0的都设置为不显示，即不显示上个月和下个月的内容
                });
              }
              .backgroundColor(Color.White)
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
              // 当前月显示的数组元素个数大于35则显示6行，否则显示5行
              .rowsTemplate(monthItem.days.length > ROW_NUMBER ?
                '1fr 1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr 1fr')
              .height(monthItem.days.length > ROW_NUMBER ? 360 : 300);
            };
          };
        };
      });
    }
    .height('90%')
    .width('100%')
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off);
  }

  @Builder
  buttonBuilder() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.check_in'))
            .fontWeight(400)
            .fontSize(14)
            .fontColor($r('app.color.week_font_color'));
          Text(this.startDay === -1 ? '' :
            util.format('%s月%s日(周%s)', DateUtils.formatMonth(this.startMonth), this.startDay.toString(),
              this.week[this.startWeekDay]))
            .fontWeight(500)
            .fontSize(16)
            .textAlign(TextAlign.Start);
        }
        .alignItems(HorizontalAlign.Start)
        .width('34%')
        .height(40);

        Text('-')
          .fontSize(16)
          .fontWeight(500)
          .fontColor('#191919')
          .textAlign(TextAlign.Center)
          .width('8%');

        Column({ space: 4 }) {
          Text($r('app.string.check_out'))
            .fontWeight(400)
            .fontSize(14)
            .fontColor($r('app.color.week_font_color'));

          Text(this.endDay === -1 ? '' :
            util.format('%s月%s日(周%s)', DateUtils.formatMonth(this.endMonth), this.endDay.toString(),
              this.week[this.endWeekDay]))
            .fontWeight(500)
            .fontSize(16)
            .textAlign(TextAlign.Start);
        }
        .alignItems(HorizontalAlign.Start)
        .width('34%')
        .height(40);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Button(`确认${this.stayNights}晚`)
        .backgroundColor($r('app.color.selected_background_color'))
        .onClick(() => {
          this.pathStack.pop([this.startMonth !== -1 ?
            util.format('%s月%s日(周%s)', this.startMonth.toString(), this.startDay.toString(),
              this.week[this.startWeekDay]) : '',
            this.endMonth !== -1 ?
              util.format('%s月%s日(周%s)', this.endMonth.toString(), this.endDay.toString(),
                this.week[this.endWeekDay]) :
              '']);
        })
        .margin({ top: 14 })
        .width('100%');
    }
    .width('100%')
    .height(126)
    .padding(16)
    .border({
      width: { top: 1 },
      color: { top: 'rgb(239, 239, 239)' },
      style: {
        top: BorderStyle.Solid
      }
    });
  }
}