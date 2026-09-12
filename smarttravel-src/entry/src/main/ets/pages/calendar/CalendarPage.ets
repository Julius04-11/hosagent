import { router } from '@kit.ArkUI';
import { DateUtils } from '../../utils/DateUtils';
import { GetDate } from '../../model/GetDate';
import { MonthDataSource } from '../../model/MonthDataSource';
import { MonthItem, DayItem, MonthData, CalendarConfig, DEFAULT_CALENDAR_CONFIG } from '../../model/CalendarDataType';

/**
 * 日历选择页面
 * 支持单日期和日期范围选择
 */
@Entry
@Component
export struct CalendarPage {
  // 日期选择状态
  @State startYear: number = 0;
  @State startMonth: number = 0;
  @State startDay: number = 0;
  @State endYear: number = 0;
  @State endMonth: number = 0;
  @State endDay: number = 0;
  
  // 选择模式：'start' - 选择开始日期, 'end' - 选择结束日期
  @State selectionMode: 'start' | 'end' = 'start';
  
  // 日历配置
  private config: CalendarConfig = DEFAULT_CALENDAR_CONFIG;
  
  // 月份数据源
  private monthDataSource: MonthDataSource = new MonthDataSource([]);
  
  // 页面参数
  @State pageTitle: string = '选择日期';
  @State selectRange: boolean = true;
  private onDateSelected?: (startDate: string, endDate?: string) => void;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as {
      title?: string,
      selectRange?: boolean,
      onDateSelected?: (startDate: string, endDate?: string) => void
    };
    
    if (params) {
      this.pageTitle = params.title || '选择日期';
      this.selectRange = params.selectRange !== undefined ? params.selectRange : true;
      this.onDateSelected = params.onDateSelected;
    }
    
    // 初始化月份列表
    const monthList = GetDate.getMonthList(12);
    this.monthDataSource = new MonthDataSource(monthList);
    
    // 初始化默认日期（明天和后天）
    const tomorrow = GetDate.getFutureDate(1);
    const dayAfterTomorrow = GetDate.getFutureDate(2);
    
    this.startYear = tomorrow.year;
    this.startMonth = tomorrow.month;
    this.startDay = tomorrow.day;
    
