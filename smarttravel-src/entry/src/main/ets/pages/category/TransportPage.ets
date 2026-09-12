import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface TransportItem {
  id: string;
  name: string;
  type: '地铁' | '公交' | '出租车' | '共享单车' | '自驾';
  icon: string;
  description: string;
  price: string;
  time: string;
  tips: string[];
}

@Entry
@Component
export struct TransportPage {
  @State transportList: TransportItem[] = [
    {
      id: '1',
      name: '深圳地铁',
      type: '地铁',
      icon: '🚇',
      description: '深圳地铁覆盖全市主要区域，方便快捷',
      price: '¥2-10',
      time: '6:00-23:00',
      tips: ['支持微信/支付宝扫码', '高峰期较拥挤', '线路覆盖广泛']
    },
    {
      id: '2',
      name: '公交车',
      type: '公交',
      icon: '🚌',
      description: '公交线路密集，可到达各景点',
      price: '¥2-5',
      time: '6:00-22:00',
      tips: ['支持移动支付', '线路较多', '适合短途出行']
    },
    {
      id: '3',
      name: '出租车/网约车',
      type: '出租车',
      icon: '🚕',
      description: '方便快捷，适合长距离出行',
      price: '起步¥10，按里程计费',
      time: '24小时',
      tips: ['支持线上叫车', '价格较高', '适合有行李时']
    },
    {
      id: '4',
      name: '共享单车',
      type: '共享单车',
      icon: '🚲',
      description: '短途出行首选，环保健康',
      price: '¥1.5/30分钟',
      time: '24小时',
      tips: ['扫码即用', '适合短距离', '注意停放位置']
    },
    {
      id: '5',
      name: '自驾租车',
      type: '自驾',
      icon: '🚗',
      description: '自由灵活，适合多人出行',
      price: '¥200-500/天',
      time: '24小时',
      tips: ['需要驾照', '注意停车问题', '适合远距离出行']
    }
  ];

  build() {
    Column() {
      TopNavigationBar({
        title: '交通出行',
        showBack: true
      })

      // 出行方式列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.transportList, (item: TransportItem) => {
            this.TransportCard(item)
          }, (item: TransportItem) => item.id)  // 添加keyGenerator
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  @Builder TransportCard(item: TransportItem) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Text(item.icon)
            .fontSize(32)
        }
        .width(50)
        .height(50)
        .backgroundColor('#f0f4ff')
        .borderRadius(8)

        Column({ space: 6 }) {
          Row() {
            Text(item.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1f2937')
              .layoutWeight(1)

            Text(item.type)
              .fontSize(12)
              .fontColor('#6366f1')
              .backgroundColor('#eef2ff')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          .width('100%')

          Text(item.description)
            .fontSize(14)
            .fontColor('#6b7280')
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Text('💰')
                .fontSize(14)
              Text(item.price)
                .fontSize(13)
                .fontColor('#ef4444')
            }

            Row({ space: 4 }) {
              Text('⏰')
                .fontSize(14)
              Text(item.time)
                .fontSize(13)
                .fontColor('#6b7280')
            }
          }
          .width('100%')
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      // 小贴士
      if (item.tips && item.tips.length > 0) {
        Column({ space: 6 }) {
          Text('💡 出行小贴士')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .width('100%')

          Column({ space: 4 }) {
            ForEach(item.tips, (tip: string, index: number) => {
              Row({ space: 6 }) {
                Text('•')
                  .fontSize(12)
                  .fontColor('#9ca3af')
                Text(tip)
                  .fontSize(12)
                  .fontColor('#6b7280')
                  .layoutWeight(1)
              }
              .width('100%')
            }, (tip: string, index: number) => `${item.id}-tip-${index}`)  // 添加keyGenerator
          }
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#f9fafb')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      ErrorHandler.safeExecute(async (): Promise<void> => {
        await router.pushUrl({
          url: 'pages/transport/TransportDetailPage',
          params: { 
            id: item.id,
            name: item.name,
            type: item.type
          }
        });
      }, (error: Error): void => ErrorHandler.handleRouterError(error, '交通详情页面'));
    })
  }
}

