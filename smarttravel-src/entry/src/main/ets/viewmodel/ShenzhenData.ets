/**
 * 深圳市旅游数据
 * 包含景点、酒店、美食、交通等真实信息
 */

// 深圳热门景点数据
export interface AttractionData {
  id: string;
  name: string;
  subtitle: string;
  description: string;
  image: string;
  category: string;
  rating: number;
  location: string;
  price: string;
  openTime: string;
  features: string[];
  hasAudio?: boolean;  // 是否有语音讲解
  audioDuration?: string;  // 语音讲解时长
}

// 深圳热门景点
export const shenzhenAttractions: AttractionData[] = [
  {
    id: 'sz001',
    name: '世界之窗',
    subtitle: '一日游遍全球',
    description: '世界之窗是中国著名的缩微景区，以弘扬世界文化为宗旨，是一个把世界奇观、历史遗迹、古今名胜、民间歌舞表演融为一体的人造主题公园。',
    image: 'https://picsum.photos/seed/attraction_shijizhichuang/800/600',
    category: '主题乐园',
    rating: 4.6,
    location: '深圳市南山区深南大道9037号',
    price: '￥200起',
    openTime: '09:00-22:30',
    features: ['亲子游', '拍照打卡', '表演秀'],
    hasAudio: true,
    audioDuration: '05:30'
  },
  {
    id: 'sz002',
    name: '欢乐谷',
    subtitle: '刺激游乐天堂',
    description: '深圳欢乐谷是华侨城集团新一代大型主题乐园，首批国家AAAAA级旅游景区，是一座融参与性、观赏性、娱乐性、趣味性于一体的中国现代主题乐园。',
    image: 'https://picsum.photos/seed/attraction_huanlegu/800/600',
    category: '主题乐园',
    rating: 4.7,
    location: '深圳市南山区侨城西街1号',
    price: '￥230起',
    openTime: '10:00-22:00',
    features: ['过山车', '亲子游', '刺激项目'],
    hasAudio: true,
    audioDuration: '06:15'
  },
  {
    id: 'sz003',
    name: '深圳湾公园',
    subtitle: '海滨漫步胜地',
    description: '深圳湾公园是深圳市最长的海滨休闲带，毗邻深圳湾体育中心，可以欣赏到深圳湾大桥和香港青山的美景。',
    image: 'https://picsum.photos/seed/attraction_shenzhenwan/800/600',
    category: '自然风光',
    rating: 4.8,
    location: '深圳市南山区滨海大道',
    price: '免费',
    openTime: '全天开放',
    features: ['海滨步道', '骑行', '观景', '免费'],
    hasAudio: true,
    audioDuration: '04:20'
  },
  {
    id: 'sz004',
    name: '东部华侨城',
    subtitle: '生态旅游度假区',
    description: '东部华侨城是集休闲度假、观光旅游、户外运动、科普教育等主题于一体的大型综合性国家生态旅游示范区。',
    image: 'https://picsum.photos/seed/attraction_dongbuhuaqiaocheng/800/600',
    category: '度假区',
    rating: 4.7,
    location: '深圳市盐田区大梅沙东部华侨城',
    price: '￥180起',
    openTime: '09:30-17:30',
    features: ['茶溪谷', '云海谷', '度假酒店'],
    hasAudio: true,
    audioDuration: '07:45'
  },
  {
    id: 'sz005',
    name: '大梅沙海滨公园',
    subtitle: '免费海滨浴场',
    description: '大梅沙海滨公园是深圳市民最喜爱的海滨度假区之一，拥有深圳最长的海滩，是游泳、沙滩运动的理想场所。',
    image: 'https://picsum.photos/seed/attraction_dameisha/800/600',
    category: '海滨浴场',
    rating: 4.5,
    location: '深圳市盐田区大梅沙盐梅路9号',
    price: '免费',
    openTime: '07:00-23:00',
    features: ['沙滩', '游泳', '水上运动', '免费']
  },
  {
    id: 'sz006',
    name: '莲花山公园',
    subtitle: '城市绿肺',
    description: '莲花山公园位于深圳市中心区，是深圳市内最大的公园之一，山顶广场有邓小平铜像。',
    image: 'https://picsum.photos/seed/attraction_lianhuashan/800/600',
    category: '城市公园',
    rating: 4.6,
    location: '深圳市福田区红荔路6030号',
    price: '免费',
    openTime: '06:00-22:00',
    features: ['登山', '广场', '纪念地标', '免费']
  },
  {
    id: 'sz007',
    name: '华强北商圈',
    subtitle: '中国电子第一街',
    description: '华强北是中国最大的电子产品集散地，被誉为"中国电子第一街"，也是深圳最繁华的商业街区之一。',
    image: 'https://picsum.photos/seed/attraction_huaqiangbei/800/600',
    category: '商业街区',
    rating: 4.4,
    location: '深圳市福田区华强北路',
    price: '免费',
    openTime: '10:00-22:00',
    features: ['电子产品', '购物', '美食']
  },
  {
    id: 'sz008',
    name: 'OCT创意文化园',
    subtitle: '艺术创意园区',
    description: 'OCT创意文化园是由旧厂房改造而成的创意产业园区，汇集了设计、音乐、摄影等创意元素。',
    image: 'https://picsum.photos/seed/attraction_oct/800/600',
    category: '文化创意',
    rating: 4.5,
    location: '深圳市南山区锦绣北街2号',
    price: '免费',
    openTime: '10:00-22:00',
    features: ['艺术展览', '创意市集', '咖啡厅']
  }
];

