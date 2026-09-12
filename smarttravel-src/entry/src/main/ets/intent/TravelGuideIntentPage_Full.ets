import { InsightIntentPage } from "@ohos.app.ability.InsightIntentDecorator";
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TravelGuideIntentPage';
const DOMAIN = 0x0000;

/**
 * 基于Page的意图装饰器完整示例（符合官方规范）
 * 使用HarmonyOS 6.0.0(20)+ 的完整装饰器字段
 * 
 * 包含字段：
 * - intentName: 意图名称
 * - domain: 功能垂域
 * - intentVersion: 版本号
 * - displayName: 展示名称
 * - llmDescription: LLM描述（便于AI理解）
 * - parameters: 参数定义（JSON Schema）
 * - uiAbility: UIAbility名称
 * - pagePath: Navigation组件所在页面路径
 * - navDestinationName: Navigation子页面名称
 */

/**
 * Builder函数 - 查看旅游攻略页面
 * 必须定义Builder函数以支持动态创建页面实例
 */
@Builder
export function TravelGuideDetailPageBuilder(pageName: string, param: object) {
  TravelGuideDetailPage({ param: param });
}

/**
 * 查看旅游攻略意图页面（完整规范版本）
 */
@InsightIntentPage({
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
  
  // 3. Navigation配置
  uiAbility: 'EntryAbility',                          // UIAbility名称（可省略，默认EntryAbility）
  pagePath: './ets/pages/MainPage',                   // Navigation组件所在页面路径
  navDestinationName: 'TravelGuideDetailPage',        // Navigation子页面名称
  
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
  }
})
@Entry
@Component
struct TravelGuideDetailPage {
  // 参数对象 - 必须定义，用于接收意图参数
  param: object = new Object();
  
  // 状态变量 - 从param中提取的参数
  @State guideId: string = '';
  @State cityName: string = '';
  @State category: string = '';
  @State keywords: string = '';
  
  // 页面数据
  @State guideTitle: string = '旅游攻略';
  @State guideContent: string = '';
  @State guideAuthor: string = '';
  @State viewCount: number = 0;
  
