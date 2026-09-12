import { InsightIntentLink, LinkParamCategory } from "@ohos.app.ability.InsightIntentDecorator";
import { url } from "@kit.ArkTS";
import { hilog } from '@kit.PerformanceAnalysisKit';
import router from '@ohos.router';

const TAG = 'MovieTickets';
const DOMAIN = 0x0000;

/**
 * 购买电影票意图实现
 * 
 * 功能说明：
 * - 通过DeepLink方式拉起电影票购买页面
 * - 支持指定影院、电影名称和放映时间
 * - 符合官方命名和参数定义规范
 * 
 * 使用示例：
 * 用户对小艺说："小艺，帮我买万达影城的流浪地球2电影票，今晚7点半的场次"
 * 
 * 触发URI：
 * decorator://ability.entry/main?location=万达影城&title=流浪地球2&time=2025-11-27 19:30
 */
@InsightIntentLink({
  // 意图名称：动词+名词，大驼峰命名
  intentName: 'PurchaseMovieTickets',
  
  // 功能垂域：票务购买
  domain: 'PurchaseTickets',
  
  // 版本号：语义化版本
  intentVersion: '1.0.1',
  
  // 展示名称：用户可见的名称
  displayName: '购买电影票',
  
  // LLM描述：详细说明意图用途、触发条件和边界
  llmDescription: '用于在线购买电影票，允许用户选择指定影院、电影和场次时间进行购票。' +
    '在用户明确表达购票需求，且已提供所有必要信息（cinema, film, time）时使用。' +
    '例如："帮我买万达影城的流浪地球2电影票"、"订一张今晚7点半的阿凡达票"等。' +
    '如果信息不全或者用户只是查询电影信息、放映时间或票价，不应调用此工具。' +
    '如果用户需要退票或改签，不应调用此工具。' +
    '必需参数：影院名称（cinema）、电影名称（film）、放映时间（time）。',
  
  // DeepLink URI
  uri: 'decorator://ability.entry/main',
  
  // 参数定义：符合JSON Schema规范
  parameters: {
    "type": "object",
    "properties": {
      "cinema": {
        "type": "string",
        "description": "目标影院名称，仅支持平台合作的影院，如'万达影城'、'大地影院'、'CGV影城'等"
      },
      "film": {
        "type": "string",
        "description": "目标电影名称，需为当前上映或即将上映且在影院排片列表中的电影"
      },
      "time": {
        "type": "string",
        "description": "放映时间，必须为未来的场次，且需为影院当天有效排片时间；时间格式应为'YYYY-MM-DD HH:MM'（例如'2025-07-01 19:30'）"
      },
      "seats": {
        "type": "number",
        "description": "购票数量，取值范围1-10，默认为1"
      },
      "hallType": {
        "type": "string",
        "description": "影厅类型，如'IMAX'、'杜比全景声'、'4DX'、'普通厅'等"
      }
    },
    "required": ["cinema", "film", "time"]
  },
  
  // 参数映射：定义意图参数如何映射到URI参数
  paramMappings: [
    {
      paramName: 'cinema',              // 意图参数名
      paramMappingName: 'location',     // URI参数名
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'film',
      paramMappingName: 'title',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'time',
      paramMappingName: 'time',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'seats',
      paramMappingName: 'count',
      paramCategory: LinkParamCategory.LINK
    },
    {
      paramName: 'hallType',
      paramMappingName: 'hall',
      paramCategory: LinkParamCategory.LINK
    }
  ]
})
export class PurchaseMovieTicketsLinkIntent {
  
