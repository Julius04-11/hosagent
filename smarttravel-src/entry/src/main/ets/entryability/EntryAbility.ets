import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import webview from '@ohos.web.webview';
import { DatabaseService } from '../database/DatabaseService';
import { NetworkConnectionManager } from '../managers/NetworkConnectionManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化数据库
    this.initializeDatabase();
    
    // 初始化网络监听
    this.initializeNetworkMonitoring();
    
    display.getDefaultDisplay((err, disp) => {
      if (err) {
        console.error('Failed to get default display. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded to get default display. display info: ' + JSON.stringify(disp));

      // 获取窗口信息并存储到AppStorage
      window.getLastWindow(this.context, (err, data) => {
        if (err) {
          console.error('Failed to get last window. Cause: ' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded to get last window. Data: ' + JSON.stringify(data));

        const windowProperties = data.getWindowProperties();
        AppStorage.set<number>('width', windowProperties.windowRect.width);
        AppStorage.set<number>('height', windowProperties.windowRect.height);
        AppStorage.set<number>('density', disp.densityPixels); // 屏幕密度
        AppStorage.set<number>('screenHeight', disp.height); // 屏幕物理高度
        AppStorage.set<number>('screenWidth', disp.width);   // 屏幕物理宽度
        console.info('AppStorage: width = ' + AppStorage.get('width'));
        console.info('AppStorage: height = ' + AppStorage.get('height'));
      });
    });
    webview.WebviewController.initializeWebEngine()
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    // 停止网络监听
    const networkManager = NetworkConnectionManager.getInstance();
    networkManager.stopListening();
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 初始化数据库
   */
  private async initializeDatabase(): Promise<void> {
    try {
      const dbService = DatabaseService.getInstance();
      await dbService.initialize(this.context);
      hilog.info(DOMAIN, 'testTag', '数据库初始化成功');
      
      // 检查是否首次启动
      const isFirstTime = await dbService.isFirstTimeLaunch();
      if (isFirstTime) {
        hilog.info(DOMAIN, 'testTag', '首次启动应用');
        // 初始化默认用户数据
        const userId = 'user_' + Date.now();
        await dbService.saveCurrentUserId(userId);
        await dbService.setFirstTimeLaunch(false);
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', '数据库初始化失败: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 初始化网络监听
   */
  private initializeNetworkMonitoring(): void {
    try {
      const networkManager = NetworkConnectionManager.getInstance();
      networkManager.startListening();
      hilog.info(DOMAIN, 'testTag', '网络监听初始化成功');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', '网络监听初始化失败: %{public}s', JSON.stringify(error));
    }
  }
}