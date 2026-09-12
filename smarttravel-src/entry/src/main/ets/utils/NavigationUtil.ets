import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

/**
 * 导航工具 - 统一管理页面跳转
 */
export namespace NavigationUtil {
  
  // ===== 首页相关 =====
  export function toHome(): void {
    router.pushUrl({ url: 'pages/MainPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toSearch(): void {
    router.pushUrl({ url: 'pages/search/SearchPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toMessage(): void {
    router.pushUrl({ url: 'pages/message/MessagePage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toNotice(): void {
    router.pushUrl({ url: 'pages/notice/NoticeListPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  // ===== 分类页面 =====
  export function toFoodCategory(): void {
    router.pushUrl({ url: 'pages/category/FoodPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toHotelCategory(): void {
    router.pushUrl({ url: 'pages/category/HotelPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toShoppingCategory(): void {
    router.pushUrl({ url: 'pages/category/ShoppingPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toTransportCategory(): void {
    router.pushUrl({ url: 'pages/category/TransportPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toRouteCategory(): void {
    router.pushUrl({ url: 'pages/category/RoutePage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toTechCategory(): void {
    router.pushUrl({ url: 'pages/category/TechPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toNatureCategory(): void {
    router.pushUrl({ url: 'pages/category/NaturePage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  export function toBeachCategory(): void {
    router.pushUrl({ url: 'pages/category/BeachPage' }).catch(() => {
      promptAction.showToast({ message: '跳转失败' });
    });
  }

  // ===== 工具方法 =====
  export function goBack(): void {
    router.back();
  }
}
