import { router } from '@kit.ArkUI';

interface DateInfo {
  year: number;
  month: number;
  day: number;
  isToday: boolean;
  isSelected: boolean;
  isInRange: boolean;
  isDisabled: boolean;
}

@Component
export struct DateRangePicker {
  @State currentMonth: number = new Date().getMonth();
  @State currentYear: number = new Date().getFullYear();
  @State selectedDate: string = '';
  @State dateGrid: DateInfo[][] = [];
  
  private monthNames = ['1月', '2月', '3月', '4月', '5月', '6月', 
                       '7月', '8月', '9月', '10月', '11月', '12月'];
  private weekDays = ['日', '一', '二', '三', '四', '五', '六'];
  
  onDateSelected?: (date: string) => void;

  aboutToAppear() {
    this.generateCalendar();
  }

  private generateCalendar() {
    const firstDay = new Date(this.currentYear, this.currentMonth, 1);
    const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());
    
    const today = new Date();
    const grid: DateInfo[][] = [];
    
    for (let week = 0; week < 6; week++) {
      const weekRow: DateInfo[] = [];
      for (let day = 0; day < 7; day++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(startDate.getDate() + week * 7 + day);
        
        const dateInfo: DateInfo = {
          year: currentDate.getFullYear(),
          month: currentDate.getMonth(),
          day: currentDate.getDate(),
          isToday: this.isSameDay(currentDate, today),
          isSelected: false,
          isInRange: false,
          isDisabled: currentDate < today || currentDate.getMonth() !== this.currentMonth
        };
        
        weekRow.push(dateInfo);
      }
      grid.push(weekRow);
    }
    
    this.dateGrid = grid;
  }

  private isSameDay(date1: Date, date2: Date): boolean {
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate();
  }

  private onDateClick(dateInfo: DateInfo) {
    if (dateInfo.isDisabled) return;
    
    const selectedDate = `${dateInfo.year}-${(dateInfo.month + 1).toString().padStart(2, '0')}-${dateInfo.day.toString().padStart(2, '0')}`;
    this.selectedDate = selectedDate;
    
    // 更新选中状态
    this.dateGrid.forEach(week => {
      week.forEach(day => {
        day.isSelected = day.year === dateInfo.year && 
                        day.month === dateInfo.month && 
                        day.day === dateInfo.day;
      });
    });
    
    if (this.onDateSelected) {
      this.onDateSelected(selectedDate);
    }
  }

  private changeMonth(delta: number) {
    this.currentMonth += delta;
    if (this.currentMonth < 0) {
      this.currentMonth = 11;
      this.currentYear--;
    } else if (this.currentMonth > 11) {
      this.currentMonth = 0;
      this.currentYear++;
    }
    this.generateCalendar();
  }

  build() {
    Column() {
      // 月份导航
      Row() {
        Button('<')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#f0f0f0')
          .fontColor('#666')
          .onClick(() => this.changeMonth(-1))

        Text(`${this.currentYear}年${this.monthNames[this.currentMonth]}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('>')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#f0f0f0')
          .fontColor('#666')
          .onClick(() => this.changeMonth(1))
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 星期标题
      Row() {
        ForEach(this.weekDays, (weekDay: string) => {
          Text(weekDay)
            .fontSize(14)
            .fontColor('#999')
            .width('14.28%')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 日期网格
      Column() {
        ForEach(this.dateGrid, (week: DateInfo[], weekIndex: number) => {
          Row() {
            ForEach(week, (dateInfo: DateInfo, dayIndex: number) => {
              Stack() {
                // 日期文字
                Text(dateInfo.day.toString())
                  .fontSize(16)
                  .fontColor(this.getDateTextColor(dateInfo))
                  .fontWeight(dateInfo.isSelected ? FontWeight.Bold : FontWeight.Normal)

                // 背景色
                if (dateInfo.isSelected || dateInfo.isToday) {
                  Text()
                    .width(36)
                    .height(36)
                    .borderRadius(18)
                    .backgroundColor(this.getDateBackgroundColor(dateInfo))
                }
              }
              .width('14.28%')
              .height(40)
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.onDateClick(dateInfo))
            })
          }
          .width('100%')
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  private getDateTextColor(dateInfo: DateInfo): string {
    if (dateInfo.isDisabled) return '#ccc';
    if (dateInfo.isSelected) return '#fff';
    if (dateInfo.isToday) return '#007AFF';
    if (dateInfo.month !== this.currentMonth) return '#ccc';
    return '#1a1a1a';
  }

  private getDateBackgroundColor(dateInfo: DateInfo): string {
    if (dateInfo.isSelected) return '#007AFF';
    if (dateInfo.isToday) return '#e6f3ff';
    return 'transparent';
  }
}
