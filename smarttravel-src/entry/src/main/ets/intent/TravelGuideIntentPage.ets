import { InsightIntentPage, IntentParams } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TravelGuideIntentPage';
const DOMAIN = 0x0000;

/**
 * 基于Page的意图装饰器示例
 * 用于直接在页面组件上声明意图，实现快速拉起
 * 
 * 使用场景：
 * - 已有Navigation架构的页面
 * - 需要快速将页面开放为意图入口
 * 
 * 约束：
 * - 仅支持前台执行
 * - 仅支持Navigation架构
 */

/**
 * 旅游攻略详情页面（使用意图装饰器）
 * 直接在Page组件上添加装饰器即可实现意图接入
 */
@InsightIntentPage({
  // 意图名称
  intentName: 'ViewTravelGuides',
  // 所属垂域
  domain: 'TravelDomain',
  // 意图版本
  intentVersion: '1.0.1',
  // 页面路由
  route: 'pages/guide/GuideDetailPage',
  // 意图描述
  description: '查看旅游攻略详情页面'
})
@Entry
@Component
export struct TravelGuideDetailIntentPage {
  @State guideId: string = '';
  @State guideTitle: string = '';
  @State location: string = '';
  
  /**
   * 页面即将显示时调用
   * 从意图参数中获取数据
   */
  aboutToAppear() {
    hilog.info(DOMAIN, TAG, '[Page] 页面加载');
    
    // 获取意图传递的参数
    this.loadIntentParams();
    
    hilog.info(DOMAIN, TAG, `[Page] 攻略: id=${this.guideId}, title=${this.guideTitle}, location=${this.location}`);
  }
  
  /**
   * 加载意图参数
   * 装饰器会自动将参数注入到页面中
   */
  private loadIntentParams() {
    // 方式1: 从AppStorage获取（兼容老方式）
    const storageId = AppStorage.get<string>('intentGuideId');
    const storageName = AppStorage.get<string>('intentGuideName');
    const storageLocation = AppStorage.get<string>('intentGuideLocation');
    
    if (storageId) {
      this.guideId = storageId;
      AppStorage.delete('intentGuideId');
    }
    
    if (storageName) {
      this.guideTitle = storageName;
      AppStorage.delete('intentGuideName');
    }
    
    if (storageLocation) {
      this.location = storageLocation;
      AppStorage.delete('intentGuideLocation');
    }
    
    // 方式2: 从@InsightIntentPage装饰器注入的参数获取
    // 装饰器会自动处理参数绑定
  }
  
  build() {
    NavDestination() {
      Column() {
        // 页面标题
        Text(this.guideTitle || '旅游攻略详情')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        // 位置信息
        if (this.location) {
          Row() {
            Text('📍')
              .fontSize(16)
            Text(this.location)
              .fontSize(16)
              .fontColor('#666666')
              .margin({ left: 5 })
          }
          .margin({ bottom: 20 })
        }
        
        // 内容区域
        Scroll() {
          Column() {
            Text('攻略内容加载中...')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 50 })
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#f8f8f8')
    }
    .title('攻略详情')
    .hideTitleBar(false)
  }
}

/**
 * 搜索结果页面（使用意图装饰器）
 */
@InsightIntentPage({
  intentName: 'SearchDestinations',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  route: 'pages/search/SearchResultPage',
  description: '搜索旅游目的地结果页'
})
@Entry
@Component
export struct SearchResultIntentPage {
  @State keyword: string = '';
  @State category: string = '';
  @State results: string[] = [];
  
  aboutToAppear() {
    hilog.info(DOMAIN, TAG, '[Page] 搜索页面加载');
    
    // 获取搜索参数
    const searchKeyword = AppStorage.get<string>('searchKeyword');
    const searchCategory = AppStorage.get<string>('searchCategory');
    
    if (searchKeyword) {
      this.keyword = searchKeyword;
      AppStorage.delete('searchKeyword');
    }
    
    if (searchCategory) {
      this.category = searchCategory;
      AppStorage.delete('searchCategory');
    }
    
    hilog.info(DOMAIN, TAG, `[Page] 搜索: keyword=${this.keyword}, category=${this.category}`);
    
    // 执行搜索
    this.performSearch();
  }
  
  /**
   * 执行搜索操作
   */
  private performSearch() {
    // 模拟搜索结果
    this.results = [
      `${this.keyword} - 攻略1`,
      `${this.keyword} - 攻略2`,
      `${this.keyword} - 攻略3`
    ];
  }
  
  build() {
    NavDestination() {
      Column() {
        // 搜索标题
        Text(`搜索: ${this.keyword}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        // 分类标签
        if (this.category) {
          Text(`分类: ${this.category}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 20 })
        }
        
        // 搜索结果列表
        List() {
          ForEach(this.results, (item: string) => {
            ListItem() {
              Text(item)
                .fontSize(16)
                .padding(15)
                .width('100%')
                .backgroundColor(Color.White)
                .borderRadius(8)
            }
            .margin({ bottom: 10 })
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#f8f8f8')
    }
    .title('搜索结果')
  }
}

/**
 * 天气预报页面（使用意图装饰器）
 */
@InsightIntentPage({
  intentName: 'ViewWeather',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  route: 'pages/weather/WeatherPage',
  description: '查看城市天气预报'
})
@Entry
@Component
export struct WeatherIntentPage {
  @State cityName: string = '当前位置';
  @State days: number = 7;
  @State temperature: string = '--';
  @State weather: string = '加载中...';
  
  aboutToAppear() {
    hilog.info(DOMAIN, TAG, '[Page] 天气页面加载');
    
    // 获取天气参数
    const weatherCity = AppStorage.get<string>('weatherCity');
    const weatherDays = AppStorage.get<number>('weatherDays');
    
    if (weatherCity) {
      this.cityName = weatherCity;
      AppStorage.delete('weatherCity');
    }
    
    if (weatherDays) {
      this.days = weatherDays;
      AppStorage.delete('weatherDays');
    }
    
    hilog.info(DOMAIN, TAG, `[Page] 天气查询: city=${this.cityName}, days=${this.days}`);
    
    // 加载天气数据
    this.loadWeatherData();
  }
  
  /**
   * 加载天气数据
   */
  private loadWeatherData() {
    // 模拟天气数据
    this.temperature = '25°C';
    this.weather = '晴天';
  }
  
  build() {
    NavDestination() {
      Column() {
        // 城市名称
        Text(this.cityName)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30, bottom: 20 })
        
        // 天气图标和温度
        Column() {
          Text('☀️')
            .fontSize(80)
            .margin({ bottom: 10 })
          
          Text(this.temperature)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 5 })
          
          Text(this.weather)
            .fontSize(20)
            .fontColor('#666666')
        }
        .margin({ bottom: 30 })
        
        // 预报天数说明
        Text(`未来${this.days}天预报`)
          .fontSize(16)
          .fontColor('#999999')
        
        // 占位空间
        Blank()
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#e3f2fd')
    }
    .title('天气预报')
  }
}
