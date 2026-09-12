import { InsightIntentLink, LinkParamCategory } from "@ohos.app.ability.InsightIntentDecorator";
import { url } from "@kit.ArkTS";
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TravelGuideIntentLink';
const DOMAIN = 0x0000;

/**
 * 基于Link的意图装饰器完整示例（符合官方规范）
 * 使用HarmonyOS 6.0.0(20)+ 的完整装饰器字段
 * 
 * 包含字段：
 * - intentName: 意图名称
 * - domain: 功能垂域
 * - intentVersion: 版本号
 * - displayName: 展示名称
 * - llmDescription: LLM描述（便于AI理解）
 * - uri: Link跳转URI
 * - parameters: 参数定义（JSON Schema）
 * - paramMappings: 参数映射关系
 * - result: 返回结果定义
 */

/**
 * 旅游攻略DeepLink处理器（完整规范版本）
 */
@InsightIntentLink({
  // 1. 基本信息
  intentName: 'ViewTravelGuides',
  domain: 'TravelDomain',
  intentVersion: '1.0.1',
  displayName: '查看旅游攻略',
  
  // 2. LLM描述（帮助AI理解何时调用）
  llmDescription: '用于查看和浏览旅游攻略详情，允许用户查看特定城市或景点的旅游攻略信息。' +
    '在用户明确表达想要查看攻略需求时使用，例如"查看深圳旅游攻略"、"帮我看看北京的攻略"、"打开广州旅游指南"等。' +
    '如果用户只是询问攻略是否存在、攻略数量、攻略作者或攻略评分，不应调用此工具。' +
    '如果用户需要编辑或创建攻略，不应调用此工具。' +
    '必需参数：城市名称（cityName）或攻略ID（guideId）至少提供其一。',
  
  // 3. Link URI模式
  uri: 'smarttravel://guide/detail',
  
  // 4. 参数定义（JSON Schema规范）
  parameters: {
    "type": "object",
    "properties": {
      "guideId": {
        "type": "string",
        "description": "攻略唯一标识符，用于精确定位特定攻略"
      },
      "cityName": {
        "type": "string",
        "description": "目标城市名称，如'深圳'、'北京'、'上海'、'广州'等国内主要城市"
      },
      "category": {
        "type": "string",
        "description": "攻略分类，支持的类型包括：美食、景点、住宿、交通、购物",
        "enum": ["美食", "景点", "住宿", "交通", "购物"]
      },
      "keywords": {
        "type": "string",
        "description": "搜索关键词，用于在攻略中查找特定内容"
      }
    },
    "required": ["cityName"]
  },
  
  // 5. 参数映射（意图参数 → Link URI参数）
  paramMappings: [
    {
      paramName: 'guideId',
      paramMappingName: 'id',              // guideId → id
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'cityName',
      paramMappingName: 'city',            // cityName → city
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'category',
      paramMappingName: 'type',            // category → type
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'keywords',
      paramMappingName: 'q',               // keywords → q
      paramCategory: LinkParamCategory.LINK
    }
  ],
  
  // 6. 返回结果定义
  result: {
    "type": "object",
    "properties": {
      "success": {
        "type": "boolean",
        "description": "是否成功打开攻略页面"
      },
      "guideName": {
        "type": "string",
        "description": "攻略标题名称"
      },
      "guideId": {
        "type": "string",
        "description": "攻略ID"
      }
    }
  }
})
export class ViewTravelGuidesLinkIntent {
  /**
   * 处理查看攻略的Link跳转
   * @param uri 完整的Link URI
   * 例如: smarttravel://guide/detail?id=123&city=深圳&type=美食
   */
  private viewTravelGuide(uri: string): void {
    try {
      hilog.info(DOMAIN, TAG, `[Link] 接收到URI: ${uri}`);
      
      // 使用url模块解析URI
      let urlObject = url.URL.parseURL(uri);
      
      // 从URI中提取参数（已通过paramMappings映射）
      let guideId = urlObject.params.get('id');           // 对应guideId
      let cityName = urlObject.params.get('city');        // 对应cityName
      let category = urlObject.params.get('type');        // 对应category
      let keywords = urlObject.params.get('q');           // 对应keywords
      
      hilog.info(DOMAIN, TAG, `[Link] 解析参数 - ID: ${guideId}, 城市: ${cityName}, 分类: ${category}, 关键词: ${keywords}`);
      
      // 根据参数处理业务逻辑
      if (cityName === "深圳") {
        hilog.info(DOMAIN, TAG, '[Link] 加载深圳旅游攻略');
        this.loadShenzhenGuide(guideId, category);
      } else if (cityName === "北京") {
        hilog.info(DOMAIN, TAG, '[Link] 加载北京旅游攻略');
        this.loadBeijingGuide(guideId, category);
      } else if (cityName === "上海") {
        hilog.info(DOMAIN, TAG, '[Link] 加载上海旅游攻略');
        this.loadShanghaiGuide(guideId, category);
      } else {
        hilog.info(DOMAIN, TAG, `[Link] 加载${cityName}旅游攻略`);
        this.loadGeneralGuide(guideId, cityName, category);
      }
      
      // 存储参数到AppStorage供页面使用
      if (guideId) {
        AppStorage.setOrCreate('linkGuideId', guideId);
      }
      if (cityName) {
        AppStorage.setOrCreate('linkCityName', cityName);
      }
      if (category) {
        AppStorage.setOrCreate('linkCategory', category);
      }
      if (keywords) {
        AppStorage.setOrCreate('linkKeywords', keywords);
      }
      
      hilog.info(DOMAIN, TAG, '[Link] 参数已存储到AppStorage');
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 解析URI失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 加载深圳攻略
   */
  private loadShenzhenGuide(guideId: string | null, category: string | null): void {
    hilog.info(DOMAIN, TAG, `加载深圳攻略: ID=${guideId}, 分类=${category}`);
    // 实际的页面跳转逻辑
  }
  
  /**
   * 加载北京攻略
   */
  private loadBeijingGuide(guideId: string | null, category: string | null): void {
    hilog.info(DOMAIN, TAG, `加载北京攻略: ID=${guideId}, 分类=${category}`);
    // 实际的页面跳转逻辑
  }
  
  /**
   * 加载上海攻略
   */
  private loadShanghaiGuide(guideId: string | null, category: string | null): void {
    hilog.info(DOMAIN, TAG, `加载上海攻略: ID=${guideId}, 分类=${category}`);
    // 实际的页面跳转逻辑
  }
  
  /**
   * 加载通用攻略
   */
  private loadGeneralGuide(guideId: string | null, cityName: string, category: string | null): void {
    hilog.info(DOMAIN, TAG, `加载${cityName}攻略: ID=${guideId}, 分类=${category}`);
    // 实际的页面跳转逻辑
  }
}

/**
 * 预订酒店房间DeepLink处理器
 */
@InsightIntentLink({
  intentName: 'BookHotelRoom',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  displayName: '预订酒店房间',
  
  llmDescription: '用于在线预订酒店房间，允许用户选择指定城市、酒店、入住日期和房型进行预订。' +
    '在用户明确表达预订需求，且已提供所有必要信息（city, hotel, checkIn, checkOut）时使用。' +
    '例如"预订深圳希尔顿酒店明天的房间"、"帮我订一个北京的酒店，12月1号入住"等。' +
    '如果信息不全或用户只是查询酒店信息、价格或房间类型，不应调用此工具。' +
    '如果用户需要取消或修改订单，不应调用此工具。' +
    '必需参数：城市（city）、酒店名称（hotel）、入住日期（checkIn）、退房日期（checkOut）。',
  
  uri: 'smarttravel://hotel/booking',
  
  parameters: {
    "type": "object",
    "properties": {
      "city": {
        "type": "string",
        "description": "酒店所在城市名称"
      },
      "hotel": {
        "type": "string",
        "description": "酒店名称，需为平台合作的酒店"
      },
      "checkIn": {
        "type": "string",
        "description": "入住日期，格式为'YYYY-MM-DD'，例如'2025-11-27'，必须为未来日期"
      },
      "checkOut": {
        "type": "string",
        "description": "退房日期，格式为'YYYY-MM-DD'，必须晚于入住日期"
      },
      "roomType": {
        "type": "string",
        "description": "房型类型，如'标准间'、'大床房'、'套房'、'豪华房'等"
      },
      "guests": {
        "type": "number",
        "description": "入住人数，取值范围1-4，默认为1"
      }
    },
    "required": ["city", "hotel", "checkIn", "checkOut"]
  },
  
  paramMappings: [
    {
      paramName: 'city',
      paramMappingName: 'location',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'hotel',
      paramMappingName: 'hotelName',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'checkIn',
      paramMappingName: 'startDate',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'checkOut',
      paramMappingName: 'endDate',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'roomType',
      paramMappingName: 'type',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'guests',
      paramMappingName: 'people',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'source',
      paramMappingName: 'launchSource',
      paramCategory: LinkParamCategory.WANT      // 作为Want参数
    }
  ],
  
  result: {
    "type": "object",
    "properties": {
      "success": {
        "type": "boolean",
        "description": "是否成功进入预订页面"
      },
      "orderId": {
        "type": "string",
        "description": "预订单号（如果立即生成）"
      }
    }
  }
})
export class BookHotelRoomLinkIntent {
  private bookHotel(uri: string): void {
    try {
      hilog.info(DOMAIN, TAG, `[Link] 预订酒店URI: ${uri}`);
      
      let urlObject = url.URL.parseURL(uri);
      let city = urlObject.params.get('location');
      let hotelName = urlObject.params.get('hotelName');
      let startDate = urlObject.params.get('startDate');
      let endDate = urlObject.params.get('endDate');
      let roomType = urlObject.params.get('type');
      let people = urlObject.params.get('people');
      
      hilog.info(DOMAIN, TAG, 
        `[Link] 预订信息 - 城市: ${city}, 酒店: ${hotelName}, ` +
        `入住: ${startDate}, 退房: ${endDate}, 房型: ${roomType}, 人数: ${people}`
      );
      
      // 验证日期
      if (!this.validateDates(startDate, endDate)) {
        hilog.error(DOMAIN, TAG, '[Link] 日期验证失败');
        return;
      }
      
      // 存储预订信息
      AppStorage.setOrCreate('bookingCity', city);
      AppStorage.setOrCreate('bookingHotel', hotelName);
      AppStorage.setOrCreate('bookingCheckIn', startDate);
      AppStorage.setOrCreate('bookingCheckOut', endDate);
      AppStorage.setOrCreate('bookingRoomType', roomType);
      AppStorage.setOrCreate('bookingGuests', people);
      
      hilog.info(DOMAIN, TAG, '[Link] 进入酒店预订页面');
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 预订失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 验证日期有效性
   */
  private validateDates(checkIn: string | null, checkOut: string | null): boolean {
    if (!checkIn || !checkOut) {
      return false;
    }
    
    try {
      const inDate = new Date(checkIn);
      const outDate = new Date(checkOut);
      const today = new Date();
      
      // 检查日期格式
      if (isNaN(inDate.getTime()) || isNaN(outDate.getTime())) {
        return false;
      }
      
      // 检查入住日期不早于今天
      if (inDate < today) {
        return false;
      }
      
      // 检查退房日期晚于入住日期
      if (outDate <= inDate) {
        return false;
      }
      
      return true;
    } catch (error) {
      return false;
    }
  }
}

/**
 * 搜索旅游目的地DeepLink处理器
 */
@InsightIntentLink({
  intentName: 'SearchDestinations',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  displayName: '搜索旅游目的地',
  
  llmDescription: '用于搜索旅游目的地，允许用户根据关键词、分类或特点查找合适的旅游地点。' +
    '在用户表达搜索意图时使用，例如"找海岛旅游"、"搜索古镇"、"查找适合亲子游的地方"、"寻找山岳景点"等。' +
    '如果用户只是询问某个具体景点的信息、门票价格或开放时间，应使用查看景点详情功能。' +
    '如果用户想要查看已保存的收藏或历史记录，不应调用此工具。' +
    '必需参数：搜索关键词（keyword）。',
  
  uri: 'smarttravel://search/destination',
  
  parameters: {
    "type": "object",
    "properties": {
      "keyword": {
        "type": "string",
        "description": "搜索关键词，如'海岛'、'古镇'、'草原'、'雪山'等"
      },
      "category": {
        "type": "string",
        "description": "目的地分类类型",
        "enum": ["自然风光", "人文历史", "休闲度假", "探险刺激", "亲子游", "蜜月游"]
      },
      "budget": {
        "type": "string",
        "description": "预算范围级别",
        "enum": ["经济型", "舒适型", "豪华型"]
      },
      "duration": {
        "type": "number",
        "description": "计划旅行天数，如3、5、7、10、15等"
      },
      "season": {
        "type": "string",
        "description": "适合季节",
        "enum": ["春季", "夏季", "秋季", "冬季", "全年"]
      }
    },
    "required": ["keyword"]
  },
  
  paramMappings: [
    {
      paramName: 'keyword',
      paramMappingName: 'q',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'category',
      paramMappingName: 'cat',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'budget',
      paramMappingName: 'price',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'duration',
      paramMappingName: 'days',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'season',
      paramMappingName: 'time',
      paramCategory: LinkParamCategory.LINK
    }
  ],
  
  result: {
    "type": "object",
    "properties": {
      "success": {
        "type": "boolean",
        "description": "是否成功执行搜索"
      },
      "resultCount": {
        "type": "number",
        "description": "搜索结果数量"
      }
    }
  }
})
export class SearchDestinationsLinkIntent {
  private searchDestination(uri: string): void {
    try {
      hilog.info(DOMAIN, TAG, `[Link] 搜索URI: ${uri}`);
      
      let urlObject = url.URL.parseURL(uri);
      let keyword = urlObject.params.get('q');
      let category = urlObject.params.get('cat');
      let budget = urlObject.params.get('price');
      let days = urlObject.params.get('days');
      let season = urlObject.params.get('time');
      
      hilog.info(DOMAIN, TAG, 
        `[Link] 搜索条件 - 关键词: ${keyword}, 分类: ${category}, ` +
        `预算: ${budget}, 天数: ${days}, 季节: ${season}`
      );
      
      // 存储搜索参数
      AppStorage.setOrCreate('searchKeyword', keyword);
      AppStorage.setOrCreate('searchCategory', category);
      AppStorage.setOrCreate('searchBudget', budget);
      AppStorage.setOrCreate('searchDuration', days);
      AppStorage.setOrCreate('searchSeason', season);
      
      hilog.info(DOMAIN, TAG, '[Link] 进入搜索结果页面');
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 搜索失败: ${JSON.stringify(error)}`);
    }
  }
}
