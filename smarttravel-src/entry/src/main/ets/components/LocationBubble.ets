import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager } from '@kit.AbilityKit';

@Component
export struct LocationBubble {
  @State isVisible: boolean = false;
  @State permissionStatus: string = 'denied';
  @State locationInfo: string = '';

  aboutToAppear() {
    this.checkLocationPermission();
  }

  // 检查定位权限状态
  private async checkLocationPermission() {
    try {
      // 获取tokenID
      let tokenID: number;
      try {
        const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
        tokenID = bundleInfo.appInfo.accessTokenId;
      } catch (err) {
        console.error('获取bundle信息失败:', err);
        this.permissionStatus = 'denied';
        this.isVisible = true;
        this.locationInfo = '无法获取应用信息';
        return;
      }

      // 检查权限状态
      const grantStatus = await abilityAccessCtrl.createAtManager().checkAccessToken(tokenID, 'ohos.permission.LOCATION');
      this.permissionStatus = grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ? 'granted' : 'denied';
      
      if (this.permissionStatus === 'denied') {
        this.isVisible = true;
        this.locationInfo = '需要开启定位权限以获取周边景点推荐';
      } else if (this.permissionStatus === 'granted') {
        this.isVisible = false;
        this.getLocationInfo();
      }
    } catch (error) {
      console.error('检查定位权限失败:', error);
      this.isVisible = true;
      this.locationInfo = '定位服务不可用，请检查设备设置';
    }
  }

  // 获取位置信息
  private async getLocationInfo() {
    try {
      const location = await geoLocationManager.getCurrentLocation();
      this.locationInfo = `当前位置: ${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`;
    } catch (error) {
      console.error('获取位置失败:', error);
      this.locationInfo = '获取位置信息失败';
    }
  }

  // 请求定位权限
  private async requestLocationPermission() {
    try {
      // 使用正确的权限请求方法
      // 使用正确的权限请求方法 - 需要传入context
      const permission = await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(getContext(), ['ohos.permission.LOCATION']);
      if (permission && permission.authResults && permission.authResults[0] === 0) {
        this.permissionStatus = 'granted';
        this.isVisible = false;
        this.getLocationInfo();
      } else {
        this.locationInfo = '权限请求失败，请手动开启定位权限';
      }
    } catch (error) {
      console.error('请求定位权限失败:', error);
      this.locationInfo = '权限请求失败，请手动开启定位权限';
    }
  }

  // 关闭气泡
  private closeBubble() {
    this.isVisible = false;
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .onClick(() => {
            this.closeBubble();
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
              this.closeBubble();
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 12 })
          
          // 气泡内容
          Column() {
            Text(this.locationInfo)
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
                this.closeBubble();
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
  }
}
