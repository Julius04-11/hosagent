import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface DayPlan {
  day: number;
  date: string;
  activities: ActivityItem[];
}

interface ActivityItem {
  time: string;
  title: string;
  location: string;
  description: string;
  icon: string;
}

@Entry
@Component
export struct ItineraryDetailPage {
  @State itineraryId: string = '';
  @State itineraryTitle: string = '深圳三日游';
  @State startDate: string = '2024-12-01';
  @State endDate: string = '2024-12-03';
  @State days: number = 3;
  @State totalBudget: string = '¥2,500';
  @State status: string = '进行中';
  
  @State dayPlans: DayPlan[] = [
    {
      day: 1,
      date: '12月01日',
      activities: [
        { time: '09:00', title: '抵达深圳', location: '深圳宝安机场', description: '乘坐早班飞机抵达', icon: '✈️' },
        { time: '11:00', title: '酒店入住', location: '深圳湾万豪酒店', description: '办理入住手续', icon: '🏨' },
        { time: '15:00', title: '深圳湾公园', location: '南山区', description: '漫步海滨栈道', icon: '🏞️' }
      ]
    },
    {
      day: 2,
      date: '12月02日',
      activities: [
        { time: '09:00', title: '世界之窗', location: '华侨城', description: '游览世界景点', icon: '🌍' },
        { time: '14:00', title: '欢乐谷', location: '南山区', description: '体验游乐项目', icon: '🎢' }
      ]
    }
  ];

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.itineraryId = params.id;
    }
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '行程详情',
        showBack: true
      })

      Scroll() {
        Column() {
          this.HeaderCard()
          this.DayPlanList()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder HeaderCard() {
    Column() {
      Text(this.itineraryTitle)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(this.days.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3b82f6')
          Text('天数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text(this.totalBudget)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('预算')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text(this.status)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#f59e0b')
          Text('状态')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder DayPlanList() {
    Column({ space: 12 }) {
      ForEach(this.dayPlans, (dayPlan: DayPlan) => {
        this.DayPlanCard(dayPlan)
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  @Builder DayPlanCard(dayPlan: DayPlan) {
    Column() {
      Text(`第${dayPlan.day}天 - ${dayPlan.date}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        ForEach(dayPlan.activities, (activity: ActivityItem) => {
          this.ActivityItem(activity)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ActivityItem(activity: ActivityItem) {
    Row() {
      Text(activity.icon)
        .fontSize(32)
        .width(50)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(activity.time)
            .fontSize(14)
            .fontColor('#6b7280')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 6 })

        Text(activity.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 4 })
          .alignSelf(ItemAlign.Start)

        Text(`📍 ${activity.location}`)
          .fontSize(13)
          .fontColor('#6b7280')
          .margin({ bottom: 4 })
          .alignSelf(ItemAlign.Start)

        Text(activity.description)
          .fontSize(13)
          .fontColor('#9ca3af')
          .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