// 深圳酒店数据
export interface HotelData {
  id: string;
  name: string;
  subtitle: string;
  image: string;
  rating: number;
  location: string;
  price: string;
  category: string;
  features: string[];
  canReview?: boolean;  // 是否可以评价
  hasOrder?: boolean;  // 是否有订单
}

export const shenzhenHotels: HotelData[] = [
  {
    id: 'hotel001',
    name: '深圳威尼斯睿途酒店',
    subtitle: '欢乐谷旁豪华酒店',
    image: 'https://picsum.photos/seed/hotel_weinisi/800/600',
    rating: 4.7,
    location: '南山区侨城东路',
    price: '￥688起',
    category: '五星级',
    features: ['近欢乐谷', '温泉', '亲子'],
    canReview: true,
    hasOrder: true
  },
  {
    id: 'hotel002',
    name: '深圳瑞吉酒店',
    subtitle: '奢华海景酒店',
    image: 'https://picsum.photos/seed/hotel_ruiji/800/600',
    rating: 4.9,
    location: '福田区深南大道5016号',
    price: '￥1580起',
    category: '五星级',
    features: ['海景房', '管家服务', '米其林餐厅'],
    canReview: true,
    hasOrder: true
  },
  {
    id: 'hotel003',
    name: '深圳大梅沙京基海湾大酒店',
    subtitle: '海滨度假酒店',
    image: 'https://picsum.photos/seed/hotel_jingji/800/600',
    rating: 4.6,
    location: '盐田区大梅沙环梅路51号',
    price: '￥580起',
    category: '四星级',
    features: ['海景房', '沙滩', '度假']
  },
  {
    id: 'hotel004',
    name: '深圳前海华侨城JW万豪酒店',
    subtitle: '商务精选',
    image: 'https://picsum.photos/seed/hotel_wanhao/800/600',
    rating: 4.8,
    location: '南山区前海路',
    price: '￥980起',
    category: '五星级',
    features: ['商务中心', '会议室', '健身房']
  },
  {
    id: 'hotel005',
    name: '深圳东部华侨城茵特拉根酒店',
    subtitle: '山景度假酒店',
    image: 'https://picsum.photos/seed/hotel_yintelagen/800/600',
    rating: 4.7,
    location: '盐田区东部华侨城',
    price: '￥880起',
    category: '五星级',
    features: ['山景房', '温泉', '高尔夫']
  },
  {
    id: 'hotel006',
    name: '维也纳国际酒店',
    subtitle: '经济实惠之选',
    image: 'https://picsum.photos/seed/hotel_weiyena/800/600',
    rating: 4.3,
    location: '福田区华强北',
    price: '￥298起',
    category: '三星级',
    features: ['交通便利', '性价比高', '早餐']
  }
];

// 深圳美食数据
export interface FoodData {
  id: string;
  name: string;
  subtitle: string;
  image: string;
  rating: number;
  location: string;
  avgPrice: string;
  category: string;
  specialties: string[];
}

