import { router } from '@kit.ArkUI';
import { map, MapComponent } from '@kit.MapKit';
import { LocationInfo, MapMarker, CollectItem, CollectedMarker } from '../../model/LocationModel';
import { CollectListDialog } from '../../components/CollectListDialog';
import { ARNavigationService } from '../../service/ARNavigationService';
import { MapViewModel } from '../../viewmodel/MapViewModel';
import { LiveViewUtil } from '../../utils/LiveViewUtil';
import { BackgroundTaskService } from '../../services/BackgroundTaskService';
import { LiveViewUpdateService, TravelLiveViewData } from '../../services/LiveViewUpdateService';
import { DataChangeDetector, SmartUpdateStrategy, PowerOptimizer } from '../../utils/LiveViewOptimizer';
// import { AgentIconComponent } from '../../agent/SmartTravelAgent'; // 模拟器不支持Agent Framework
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
export struct MapPage {
  // ViewModel实例
  private viewModel: MapViewModel = new MapViewModel();
  
  // UI状态 - 从ViewModel同步
  @State currentLocation: LocationInfo | null = null;
  @State markers: MapMarker[] = [];
  @State showLocationBubble: boolean = false;
  @State locationPermissionGranted: boolean = false;
  @State isLoading: boolean = false;
  @State departureAddress: string = '';
  @State destinationAddress: string = '';
  @State isAnimating: boolean = false;
  @State showCollectDialog: boolean = false;
  @State favoriteLocations: CollectItem[] = [];
  @State showARButton: boolean = true;
  @State selectedMarkerId: string | null = null;
  @State selectedMarker: MapMarker | null = null;
  
  // 实况窗相关状态
  @State isNavigating: boolean = false;
  @State navigationDistance: string = '2.5km'; // 初始距离
  @State navigationEta: string = '预计到达';
  @State batteryLevel: number = 100;
  @State updateIntervalValue: number = 5000; // 当前更新间隔
  private updateInterval?: number;
  private context: common.UIAbilityContext | null = null;
  private readonly TAG = '[MapPage]';
  private readonly DOMAIN = 0x0000;
  
  // 优化工具实例
  private dataChangeDetector: DataChangeDetector = new DataChangeDetector();
  private smartUpdateStrategy: SmartUpdateStrategy = new SmartUpdateStrategy();
  private liveViewUtil: LiveViewUtil = new LiveViewUtil();

  private arNavigationService: ARNavigationService = ARNavigationService.getInstance();

  async aboutToAppear() {
    this.context = getContext(this) as common.UIAbilityContext;
    this.viewModel.setMarkerSelectionListener(this.onMarkerSelectedFromMap);
    await this.viewModel.initialize();
    this.syncStateFromViewModel();
  }

  aboutToDisappear() {
    this.viewModel.setMarkerSelectionListener();
    this.stopNavigation();
  }

  // 从ViewModel同步状态到View
  private syncStateFromViewModel(): void {
    this.currentLocation = this.viewModel.currentLocation;
    this.markers = this.viewModel.markers;
    this.showLocationBubble = this.viewModel.showLocationBubble;
    this.locationPermissionGranted = this.viewModel.locationPermissionGranted;
    this.isLoading = this.viewModel.isLoading;
    this.departureAddress = this.viewModel.departureAddress;
    this.destinationAddress = this.viewModel.destinationAddress;
    this.isAnimating = this.viewModel.isAnimating;
    this.favoriteLocations = this.viewModel.favoriteLocations;
    this.selectedMarkerId = this.viewModel.selectedMarkerId;
    this.selectedMarker = this.viewModel.getMarkerById(this.selectedMarkerId ?? undefined) ?? null;
  }

  private onMarkerSelectedFromMap = (markerId: string | null, markerData?: MapMarker) => {
    this.selectedMarkerId = markerId;
    this.selectedMarker = markerData ?? (markerId ? this.viewModel.getMarkerById(markerId) ?? null : null);
  }

  // 请求定位权限
  private async requestLocationPermission() {
    const success = await this.viewModel.requestLocationPermission();
      if (success) {
      this.syncStateFromViewModel();
    }
  }

  // 获取当前位置
  private async getCurrentLocation() {
    await this.viewModel.getCurrentLocation();
    this.syncStateFromViewModel();
  }

  // 切换收藏状态
  private toggleFavorite(markerId: string) {
    this.viewModel.toggleFavorite(markerId);
    this.syncStateFromViewModel();
  }

  private async focusMarker(marker: MapMarker) {
    await this.viewModel.focusMarker(marker.id);
    this.selectedMarkerId = marker.id;
    this.selectedMarker = marker;
  }
 
