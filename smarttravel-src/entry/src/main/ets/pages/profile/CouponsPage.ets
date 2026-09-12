import { router } from "@kit.ArkUI";
import { TopNavigationBar } from '../../components/TopNavigationBar';

interface CouponItem {
  id: string;
  title: string;
  description: string;
  discountType: 'percentage' | 'amount' | 'free';
  discountValue: number;
  minAmount?: number;
  maxDiscount?: number;
  validFrom: string;
  validTo: string;
  status: 'available' | 'used' | 'expired';
  applicableActivities: string[];
  conditions: string[];
  imageUrl: string;
}

@Entry
@Component
export struct CouponsPage {
  @State couponList: CouponItem[] = [
    {
      id: '1',
      title: '新用户专享券',
      description: '首次注册用户专享，全场活动通用',
      discountType: 'percentage',
      discountValue: 20,
      minAmount: 100,
      maxDiscount: 50,
      validFrom: '2024-06-01',
      validTo: '2024-06-30',
      status: 'available',
      applicableActivities: ['全部活动'],
      conditions: ['新用户专享', '满100元可用'],
      imageUrl: 'https://picsum.photos/300/150?random=1'
    },
    {
      id: '2',
      title: '端午活动券',
      description: '端午民俗嘉年华专用优惠券',
      discountType: 'amount',
      discountValue: 30,
      minAmount: 200,
      validFrom: '2024-06-08',
      validTo: '2024-06-12',
      status: 'available',
      applicableActivities: ['端午民俗嘉年华'],
      conditions: ['限端午活动使用', '满200元可用'],
      imageUrl: 'https://picsum.photos/300/150?random=2'
    },
    {
      id: '3',
      title: '美食探店券',
      description: '谭师傅私房菜专用优惠券',
      discountType: 'percentage',
      discountValue: 15,
      minAmount: 150,
      maxDiscount: 30,
      validFrom: '2024-06-01',
      validTo: '2024-06-20',
      status: 'used',
      applicableActivities: ['谭师傅私房菜'],
      conditions: ['限指定餐厅使用', '满150元可用'],
      imageUrl: 'https://picsum.photos/300/150?random=3'
    },
    {
      id: '4',
      title: '免费体验券',
      description: '东湖公园荷花节免费门票',
      discountType: 'free',
      discountValue: 0,
      validFrom: '2024-06-15',
      validTo: '2024-06-25',
      status: 'available',
      applicableActivities: ['东湖公园荷花节'],
      conditions: ['免费体验', '限1人使用'],
      imageUrl: 'https://picsum.photos/300/150?random=4'
    },
    {
      id: '5',
      title: '会员专享券',
      description: '白银会员专享，全场通用',
      discountType: 'amount',
      discountValue: 50,
      minAmount: 300,
      validFrom: '2024-05-01',
      validTo: '2024-05-31',
      status: 'expired',
      applicableActivities: ['全部活动'],
      conditions: ['会员专享', '满300元可用'],
      imageUrl: 'https://picsum.photos/300/150?random=5'
    },
    {
      id: '6',
      title: '夜游灯会券',
      description: '深圳湾公园夜游灯会专用',
      discountType: 'percentage',
      discountValue: 25,
      minAmount: 80,
      maxDiscount: 20,
      validFrom: '2024-06-10',
      validTo: '2024-06-20',
      status: 'available',
      applicableActivities: ['夜游灯会大赏'],
      conditions: ['限夜游活动使用', '满80元可用'],
      imageUrl: 'https://picsum.photos/300/150?random=6'
    }
  ];

