import { Prompt, router } from "@kit.ArkUI";
import { resourceManager } from "@kit.LocalizationKit";
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { SignInUtils } from '../../utils/SignInUtils';

interface FeatureItem {
  icon: string;
  name: string;
}

@Entry
@Component
export struct ProfilePage {
  @State userName: string = 'syt';
  @State userAvatar: Resource = $r('app.string.AvatarUrl');
  @State userBio: string = '热爱探索世界，记录美好生活';
  private featureList: FeatureItem[] = [
    { icon: '🧪', name: '测试页面' },
    { icon: '📋', name: '报名情况' },
    { icon: '📦', name: '我的订单' },
    { icon: '📸', name: '我的相册' },
    { icon: '❤️', name: '我的收藏' },
    { icon: '📝', name: '我的攻略' },
    { icon: '🏷️', name: '优惠券' },
    { icon: '⚙️', name: '设置' },
    { icon: '❓', name: '帮助与反馈' },
    { icon: '🗺️', name: '我的行程' }
  ];

  // 统一的路由跳转方法，带错误处理
  private navigateToPage(featureName: string): void {
    const routeMap: Record<string, string> = {
      '测试页面': 'pages/profile/TestPage',
      '报名情况': 'pages/profile/RegistrationStatusPage',
      '我的订单': 'pages/order/HotelOrderPage',
      '我的相册': 'pages/profile/MyAlbumPage',
      '我的收藏': 'pages/profile/MyFavoritesPage',
      '我的攻略': 'pages/profile/MyGuidesPage',
      '优惠券': 'pages/profile/CouponsPage',
      '设置': 'pages/profile/SettingsPage',
      '帮助与反馈': 'pages/profile/HelpFeedbackPage',
      '我的行程': 'pages/profile/MyItineraryPage'
    };

    const url = routeMap[featureName];
    if (url) {
      router.pushUrl({ url }).catch((err: Error) => {
        console.error(`页面跳转失败: ${featureName}`, err.message);
        Prompt.showToast({ message: '页面加载失败，请稍后重试' });
      });
    } else {
      Prompt.showToast({ message: `${featureName} 功能开发中...` });
    }
  }

