import { Prompt } from '@kit.ArkUI';

/**
 * 错误处理工具类
 * 统一处理应用中的错误信息
 */
export class ErrorHandler {
  
  /**
   * 处理路由跳转错误
   */
  static handleRouterError(error: Error, targetPage?: string) {
    console.error(`路由跳转失败${targetPage ? `到${targetPage}` : ''}:`, error.message);
    Prompt.showToast({ 
      message: `页面跳转失败，请重试`,
      duration: 2000
    });
  }

  /**
   * 处理网络请求错误
   */
  static handleNetworkError(error: Error, operation?: string) {
    console.error(`网络请求失败${operation ? `(${operation})` : ''}:`, error.message);
    Prompt.showToast({ 
      message: '网络连接异常，请检查网络设置',
      duration: 3000
    });
  }

  /**
   * 处理数据加载错误
   */
  static handleDataLoadError(error: Error, dataType?: string) {
    console.error(`数据加载失败${dataType ? `(${dataType})` : ''}:`, error.message);
    Prompt.showToast({ 
      message: '数据加载失败，请刷新重试',
      duration: 2000
    });
  }

  /**
   * 处理权限错误
   */
  static handlePermissionError(permission: string) {
    console.error(`权限获取失败: ${permission}`);
    Prompt.showToast({ 
      message: `需要${permission}权限才能使用此功能`,
      duration: 3000
    });
  }

  /**
   * 处理功能未实现错误
   */
  static handleFeatureNotImplemented(featureName: string) {
    console.log(`功能未实现: ${featureName}`);
    Prompt.showToast({ 
      message: `${featureName}功能正在开发中，敬请期待`,
      duration: 2000
    });
  }

  /**
   * 处理通用错误
   */
  static handleGenericError(error: Error, context?: string) {
    console.error(`发生错误${context ? `(${context})` : ''}:`, error.message);
    Prompt.showToast({ 
      message: '操作失败，请重试',
      duration: 2000
    });
  }

  /**
   * 显示提示消息
   */
  static showToast(message: string, duration: number = 2000) {
    Prompt.showToast({ 
      message: message,
      duration: duration
    });
  }

  /**
   * 安全执行异步操作
   */
  static async safeExecute<T>(
    operation: () => Promise<T>,
    errorHandler?: (error: Error) => void,
    context?: string
  ): Promise<T | null> {
    try {
      return await operation();
    } catch (error) {
      if (errorHandler) {
        errorHandler(error as Error);
      } else {
        ErrorHandler.handleGenericError(error as Error, context);
      }
      return null;
    }
  }

  /**
   * 安全执行同步操作
   */
  static safeExecuteSync<T>(
    operation: () => T,
    errorHandler?: (error: Error) => void,
    context?: string
  ): T | null {
    try {
      return operation();
    } catch (error) {
      if (errorHandler) {
        errorHandler(error as Error);
      } else {
        ErrorHandler.handleGenericError(error as Error, context);
      }
      return null;
    }
  }
}