  /**
   * 页面即将显示时调用
   * 从param对象中提取意图参数
   */
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '[Page] 攻略详情页面加载');
    hilog.info(DOMAIN, TAG, `[Page] 接收参数: ${JSON.stringify(this.param)}`);
    
    // 从param中提取参数（使用可选链和默认值）
    this.guideId = this.param?.['guideId'] || '';
    this.cityName = this.param?.['cityName'] || '';
    this.category = this.param?.['category'] || '';
    this.keywords = this.param?.['keywords'] || '';
    
    hilog.info(DOMAIN, TAG, 
      `[Page] 解析参数 - ID: ${this.guideId}, 城市: ${this.cityName}, ` +
      `分类: ${this.category}, 关键词: ${this.keywords}`
    );
    
    // 参数验证
    if (!this.cityName && !this.guideId) {
      hilog.error(DOMAIN, TAG, '[Page] 缺少必需参数：cityName或guideId');
      this.showError('缺少必需参数');
      return;
    }
    
    // 根据参数加载攻略数据
    this.loadGuideData();
  }
  
  /**
   * 加载攻略数据
   */
  private loadGuideData(): void {
    // 根据城市名称加载相应攻略
    if (this.cityName === '深圳') {
      this.guideTitle = '深圳旅游攻略';
      this.guideContent = '深圳是一座现代化都市，拥有世界之窗、欢乐谷、东部华侨城等著名景点。' +
        '这里既有繁华的商业区，也有美丽的海滨风光。推荐景点包括深圳湾公园、莲花山公园等。';
      this.guideAuthor = '旅游达人小张';
      this.viewCount = 12580;
    } else if (this.cityName === '北京') {
      this.guideTitle = '北京旅游攻略';
      this.guideContent = '北京是中国的首都，拥有故宫、长城、天坛等世界文化遗产。' +
        '这里历史悠久，文化底蕴深厚。必游景点包括故宫博物院、八达岭长城、颐和园等。';
      this.guideAuthor = '北京通老王';
      this.viewCount = 35820;
    } else if (this.cityName === '上海') {
      this.guideTitle = '上海旅游攻略';
      this.guideContent = '上海是国际化大都市，拥有外滩、东方明珠、豫园等著名景点。' +
        '这里融合了东西方文化，既有现代摩天大楼，也有传统石库门建筑。';
      this.guideAuthor = '魔都小吃货';
      this.viewCount = 28960;
    } else {
      this.guideTitle = `${this.cityName}旅游攻略`;
      this.guideContent = `${this.cityName}的旅游信息正在加载中，请稍候...`;
      this.guideAuthor = '系统推荐';
      this.viewCount = 0;
    }
    
    // 如果有分类，添加到标题
    if (this.category) {
      this.guideTitle += ` - ${this.category}`;
    }
    
    hilog.info(DOMAIN, TAG, `[Page] 加载完成 - 标题: ${this.guideTitle}`);
  }
  
  /**
   * 显示错误信息
   */
  private showError(message: string): void {
    this.guideTitle = '加载失败';
    this.guideContent = message;
  }
  
  build() {
    NavDestination() {
      Column() {
        // 标题区域
        Column() {
          Text(this.guideTitle)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
          
          // 城市和分类信息
          Row({ space: 15 }) {
            if (this.cityName) {
              Row({ space: 5 }) {
                Text('📍')
                  .fontSize(16)
                Text(this.cityName)
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
            
            if (this.category) {
              Row({ space: 5 }) {
                Text('🏷️')
                  .fontSize(16)
                Text(this.category)
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
          }
          .margin({ bottom: 10 })
          
          // 作者和浏览量
          if (this.guideAuthor) {
            Row({ space: 20 }) {
              Text(`作者: ${this.guideAuthor}`)
                .fontSize(12)
                .fontColor('#999999')
              
              if (this.viewCount > 0) {
                Text(`浏览: ${this.viewCount}`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
            }
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(20)
        .backgroundColor(Color.White)
        
        Divider()
          .margin({ vertical: 10 })
        
        // 内容区域
        Scroll() {
          Column() {
            Text(this.guideContent)
              .fontSize(16)
              .lineHeight(28)
              .fontColor('#333333')
          }
          .width('100%')
          .padding(20)
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('攻略详情')
    .width('100%')
  }
}

/**
 * Builder函数 - 预订酒店页面
 */
@Builder
export function HotelBookingPageBuilder(pageName: string, param: object) {
  HotelBookingPage({ param: param });
}

/**
 * 预订酒店房间意图页面
 */
@InsightIntentPage({
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
  
  pagePath: './ets/pages/MainPage',
  navDestinationName: 'HotelBookingPage',
  
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
  }
})
@Entry
@Component
struct HotelBookingPage {
  param: object = new Object();
  
  @State city: string = '';
  @State hotel: string = '';
  @State checkIn: string = '';
  @State checkOut: string = '';
  @State roomType: string = '标准间';
  @State guests: number = 1;
  @State totalPrice: number = 0;
  
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '[Page] 酒店预订页面加载');
    
    // 提取参数
    this.city = this.param?.['city'] || '';
    this.hotel = this.param?.['hotel'] || '';
    this.checkIn = this.param?.['checkIn'] || '';
    this.checkOut = this.param?.['checkOut'] || '';
    this.roomType = this.param?.['roomType'] || '标准间';
    this.guests = this.param?.['guests'] || 1;
    
    hilog.info(DOMAIN, TAG, 
      `[Page] 预订信息 - 城市: ${this.city}, 酒店: ${this.hotel}, ` +
      `入住: ${this.checkIn}, 退房: ${this.checkOut}`
    );
    
    // 参数验证
    if (!this.city || !this.hotel || !this.checkIn || !this.checkOut) {
      hilog.error(DOMAIN, TAG, '[Page] 缺少必需参数');
      return;
    }
    
    // 验证日期
    if (!this.validateDates()) {
      hilog.error(DOMAIN, TAG, '[Page] 日期验证失败');
      return;
    }
    
    // 计算价格
    this.calculatePrice();
  }
  
  /**
   * 验证日期有效性
   */
  private validateDates(): boolean {
    try {
      const inDate = new Date(this.checkIn);
      const outDate = new Date(this.checkOut);
      const today = new Date();
      
      if (isNaN(inDate.getTime()) || isNaN(outDate.getTime())) {
        return false;
      }
      
      if (inDate < today) {
        return false;
      }
      
      if (outDate <= inDate) {
        return false;
      }
      
      return true;
    } catch (error) {
      return false;
    }
  }
  
  /**
   * 计算总价
   */
  private calculatePrice(): void {
    const nights = this.calculateNights();
    const pricePerNight = this.roomType === '套房' ? 800 : 
                          this.roomType === '大床房' ? 500 : 350;
    this.totalPrice = nights * pricePerNight;
  }
  
  /**
   * 计算住宿天数
   */
  private calculateNights(): number {
    const inDate = new Date(this.checkIn);
    const outDate = new Date(this.checkOut);
    const diffTime = outDate.getTime() - inDate.getTime();
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
  
  build() {
    NavDestination() {
      Column({ space: 0 }) {
        // 酒店信息卡片
        Column({ space: 10 }) {
          Text(this.hotel)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          
          Row({ space: 5 }) {
            Text('📍')
              .fontSize(16)
            Text(this.city)
              .fontSize(16)
              .fontColor('#666666')
          }
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
        
        Divider().height(8).color('#F5F5F5')
        
        // 预订信息
        Column({ space: 15 }) {
          this.InfoRow('入住日期', this.checkIn)
          this.InfoRow('退房日期', this.checkOut)
          this.InfoRow('住宿天数', `${this.calculateNights()}晚`)
          this.InfoRow('房型', this.roomType)
          this.InfoRow('入住人数', `${this.guests}人`)
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
        
        Divider().height(8).color('#F5F5F5')
        
        // 价格信息
        Column({ space: 10 }) {
          Row() {
            Text('总价')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(`¥${this.totalPrice}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B6B')
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        
        Spacer()
        
        // 预订按钮
        Button('确认预订')
          .width('90%')
          .height(50)
          .fontSize(18)
          .backgroundColor('#FF6B6B')
          .margin({ bottom: 20 })
          .onClick(() => {
            hilog.info(DOMAIN, TAG, '[Page] 确认预订');
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('预订酒店')
  }
  
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#666666')
      Blank()
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
  }
}

/**
 * Builder函数 - 搜索目的地页面
 */
@Builder
export function SearchDestinationsPageBuilder(pageName: string, param: object) {
  SearchDestinationsPage({ param: param });
}

/**
 * 搜索旅游目的地意图页面
 */
@InsightIntentPage({
  intentName: 'SearchDestinations',
  domain: 'TravelDomain',
  intentVersion: '1.0.0',
  displayName: '搜索旅游目的地',
  
  llmDescription: '用于搜索旅游目的地，允许用户根据关键词、分类或特点查找合适的旅游地点。' +
    '在用户表达搜索意图时使用，如"找海岛旅游"、"搜索古镇"、"查找适合亲子游的地方"、"寻找山岳景点"等。' +
    '如果用户只是询问某个具体景点的信息、门票价格或开放时间，应使用查看景点详情功能。' +
    '如果用户想要查看已保存的收藏或历史记录，不应调用此工具。' +
    '必需参数：搜索关键词（keyword）。',
  
  pagePath: './ets/pages/MainPage',
  navDestinationName: 'SearchDestinationsPage',
  
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
      }
    },
    "required": ["keyword"]
  }
})
@Entry
@Component
struct SearchDestinationsPage {
  param: object = new Object();
  
  @State keyword: string = '';
  @State category: string = '';
  @State budget: string = '';
  @State duration: number = 0;
  @State searchResults: Array<{name: string, tag: string, price: string}> = [];
  
  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '[Page] 搜索页面加载');
    
    this.keyword = this.param?.['keyword'] || '';
    this.category = this.param?.['category'] || '';
    this.budget = this.param?.['budget'] || '';
    this.duration = this.param?.['duration'] || 0;
    
    hilog.info(DOMAIN, TAG, 
      `[Page] 搜索条件 - 关键词: ${this.keyword}, 分类: ${this.category}, ` +
      `预算: ${this.budget}, 天数: ${this.duration}`
    );
    
    if (!this.keyword) {
      hilog.error(DOMAIN, TAG, '[Page] 缺少搜索关键词');
      return;
    }
    
    this.performSearch();
  }
  
  /**
   * 执行搜索
   */
  private performSearch(): void {
    // 根据关键词返回模拟结果
    if (this.keyword.includes('海岛')) {
      this.searchResults = [
        { name: '三亚', tag: '热带海岛', price: '¥3000起' },
        { name: '马尔代夫', tag: '海岛天堂', price: '¥15000起' },
        { name: '普吉岛', tag: '东南亚海岛', price: '¥4000起' },
        { name: '巴厘岛', tag: '度假胜地', price: '¥5000起' }
      ];
    } else if (this.keyword.includes('古镇')) {
      this.searchResults = [
        { name: '乌镇', tag: '江南水乡', price: '¥1200起' },
        { name: '周庄', tag: '中国第一水乡', price: '¥1000起' },
        { name: '西塘', tag: '生活着的千年古镇', price: '¥800起' },
        { name: '同里', tag: '东方威尼斯', price: '¥900起' }
      ];
    } else {
      this.searchResults = [
        { name: `${this.keyword}推荐地1`, tag: '热门景点', price: '¥2000起' },
        { name: `${this.keyword}推荐地2`, tag: '特色体验', price: '¥2500起' },
        { name: `${this.keyword}推荐地3`, tag: '经典路线', price: '¥1800起' }
      ];
    }
    
    hilog.info(DOMAIN, TAG, `[Page] 搜索完成，找到${this.searchResults.length}个结果`);
  }
  
  build() {
    NavDestination() {
      Column({ space: 0 }) {
        // 搜索条件展示
        Column({ space: 10 }) {
          Text(`搜索: ${this.keyword}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          
          Row({ space: 10 }) {
            if (this.category) {
              Text(this.category)
                .fontSize(14)
                .fontColor('#666666')
                .padding({ horizontal: 10, vertical: 5 })
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
            }
            
            if (this.budget) {
              Text(this.budget)
                .fontSize(14)
                .fontColor('#666666')
                .padding({ horizontal: 10, vertical: 5 })
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
            }
            
            if (this.duration > 0) {
              Text(`${this.duration}天`)
                .fontSize(14)
                .fontColor('#666666')
                .padding({ horizontal: 10, vertical: 5 })
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
            }
          }
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
        
        Divider().height(8).color('#F5F5F5')
        
        // 搜索结果
        Text(`找到 ${this.searchResults.length} 个结果`)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 20, top: 15, bottom: 10 })
        
        List({ space: 10 }) {
          ForEach(this.searchResults, (item: {name: string, tag: string, price: string}) => {
            ListItem() {
              Row() {
                Column({ space: 5 }) {
                  Text(item.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  
                  Text(item.tag)
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                
                Blank()
                
                Text(item.price)
                  .fontSize(16)
                  .fontColor('#FF6B6B')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding(15)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
            .margin({ horizontal: 15 })
          })
        }
        .layoutWeight(1)
        .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('搜索结果')
  }
}
