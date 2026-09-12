// 酒店订单数据模型
@Observed
export class HotelOrder {
  id: string;
  hotelName: string;
  hotelImage: string;
  roomType: string;
  checkInDate: string;
  checkOutDate: string;
  totalPrice: number;
  status: OrderStatus;
  orderTime: string;
  guestName: string;
  guestPhone: string;
  roomCount: number;
  nights: number;

  constructor(
    id: string,
    hotelName: string,
    hotelImage: string,
    roomType: string,
    checkInDate: string,
    checkOutDate: string,
    totalPrice: number,
    status: OrderStatus,
    orderTime: string,
    guestName: string,
    guestPhone: string,
    roomCount: number = 1,
    nights: number = 1
  ) {
    this.id = id;
    this.hotelName = hotelName;
    this.hotelImage = hotelImage;
    this.roomType = roomType;
    this.checkInDate = checkInDate;
    this.checkOutDate = checkOutDate;
    this.totalPrice = totalPrice;
    this.status = status;
    this.orderTime = orderTime;
    this.guestName = guestName;
    this.guestPhone = guestPhone;
    this.roomCount = roomCount;
    this.nights = nights;
  }
}

export enum OrderStatus {
  ALL = 0,
  PENDING_PAYMENT = 1,
  PENDING_CHECKIN = 2,
  WAITING_EVALUATE = 3
}

export class OrderStatusInfo {
  static getStatusText(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.ALL:
        return '全部';
      case OrderStatus.PENDING_PAYMENT:
        return '待支付';
      case OrderStatus.PENDING_CHECKIN:
        return '待入住';
      case OrderStatus.WAITING_EVALUATE:
        return '待评价';
      default:
        return '全部';
    }
  }

  static getActionText(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.PENDING_PAYMENT:
        return '去支付';
      case OrderStatus.PENDING_CHECKIN:
        return '再次预订';
      case OrderStatus.WAITING_EVALUATE:
        return '立即评价';
      default:
        return '查看详情';
    }
  }

  static getActionButtonColor(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.PENDING_PAYMENT:
        return '#FF6B35';
      case OrderStatus.PENDING_CHECKIN:
        return '#007AFF';
      case OrderStatus.WAITING_EVALUATE:
        return '#34C759';
      default:
        return '#007AFF';
    }
  }
}

export class HotelOrderData {
  // 全局订单存储（应用运行期内有效）
  private static orders: HotelOrder[] = [];

  // 初始化全局订单（只在首次调用时填充一次）
  static getCurrentOrders(): HotelOrder[] {
    if (HotelOrderData.orders.length === 0) {
      HotelOrderData.orders = HotelOrderData.getMockOrders();
    }
    return HotelOrderData.orders;
  }

  static addOrder(order: HotelOrder): void {
    // 新订单置顶
    HotelOrderData.orders = [order, ...HotelOrderData.getCurrentOrders()];
  }

  static updateOrderStatus(orderId: string, status: OrderStatus): void {
    const list = HotelOrderData.getCurrentOrders();
    const idx = list.findIndex(o => o.id === orderId);
    if (idx >= 0) {
      list[idx].status = status;
      HotelOrderData.orders = [...list];
    }
  }

  static getMockOrders(): HotelOrder[] {
    return [
      new HotelOrder(
        '001',
        '豪华酒店',
        '🏨',
        '豪华大床房',
        '2025/07/07',
        '2025/07/09',
        489.45,
        OrderStatus.WAITING_EVALUATE,
        '2025-07-05 14:30',
        '张三',
        '13800138000',
        1,
        2
      ),
      new HotelOrder(
        '002',
        '海景度假村',
        '🏖️',
        '海景套房',
        '2025/08/15',
        '2025/08/18',
        1299.00,
        OrderStatus.PENDING_CHECKIN,
        '2025-07-20 09:15',
        '李四',
        '13900139000',
        1,
        3
      ),
      new HotelOrder(
        '003',
        '商务酒店',
        '🏢',
        '标准双床房',
        '2025/09/10',
        '2025/09/12',
        356.80,
        OrderStatus.PENDING_PAYMENT,
        '2025-09-08 16:45',
        '王五',
        '13700137000',
        1,
        2
      ),
      new HotelOrder(
        '004',
        '温泉酒店',
        '♨️',
        '温泉大床房',
        '2025/10/01',
        '2025/10/03',
        688.90,
        OrderStatus.PENDING_CHECKIN,
        '2025-09-25 11:20',
        '赵六',
        '13600136000',
        1,
        2
      ),
      new HotelOrder(
        '005',
        '精品民宿',
        '🏡',
        '复式套房',
        '2025/11/20',
        '2025/11/22',
        456.70,
        OrderStatus.WAITING_EVALUATE,
        '2025-11-18 20:30',
        '孙七',
        '13500135000',
        1,
        2
      )
    ];
  }

  static getOrdersByStatus(orders: HotelOrder[], status: OrderStatus): HotelOrder[] {
    if (status === OrderStatus.ALL) {
      return orders;
    }
    return orders.filter(order => order.status === status);
  }
}
