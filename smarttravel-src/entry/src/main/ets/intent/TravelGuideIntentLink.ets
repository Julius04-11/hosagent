import { InsightIntentLink, IntentContext } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TravelGuideIntentLink';
const DOMAIN = 0x0000;

/**
 * 基于Link的意图装饰器示例
 * 用于通过DeepLink方式快速拉起旅游攻略页面
 * 
 * 使用场景：
 * - 用户对小艺说"查看旅游攻略"
 * - 小艺通过Link方式打开应用并跳转到指定页面
 * 
 * 约束：仅支持前台执行
 */

/**
 * 旅游攻略DeepLink处理器
 * 装饰器会自动注册该Link为意图入口
 */
@InsightIntentLink({
  // 意图名称：查看旅游攻略
  intentName: 'ViewTravelGuides',
  // 所属垂域
  domain: 'TravelDomain',
  // 意图版本
  intentVersion: '1.0.1',
  // DeepLink URI模式
  uriPattern: 'smarttravel://travelguides/{guideId}',
  // 意图描述
  description: '查看旅游攻略详情'
})
export class TravelGuideIntentLink {
  /**
   * 处理意图调用
   * 
   * @param context 意图上下文，包含参数和环境信息
   * @returns 返回true表示处理成功，false表示失败
   */
  static execute(context: IntentContext): boolean {
    try {
      hilog.info(DOMAIN, TAG, '[Link] 收到意图调用');
      hilog.info(DOMAIN, TAG, `[Link] 参数: ${JSON.stringify(context.params)}`);
      
      // 从上下文中提取参数
      const guideId = context.params?.['guideId'] as string || '';
      const guideName = context.params?.['name'] as string || '';
      const location = context.params?.['location'] as string || '';
      
      hilog.info(DOMAIN, TAG, `[Link] 攻略信息: id=${guideId}, name=${guideName}, location=${location}`);
      
      // 构造DeepLink URI
      let uri = `smarttravel://travelguides/${guideId}`;
      if (guideName) {
        uri += `?name=${encodeURIComponent(guideName)}`;
      }
      if (location) {
        uri += `&location=${encodeURIComponent(location)}`;
      }
      
      hilog.info(DOMAIN, TAG, `[Link] 跳转URI: ${uri}`);
      
      // 存储参数供页面使用
      AppStorage.setOrCreate('linkGuideId', guideId);
      AppStorage.setOrCreate('linkGuideName', guideName);
      AppStorage.setOrCreate('linkGuideLocation', location);
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 执行失败: ${JSON.stringify(error)}`);
      return false;
    }
  }
}

/**
 * 搜索目的地DeepLink处理器
 */
@InsightIntentLink({
  intentName: 'SearchDestinations',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  uriPattern: 'smarttravel://search/{keyword}',
  description: '搜索旅游目的地'
})
export class SearchDestinationIntentLink {
  static execute(context: IntentContext): boolean {
    try {
      hilog.info(DOMAIN, TAG, '[Link] 搜索目的地意图');
      
      const keyword = context.params?.['keyword'] as string || '';
      const category = context.params?.['category'] as string || '';
      
      hilog.info(DOMAIN, TAG, `[Link] 搜索关键词: ${keyword}, 分类: ${category}`);
      
      // 存储搜索参数
      AppStorage.setOrCreate('searchKeyword', keyword);
      AppStorage.setOrCreate('searchCategory', category);
      
      // 构造URI并跳转
      const uri = `smarttravel://search/${encodeURIComponent(keyword)}?category=${category}`;
      hilog.info(DOMAIN, TAG, `[Link] 搜索URI: ${uri}`);
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 搜索失败: ${JSON.stringify(error)}`);
      return false;
    }
  }
}

/**
 * 查看天气DeepLink处理器
 */
@InsightIntentLink({
  intentName: 'ViewWeather',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  uriPattern: 'smarttravel://weather/{cityName}',
  description: '查看城市天气预报'
})
export class WeatherIntentLink {
  static execute(context: IntentContext): boolean {
    try {
      hilog.info(DOMAIN, TAG, '[Link] 查看天气意图');
      
      const cityName = context.params?.['cityName'] as string || '当前位置';
      const days = context.params?.['days'] as number || 7;
      
      hilog.info(DOMAIN, TAG, `[Link] 城市: ${cityName}, 天数: ${days}`);
      
      // 存储天气参数
      AppStorage.setOrCreate('weatherCity', cityName);
      AppStorage.setOrCreate('weatherDays', days);
      
      const uri = `smarttravel://weather/${encodeURIComponent(cityName)}?days=${days}`;
      hilog.info(DOMAIN, TAG, `[Link] 天气URI: ${uri}`);
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 天气查询失败: ${JSON.stringify(error)}`);
      return false;
    }
  }
}
