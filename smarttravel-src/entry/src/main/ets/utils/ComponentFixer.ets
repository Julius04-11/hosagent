/**
 * 组件问题自动修复工具
 * 提供常见组件问题的修复方法
 */

export class ComponentFixer {
  /**
   * 修复ForEach数据绑定问题
   * 使用展开运算符创建新数组引用
   */
  static fixArrayBinding<T>(sourceArray: T[]): T[] {
    return [...sourceArray];
  }

  /**
   * 安全的数组过滤
   * 确保返回新的数组引用
   */
  static safeFilter<T>(
    sourceArray: T[],
    predicate: (item: T) => boolean
  ): T[] {
    const filtered = sourceArray.filter(predicate);
    return [...filtered];
  }

  /**
   * 安全的数组映射
   * 确保返回新的数组引用
   */
  static safeMap<T, R>(
    sourceArray: T[],
    mapper: (item: T) => R
  ): R[] {
    const mapped = sourceArray.map(mapper);
    return [...mapped];
  }

  /**
   * 生成ForEach的keyGenerator
   */
  static generateKeyFunction<T extends { id: string | number }>(
    item: T
  ): string {
    return String(item.id);
  }

  /**
   * 安全获取router参数
   */
  static safeGetRouterParams<T>(
    defaultParams: T,
    requiredKeys?: (keyof T)[]
  ): T | null {
    try {
      const params = router.getParams() as T;
      
      if (!params) {
        console.error('[ComponentFixer] router参数为空');
        return null;
      }

      // 检查必需参数
      if (requiredKeys) {
        for (const key of requiredKeys) {
          if (!params[key]) {
            console.error(`[ComponentFixer] 缺少必需参数: ${String(key)}`);
            return null;
          }
        }
      }

      return params;
    } catch (error) {
      console.error('[ComponentFixer] 获取router参数失败:', error);
      return null;
    }
  }

  /**
   * 创建带错误处理的异步包装器
   */
  static async safeAsync<T>(
    asyncFn: () => Promise<T>,
    errorHandler?: (error: Error) => void
  ): Promise<T | null> {
    try {
      return await asyncFn();
    } catch (error) {
      console.error('[ComponentFixer] 异步操作失败:', error);
      if (errorHandler) {
        errorHandler(error as Error);
      }
      return null;
    }
  }

  /**
   * 防抖函数
   * 用于优化搜索等高频操作
   */
  static debounce(fn: Function, delay: number = 300): Function {
    let timeoutId: number | null = null;
    
    return function(...args: any[]) {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
      
      timeoutId = setTimeout(() => {
        fn.apply(this, args);
        timeoutId = null;
      }, delay);
    };
  }

  /**
   * 节流函数
   * 用于优化滚动等高频操作
   */
  static throttle(fn: Function, delay: number = 100): Function {
    let lastCall = 0;
    
    return function(...args: any[]) {
      const now = Date.now();
      
      if (now - lastCall >= delay) {
        lastCall = now;
        fn.apply(this, args);
      }
    };
  }
}

/**
 * 数据源接口实现
 * 用于LazyForEach
 */
export class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private dataArray: T[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  // 通知数据重新加载
  public notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  // 通知数据添加
  public notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  // 通知数据变化
  public notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  // 通知数据删除
  public notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  // 设置数据
  public setData(data: T[]): void {
    this.dataArray = data;
    this.notifyDataReload();
  }

  // 添加数据
  public pushData(item: T): void {
    this.dataArray.push(item);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  // 更新数据
  public updateData(index: number, item: T): void {
    this.dataArray[index] = item;
    this.notifyDataChange(index);
  }

  // 删除数据
  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  // 获取全部数据
  public getAllData(): T[] {
    return this.dataArray;
  }
}

/**
 * 图片加载状态管理
 */
export class ImageLoadManager {
  private static loadedImages: Set<string> = new Set();
  private static failedImages: Set<string> = new Set();

  /**
   * 标记图片加载成功
   */
  static markAsLoaded(imageUrl: string): void {
    this.loadedImages.add(imageUrl);
    this.failedImages.delete(imageUrl);
  }

  /**
   * 标记图片加载失败
   */
  static markAsFailed(imageUrl: string): void {
    this.failedImages.add(imageUrl);
    this.loadedImages.delete(imageUrl);
  }

  /**
   * 检查图片是否已加载
   */
  static isLoaded(imageUrl: string): boolean {
    return this.loadedImages.has(imageUrl);
  }

  /**
   * 检查图片是否加载失败
   */
  static isFailed(imageUrl: string): boolean {
    return this.failedImages.has(imageUrl);
  }

  /**
   * 清除缓存
   */
  static clearCache(): void {
    this.loadedImages.clear();
    this.failedImages.clear();
  }
}

import { router } from '@kit.ArkUI';