export const shenzhenFoods: FoodData[] = [
  {
    id: 'food001',
    name: '潮汕牛肉火锅',
    subtitle: '八合里海记牛肉火锅',
    image: 'https://picsum.photos/seed/food_niurou/800/600',
    rating: 4.7,
    location: '福田区车公庙',
    avgPrice: '￥150/人',
    category: '火锅',
    specialties: ['手打牛肉丸', '吊龙', '匙仁']
  },
  {
    id: 'food002',
    name: '客家菜',
    subtitle: '客家王',
    image: 'https://picsum.photos/seed/food_kejia/800/600',
    rating: 4.5,
    location: '罗湖区东门',
    avgPrice: '￥80/人',
    category: '客家菜',
    specialties: ['梅菜扣肉', '酿豆腐', '盐焗鸡']
  },
  {
    id: 'food003',
    name: '粤菜茶餐厅',
    subtitle: '翠华餐厅',
    image: 'https://picsum.photos/seed/food_canting/800/600',
    rating: 4.6,
    location: '福田区购物公园',
    avgPrice: '￥60/人',
    category: '茶餐厅',
    specialties: ['菠萝包', '奶茶', '叉烧饭']
  },
  {
    id: 'food004',
    name: '海鲜大排档',
    subtitle: '盐田海鲜街',
    image: 'https://picsum.photos/seed/food_haixian/800/600',
    rating: 4.8,
    location: '盐田区海鲜街',
    avgPrice: '￥200/人',
    category: '海鲜',
    specialties: ['生蚝', '濑尿虾', '石斑鱼']
  },
  {
    id: 'food005',
    name: '烧腊饭',
    subtitle: '再兴烧腊饭店',
    image: 'https://picsum.photos/seed/food_shaola/800/600',
    rating: 4.4,
    location: '福田区华强北',
    avgPrice: '￥35/人',
    category: '快餐',
    specialties: ['烧鹅', '叉烧', '烧肉']
  },
  {
    id: 'food006',
    name: '潮汕砂锅粥',
    subtitle: '潮香砂锅粥',
    image: 'https://picsum.photos/seed/food_zhou/800/600',
    rating: 4.5,
    location: '南山区白石洲',
    avgPrice: '￥45/人',
    category: '粥品',
    specialties: ['海鲜粥', '生鱼粥', '皮蛋瘦肉粥']
  },
  {
    id: 'food007',
    name: '椰子鸡',
    subtitle: '润园四季椰子鸡',
    image: 'https://picsum.photos/seed/food_yeziji/800/600',
    rating: 4.7,
    location: '福田区车公庙',
    avgPrice: '￥120/人',
    category: '火锅',
    specialties: ['文昌鸡', '椰子水', '沙姜']
  },
  {
    id: 'food008',
    name: '深圳本地菜',
    subtitle: '向西村',
    image: 'https://picsum.photos/seed/food_bendi/800/600',
    rating: 4.6,
    location: '南山区南头古城',
    avgPrice: '￥90/人',
    category: '本帮菜',
    specialties: ['公明烧鹅', '光明乳鸽', '沙井蚝']
  }
];

// 深圳交通数据
export interface TransportData {
  id: string;
  name: string;
  type: string;
  description: string;
  price: string;
  icon: string;
}

export const shenzhenTransport: TransportData[] = [
  {
    id: 'trans001',
    name: '深圳地铁',
    type: '地铁',
    description: '覆盖全市的地铁网络，共16条线路',
    price: '￥2-11',
    icon: 'https://picsum.photos/seed/ic_metro/400/400'
  },
  {
    id: 'trans002',
    name: '公交车',
    type: '公交',
    description: '便捷的公交系统，支持深圳通和移动支付',
    price: '￥1-3',
    icon: 'https://picsum.photos/seed/ic_bus/400/400'
  },
  {
    id: 'trans003',
    name: '出租车',
    type: '出租车',
    description: '红色出租车和绿色出租车',
    price: '起步价￥10',
    icon: 'https://picsum.photos/seed/ic_taxi/400/400'
  },
  {
    id: 'trans004',
    name: '共享单车',
    type: '单车',
    description: '美团、青桔等共享单车',
    price: '￥1.5起',
    icon: 'https://picsum.photos/seed/ic_bike/400/400'
  }
];

// 深圳购物数据
export interface ShoppingData {
  id: string;
  name: string;
  subtitle: string;
  image: string;
  category: string;
  location: string;
  features: string[];
}

export const shenzhenShopping: ShoppingData[] = [
  {
    id: 'shop001',
    name: 'KK MALL',
    subtitle: '华强北地标商场',
    image: 'https://picsum.photos/seed/shop_kkmall/800/600',
    category: '购物中心',
    location: '福田区华强北路',
    features: ['电子产品', '数码配件', '美食']
  },
  {
    id: 'shop002',
    name: '万象城',
    subtitle: '高端购物中心',
    image: 'https://picsum.photos/seed/shop_wanxiang/800/600',
    category: '购物中心',
    location: '罗湖区宝安南路',
    features: ['奢侈品', '餐饮', '影院']
  },
  {
    id: 'shop003',
    name: '海岸城',
    subtitle: '南山核心商圈',
    image: 'https://picsum.photos/seed/shop_haian/800/600',
    category: '购物中心',
    location: '南山区文心五路',
    features: ['购物', '美食', '儿童乐园']
  },
  {
    id: 'shop004',
    name: '东门老街',
    subtitle: '深圳传统商业街',
    image: 'https://picsum.photos/seed/shop_dongmen/800/600',
    category: '商业街',
    location: '罗湖区东门',
    features: ['服装', '小吃', '人气旺']
  },
  {
    id: 'shop005',
    name: 'coco Park',
    subtitle: '时尚潮流汇聚地',
    image: 'https://picsum.photos/seed/shop_coco/800/600',
    category: '购物中心',
    location: '福田区福华一路',
    features: ['潮牌', '网红店', '美食']
  }
];

