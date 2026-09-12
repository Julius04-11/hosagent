import { UIExtensionContentSession, UIExtensionAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { display, window } from '@kit.ArkUI';

const TAG = '[LiveViewExtAbility]';
const DOMAIN = 0x0000;

export default class LiveViewExtAbility extends UIExtensionAbility {
  private subscriber?: commonEventManager.CommonEventSubscriber;
  private verticalBreakpoint: string = 'sm';
  
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    hilog.info(DOMAIN, TAG, 'onSessionCreate called');
    
    try {
      session.loadContent('liveview/LockScreenPage');
      this.initializeData(want);
      this.subscribeCommonEvent();
      this.setupWindowSizeListener(session);
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Session create failed: ${error.message}`);
    }
  }
  
  private initializeData(want: Want): void {
    try {
      const params = want.parameters?.['liveViewLockScreenAbilityParameters'] as Record<string, string>;
      if (params?.initialData) {
        const data: Record<string, string> = JSON.parse(params.initialData);
        AppStorage.setOrCreate('liveViewData', data);
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to initialize data: ${err}`);
    }
  }
  
  private subscribeCommonEvent(): void {
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['smart_travel_live_view'],
      publisherBundleName: 'com.example.smarttravel',
      priority: 0
    };
    
    commonEventManager.createSubscriber(subscribeInfo, (error, data) => {
      if (error) {
        hilog.error(DOMAIN, TAG, `Failed to create subscriber: ${error.message}`);
        return;
      }
      
      this.subscriber = data;
      hilog.info(DOMAIN, TAG, 'Subscriber created successfully');
      
      commonEventManager.subscribe(this.subscriber, (error, data) => {
        if (error) {
          hilog.error(DOMAIN, TAG, `Failed to subscribe: ${error.message}`);
          return;
        }
        
        if (data.parameters) {
          const liveViewData: Record<string, string> = data.parameters['liveViewData'] as Record<string, string>;
          AppStorage.setOrCreate('liveViewData', liveViewData);
          hilog.info(DOMAIN, TAG, 'Live view data updated');
        }
      });
    });
  }
  
  private setupWindowSizeListener(session: UIExtensionContentSession): void {
    try {
      const extensionWindow = session.getUIExtensionWindowProxy();
      extensionWindow.on('windowSizeChange', (windowSize: window.Size) => {
        this.updateBreakPoint(windowSize);
      });
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Setup listener failed: ${error.message}`);
    }
  }
  
  private updateBreakPoint(windowSize: window.Size): void {
    try {
      const densityPixels = display.getDefaultDisplaySync().densityPixels;
      const windowWidthVp = windowSize.width / densityPixels;
      const windowHeightVp = windowSize.height / densityPixels;
      const windowRatio = windowWidthVp / windowHeightVp;
      
      let verticalBreakpoint = 'sm';
      if (windowRatio < 0.8) {
        verticalBreakpoint = 'sm';
      } else if (windowRatio > 1.2) {
        verticalBreakpoint = 'lg';
      } else {
        verticalBreakpoint = 'md';
      }
      
      if (this.verticalBreakpoint !== verticalBreakpoint) {
        this.verticalBreakpoint = verticalBreakpoint;
        AppStorage.setOrCreate('verticalBreakpoint', verticalBreakpoint);
        hilog.info(DOMAIN, TAG, `Breakpoint updated: ${verticalBreakpoint}`);
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Update breakpoint failed: ${err}`);
    }
  }
  
  onSessionDestroy(session: UIExtensionContentSession): void {
    hilog.info(DOMAIN, TAG, 'onSessionDestroy called');
    
    if (this.subscriber) {
      commonEventManager.unsubscribe(this.subscriber, (err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to unsubscribe: ${err.message}`);
        } else {
          hilog.info(DOMAIN, TAG, 'Unsubscribed successfully');
        }
      });
    }
  }
}