  /**
   * 处理购买电影票的DeepLink
   * @param uri 传入的DeepLink URI
   * 格式示例：decorator://ability.entry/main?location=万达影城&title=流浪地球2&time=2025-11-27 19:30&count=2&hall=IMAX
   */
  private purchaseMovieTickets(uri: string): void {
    try {
      hilog.info(DOMAIN, TAG, `[Link] 接收购票请求: ${uri}`);
      
      // 解析URI参数
      let urlObject = url.URL.parseURL(uri);
      let location = urlObject.params.get('location');
      let title = urlObject.params.get('title');
      let time = urlObject.params.get('time');
      let count = urlObject.params.get('count') || '1';
      let hall = urlObject.params.get('hall') || '普通厅';
      
      hilog.info(DOMAIN, TAG, 
        `[Link] 解析参数 - 影院: ${location}, 电影: ${title}, ` +
        `时间: ${time}, 数量: ${count}, 影厅: ${hall}`
      );
      
      // 参数验证
      if (!this.validateParams(location, title, time)) {
        return;
      }
      
      // 验证影院是否在合作范围内
      if (!this.validateCinema(location)) {
        hilog.warn(DOMAIN, TAG, `[Link] 影院不在合作范围: ${location}`);
        return;
      }
      
      // 验证时间格式和有效性
      if (!this.validateTime(time)) {
        hilog.error(DOMAIN, TAG, `[Link] 时间格式或有效性验证失败: ${time}`);
        return;
      }
      
      // 验证票数
      const seatCount = parseInt(count);
      if (isNaN(seatCount) || seatCount < 1 || seatCount > 10) {
        hilog.warn(DOMAIN, TAG, `[Link] 票数无效: ${count}，使用默认值1`);
        count = '1';
      }
      
      // 存储参数到AppStorage，供购票页面使用
      AppStorage.setOrCreate('movieCinema', location);
      AppStorage.setOrCreate('movieTitle', title);
      AppStorage.setOrCreate('movieTime', time);
      AppStorage.setOrCreate('movieSeats', count);
      AppStorage.setOrCreate('movieHall', hall);
      
      hilog.info(DOMAIN, TAG, '[Link] 参数已存储到AppStorage');
      
      // 跳转到购票页面
      // 注意：实际项目中需要创建对应的页面
      // router.pushUrl({
      //   url: 'pages/movie/PurchasePage'
      // });
      
      hilog.info(DOMAIN, TAG, '[Link] 准备跳转到购票页面');
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 处理购票请求失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 验证必需参数
   */
  private validateParams(location: string | null, title: string | null, time: string | null): boolean {
    if (!location || !title || !time) {
      hilog.error(DOMAIN, TAG, '[Link] 缺少必需参数');
      hilog.error(DOMAIN, TAG, `location: ${location}, title: ${title}, time: ${time}`);
      return false;
    }
    return true;
  }
  
  /**
   * 验证影院是否在合作范围内
   */
  private validateCinema(location: string): boolean {
    // 合作影院列表（实际项目中应从服务器获取）
    const supportedCinemas = [
      '万达影城',
      '大地影院',
      'CGV影城',
      '金逸影城',
      '博纳国际影城',
      '横店影城',
      'UME国际影城'
    ];
    
    // 检查是否包含合作影院名称
    for (const cinema of supportedCinemas) {
      if (location.includes(cinema)) {
        hilog.info(DOMAIN, TAG, `[Link] 影院验证通过: ${location}`);
        return true;
      }
    }
    
    return false;
  }
  
  /**
   * 验证时间格式和有效性
   * 格式：YYYY-MM-DD HH:MM
   * 要求：必须是未来时间
   */
  private validateTime(time: string): boolean {
    try {
      // 验证格式：YYYY-MM-DD HH:MM
      const timeRegex = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/;
      if (!timeRegex.test(time)) {
        hilog.error(DOMAIN, TAG, `[Link] 时间格式错误: ${time}，应为 YYYY-MM-DD HH:MM`);
        return false;
      }
      
      // 解析时间
      const [datePart, timePart] = time.split(' ');
      const [year, month, day] = datePart.split('-').map(Number);
      const [hour, minute] = timePart.split(':').map(Number);
      
      const showTime = new Date(year, month - 1, day, hour, minute);
      const now = new Date();
      
      // 验证是否为未来时间
      if (showTime <= now) {
        hilog.error(DOMAIN, TAG, `[Link] 放映时间必须是未来时间: ${time}`);
        return false;
      }
      
      hilog.info(DOMAIN, TAG, `[Link] 时间验证通过: ${time}`);
      return true;
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[Link] 时间验证异常: ${JSON.stringify(error)}`);
      return false;
    }
  }
}

/**
 * 支持的影院列表常量
 */
export const SUPPORTED_CINEMAS = [
  '万达影城',
  '大地影院',
  'CGV影城',
  '金逸影城',
  '博纳国际影城',
  '横店影城',
  'UME国际影城'
];

/**
 * 支持的影厅类型
 */
export const HALL_TYPES = [
  'IMAX',
  '杜比全景声',
  '4DX',
  'ScreenX',
  'DTS:X',
  '普通厅'
];

/**
 * 时间格式说明
 */
export const TIME_FORMAT = 'YYYY-MM-DD HH:MM';
export const TIME_FORMAT_EXAMPLE = '2025-11-27 19:30';
