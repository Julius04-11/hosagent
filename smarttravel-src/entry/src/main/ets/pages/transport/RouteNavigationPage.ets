import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface StationInfo {
  name: string;
  time: string;
  distance: string;
  isTransfer: boolean;
  transferLines?: string[];
}

interface RouteStep {
  type: 'walk' | 'metro' | 'bus';
  lineName?: string;
  stations: StationInfo[];
  duration: string;
  distance: string;
}

interface NavigationRoute {
  id: string;
  totalDuration: string;
  totalDistance: string;
  steps: RouteStep[];
  price: string;
}

@Entry
@Component
export struct RouteNavigationPage {
  @State transportType: string = '';
  @State transportName: string = '';
  @State isLoading: boolean = true;
  @State selectedRouteIndex: number = 0;
  @State routes: NavigationRoute[] = [];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.transportType = params['transportType'] as string || '地铁';
    this.transportName = params['transportName'] as string || '深圳地铁';
    this.loadRoutes();
  }

  private loadRoutes() {
    setTimeout(() => {
      // 模拟路线数据
      this.routes = [
        {
          id: '1',
          totalDuration: '45分钟',
          totalDistance: '12.5公里',
          price: '6元',
          steps: [
            {
              type: 'walk',
              stations: [
                { name: '起点: 深圳北站', time: '0分钟', distance: '0米', isTransfer: false }
              ],
              duration: '5分钟',
              distance: '300米'
            },
            {
              type: 'metro',
              lineName: '4号线',
              stations: [
                { name: '深圳北站', time: '0分钟', distance: '0米', isTransfer: false },
                { name: '红山', time: '3分钟', distance: '2.1公里', isTransfer: false },
                { name: '上塘', time: '6分钟', distance: '4.2公里', isTransfer: false },
                { name: '龙胜', time: '9分钟', distance: '6.5公里', isTransfer: false },
                { name: '龙华', time: '12分钟', distance: '8.8公里', isTransfer: false },
                { name: '清湖', time: '15分钟', distance: '11.2公里', isTransfer: false }
              ],
              duration: '35分钟',
              distance: '11.2公里'
            },
            {
              type: 'walk',
              stations: [
                { name: '终点: 清湖站出口', time: '45分钟', distance: '12.5公里', isTransfer: false }
              ],
              duration: '5分钟',
              distance: '300米'
            }
          ]
        },
        {
          id: '2',
          totalDuration: '52分钟',
          totalDistance: '14.2公里',
          price: '7元',
          steps: [
            {
              type: 'walk',
              stations: [
                { name: '起点: 深圳北站', time: '0分钟', distance: '0米', isTransfer: false }
              ],
              duration: '5分钟',
              distance: '300米'
            },
            {
              type: 'metro',
              lineName: '5号线',
              stations: [
                { name: '深圳北站', time: '0分钟', distance: '0米', isTransfer: false },
                { name: '民治', time: '4分钟', distance: '2.8公里', isTransfer: false },
                { name: '五和', time: '8分钟', distance: '5.6公里', isTransfer: false },
                { name: '坂田', time: '12分钟', distance: '8.4公里', isTransfer: false },
                { name: '杨美', time: '16分钟', distance: '11.2公里', isTransfer: false }
              ],
              duration: '42分钟',
              distance: '13.9公里'
            },
            {
              type: 'walk',
              stations: [
                { name: '终点: 杨美站出口', time: '52分钟', distance: '14.2公里', isTransfer: false }
              ],
              duration: '5分钟',
              distance: '300米'
            }
          ]
        }
      ];
      this.isLoading = false;
    }, 800);
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '路线导航',
        showBack: true
      })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Column() {
          // 路线选择卡片
          this.RouteSelector()

          // 路线详情
          Scroll() {
            Column() {
              if (this.routes.length > 0 && this.routes[this.selectedRouteIndex]) {
                this.RouteDetail(this.routes[this.selectedRouteIndex])
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
          }
          .layoutWeight(1)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder LoadingView() {
    Column() {
      Text('🗺️')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('正在规划路线...')
        .fontSize(16)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder RouteSelector() {
    Column() {
      Text('推荐路线')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .width('100%')
        .margin({ bottom: 12 })

      Column({ space: 12 }) {
        ForEach(this.routes ?? [], (route: NavigationRoute, index: number) => {
          Row() {
            Column({ space: 4 }) {
              Row() {
                Text(`路线${index + 1}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.selectedRouteIndex === index ? '#6366f1' : '#6b7280')
                
                if (index === 0) {
                  Text('推荐')
                    .fontSize(10)
                    .fontColor(Color.White)
                    .backgroundColor('#10b981')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .margin({ left: 8 })
                }
              }
              .width('100%')

              Row({ space: 16 }) {
                Row({ space: 4 }) {
                  Text('⏱️')
                    .fontSize(12)
                  Text(route.totalDuration)
                    .fontSize(12)
                    .fontColor('#6b7280')
                }

                Row({ space: 4 }) {
                  Text('📏')
                    .fontSize(12)
                  Text(route.totalDistance)
                    .fontSize(12)
                    .fontColor('#6b7280')
                }

                Row({ space: 4 }) {
                  Text('💰')
                    .fontSize(12)
                  Text(route.price)
                    .fontSize(12)
                    .fontColor('#6b7280')
                }
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            if (this.selectedRouteIndex === index) {
              Text('✓')
                .fontSize(20)
                .fontColor('#6366f1')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.selectedRouteIndex === index ? '#eef2ff' : Color.White)
          .borderRadius(8)
          .border({
            width: this.selectedRouteIndex === index ? 2 : 1,
            color: this.selectedRouteIndex === index ? '#6366f1' : '#e5e7eb'
          })
          .onClick(() => {
            this.selectedRouteIndex = index;
          })
        }, (route: NavigationRoute, index: number) => `route-${route.id}-${index}`)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
  }

  @Builder RouteDetail(route: NavigationRoute) {
    Column({ space: 16 }) {
      // 路线总览
      Column() {
        Row() {
          Text('路线总览')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row({ space: 24 }) {
          Column({ space: 4 }) {
            Text(route.totalDuration)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#6366f1')
            Text('预计时间')
              .fontSize(12)
              .fontColor('#6b7280')
          }

          Column({ space: 4 }) {
            Text(route.totalDistance)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#10b981')
            Text('总距离')
              .fontSize(12)
              .fontColor('#6b7280')
          }

          Column({ space: 4 }) {
            Text(route.price)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#f59e0b')
            Text('票价')
              .fontSize(12)
              .fontColor('#6b7280')
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // 详细步骤
      Column() {
        Text('详细路线')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .width('100%')
          .margin({ bottom: 16 })

        Column({ space: 16 }) {
          ForEach(route.steps ?? [], (step: RouteStep, stepIndex: number) => {
            this.RouteStep(step, stepIndex, (route.steps ?? []).length)
          }, (step: RouteStep, stepIndex: number) => `step-${stepIndex}-${step.type}-${step.lineName ?? ''}`)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
  }

  @Builder RouteStep(step: RouteStep, stepIndex: number, totalSteps: number) {
    Column({ space: 12 }) {
      // 步骤标题
      Row() {
        Text(this.getStepIcon(step.type))
          .fontSize(18)
          .margin({ right: 8 })

        Column({ space: 2 }) {
          Text(this.getStepTitle(step))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')

          Row({ space: 8 }) {
            Text(step.duration)
              .fontSize(12)
              .fontColor('#6b7280')
            Text('•')
              .fontSize(12)
              .fontColor('#6b7280')
            Text(step.distance)
              .fontSize(12)
              .fontColor('#6b7280')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 站点列表
      if ((step.stations ?? []).length > 0) {
        Column({ space: 8 }) {
          ForEach(step.stations ?? [], (station: StationInfo, stationIndex: number) => {
            Row() {
              // 连接线
              if (stationIndex < (step.stations ?? []).length - 1) {
                Column()
                  .width(2)
                  .height(30)
                  .backgroundColor(step.type === 'metro' ? '#6366f1' : step.type === 'bus' ? '#10b981' : '#9ca3af')
                  .margin({ left: 9, right: 9 })
              } else {
                Column()
                  .width(2)
                  .height(0)
                  .margin({ left: 9, right: 9 })
              }

              Column({ space: 4 }) {
                Row() {
                  // 站点标记
                  Column()
                    .width(20)
                    .height(20)
                    .borderRadius(10)
                    .backgroundColor(step.type === 'metro' ? '#6366f1' : step.type === 'bus' ? '#10b981' : '#9ca3af')
                    .margin({ right: 8 })

                  Column({ space: 2 }) {
                    Text(station.name)
                      .fontSize(13)
                      .fontColor('#374151')
                      .fontWeight(stationIndex === 0 || stationIndex === step.stations.length - 1 ? FontWeight.Medium : FontWeight.Normal)

                    if (station.isTransfer && (station.transferLines ?? []).length > 0) {
                      Row({ space: 4 }) {
                        Text('换乘')
                          .fontSize(10)
                          .fontColor('#f59e0b')
                        ForEach(station.transferLines ?? [], (line: string, idx: number) => {
                          Text(line)
                            .fontSize(10)
                            .fontColor('#f59e0b')
                            .backgroundColor('#fef3c7')
                            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                            .borderRadius(2)
                        }, (line: string, idx: number) => `transfer-${stationIndex}-${idx}-${line}`)
                      }
                      .margin({ top: 2 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column({ space: 2 }) {
                    Text(station.time)
                      .fontSize(11)
                      .fontColor('#9ca3af')
                    Text(station.distance)
                      .fontSize(11)
                      .fontColor('#9ca3af')
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
              }
              .layoutWeight(1)
            }
            .width('100%')
          }, (station: StationInfo, stationIndex: number) => `station-${stepIndex}-${stationIndex}-${station.name}`)
        }
        .width('100%')
        .margin({ left: 20 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f9fafb')
    .borderRadius(8)
  }

  private getStepIcon(type: string): string {
    const iconMap: Record<string, string> = {
      'walk': '🚶',
      'metro': '🚇',
      'bus': '🚌'
    };
    return iconMap[type] || '📍';
  }

  private getStepTitle(step: RouteStep): string {
    if (step.type === 'walk') {
      return '步行';
    } else if (step.type === 'metro') {
      return step.lineName ? `${step.lineName}地铁` : '地铁';
    } else if (step.type === 'bus') {
      return step.lineName ? `${step.lineName}公交` : '公交';
    }
    return '未知';
  }
}

