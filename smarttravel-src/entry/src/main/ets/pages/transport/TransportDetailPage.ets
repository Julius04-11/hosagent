import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface TransportDetail {
  id: string;
  name: string;
  type: string;
  icon: string;
  description: string;
  price: string;
  operatingHours: string;
  routes: RouteInfo[];
  tips: string[];
  paymentMethods: string[];
  features: string[];
}

interface RouteInfo {
  routeName: string;
  stations: string[];
  duration: string;
  frequency: string;
}

@Entry
@Component
export struct TransportDetailPage {
  @State transportDetail: TransportDetail = {} as TransportDetail;
  @State isLoading: boolean = true;
  @State selectedRouteIndex: number = 0;
  @State selectedRoute: RouteInfo | null = null;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    const transportId = params['id'] as string || '1';
    this.loadTransportDetail(transportId);
  }

  private loadTransportDetail(transportId: string) {
    setTimeout(() => {
      const detail: TransportDetail = {
        id: transportId,
        name: '深圳地铁',
        type: '地铁',
        icon: '🚇',
        description: '深圳地铁是深圳市的城市轨道交通系统，覆盖全市主要区域，是市民出行的重要交通工具。',
        price: '起步价2元，最高10元',
        operatingHours: '06:00 - 23:00',
        routes: [
          {
            routeName: '1号线(罗宝线)',
            stations: ['罗湖', '国贸', '老街', '大剧院', '科学馆', '华强路', '岗厦', '会展中心', '购物公园', '香蜜湖', '车公庙', '竹子林', '侨城东', '华侨城', '世界之窗', '白石洲', '高新园', '深大', '桃园', '大新', '鲤鱼门', '前海湾', '新安', '宝安中心', '宝体', '坪洲', '西乡', '固戍', '后瑞', '机场东'],
            duration: '约60分钟全程',
            frequency: '高峰期2-3分钟，平峰期4-6分钟'
          },
          {
            routeName: '2号线(蛇口线)',
            stations: ['赤湾', '蛇口港', '海上世界', '水湾', '东角头', '湾厦', '海月', '登良', '后海', '科苑', '红树湾', '世界之窗', '侨城北', '深康', '安托山', '侨香', '香蜜', '香梅北', '景田', '莲花西', '福田', '市民中心', '岗厦北', '华强北', '燕南', '大剧院', '湖贝', '黄贝岭', '新秀'],
            duration: '约50分钟全程',
            frequency: '高峰期2-4分钟，平峰期5-8分钟'
          }
        ],
        tips: [
          '支持深圳通、微信、支付宝扫码支付',
          '高峰期(7:00-9:00, 17:30-19:30)较为拥挤',
          '老人、儿童、残疾人可享受优惠票价',
          '禁止携带易燃易爆危险品',
          '车厢内禁止饮食'
        ],
        paymentMethods: ['深圳通', '微信支付', '支付宝', '银联闪付', '数字人民币'],
        features: ['空调车厢', '无障碍设施', '免费WiFi', '手机充电', 'LED信息显示']
      };
      this.transportDetail = detail;
      this.updateSelectedRoute(detail.routes);
      this.isLoading = false;
    }, 800);
  }

  private navigateToRoute() {
    ErrorHandler.safeExecute(async (): Promise<void> => {
      await router.pushUrl({
        url: 'pages/transport/RouteNavigationPage',
        params: {
          transportType: this.transportDetail.type,
          transportName: this.transportDetail.name
        }
      });
    }, (error: Error): void => ErrorHandler.handleRouterError(error, '路线导航页面'));
  }

  build() {
    Column() {
      TopNavigationBar({
        title: this.isLoading ? '加载中...' : this.transportDetail.name,
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column() {
            this.HeaderSection()
            this.BasicInfoSection()
            this.RoutesSection()
            this.PaymentMethodsSection()
            this.FeaturesSection()
            this.TipsSection()
          }
        }
        .layoutWeight(1)
      }

      if (!this.isLoading) {
        this.BottomActionSection()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('🚇')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在加载交通信息...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder HeaderSection() {
    Row() {
      Text(this.transportDetail.icon)
        .fontSize(48)
        .margin({ right: 16 })

      Column() {
        Text(this.transportDetail.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .width('100%')
          .margin({ bottom: 8 })

        Text(this.transportDetail.type)
          .fontSize(16)
          .fontColor('#6366f1')
          .backgroundColor('#eef2ff')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(20)
    .margin({ bottom: 12 })
    .borderRadius(12)
  }

  @Builder BasicInfoSection() {
    Column() {
      Text('📋 基本信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Text(this.transportDetail.description)
        .fontSize(14)
        .fontColor('#4b5563')
        .lineHeight(22)
        .width('100%')
        .margin({ bottom: 16 })

      Column({ space: 12 }) {
        Row() {
          Text('💰 票价:')
            .fontSize(16)
            .fontColor('#6b7280')
            .width(80)
          Text(this.transportDetail.price)
            .fontSize(16)
            .fontColor('#374151')
            .layoutWeight(1)
        }
        .width('100%')

        Row() {
          Text('⏰ 运营时间:')
            .fontSize(16)
            .fontColor('#6b7280')
            .width(80)
          Text(this.transportDetail.operatingHours)
            .fontSize(16)
            .fontColor('#374151')
            .layoutWeight(1)
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoutesSection() {
    Column() {
      Text('🚉 线路信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      // 线路选择标签
      Row() {
        ForEach(this.transportDetail.routes ?? [], (route: RouteInfo, index: number) => {
          Text(route.routeName)
            .fontSize(14)
            .fontColor(this.selectedRouteIndex === index ? Color.White : '#6366f1')
            .backgroundColor(this.selectedRouteIndex === index ? '#6366f1' : '#eef2ff')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedRouteIndex = index;
              this.selectedRoute = route;
            })
        }, (route: RouteInfo, index: number) => `route-${index}-${route.routeName}`)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 选中线路详情
      if (this.transportDetail.routes.length > 0 && this.selectedRoute) {
        Column() {
          Row() {
            Text('⏱️ 全程时间:')
              .fontSize(14)
              .fontColor('#6b7280')
            Text(this.selectedRoute.duration)
              .fontSize(14)
              .fontColor('#374151')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            Text('🔄 发车频率:')
              .fontSize(14)
              .fontColor('#6b7280')
            Text(this.selectedRoute.frequency)
              .fontSize(14)
              .fontColor('#374151')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text('主要站点:')
            .fontSize(14)
            .fontColor('#6b7280')
            .width('100%')
            .margin({ bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach((this.selectedRoute?.stations ?? []).slice(0, 10), (station: string, idx: number) => {
              Text(station)
                .fontSize(12)
                .fontColor('#374151')
                .backgroundColor('#f3f4f6')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
                .margin({ right: 6, bottom: 6 })
            }, (station: string, idx: number) => `station-chip-${idx}-${station}`)
            
            if ((this.selectedRoute?.stations ?? []).length > 10) {
              Text(`+${(this.selectedRoute?.stations ?? []).length - 10}个站点`)
                .fontSize(12)
                .fontColor('#6b7280')
                .backgroundColor('#f9fafb')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PaymentMethodsSection() {
    Column() {
      Text('💳 支付方式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.transportDetail.paymentMethods ?? [], (method: string, index: number) => {
          Row() {
            Text(this.getPaymentIcon(method))
              .fontSize(16)
              .margin({ right: 6 })
            Text(method)
              .fontSize(14)
              .fontColor('#374151')
          }
          .backgroundColor('#f0fdf4')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .borderRadius(8)
          .margin({ right: 8, bottom: 8 })
        }, (method: string, index: number) => `pay-${index}-${method}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder FeaturesSection() {
    Column() {
      Text('✨ 服务特色')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Column({ space: 8 }) {
        ForEach(this.transportDetail.features ?? [], (feature: string, index: number) => {
          Row() {
            Text('✅')
              .fontSize(16)
              .margin({ right: 8 })
            Text(feature)
              .fontSize(14)
              .fontColor('#374151')
              .layoutWeight(1)
          }
          .width('100%')
        }, (feature: string, index: number) => `feat-${index}-${feature}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder TipsSection() {
    Column() {
      Text('💡 出行提示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 16 })

      Column({ space: 8 }) {
        ForEach(this.transportDetail.tips ?? [], (tip: string, index: number) => {
          Row() {
            Text('•')
              .fontSize(16)
              .fontColor('#f59e0b')
              .margin({ right: 8 })
            Text(tip)
              .fontSize(14)
              .fontColor('#6b7280')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }, (tip: string, index: number) => `tip-${index}`)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BottomActionSection() {
    Row({ space: 12 }) {
      Button('路线查询')
        .backgroundColor('#6366f1')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          this.navigateToRoute();
        })

      Button('实时信息')
        .backgroundColor('#10b981')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          ErrorHandler.showToast('实时信息功能开发中...');
        })

      Button('收藏')
        .backgroundColor('#f59e0b')
        .fontColor(Color.White)
        .borderRadius(8)
        .layoutWeight(1)
        .onClick(() => {
          ErrorHandler.showToast('已收藏到我的交通');
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#e5e7eb' })
  }

  private getPaymentIcon(method: string): string {
    const iconMap: Record<string, string> = {
      '深圳通': '💳',
      '微信支付': '💚',
      '支付宝': '🔵',
      '银联闪付': '💎',
      '数字人民币': '🪙'
    };
    return iconMap[method] || '💳';
  }

  private updateSelectedRoute(routes: RouteInfo[]): void {
    if (routes.length === 0) {
      this.selectedRouteIndex = 0;
      this.selectedRoute = null;
      return;
    }
    const safeIndex = Math.min(this.selectedRouteIndex, routes.length - 1);
    this.selectedRouteIndex = safeIndex;
    this.selectedRoute = routes[safeIndex];
  }
}
