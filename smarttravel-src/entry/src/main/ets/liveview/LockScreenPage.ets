import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[LockScreenPage]';
const DOMAIN = 0x0000;

interface TravelLiveViewData {
  title?: string;
  distance?: string;
  destination?: string;
  eta?: string;
}

@Entry
@Component
struct LockScreenPage {
  @StorageLink('verticalBreakpoint') verticalBreakpoint: string = 'sm';
  @StorageProp('liveViewData') liveViewData: TravelLiveViewData | undefined = undefined;
  
  aboutToAppear() {
    hilog.info(DOMAIN, TAG, 'LockScreenPage appeared');
  }
  
  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_public_back'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .backgroundColor('#1976D2')
      
      Column() {
        this.buildHeader()
        this.buildContent()
        this.buildFooter()
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_public_location'))
        .width(this.verticalBreakpoint === 'md' ? 40 : 32)
        .height(this.verticalBreakpoint === 'md' ? 40 : 32)
        .fillColor(Color.White)
      
      Text(this.liveViewData?.title || '旅游导航')
        .fontSize(this.verticalBreakpoint === 'md' ? 24 : 20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 12 })
    }
    .width('100%')
    .margin({ top: this.verticalBreakpoint === 'md' ? 40 : 30 })
  }
  
  @Builder
  buildContent() {
    Column() {
      Text(this.liveViewData?.distance || '0.0km')
        .fontSize(this.verticalBreakpoint === 'md' ? 60 : 48)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      
      Text(this.liveViewData?.destination || '目的地')
        .fontSize(this.verticalBreakpoint === 'md' ? 20 : 16)
        .fontColor('#CCFFFFFF')
        .margin({ top: 12 })
      
      Row() {
        Image($r('app.media.ic_public_clock'))
          .width(20)
          .height(20)
          .fillColor('#CCFFFFFF')
        
        Text(this.liveViewData?.eta || '预计到达')
          .fontSize(16)
          .fontColor('#CCFFFFFF')
          .margin({ left: 8 })
      }
      .margin({ top: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  buildFooter() {
    Row() {
      Text('点击查看详情')
        .fontSize(14)
        .fontColor('#99FFFFFF')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 30 })
  }
}