    if (this.selectRange) {
      this.endYear = dayAfterTomorrow.year;
      this.endMonth = dayAfterTomorrow.month;
      this.endDay = dayAfterTomorrow.day;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()
      
      // 日期显示区
      this.DateDisplay()
      
      // 星期标题
      this.WeekHeader()
      
      // 月份列表
      List() {
        LazyForEach(this.monthDataSource, (monthItem: MonthItem) => {
          ListItem() {
            this.MonthView(monthItem)
          }
        }, (monthItem: MonthItem) => `${monthItem.year}-${monthItem.num}`)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      
      // 底部确认按钮
      this.BottomButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder TopBar() {
    Row() {
      Text('< 返回')
        .fontSize(16)
        .fontColor('#007AFF')
        .onClick(() => {
          router.back();
        })
      
      Text(this.pageTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text('清空')
        .fontSize(16)
        .fontColor('#007AFF')
        .onClick(() => {
          this.clearSelection();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetY: 2
    })
  }

  @Builder DateDisplay() {
    Row() {
      // 入住日期
      Column() {
        Text(this.selectRange ? '入住' : '日期')
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 8 })
        
        if (this.startYear > 0) {
          Text(DateUtils.formatMonthDay(this.startMonth, this.startDay))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.selectionMode === 'start' ? '#007AFF' : '#333')
        } else {
          Text('请选择')
            .fontSize(16)
            .fontColor('#999')
        }
        
        if (this.startYear > 0) {
          Text(`${this.startYear}年`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor(this.selectionMode === 'start' ? '#f0f9ff' : Color.White)
      .borderRadius(12)
      .onClick(() => {
        this.selectionMode = 'start';
      })
      
      if (this.selectRange) {
        // 间隔
        Column() {
          Text('→')
            .fontSize(20)
            .fontColor('#ccc')
        }
        .width(40)
        .justifyContent(FlexAlign.Center)
        
        // 离店日期
        Column() {
          Text('离店')
            .fontSize(14)
            .fontColor('#666')
            .margin({ bottom: 8 })
          
          if (this.endYear > 0) {
            Text(DateUtils.formatMonthDay(this.endMonth, this.endDay))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selectionMode === 'end' ? '#007AFF' : '#333')
          } else {
            Text('请选择')
              .fontSize(16)
              .fontColor('#999')
          }
          
          if (this.endYear > 0) {
            Text(`${this.endYear}年`)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor(this.selectionMode === 'end' ? '#f0f9ff' : Color.White)
        .borderRadius(12)
        .onClick(() => {
          if (this.startYear > 0) {
            this.selectionMode = 'end';
          }
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
  }

  @Builder WeekHeader() {
    Row() {
      ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string, index: number) => {
        Text(day)
          .fontSize(14)
          .fontColor('#666')
          .width(`${100 / 7}%`)
          .textAlign(TextAlign.Center)
      }, (day: string, index: number) => `wd-${index}-${day}`)
    }
    .width('100%')
    .height(40)
    .backgroundColor(Color.White)
  }

  @Builder MonthView(monthItem: MonthItem) {
    Column() {
      // 月份标题
      Text(`${monthItem.year}年${monthItem.num}月`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 12 })
      
      // 日期网格
      this.DayGrid(monthItem)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder DayGrid(monthItem: MonthItem) {
    const monthData = GetDate.getMonthData(
      monthItem.year,
      monthItem.num,
      this.startYear > 0 ? {
        startYear: this.startYear,
        startMonth: this.startMonth,
        startDay: this.startDay,
        endYear: this.endYear,
        endMonth: this.endMonth,
        endDay: this.endDay
      } : undefined
    );
    
    Grid() {
      ForEach(monthData.days, (dayItem: DayItem, index: number) => {
        GridItem() {
          this.DayCell(dayItem, monthItem.year, monthItem.num)
        }
      }, (dayItem: DayItem, index: number) => `d-${monthItem.year}-${monthItem.num}-${index}-${dayItem.day}`)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(8)
    .columnsGap(0)
    .width('100%')
    .height(this.calculateGridHeight(monthData.days.length))
    .padding({ left: 8, right: 8, bottom: 16 })
  }

  @Builder DayCell(dayItem: DayItem, year: number, month: number) {
    Stack() {
      // 背景（范围内的日期）
      if (dayItem.isInRange && !dayItem.isDisabled) {
        Text()
          .width('100%')
          .height('100%')
          .backgroundColor('#e6f3ff')
      }
      
      // 日期文字
      Text(dayItem.day.toString())
        .fontSize(16)
        .fontColor(
          dayItem.isDisabled ? '#ccc' :
          dayItem.isSelected ? Color.White :
          dayItem.isToday ? '#007AFF' :
          dayItem.isCurrentMonth ? '#333' : '#ccc'
        )
        .fontWeight(dayItem.isToday || dayItem.isSelected ? FontWeight.Bold : FontWeight.Normal)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor(dayItem.isSelected ? '#007AFF' : Color.Transparent)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (!dayItem.isDisabled && dayItem.isCurrentMonth) {
        this.onDayClick(year, month, dayItem.day);
      }
    })
  }

  @Builder BottomButton() {
    Row() {
      if (this.selectRange && this.startYear > 0 && this.endYear > 0) {
        const nights = DateUtils.getDaysDifference(
          this.startMonth, this.startDay,
          this.endMonth, this.endDay,
          this.startYear
        );
        Text(`共${nights}晚`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ right: 16 })
      }
      
      Button('确定')
        .width(120)
        .height(44)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(22)
        .enabled(this.isSelectionValid())
        .onClick(() => {
          this.confirmSelection();
        })
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.End)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetY: -2
    })
  }

  // 点击日期
  private onDayClick(year: number, month: number, day: number) {
    if (this.selectionMode === 'start' || !this.selectRange) {
      // 选择开始日期
      this.startYear = year;
      this.startMonth = month;
      this.startDay = day;
      
      // 如果是范围选择，自动切换到选择结束日期
      if (this.selectRange) {
        // 清空结束日期
        this.endYear = 0;
        this.endMonth = 0;
        this.endDay = 0;
        this.selectionMode = 'end';
      }
    } else {
      // 选择结束日期
      // 确保结束日期不早于开始日期
      if (DateUtils.isDayLaterThan(this.startMonth, this.startDay, month, day) ||
          (month === this.startMonth && day === this.startDay)) {
        this.endYear = year;
        this.endMonth = month;
        this.endDay = day;
      } else {
        // 如果选择的日期早于开始日期，则交换
        this.endYear = this.startYear;
        this.endMonth = this.startMonth;
        this.endDay = this.startDay;
        this.startYear = year;
        this.startMonth = month;
        this.startDay = day;
      }
    }
  }

  // 清空选择
  private clearSelection() {
    this.startYear = 0;
    this.startMonth = 0;
    this.startDay = 0;
    this.endYear = 0;
    this.endMonth = 0;
    this.endDay = 0;
    this.selectionMode = 'start';
  }

  // 确认选择
  private confirmSelection() {
    const startDate = DateUtils.formatDate(this.startYear, this.startMonth, this.startDay);
    const endDate = this.selectRange && this.endYear > 0 ?
      DateUtils.formatDate(this.endYear, this.endMonth, this.endDay) : undefined;
    
    // 如果有回调函数，调用它
    if (this.onDateSelected) {
      this.onDateSelected(startDate, endDate);
    }
    
    // 返回上一页，携带选择结果
    router.back({
      url: '',
      params: {
        startDate: startDate,
        endDate: endDate,
        nights: this.selectRange ? DateUtils.getDaysDifference(
          this.startMonth, this.startDay,
          this.endMonth, this.endDay,
          this.startYear
        ) : undefined
      }
    });
  }

  // 判断选择是否有效
  private isSelectionValid(): boolean {
    if (!this.selectRange) {
      return this.startYear > 0;
    }
    return this.startYear > 0 && this.endYear > 0;
  }

  // 计算网格高度
  private calculateGridHeight(dayCount: number): number {
    const rows = Math.ceil(dayCount / 7);
    return rows * 48 + (rows - 1) * 8; // 每行48px + 行间距8px
  }
}