  @State selectedTab: number = 0;
  private tabs: string[] = ['全部', '可用', '已使用', '已过期'];

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: '优惠券',
        showBack: true,
        showSearch: false,
        showNotification: false
      })

      // 统计信息
      this.StatisticsCard()

      // 标签页
      this.TabBar()

      // 内容区域
      this.ContentArea()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }

  @Builder StatisticsCard() {
    Column() {
      Row() {
        Column() {
          Text('6')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('优惠券总数')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('4')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#10b981')
          Text('可用')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#6b7280')
          Text('已使用')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)

        Column() {
          Text('1')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ef4444')
          Text('已过期')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder TabBar() {
    Row() {
      ForEach(this.tabs ?? [], (tab: string, index: number) => {
        Text(tab)
          .fontSize(14)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#3b82f6' : '#6b7280')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.selectedTab === index ? '#dbeafe' : Color.Transparent)
          .borderRadius(20)
          .onClick(() => {
            this.selectedTab = index;
          })
      }, (tab: string, index: number) => `tab-${index}-${tab}`)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder ContentArea() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredCoupons() ?? [], (coupon: CouponItem, index: number) => {
          this.CouponCard(coupon)
        }, (coupon: CouponItem, index: number) => `coupon-${coupon.id}-${index}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder CouponCard(coupon: CouponItem) {
    Column() {
      // 优惠券主体
      Row() {
        // 左侧折扣信息
        Column() {
          if (coupon.discountType === 'percentage') {
            Text(`${coupon.discountValue}%`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getStatusColor(coupon.status))
          } else if (coupon.discountType === 'amount') {
            Text(`¥${coupon.discountValue}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getStatusColor(coupon.status))
          } else {
            Text('免费')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getStatusColor(coupon.status))
          }

          if (coupon.minAmount) {
            Text(`满¥${coupon.minAmount}可用`)
              .fontSize(10)
              .fontColor('#6b7280')
              .margin({ top: 4 })
          }
        }
        .width(80)
        .height(100)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.getStatusBgColor(coupon.status))
        .borderRadius({ topLeft: 12, bottomLeft: 12 })

        // 右侧详细信息
        Column() {
          // 标题和状态
          Row() {
            Text(coupon.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getStatusText(coupon.status))
              .fontSize(10)
              .fontColor(this.getStatusColor(coupon.status))
              .backgroundColor(this.getStatusBgColor(coupon.status))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 4 })

          // 描述
          Text(coupon.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          // 有效期
          Row() {
            Text('📅')
              .fontSize(12)
              .margin({ right: 4 })
            Text(`${coupon.validFrom} 至 ${coupon.validTo}`)
              .fontSize(10)
              .fontColor('#9ca3af')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 适用活动
          Text(`适用: ${coupon.applicableActivities.join(', ')}`)
            .fontSize(10)
            .fontColor('#6b7280')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .padding(12)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
        .borderRadius({ topRight: 12, bottomRight: 12 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 使用条件
      if (coupon.conditions.length > 0) {
        Column() {
          Text('使用条件:')
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          ForEach(coupon.conditions ?? [], (condition: string, index: number) => {
            Row() {
              Text('•')
                .fontSize(12)
                .fontColor('#6b7280')
                .margin({ right: 4 })
              Text(condition)
                .fontSize(12)
                .fontColor('#6b7280')
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
            .margin({ bottom: 2 })
          }, (condition: string, index: number) => `cond-${coupon.id}-${index}`)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
        .margin({ bottom: 12 })
      }

      // 操作按钮
      if (coupon.status === 'available') {
        Row() {
          Button('立即使用')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#3b82f6')
            .borderRadius(8)
            .padding({ left: 24, right: 24, top: 10, bottom: 10 })
            .onClick(() => {
              this.useCoupon(coupon.id);
            })

          Blank()

          Button('查看详情')
            .fontSize(14)
            .fontColor('#3b82f6')
            .backgroundColor('#dbeafe')
            .borderRadius(8)
            .padding({ left: 24, right: 24, top: 10, bottom: 10 })
            .onClick(() => {
              this.viewCouponDetail(coupon.id);
            })
        }
        .width('100%')
      } else {
        Row() {
          Button(this.getActionText(coupon.status))
            .fontSize(14)
            .fontColor('#6b7280')
            .backgroundColor('#f3f4f6')
            .borderRadius(8)
            .padding({ left: 24, right: 24, top: 10, bottom: 10 })
            .enabled(false)

          Blank()

          Button('查看详情')
            .fontSize(14)
            .fontColor('#6b7280')
            .backgroundColor('#f3f4f6')
            .borderRadius(8)
            .padding({ left: 24, right: 24, top: 10, bottom: 10 })
            .onClick(() => {
              this.viewCouponDetail(coupon.id);
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getFilteredCoupons(): CouponItem[] {
    switch (this.selectedTab) {
      case 1: // 可用
        return this.couponList.filter(coupon => coupon.status === 'available');
      case 2: // 已使用
        return this.couponList.filter(coupon => coupon.status === 'used');
      case 3: // 已过期
        return this.couponList.filter(coupon => coupon.status === 'expired');
      default: // 全部
        return this.couponList;
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'available': return '可用';
      case 'used': return '已使用';
      case 'expired': return '已过期';
      default: return '未知';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'available': return '#10b981';
      case 'used': return '#6b7280';
      case 'expired': return '#ef4444';
      default: return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'available': return '#d1fae5';
      case 'used': return '#f3f4f6';
      case 'expired': return '#fee2e2';
      default: return '#f3f4f6';
    }
  }

  private getActionText(status: string): string {
    switch (status) {
      case 'used': return '已使用';
      case 'expired': return '已过期';
      default: return '不可用';
    }
  }

  private useCoupon(id: string): void {
    // 使用优惠券逻辑
    const index = this.couponList.findIndex(coupon => coupon.id === id);
    if (index !== -1) {
      this.couponList[index].status = 'used';
    }
  }

  private viewCouponDetail(id: string): void {
    try {
      router.pushUrl({ 
        url: 'pages/coupon/CouponDetailPage',
        params: { id: id }
      });
    } catch (error) {
      console.error('Failed to navigate to coupon detail:', error);
    }
  }
}
