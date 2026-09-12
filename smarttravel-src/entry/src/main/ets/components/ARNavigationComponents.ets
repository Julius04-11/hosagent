import { ARNavigationService, ARNavigationPoint, ARNavigationRoute, ARNavigationStatus } from '../service/ARNavigationService';
import { LocationInfo } from '../model/LocationModel';
import { AnimationUtils } from '../utils/AnimationUtils';

/**
 * AR导航箭头组件
 * 显示导航方向箭头
 */
@Component
export struct ARNavigationArrow {
  @Prop navigationPoint: ARNavigationPoint;
  @Prop isVisible: boolean = true;
  @State arrowRotation: number = 0;
  @State pulseScale: number = 1.0;

  aboutToAppear() {
    this.startArrowAnimation();
  }

  // 开始箭头动画
  private startArrowAnimation() {
    // 旋转动画
    setInterval(() => {
      this.arrowRotation = this.navigationPoint.bearing;
    }, 100);

    // 脉冲动画
    setInterval(() => {
      this.pulseScale = this.pulseScale === 1.0 ? 1.2 : 1.0;
    }, 1000);
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 箭头背景
        Circle()
          .width(60)
          .height(60)
          .fill('#1e40af')
          .opacity(0.8)
        
        // 箭头图标
        Text(this.navigationPoint.icon)
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        
        // 距离标签
        Text(`${this.navigationPoint.distance}m`)
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.6)')
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .borderRadius(8)
          .position({ x: 0, y: 35 })
      }
      .scale({ x: this.pulseScale, y: this.pulseScale })
      .rotate({ angle: this.arrowRotation })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
    }
  }
}

/**
 * AR导航信息面板
 * 显示导航信息
 */
@Component
export struct ARNavigationInfoPanel {
  @Prop navigationPoint: ARNavigationPoint;
  @Prop isVisible: boolean = true;
  @State panelHeight: number = 0;

  build() {
    if (this.isVisible) {
      Column() {
        // 导航标题
        Text(this.navigationPoint.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 8 })
        
        // 导航描述
        Text(this.navigationPoint.description)
          .fontSize(14)
          .fontColor('#6b7280')
          .margin({ bottom: 12 })
        
        // 距离信息
        Row() {
          Text('📍')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text(`${this.navigationPoint.distance}米`)
            .fontSize(16)
            .fontColor('#059669')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 8 })
        
        // 方位信息
        Row() {
          Text('🧭')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text(`方位角: ${Math.round(this.navigationPoint.bearing)}°`)
            .fontSize(14)
            .fontColor('#6b7280')
        }
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.1)',
        offsetX: 0,
        offsetY: 4
      })
      .margin({ bottom: 16 })
    }
  }
}

/**
 * AR导航控制面板
 * 提供导航控制功能
 */
@Component
export struct ARNavigationControlPanel {
  @Prop navigationStatus: ARNavigationStatus;
  @Prop onStartNavigation: () => void = () => {};
  @Prop onStopNavigation: () => void = () => {};
  @Prop onToggleNavigation: () => void = () => {};
  @Prop onCalibrate: () => void = () => {};