  // 地址交换动画
  private async swapAddresses() {
    await this.viewModel.swapAddresses(this.getUIContext());
    this.syncStateFromViewModel();
  }

  // 添加新标记
  private async addMarker() {
    const newMarker = await this.viewModel.addMarker();
    if (newMarker) {
      this.syncStateFromViewModel();
    }
  }

  // 显示收藏列表
  private showCollectList() {
    this.showCollectDialog = true;
  }

  // 隐藏收藏列表
  private hideCollectList() {
    this.showCollectDialog = false;
  }

  // 启动AR导航（已集成实况窗）
  private async startARNavigation() {
    try {
      // 检查是否有起点和终点
      if (!this.departureAddress || !this.destinationAddress) {
        hilog.warn(this.DOMAIN, this.TAG, '请先设置起点和终点');
        return;
      }

      if (!this.context || this.isNavigating) return;
      
      hilog.info(this.DOMAIN, this.TAG, 'Starting navigation with live view...');
      
      // 1. 创建实况窗
      await this.liveViewUtil.createLiveView(
        '旅游导航',
        this.navigationDistance,
        'ic_public_location.png',
        this.context
      );
      
      // 2. 开启后台任务
      await BackgroundTaskService.startBackgroundTask(this.context);
      
      // 3. 开启定时更新
      this.startPeriodicUpdate();
      
      this.isNavigating = true;
      hilog.info(this.DOMAIN, this.TAG, 'Navigation and live view started successfully');
      
      // 4. 跳转到AR导航页面
      router.pushUrl({
        url: 'pages/ar/ARNavigationPage'
      }).catch((error: Error) => {
        hilog.error(this.DOMAIN, this.TAG, `跳转到AR导航页面失败: ${error.message}`);
      });
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `启动AR导航失败: ${error}`);
    }
  }
  
  // 停止导航和实况窗
  private async stopNavigation() {
    if (!this.context || !this.isNavigating) return;
    
    try {
      hilog.info(this.DOMAIN, this.TAG, 'Stopping navigation...');
      
      // 1. 清除定时器
      if (this.updateInterval) {
        clearInterval(this.updateInterval);
        this.updateInterval = undefined;
      }
      
      // 2. 停止实况窗
      await this.liveViewUtil.stopLiveView(this.context);
      
      // 3. 停止后台任务
      await BackgroundTaskService.stopBackgroundTask(this.context);
      
      // 4. 重置优化器状态
      this.dataChangeDetector.reset();
      this.smartUpdateStrategy.reset();
      
      // 5. 重置导航数据
      this.navigationDistance = '2.5km';
      this.navigationEta = '预计到达';
      
      this.isNavigating = false;
      hilog.info(this.DOMAIN, this.TAG, '✅ Navigation stopped and resources cleaned');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `❌ 停止导航失败: ${error}`);
    }
  }
  
  // 开启定时更新（带智能优化）
  private async startPeriodicUpdate() {
    // 获取当前电量
    this.batteryLevel = await this.smartUpdateStrategy.getBatteryLevel();
    
    // 根据电量调整更新间隔
    this.updateIntervalValue = this.smartUpdateStrategy.getUpdateInterval(this.batteryLevel);
    
    hilog.info(this.DOMAIN, this.TAG, `Starting updates with interval: ${this.updateIntervalValue}ms`);
    
    this.updateInterval = setInterval(() => {
      // 检查是否应该更新
      if (!this.smartUpdateStrategy.shouldUpdate()) {
        return;
      }
      
      // 模拟数据更新
      this.updateNavigationData();
      
      // 准备更新数据
      const updateData: TravelLiveViewData = {
        title: '旅游导航',
        distance: this.navigationDistance,
        destination: this.destinationAddress,
        eta: this.navigationEta
      };
      
      // 检查数据是否变化
      if (this.dataChangeDetector.hasChanged(updateData)) {
        // 发布公共事件
        LiveViewUpdateService.publishUpdate(updateData);
        hilog.info(this.DOMAIN, this.TAG, `✅ Updated: ${this.navigationDistance}`);
      } else {
        hilog.info(this.DOMAIN, this.TAG, `⏭️ Skip update: Data unchanged`);
      }
    }, this.updateIntervalValue);
    
    // 每30秒检查一次电量并调整更新频率
    this.adjustUpdateFrequency();
  }
  
  // 动态调整更新频率
  private adjustUpdateFrequency() {
    setInterval(async () => {
      const newBatteryLevel = await this.smartUpdateStrategy.getBatteryLevel();
      const newInterval = this.smartUpdateStrategy.getUpdateInterval(newBatteryLevel);
      
      if (newInterval !== this.updateIntervalValue) {
        hilog.info(this.DOMAIN, this.TAG, 
          `🔋 Battery changed: ${this.batteryLevel}% -> ${newBatteryLevel}%`);
        hilog.info(this.DOMAIN, this.TAG, 
          `⏱️ Adjusting interval: ${this.updateIntervalValue}ms -> ${newInterval}ms`);
        
        this.batteryLevel = newBatteryLevel;
        this.updateIntervalValue = newInterval;
        
        // 重启定时器以应用新间隔
        if (this.updateInterval && this.isNavigating) {
          clearInterval(this.updateInterval);
          this.startPeriodicUpdate();
        }
      }
    }, 30000); // 每30秒检查一次
  }
  
  // 更新导航数据（模拟）
  private updateNavigationData() {
    const currentDist = parseFloat(this.navigationDistance);
    if (currentDist > 0) {
      this.navigationDistance = `${(currentDist - 0.1).toFixed(1)}km`;
    }
    
    const minutes = Math.ceil(currentDist / 0.25);
    this.navigationEta = `预计${minutes}分钟到达`;
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        this.HeaderSection()
        
        // 地址输入区域
        this.AddressInputSection()
        
        // 地图区域
        this.MapSection()
        
        // 标记点列表
        this.MarkersList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
      
      // 收藏列表对话框
      if (this.showCollectDialog) {
        CollectListDialog({
          visible: $showCollectDialog,
          favorites: this.convertToCollectedMarkers(this.favoriteLocations)
        })
      }
      
      // 位置气泡
      if (this.showLocationBubble) {
        this.LocationBubble()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder HeaderSection() {
    Column() {
      // 顶部工具栏
      Row() {
        Text('地图导航')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e40af')
        
        Blank()
        
        // AI智能助手 (模拟器暂不支持Agent Framework)
        // AgentIconComponent()
        //   .width(40)
        //   .height(40)
        //   .margin({ right: 8 })
        
        // 收藏列表按钮
        Button() {
          Text('❤️')
            .fontSize(20)
            .fontColor('#64748b')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .borderRadius(20)
        .margin({ right: 8 })
        .onClick(() => {
          this.showCollectList();
        })
        
        // AR导航/停止按钮
        if (this.showARButton) {
          Button() {
            Row() {
              Text(this.isNavigating ? '⏹️' : '🥽')
                .fontSize(16)
              Text(this.isNavigating ? '停止' : '导航')
                .fontSize(14)
                .fontColor(this.isNavigating ? '#ef4444' : '#1e40af')
                .margin({ left: 4 })
            }
          }
          .height(40)
          .backgroundColor(this.isNavigating ? '#fee2e2' : '#dbeafe')
          .borderRadius(20)
          .padding({ left: 12, right: 12 })
          .margin({ right: 8 })
          .onClick(() => {
            if (this.isNavigating) {
              this.stopNavigation();
            } else {
              this.startARNavigation();
            }
          })
        }
        
        // 添加标记按钮
        Button() {
          Text('📍')
            .fontSize(20)
            .fontColor('#64748b')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .borderRadius(20)
        .onClick(() => {
          this.addMarker();
        })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      
      // 导航状态面板（仅在导航时显示）
      if (this.isNavigating) {
        this.NavigationStatusPanel()
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
  
  @Builder NavigationStatusPanel() {
    Row() {
      // 实时距离
      Column() {
        Text('📍 距离')
          .fontSize(12)
          .fontColor('#64748b')
        Text(this.navigationDistance)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e40af')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      // 预计到达
      Column() {
        Text('🕐 到达时间')
          .fontSize(12)
          .fontColor('#64748b')
        Text(this.navigationEta)
          .fontSize(14)
          .fontColor('#059669')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor('#f0f9ff')
    .borderRadius(8)
    .margin({ left: 20, right: 20, bottom: 10 })
  }

  @Builder AddressInputSection() {
    Column() {
      // 出发地
      Row() {
        Text('出发地:')
          .fontSize(16)
          .fontColor('#64748b')
          .width(60)
        
        TextInput({ placeholder: '请输入出发地', text: this.departureAddress })
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('#1e293b')
          .backgroundColor('#f8fafc')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onChange((value: string) => {
            this.viewModel.setDepartureAddress(value);
            this.departureAddress = value;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 目的地
      Row() {
        Text('目的地:')
          .fontSize(16)
          .fontColor('#64748b')
          .width(60)
        
        TextInput({ placeholder: '请输入目的地', text: this.destinationAddress })
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('#1e293b')
          .backgroundColor('#f8fafc')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onChange((value: string) => {
            this.viewModel.setDestinationAddress(value);
            this.destinationAddress = value;
          })
        
        // 地址交换按钮
        Button() {
          Text('🔄')
            .fontSize(16)
            .fontColor('#1e40af')
        }
        .width(40)
        .height(40)
        .backgroundColor('#f0f8ff')
        .borderRadius(20)
        .margin({ left: 8 })
        .onClick(() => {
          this.swapAddresses();
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder MapSection() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({
          mapOptions: this.viewModel.mapOptions,
          mapCallback: this.viewModel.mapCallback,
          customInfoWindow: this.customInfoWindow
        })
          .width('100%')
          .height('100%')

        if (this.currentLocation) {
          Stack() {
            this.CurrentLocationChip(this.currentLocation)
          }
          .position({ x: 16, y: 16 })
        }

        Button() {
          Text('📍')
            .fontSize(20)
            .fontColor('#1e40af')
        }
        .width(50)
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(25)
        .shadow({
          radius: 8,
          color: 'rgba(0,0,0,0.15)',
          offsetX: 0,
          offsetY: 4
        })
        .position({ x: 30, y: 220 })
        .onClick(async () => {
          await this.getCurrentLocation();
        })

        if (this.selectedMarker) {
          this.SelectedMarkerCard(this.selectedMarker)
        }

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(30)
              .height(30)
              .color('#1e40af')

            Text('定位中...')
              .fontSize(12)
              .fontColor('#64748b')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgba(248, 250, 252, 0.8)')
        }
      }
      .width('100%')
      .height(300)
      .borderRadius(12)
      .clip(true)
      .backgroundColor('#f1f5f9')
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .margin({ bottom: 8 })
  }

  @Builder MarkersList() {
    Column() {
      Row() {
        Text('标记点列表')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')
        
        Blank()
        
        Text(`共 ${this.markers.length} 个`)
          .fontSize(14)
          .fontColor('#64748b')
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 12 })
      
      Scroll() {
        Column() {
          ForEach(this.markers ?? [], (marker: MapMarker, index: number) => {
            this.MarkerItem(marker, index)
          }, (marker: MapMarker, index: number) => `marker-${marker.id ?? index}`)
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }

  @Builder MarkerItem(marker: MapMarker, index: number) {
    Row() {
      // 标记点图标
      Column() {
        Text('📍')
          .fontSize(24)
          .fontColor(marker.isFavorite ? '#ff6b6b' : (this.selectedMarkerId === marker.id ? '#1e40af' : '#64748b'))
      }
      .width(50)
      .height(50)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 标记点信息
      Column() {
        Text(marker.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedMarkerId === marker.id ? '#1e40af' : '#1e293b')
          .alignSelf(ItemAlign.Start)
        
        Text(marker.description)
          .fontSize(14)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
        
        Text(`坐标: ${marker.latitude.toFixed(4)}, ${marker.longitude.toFixed(4)}`)
          .fontSize(12)
          .fontColor('#94a3b8')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      // 收藏按钮
      Button() {
        Text(marker.isFavorite ? '❤️' : '🤍')
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .borderRadius(20)
      .onClick(() => {
        this.toggleFavorite(marker.id);
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.selectedMarkerId === marker.id ? '#e0f2fe' : Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 12 })
    .onClick(async () => {
      await this.focusMarker(marker);
    })
  }

  @Builder LocationBubble() {
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .onClick(() => {
          this.viewModel.hideLocationBubble();
          this.showLocationBubble = false;
        })
      
      // 气泡内容
      Column() {
        // 气泡头部
        Row() {
          Text('📍')
            .fontSize(24)
            .fontColor('#1e40af')
          
          Text('定位服务')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
            .margin({ left: 8 })
          
          Blank()
          
          Button() {
            Text('✕')
              .fontSize(16)
              .fontColor('#64748b')
          }
          .width(30)
          .height(30)
          .backgroundColor(Color.Transparent)
          .borderRadius(15)
          .onClick(() => {
            this.viewModel.hideLocationBubble();
            this.showLocationBubble = false;
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })
        
        // 气泡内容
        Column() {
          Text('需要开启定位权限以获取周边景点推荐')
            .fontSize(16)
            .fontColor('#475569')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })
          
          // 操作按钮
          Row() {
            Button() {
              Text('取消')
                .fontSize(16)
                .fontColor('#64748b')
            }
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#f1f5f9')
            .borderRadius(22)
            .margin({ right: 8 })
            .onClick(() => {
              this.viewModel.hideLocationBubble();
              this.showLocationBubble = false;
            })
            
            Button() {
              Text('开启定位')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
            }
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#1e40af')
            .borderRadius(22)
            .margin({ left: 8 })
            .onClick(() => {
              this.requestLocationPermission();
            })
          }
          .width('100%')
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .width(320)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.15)',
        offsetX: 0,
        offsetY: 8
      })
      .position({ x: '50%', y: '50%' })
      .translate({ x: -160, y: -100 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder CurrentLocationChip(location: LocationInfo) {
    Row({ space: 8 }) {
      Text('📍')
        .fontSize(16)
        .fontColor('#1e40af')

      Column() {
        Text('当前位置')
          .fontSize(12)
          .fontColor('#1e293b')
          .fontWeight(FontWeight.Medium)

        Text(location.address ?? `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`)
          .fontSize(10)
          .fontColor('#475569')
      }
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor('rgba(255,255,255,0.92)')
    .borderRadius(24)
    .shadow({
      radius: 8,
      color: 'rgba(15,23,42,0.12)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder SelectedMarkerCard(marker: MapMarker) {
    Column({ space: 12 }) {
      Row() {
        Column() {
          Text(marker.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0f172a')

          Text(marker.description)
            .fontSize(13)
            .fontColor('#475569')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button() {
          Text(marker.isFavorite ? '❤️' : '🤍')
            .fontSize(18)
        }
        .width(44)
        .height(44)
        .backgroundColor('#eff6ff')
        .borderRadius(22)
        .onClick(() => {
          this.toggleFavorite(marker.id);
        })
      }

      Row() {
        Text(`坐标: ${marker.latitude.toFixed(4)}, ${marker.longitude.toFixed(4)}`)
          .fontSize(12)
          .fontColor('#64748b')
        
        Blank()

        Button('聚焦')
          .type(ButtonType.Capsule)
          .height(32)
          .onClick(async () => {
            await this.focusMarker(marker);
          })
      }

      Row({ space: 12 }) {
        Button('设为目的地')
          .layoutWeight(1)
          .height(36)
          .type(ButtonType.Normal)
          .onClick(() => {
            this.viewModel.setDestinationAddress(marker.title);
            this.destinationAddress = marker.title;
          })

        Button('设为出发地')
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent)
          .borderWidth(1)
          .borderColor('#007AFF')
          .onClick(() => {
            this.viewModel.setDepartureAddress(marker.title);
            this.departureAddress = marker.title;
          })
      }
    }
    .width('90%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(Color.White)
    .borderRadius(18)
    .shadow({
      radius: 16,
      color: 'rgba(15,23,42,0.14)',
      offsetX: 0,
      offsetY: 8
    })
    .align(Alignment.Bottom)
    .margin({ bottom: 16 })
  }

  @Builder customInfoWindowBuilder($$: map.MarkerDelegate) {
    Column({ space: 4 }) {
      Text(this.getMarkerTitle($$))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Text(this.getMarkerDescription($$))
        .fontSize(11)
        .fontColor('rgba(255,255,255,0.85)')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('rgba(15,23,42,0.92)')
    .borderRadius(12)
    .visibility(this.getMarkerData($$.marker) ? Visibility.Visible : Visibility.None)
  }

  customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder.bind(this);

  // 获取标记数据的辅助方法
  private getMarkerData(marker: map.Marker): MapMarker | null {
    const markerId: string = marker.getTitle();
    return this.viewModel.getMarkerById(markerId ?? undefined) || null;
  }

  // 获取标记标题
  private getMarkerTitle($$: map.MarkerDelegate): string {
    if (!$$.marker) return '';
    const markerData = this.getMarkerData($$.marker);
    return markerData?.title || '';
  }

  // 获取标记描述
  private getMarkerDescription($$: map.MarkerDelegate): string {
    if (!$$.marker) return '';
    const markerData = this.getMarkerData($$.marker);
    return markerData?.description || '';
  }

  // 转换CollectItem[]到CollectedMarker[]
  private convertToCollectedMarkers(items: CollectItem[]): CollectedMarker[] {
    return items.map((item): CollectedMarker => ({
      id: item.id || '',
      latitude: item.latitude || 0,
      longitude: item.longitude || 0,
      simpleAddress: item.title || '未命名地址',
      detailAddress: item.description || '未提供详细地址',
      createdAt: Date.now()
    }));
  }
}
