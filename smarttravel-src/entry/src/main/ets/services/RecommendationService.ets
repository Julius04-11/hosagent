import { RecommendationItem } from '../components/RecommendationSection';

export class RecommendationService {
  
  // 获取科技类推荐
  static getTechRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'tech_1',
        title: 'VR虚拟现实体验馆',
        image: 'https://picsum.photos/id/400/300/200',
        rating: 4.8,
        price: '￥88起',
        tags: ['VR体验', '科技', '互动'],
        description: '最新VR技术，沉浸式虚拟现实体验',
        location: '科技园',
        type: 'tech'
      },
      {
        id: 'tech_2',
        title: 'AI智能展览馆',
        image: 'https://picsum.photos/id/401/300/200',
        rating: 4.7,
        price: '￥68起',
        tags: ['AI', '展览', '教育'],
        description: '人工智能科普展览，寓教于乐',
        location: '南山区',
        type: 'tech'
      },
      {
        id: 'tech_3',
        title: '机器人互动体验',
        image: 'https://picsum.photos/id/402/300/200',
        rating: 4.6,
        price: '￥58起',
        tags: ['机器人', '互动', '娱乐'],
        description: '与智能机器人互动，体验未来科技',
        location: '福田区',
        type: 'tech'
      }
    ];
  }

  // 获取购物类推荐
  static getShoppingRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'shop_1',
        title: '华强北商业街',
        image: 'https://picsum.photos/id/410/300/200',
        rating: 4.5,
        tags: ['电子产品', '数码', '批发'],
        description: '全球最大电子市场，数码产品天堂',
        location: '福田区',
        type: 'shopping'
      },
      {
        id: 'shop_2',
        title: '万象城购物中心',
        image: 'https://picsum.photos/id/411/300/200',
        rating: 4.7,
        tags: ['奢侈品', '时尚', '餐饮'],
        description: '高端购物中心，国际品牌云集',
        location: '罗湖区',
        type: 'shopping'
      },
      {
        id: 'shop_3',
        title: '海岸城购物中心',
        image: 'https://picsum.photos/id/412/300/200',
        rating: 4.6,
        tags: ['时尚', '美食', '娱乐'],
        description: '南山地标购物中心，一站式购物体验',
        location: '南山区',
        type: 'shopping'
      }
    ];
  }

  // 获取路线类推荐
  static getRouteRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'route_1',
        title: '深圳一日游经典路线',
        image: 'https://picsum.photos/id/420/300/200',
        rating: 4.8,
        tags: ['经典', '一日游', '景点'],
        description: '世界之窗→欢乐谷→深圳湾公园',
        location: '全市',
        type: 'route'
      },
      {
        id: 'route_2',
        title: '文化艺术探索之旅',
        image: 'https://picsum.photos/id/421/300/200',
        rating: 4.6,
        tags: ['文化', '艺术', '博物馆'],
        description: '深圳博物馆→音乐厅→图书馆',
        location: '福田区',
        type: 'route'
      },
      {
        id: 'route_3',
        title: '海滨休闲路线',
        image: 'https://picsum.photos/id/422/300/200',
        rating: 4.7,
        tags: ['海滨', '休闲', '自然'],
        description: '大梅沙→小梅沙→东部华侨城',
        location: '盐田区',
        type: 'route'
      }
    ];
  }

  // 获取自然类推荐
  static getNatureRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'nature_1',
        title: '深圳湾公园',
        image: 'https://picsum.photos/id/430/300/200',
        rating: 4.7,
        tags: ['湿地', '观鸟', '生态'],
        description: '城市湿地公园，观鸟胜地',
        location: '南山区',
        type: 'nature'
      },
      {
        id: 'nature_2',
        title: '梧桐山国家森林公园',
        image: 'https://picsum.photos/id/431/300/200',
        rating: 4.6,
        tags: ['登山', '森林', '健身'],
        description: '深圳最高峰，登山健身好去处',
        location: '罗湖区',
        type: 'nature'
      },
      {
        id: 'nature_3',
        title: '仙湖植物园',
        image: 'https://picsum.photos/id/432/300/200',
        rating: 4.8,
        tags: ['植物', '科普', '休闲'],
        description: '热带植物王国，科普教育基地',
        location: '罗湖区',
        type: 'nature'
      }
    ];
  }

  // 获取美食推荐
  static getFoodRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'food_1',
        title: '潮汕牛肉火锅',
        image: 'https://picsum.photos/id/440/300/200',
        rating: 4.8,
        price: '￥128/人',
        tags: ['火锅', '潮汕菜', '牛肉'],
        description: '正宗潮汕牛肉火锅，新鲜牛肉现切现煮',
        location: '福田区',
        type: 'food'
      },
      {
        id: 'food_2',
        title: '粤菜茶餐厅',
        image: 'https://picsum.photos/id/441/300/200',
        rating: 4.6,
        price: '￥88/人',
        tags: ['粤菜', '茶餐厅', '港式'],
        description: '地道港式茶餐厅，经典粤菜美食',
        location: '罗湖区',
        type: 'food'
      },
      {
        id: 'food_3',
        title: '海鲜大排档',
        image: 'https://picsum.photos/id/442/300/200',
        rating: 4.7,
        price: '￥168/人',
        tags: ['海鲜', '大排档', '新鲜'],
        description: '新鲜海鲜，地道做法，性价比高',
        location: '盐田区',
        type: 'food'
      }
    ];
  }

  // 获取交通推荐
  static getTransportRecommendations(): RecommendationItem[] {
    return [
      {
        id: 'transport_1',
        title: '深圳地铁一日通',
        image: 'https://picsum.photos/id/450/300/200',
        rating: 4.9,
        price: '￥20/天',
        tags: ['地铁', '便民', '优惠'],
        description: '一日内无限次乘坐地铁，经济实惠',
        location: '全市',
        type: 'transport'
      },
      {
        id: 'transport_2',
        title: '观光巴士路线',
        image: 'https://picsum.photos/id/451/300/200',
        rating: 4.6,
        price: '￥50/天',
        tags: ['观光', '巴士', '景点'],
        description: '双层观光巴士，游览主要景点',
        location: '主要景点',
        type: 'transport'
      },
      {
        id: 'transport_3',
        title: '共享单车骑行',
        image: 'https://picsum.photos/id/452/300/200',
        rating: 4.5,
        price: '￥2/小时',
        tags: ['单车', '环保', '健身'],
        description: '绿色出行，健康骑行，随借随还',
        location: '全市',
        type: 'transport'
      }
    ];
  }

  // 根据类型获取推荐
  static getRecommendationsByType(type: string): RecommendationItem[] {
    switch (type.toLowerCase()) {
      case 'tech':
      case '科技':
        return RecommendationService.getTechRecommendations();
      case 'shopping':
      case '购物':
        return RecommendationService.getShoppingRecommendations();
      case 'route':
      case '路线':
        return RecommendationService.getRouteRecommendations();
      case 'nature':
      case '自然':
        return RecommendationService.getNatureRecommendations();
      case 'food':
      case '美食':
        return RecommendationService.getFoodRecommendations();
      case 'transport':
      case '交通':
        return RecommendationService.getTransportRecommendations();
      default:
        return [];
    }
  }

  // 获取热门推荐（混合各类型）
  static getHotRecommendations(): RecommendationItem[] {
    const allRecommendations = [
      ...RecommendationService.getTechRecommendations().slice(0, 1),
      ...RecommendationService.getFoodRecommendations().slice(0, 1),
      ...RecommendationService.getNatureRecommendations().slice(0, 1),
      ...RecommendationService.getShoppingRecommendations().slice(0, 1),
      ...RecommendationService.getTransportRecommendations().slice(0, 1),
      ...RecommendationService.getRouteRecommendations().slice(0, 1)
    ];
    
    // 随机排序
    return allRecommendations.sort(() => Math.random() - 0.5);
  }
}