  build() {
    Row() {
      // 开始/停止导航按钮
      Button() {
        Text(this.navigationStatus === ARNavigationStatus.IDLE ? '开始导航' : '停止导航')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor(this.navigationStatus === ARNavigationStatus.IDLE ? '#059669' : '#dc2626')
      .borderRadius(20)
      .onClick(() => {
        if (this.navigationStatus === ARNavigationStatus.IDLE) {
          this.onStartNavigation();
        } else {
          this.onStopNavigation();
        }
      })
      
      // 暂停/恢复按钮
      if (this.navigationStatus === ARNavigationStatus.NAVIGATING || 
          this.navigationStatus === ARNavigationStatus.PAUSED) {
        Button() {
          Text(this.navigationStatus === ARNavigationStatus.PAUSED ? '▶️' : '⏸️')
            .fontSize(16)
        }
        .width(40)
        .height(40)
        .backgroundColor('#f59e0b')
        .borderRadius(20)
        .margin({ left: 8 })
        .onClick(() => {
          this.onToggleNavigation();
        })
      }
      
      // 校准按钮
      Button() {
        Text('🎯')
          .fontSize(16)
        Text('校准')
          .fontSize(10)
          .fontColor(Color.White)
          .margin({ top: 2 })
      }
      .width(50)
      .height(40)
      .backgroundColor('#6366f1')
      .borderRadius(20)
      .margin({ left: 8 })
      .onClick(() => {
        this.onCalibrate();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
}

/**
 * AR导航主界面
 * 集成所有AR导航功能
 */
@Component
export struct ARNavigationView {
  @State navigationService: ARNavigationService = ARNavigationService.getInstance();
  @State currentNavigationPoint: ARNavigationPoint | null = null;
  @State navigationStatus: ARNavigationStatus = ARNavigationStatus.IDLE;
  @State isARInitialized: boolean = false;
  @State showInfoPanel: boolean = true;
  @State cameraViewHeight: number = 300;

  // 模拟路线数据
  private mockRoute: ARNavigationRoute = {
    id: 'route_1',
    startPoint: {
      latitude: 22.5431,
      longitude: 114.0579,
      address: '深圳市南山区',
      city: '深圳市',
      province: '广东省',
      country: '中国',
      accuracy: 10,
      timestamp: Date.now()
    },
    endPoint: {
      latitude: 22.5531,
      longitude: 114.0679,
      address: '世界之窗',
      city: '深圳市',
      province: '广东省',
      country: '中国',
      accuracy: 10,
      timestamp: Date.now()
    },
    waypoints: [],
    totalDistance: 1000,
    estimatedTime: 15,
    routeType: 'walking'
  };

  async aboutToAppear() {
    await this.initializeAR();
  }

  // 初始化AR
  private async initializeAR() {
    this.isARInitialized = await this.navigationService.initializeAR();
    if (this.isARInitialized) {
      this.navigationStatus = ARNavigationStatus.IDLE;
      console.log('AR导航初始化成功');
    } else {
      console.error('AR导航初始化失败');
    }
  }

  // 开始导航
  private async startNavigation() {
    if (!this.isARInitialized) {
      await this.initializeAR();
    }
    
    const success = await this.navigationService.startARNavigation(this.mockRoute);
    if (success) {
      this.navigationStatus = ARNavigationStatus.NAVIGATING;
      this.updateNavigationPoint();
    }
  }

  // 停止导航
  private stopNavigation() {
    this.navigationService.stopARNavigation();
    this.navigationStatus = ARNavigationStatus.IDLE;
    this.currentNavigationPoint = null;
  }

  // 切换导航状态
  private toggleNavigation() {
    this.navigationService.toggleARNavigation();
    this.navigationStatus = this.navigationService.getNavigationStatus();
  }

  // 校准AR
  private async calibrateAR() {
    this.navigationStatus = ARNavigationStatus.CALIBRATING;
    
    // 模拟校准过程
    setTimeout(async () => {
      await this.navigationService.updateCurrentLocation();
      this.navigationStatus = ARNavigationStatus.IDLE;
    }, 2000);
  }

  // 更新导航点
  private updateNavigationPoint() {
    this.currentNavigationPoint = this.navigationService.getNextNavigationPoint();
  }

  // 切换信息面板显示
  private toggleInfoPanel() {
    this.showInfoPanel = !this.showInfoPanel;
  }

  build() {
    Column() {
      // AR相机视图区域
      Stack() {
        // 相机背景（模拟）
        Column() {
          Text('📷')
            .fontSize(48)
            .fontColor('#6b7280')
            .margin({ bottom: 8 })
          
          Text('AR相机视图')
            .fontSize(16)
            .fontColor('#6b7280')
            .margin({ bottom: 4 })
          
          Text('实时显示导航箭头和方向指引')
            .fontSize(12)
            .fontColor('#9ca3af')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(this.cameraViewHeight)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        
        // AR导航箭头
        if (this.currentNavigationPoint && this.navigationStatus === ARNavigationStatus.NAVIGATING) {
          ARNavigationArrow({
            navigationPoint: this.currentNavigationPoint,
            isVisible: true
          })
          .position({ x: '50%', y: '50%' })
          .translate({ x: -30, y: -30 })
        }
        
        // 状态指示器
        if (this.navigationStatus === ARNavigationStatus.CALIBRATING) {
          Column() {
            LoadingProgress()
              .width(30)
              .height(30)
              .color('#1e40af')
            
            Text('AR校准中...')
              .fontSize(12)
              .fontColor('#6b7280')
              .margin({ top: 8 })
          }
          .position({ x: '50%', y: '50%' })
          .translate({ x: -50, y: -20 })
        }
      }
      .width('100%')
      .height(this.cameraViewHeight)
      .margin({ bottom: 16 })

      // 导航信息面板
      if (this.showInfoPanel && this.currentNavigationPoint) {
        ARNavigationInfoPanel({
          navigationPoint: this.currentNavigationPoint,
          isVisible: true
        })
        .margin({ left: 16, right: 16, bottom: 16 })
      }

      // 导航控制面板
      ARNavigationControlPanel({
        navigationStatus: this.navigationStatus,
        onStartNavigation: () => this.startNavigation(),
        onStopNavigation: () => this.stopNavigation(),
        onToggleNavigation: () => this.toggleNavigation(),
        onCalibrate: () => this.calibrateAR()
      })
      .margin({ bottom: 16 })

      // 底部操作栏
      Row() {
        Button() {
          Text('📍')
            .fontSize(16)
            .margin({ right: 4 })
          Text('定位')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .height(36)
        .backgroundColor('#f1f5f9')
        .borderRadius(18)
        .onClick(async () => {
          await this.navigationService.updateCurrentLocation();
          this.updateNavigationPoint();
        })
        
        Blank()
        
        Button() {
          Text(this.showInfoPanel ? '📋' : '📋')
            .fontSize(16)
            .margin({ right: 4 })
          Text(this.showInfoPanel ? '隐藏' : '显示')
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .height(36)
        .backgroundColor('#f1f5f9')
        .borderRadius(18)
        .onClick(() => {
          this.toggleInfoPanel();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f8fafc')
  }
}
