/**
 * 日期选择页面
 * 用于酒店预订的入住/退房日期选择
 * 参考: example_code/DateSelection
 * v5.0: 简化版本，专注于日期范围选择
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

interface DateInfo {
  year: number;
  month: number;
  day: number;
  date: Date;
}

@Entry
@Component
export struct DateSelectionPage {
  @State checkInDate: DateInfo | null = null;
  @State checkOutDate: DateInfo | null = null;
  @State currentMonth: number = new Date().getMonth();
  @State currentYear: number = new Date().getFullYear();
  @State stayNights: number = 0;
  @State selectedMode: 'checkIn' | 'checkOut' | null = null;

  private weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  private monthNames: string[] = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

  aboutToAppear() {
    // 初始化选择模式为入住日期
    this.selectedMode = 'checkIn';
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()

      Scroll() {
        Column() {
          // 日期范围显示
          this.DateRangeDisplay()

          // 日历视图
          this.CalendarView()

          // 月份切换
          this.MonthNavigation()
        }
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)

      // 底部确认按钮
      this.ConfirmButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#1e40af')
        .onClick(() => {
          router.back();
        })

      Text('选择日期')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1e293b')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('清空')
        .fontSize(16)
        .fontColor('#1e40af')
        .onClick(() => {
          this.clearDates();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetY: 2
    })
  }

  @Builder DateRangeDisplay() {
    Row() {
      // 入住日期
      Column() {
        Text('入住')
          .fontSize(14)
          .fontColor('#64748b')
          .margin({ bottom: 8 })

        if (this.checkInDate) {
          Column() {
            Text(`${this.checkInDate.month + 1}月${this.checkInDate.day}日`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e40af')

            Text(this.getWeekday(this.checkInDate.date))
              .fontSize(12)
              .fontColor('#94a3b8')
              .margin({ top: 4 })
          }
        } else {
          Text('请选择')
            .fontSize(16)
            .fontColor('#cbd5e1')
        }
      }
      .layoutWeight(1)
      .padding(20)
      .backgroundColor(this.selectedMode === 'checkIn' ? '#e0f2fe' : Color.White)
      .borderRadius(12)
      .onClick(() => {
        this.selectedMode = 'checkIn';
      })

      // 停留晚数
      Column() {
        Text('🌙')
          .fontSize(20)
        Text(`${this.stayNights}晚`)
          .fontSize(12)
          .fontColor('#64748b')
          .margin({ top: 4 })
      }
      .width(60)
      .justifyContent(FlexAlign.Center)

      // 退房日期
      Column() {
        Text('退房')
          .fontSize(14)
          .fontColor('#64748b')
          .margin({ bottom: 8 })

        if (this.checkOutDate) {
          Column() {
            Text(`${this.checkOutDate.month + 1}月${this.checkOutDate.day}日`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e40af')

            Text(this.getWeekday(this.checkOutDate.date))
              .fontSize(12)
              .fontColor('#94a3b8')
              .margin({ top: 4 })
          }
        } else {
          Text('请选择')
            .fontSize(16)
            .fontColor('#cbd5e1')
        }
      }
      .layoutWeight(1)
      .padding(20)
      .backgroundColor(this.selectedMode === 'checkOut' ? '#e0f2fe' : Color.White)
      .borderRadius(12)
      .onClick(() => {
        if (this.checkInDate) {
          this.selectedMode = 'checkOut';
        } else {
          promptAction.showToast({
            message: '请先选择入住日期',
            duration: 2000
          });
        }
      })
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 12 })
  }

  @Builder CalendarView() {
    Column() {
      // 月份标题
      Text(`${this.currentYear}年 ${this.monthNames[this.currentMonth]}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1e293b')
        .margin({ bottom: 16 })

      // 星期标题
      Row() {
        ForEach(this.weekdays ?? [], (day: string, index: number) => {
          Text(day)
            .fontSize(14)
            .fontColor('#64748b')
            .width('14.28%')
            .textAlign(TextAlign.Center)
        }, (day: string, index: number) => `wd-${index}-${day}`)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 日期网格
      Grid() {
        ForEach(this.getMonthDays() ?? [], (dayInfo: DateInfo | null, index: number) => {
          GridItem() {
            if (dayInfo) {
              this.DayCell(dayInfo)
            } else {
              Text('')
                .width(40)
                .height(40)
            }
          }
        }, (dayInfo: DateInfo | null, index: number) => `d-${index}-${dayInfo ? dayInfo.day : 'empty'}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder DayCell(dayInfo: DateInfo) {
    Text(`${dayInfo.day}`)
      .fontSize(16)
      .fontColor(this.getDayTextColor(dayInfo))
      .fontWeight(this.isDaySelected(dayInfo) ? FontWeight.Bold : FontWeight.Normal)
      .width(40)
      .height(40)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.getDayBackground(dayInfo))
      .borderRadius(20)
      .onClick(() => {
        this.selectDate(dayInfo);
      })
  }

  @Builder MonthNavigation() {
    Row() {
      Button('上个月')
        .fontSize(14)
        .fontColor('#1e40af')
        .backgroundColor('#e0f2fe')
        .borderRadius(8)
        .height(36)
        .onClick(() => {
          this.previousMonth();
        })

      Text(`${this.currentYear}年${this.currentMonth + 1}月`)
        .fontSize(14)
        .fontColor('#64748b')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('下个月')
        .fontSize(14)
        .fontColor('#1e40af')
        .backgroundColor('#e0f2fe')
        .borderRadius(8)
        .height(36)
        .onClick(() => {
          this.nextMonth();
        })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 12 })
  }

  @Builder ConfirmButton() {
    Button('确认日期')
      .width('90%')
      .height(48)
      .margin({ top: 16, bottom: 16 })
      .backgroundColor(this.checkInDate && this.checkOutDate ? '#1e40af' : '#cbd5e1')
      .fontSize(16)
      .fontColor(Color.White)
      .enabled(this.checkInDate !== null && this.checkOutDate !== null)
      .onClick(() => {
        this.confirmDates();
      })
  }

  // 获取当月的所有日期
  private getMonthDays(): (DateInfo | null)[] {
    const firstDay = new Date(this.currentYear, this.currentMonth, 1);
    const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0);
    const startWeekday = firstDay.getDay();
    const daysInMonth = lastDay.getDate();

    const days: (DateInfo | null)[] = [];

    // 填充前面的空白
    for (let i = 0; i < startWeekday; i++) {
      days.push(null);
    }

    // 填充日期
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(this.currentYear, this.currentMonth, day);
      days.push({
        year: this.currentYear,
        month: this.currentMonth,
        day: day,
        date: date
      });
    }

    return days;
  }

  // 选择日期
  private selectDate(dayInfo: DateInfo) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (dayInfo.date < today) {
      promptAction.showToast({
        message: '不能选择过去的日期',
        duration: 2000
      });
      return;
    }

    if (this.selectedMode === 'checkIn') {
      this.checkInDate = dayInfo;
      // 如果退房日期早于入住日期，清空退房日期
      if (this.checkOutDate && this.checkOutDate.date <= dayInfo.date) {
        this.checkOutDate = null;
      }
      this.selectedMode = 'checkOut';
      this.calculateStayNights();
    } else if (this.selectedMode === 'checkOut') {
      if (this.checkInDate && dayInfo.date > this.checkInDate.date) {
        this.checkOutDate = dayInfo;
        this.calculateStayNights();
      } else {
        promptAction.showToast({
          message: '退房日期必须晚于入住日期',
          duration: 2000
        });
      }
    }
  }

  // 计算停留晚数
  private calculateStayNights() {
    if (this.checkInDate && this.checkOutDate) {
      const diffTime = this.checkOutDate.date.getTime() - this.checkInDate.date.getTime();
      this.stayNights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    } else {
      this.stayNights = 0;
    }
  }

  // 判断日期是否被选中
  private isDaySelected(dayInfo: DateInfo): boolean {
    if (this.checkInDate &&
      dayInfo.year === this.checkInDate.year &&
      dayInfo.month === this.checkInDate.month &&
      dayInfo.day === this.checkInDate.day) {
      return true;
    }

    if (this.checkOutDate &&
      dayInfo.year === this.checkOutDate.year &&
      dayInfo.month === this.checkOutDate.month &&
      dayInfo.day === this.checkOutDate.day) {
      return true;
    }

    return false;
  }

  // 判断日期是否在范围内
  private isDayInRange(dayInfo: DateInfo): boolean {
    if (!this.checkInDate || !this.checkOutDate) {
      return false;
    }

    return dayInfo.date > this.checkInDate.date && dayInfo.date < this.checkOutDate.date;
  }

  // 获取日期背景色
  private getDayBackground(dayInfo: DateInfo): string | Color {
    if (this.isDaySelected(dayInfo)) {
      return '#1e40af';
    }

    if (this.isDayInRange(dayInfo)) {
      return '#e0f2fe';
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (dayInfo.date < today) {
      return '#f1f5f9';
    }

    return Color.Transparent;
  }

  // 获取日期文字颜色
  private getDayTextColor(dayInfo: DateInfo): string {
    if (this.isDaySelected(dayInfo)) {
      return '#ffffff';
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (dayInfo.date < today) {
      return '#cbd5e1';
    }

    if (this.isDayInRange(dayInfo)) {
      return '#1e40af';
    }

    return '#1e293b';
  }

  // 获取星期几
  private getWeekday(date: Date): string {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.getDay()];
  }

  // 上个月
  private previousMonth() {
    if (this.currentMonth === 0) {
      this.currentMonth = 11;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
  }

  // 下个月
  private nextMonth() {
    if (this.currentMonth === 11) {
      this.currentMonth = 0;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
  }

  // 清空日期
  private clearDates() {
    this.checkInDate = null;
    this.checkOutDate = null;
    this.stayNights = 0;
    this.selectedMode = 'checkIn';
  }

  // 确认日期
  private confirmDates() {
    if (!this.checkInDate || !this.checkOutDate) {
      return;
    }

    // 返回选择的日期
    router.back();

    // TODO: 传递日期参数给上一页
    promptAction.showToast({
      message: `已选择 ${this.checkInDate.month + 1}/${this.checkInDate.day} - ${this.checkOutDate.month + 1}/${this.checkOutDate.day}，共${this.stayNights}晚`,
      duration: 2000
    });
  }
}