// 快捷入口配置（深圳主题）
export interface QuickEntryData {
  id: string;
  name: string;
  icon: string;
  url: string;
  color: string;
  description: string;
}

export const shenzhenQuickEntries: QuickEntryData[] = [
  // 第一行
  {
    id: '1',
    name: '门票',
    icon: '🎫',
    url: 'pages/ticket/TicketBookingPage',
    color: '#ff6b9d',
    description: '景区门票预订'
  },
  {
    id: '2',
    name: '酒店',
    icon: '🏨',
    url: 'pages/hotel/HotelListPage',
    color: '#0086f6',
    description: '深圳酒店预订'
  },
  {
    id: '3',
    name: '美食',
    icon: '🍽️',
    url: 'pages/category/FoodPage',
    color: '#ff9900',
    description: '深圳特色美食'
  },
  {
    id: '4',
    name: '购物',
    icon: '🛍️',
    url: 'pages/category/ShoppingPage',
    color: '#722ed1',
    description: '购物商场'
  },
  {
    id: '5',
    name: '交通',
    icon: '🚇',
    url: 'pages/category/TransportPage',
    color: '#13c2c2',
    description: '地铁公交'
  },
  // 第二行
  {
    id: '6',
    name: '景点',
    icon: '🏞️',
    url: 'pages/activity/ActivityPageNew',
    color: '#52c41a',
    description: '深圳景点'
  },
  {
    id: '7',
    name: '海滨',
    icon: '🏖️',
    url: 'pages/category/BeachPage',
    color: '#1890ff',
    description: '海滨浴场'
  },
  {
    id: '8',
    name: '路线',
    icon: '🗺️',
    url: 'pages/category/RoutePage',
    color: '#fa8c16',
    description: '旅游路线'
  },
  {
    id: '9',
    name: '攻略',
    icon: '📖',
    url: 'pages/itinerary/ItineraryPage',
    color: '#eb2f96',
    description: '旅游攻略'
  },
  {
    id: '10',
    name: '订单',
    icon: '📋',
    url: 'pages/order/OrderPage',
    color: '#1e40af',
    description: '我的订单'
  }
];

// 深圳公告数据
export interface NoticeData {
  id: string;
  title: string;
  content: string;
  time: string;
  type: string;
}

export const shenzhenNotices: NoticeData[] = [
  {
    id: 'notice001',
    title: '深圳欢乐谷夜场优惠',
    content: '即日起至月底，夜场门票8折优惠，快来体验刺激项目！',
    time: '2025-11-18',
    type: '优惠'
  },
  {
    id: 'notice002',
    title: '深圳湾公园骑行活动',
    content: '本周末举办环深圳湾骑行活动，欢迎市民参与。',
    time: '2025-11-17',
    type: '活动'
  },
  {
    id: 'notice003',
    title: '大梅沙海滨浴场开放时间调整',
    content: '冬季开放时间调整为07:00-21:00，请注意安全。',
    time: '2025-11-16',
    type: '通知'
  }
];

// 旅游路线推荐
export interface TourRouteData {
  id: string;
  name: string;
  duration: string;
  distance: string;
  spots: string[];
  image: string;
  description: string;
}

export const shenzhenRoutes: TourRouteData[] = [
  {
    id: 'route001',
    name: '深圳经典一日游',
    duration: '8小时',
    distance: '约30公里',
    spots: ['世界之窗', '欢乐谷', '深圳湾公园', '海岸城'],
    image: 'https://picsum.photos/seed/route_classic/800/600',
    description: '游览深圳最经典的景点，感受特区魅力'
  },
  {
    id: 'route002',
    name: '海滨度假二日游',
    duration: '2天',
    distance: '约50公里',
    spots: ['大梅沙', '小梅沙', '东部华侨城', '盐田海鲜街'],
    image: 'https://picsum.photos/seed/route_beach/800/600',
    description: '享受海滨风光，品尝新鲜海鲜'
  },
  {
    id: 'route003',
    name: '文化探索游',
    duration: '6小时',
    distance: '约20公里',
    spots: ['莲花山公园', 'OCT创意园', '南头古城', '华强北'],
    image: 'https://picsum.photos/seed/route_culture/800/600',
    description: '探索深圳文化底蕴，体验创意氛围'
  },
  {
    id: 'route004',
    name: '亲子欢乐游',
    duration: '全天',
    distance: '约15公里',
    spots: ['欢乐谷', '世界之窗', '野生动物园', '儿童乐园'],
    image: 'https://picsum.photos/seed/route_family/800/600',
    description: '适合全家出游的亲子路线'
  }
];