  build() {
    Column() {
      // 统一的顶部导航栏
      TopNavigationBar({
        title: '我的',
        showSearch: true,
        showNotification: true
      })
      
      Scroll() {
        Column() {
          // 用户信息卡片
          this.UserInfoCard()
          
          // 会员权益卡片
          this.MemberBenefitsCard()
          
          // 快捷功能区域
          this.QuickActionsCard()
          
          // 功能列表区域
          this.FeatureGrid()
        }
        .width('100%')
        .backgroundColor('#f8fafc')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }


  @Builder UserInfoCard() {
    Column() {
      // 右上角功能按钮
      Row() {
        Blank()
        
        Row({ space: 12 }) {
          // 扫一扫
          Column() {
            Text('📱')
              .fontSize(20)
              .margin({ bottom: 2 })
            
            Text('扫一扫')
              .fontSize(10)
              .fontColor('#6b7280')
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/scan/ScanPage' })
          })

          // 签到
          Column() {
            Text('📅')
              .fontSize(20)
              .margin({ bottom: 2 })
            
            Text('签到')
              .fontSize(10)
              .fontColor('#6b7280')
          }
          .onClick(() => {
            SignInUtils.handleSignIn();
          })

          // 客服
          Column() {
            Text('🎧')
              .fontSize(20)
              .margin({ bottom: 2 })
            
            Text('客服')
              .fontSize(10)
              .fontColor('#6b7280')
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/customer/CustomerServicePage' })
          })

          // 设置
          Column() {
            Text('⚙️')
              .fontSize(20)
              .margin({ bottom: 2 })
            
            Text('设置')
              .fontSize(10)
              .fontColor('#6b7280')
          }
          .onClick(() => {
            Prompt.showToast({ message: '设置功能' })
          })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 16 })

      Row() {
        // 用户头像
        Image(this.userAvatar)
          .width(60)
          .height(60)
          .borderRadius(30)
          .objectFit(ImageFit.Cover)
          .margin({ right: 16 })

        // 用户信息
        Column() {
          Text(this.userName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .margin({ bottom: 4 })

          Text(this.userBio)
            .fontSize(14)
            .fontColor('#6b7280')
            .margin({ bottom: 8 })

          // 用户统计
          Row({ space: 16 }) {
            Column() {
              Text('0')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1f2937')
              Text('粉丝')
                .fontSize(12)
                .fontColor('#6b7280')
            }

            Column() {
              Text('0')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1f2937')
              Text('关注')
                .fontSize(12)
                .fontColor('#6b7280')
            }

            Column() {
              Text('0')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1f2937')
              Text('获赞')
                .fontSize(12)
                .fontColor('#6b7280')
            }
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 编辑按钮
        Button('编辑')
          .fontSize(14)
          .fontColor('#3b82f6')
          .backgroundColor('#dbeafe')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .onClick(() => {
            // 跳转到编辑页面
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder MemberBenefitsCard() {
    Column() {
      Row() {
        Text('白银贵宾')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .layoutWeight(1)

        Text('会员中心 >')
          .fontSize(14)
          .fontColor('#3b82f6')
          .onClick(() => {
            // 跳转到会员中心
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 会员权益列表
      Column({ space: 8 }) {
        Row() {
          Text('🚀')
            .fontSize(16)
            .margin({ right: 8 })
          Text('1.2倍 积分加速')
            .fontSize(14)
            .fontColor('#374151')
        }

        Row() {
          Text('🎁')
            .fontSize(16)
            .margin({ right: 8 })
          Text('谭师傅美食团 品鉴私房菜')
            .fontSize(14)
            .fontColor('#374151')
        }

        Row() {
          Text('🎁')
            .fontSize(16)
            .margin({ right: 8 })
          Text('一旬一味 酒店免费住')
            .fontSize(14)
            .fontColor('#374151')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#dbeafe')
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
  }

  @Builder QuickActionsCard() {
    Column() {
      Text('快捷功能')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Row({ space: 20 }) {
        Column() {
          Text('1')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('收藏')
            .fontSize(12)
            .fontColor('#6b7280')
        }

        Column() {
          Text('1')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('浏览历史')
            .fontSize(12)
            .fontColor('#6b7280')
        }

        Column() {
          Text('239')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('积分')
            .fontSize(12)
            .fontColor('#6b7280')
        }

        Column() {
          Text('1')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
          Text('优惠券')
            .fontSize(12)
            .fontColor('#6b7280')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder FeatureGrid() {
    Column() {
      Text('更多功能')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1f2937')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      GridRow({
        columns: 4,
        gutter: { x: 12, y: 12 }
      }) {
        ForEach(this.featureList.slice(0, 8), (item: FeatureItem) => {
          GridCol({ span: 1 }) {
            this.FeatureItem(item)
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder FeatureItem(item: FeatureItem) {
    Column() {
      Text(item.icon)
        .fontSize(24)
        .margin({ bottom: 8 })

      Text(item.name)
        .fontSize(12)
        .fontColor('#374151')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.navigateToPage(item.name)
    })
  }
}

@Component
struct functionEntry {
  @Prop item: FeatureItem;

  build() {
    Column() {
      Text(this.item.icon)
        .fontSize(36)
        .margin({ bottom: 8 })

      Text(this.item.name)
        .fontSize(16)
        .fontColor(Color.Black)
    }
    .width('100%')
    .height(120)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: Color.Gray,
      offsetX: 0,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.handleFeatureClick(this.item.name)
    })
  }

  private handleFeatureClick(featureName: string): void {
    const routeMap: Record<string, string> = {
      '测试页面': 'pages/profile/TestPage',
      '报名情况': 'pages/profile/RegistrationStatusPage',
      '我的订单': 'pages/order/HotelOrderPage',
      '我的相册': 'pages/profile/MyAlbumPage',
      '我的收藏': 'pages/profile/MyFavoritesPage',
      '我的攻略': 'pages/profile/MyGuidesPage',
      '优惠券': 'pages/profile/CouponsPage',
      '设置': 'pages/profile/SettingsPage',
      '帮助与反馈': 'pages/profile/HelpFeedbackPage',
      '我的行程': 'pages/profile/MyItineraryPage'
    };

    const url = routeMap[featureName];
    if (url) {
      router.pushUrl({ url }).catch((err: Error) => {
        console.error(`页面跳转失败: ${featureName}`, err.message);
        Prompt.showToast({ message: '页面加载失败，请稍后重试' });
      });
    } else {
      Prompt.showToast({ message: `${featureName} 功能开发中...` });
    }
  }
}
