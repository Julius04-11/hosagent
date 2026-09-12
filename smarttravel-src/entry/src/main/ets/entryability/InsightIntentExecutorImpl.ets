import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'InsightIntentExecutor';

/**
 * 意图调用执行器实现
 * 支持小艺AI助手通过自然语言调用应用功能
 */
export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  private static readonly VIEW_TRAVEL_GUIDES = 'ViewTravelGuides';
  private static readonly JUMP_FUNCTION_PAGE = 'JumpFunctionPage';

  /**
   * 执行前台UIAbility意图
   * 当用户通过小艺说"查看旅游攻略"时，会触发此方法
   *
   * @param name 意图名称
   * @param param 意图参数
   * @param pageLoader 窗口对象
   * @returns 意图调用结果
   */
  onExecuteInUIAbilityForegroundMode(
    name: string,
    param: Record<string, Object>,
    pageLoader: window.WindowStage
  ): Promise<insightIntent.ExecuteResult> {
    hilog.info(DOMAIN, TAG, `执行前台意图: ${name}`);
    hilog.info(DOMAIN, TAG, `意图参数: ${JSON.stringify(param)}`);

    // 根据意图名称分发处理逻辑
    switch (name) {
      case InsightIntentExecutorImpl.VIEW_TRAVEL_GUIDES:
        return this.viewTravelGuides(param, pageLoader);
      case InsightIntentExecutorImpl.JUMP_FUNCTION_PAGE:
        return this.jumpFunctionPage(param, pageLoader);
      default:
        hilog.error(DOMAIN, TAG, `未知意图: ${name}`);
        break;
    }

    return Promise.resolve({
      code: -1,
      result: {
        message: 'unknown intent'
      }
    } as insightIntent.ExecuteResult);
  }

  /**
   * 执行后台UIAbility意图
   * 
   * @param name 意图名称
   * @param param 意图参数
   * @returns 意图调用结果
   */
  onExecuteInUIAbilityBackgroundMode(
    name: string,
    param: Record<string, Object>
  ): Promise<insightIntent.ExecuteResult> {
    hilog.info(DOMAIN, TAG, `执行后台意图: ${name}`);
    hilog.info(DOMAIN, TAG, `意图参数: ${JSON.stringify(param)}`);

    // 后台模式下可以执行数据同步等操作
    return Promise.resolve({
      code: 0,
      result: {
        message: 'Background intent execute success'
      }
    } as insightIntent.ExecuteResult);
  }

  /**
   * 实现查看旅游攻略功能
   * 解析意图参数并跳转到旅游攻略详情页
   *
   * @param param 意图参数
   * @param pageLoader 窗口对象
   */
  private viewTravelGuides(
    param: Record<string, Object>,
    pageLoader: window.WindowStage
  ): Promise<insightIntent.ExecuteResult> {
    return new Promise((resolve, reject) => {
      try {
        // 解析意图参数
        let entityId: string = '';
        let guideName: string = '';
        let location: string = '';

        // 从参数中提取实体信息
        if (param.items && Array.isArray(param.items) && param.items.length > 0) {
          const item = param.items[0] as Record<string, Object>;
          entityId = item['entityId'] as string || '';
          guideName = item['name'] as string || '';
          location = item['location'] as string || '';
        }

        hilog.info(DOMAIN, TAG, `加载旅游攻略: entityId=${entityId}, name=${guideName}, location=${location}`);

        // 跳转到旅游攻略详情页
        // 如果有具体的攻略ID，跳转到详情页；否则跳转到攻略列表页
        const targetPage = entityId ? 'pages/guide/GuideDetailPage' : 'pages/profile/MyGuidesPage';

        pageLoader.loadContent(targetPage, (err: BusinessError) => {
          if (err.code) {
            hilog.error(DOMAIN, TAG, `加载页面失败: ${JSON.stringify(err)}`);
            resolve({
              code: -1,
              result: {
                message: `Intent execute failed: ${err.message}`
              }
            });
            return;
          }

          hilog.info(DOMAIN, TAG, '意图执行成功，已跳转到旅游攻略页面');
          
          // 如果有具体参数，可以通过AppStorage传递给页面
          if (entityId) {
            AppStorage.setOrCreate('intentGuideId', entityId);
          }
          if (guideName) {
            AppStorage.setOrCreate('intentGuideName', guideName);
          }
          if (location) {
            AppStorage.setOrCreate('intentGuideLocation', location);
          }

          resolve({
            code: 0,
            result: {
              message: 'Intent execute success',
              data: {
                entityId: entityId,
                guideName: guideName,
                location: location
              }
            }
          });
        });
      } catch (error) {
        hilog.error(DOMAIN, TAG, `执行意图异常: ${JSON.stringify(error)}`);
        resolve({
          code: -1,
          result: {
            message: `Intent execute failed: ${error}`
          }
        });
      }
    });
  }

  /**
   * 实现跳转功能页面（一步达）
   * 快速打开应用内的功能页面，无需手动导航
   *
   * @param param 意图参数，包含pageId
   * @param pageLoader 窗口对象
   */
  private jumpFunctionPage(
    param: Record<string, Object>,
    pageLoader: window.WindowStage
  ): Promise<insightIntent.ExecuteResult> {
    return new Promise((resolve) => {
      try {
        const pageId = param?.pageId as string;

        hilog.info(DOMAIN, TAG, `一步达跳转: pageId=${pageId}`);

        // 验证pageId
        if (!pageId) {
          hilog.error(DOMAIN, TAG, '缺少pageId参数');
          resolve({
            code: -1,
            result: {
              message: 'Missing pageId parameter'
            }
          });
          return;
        }

        // 根据pageId映射到实际页面路径
        const pagePath = this.getPagePath(pageId);
        if (!pagePath) {
          hilog.error(DOMAIN, TAG, `无效的pageId: ${pageId}`);
          resolve({
            code: -1,
            result: {
              message: `Invalid pageId: ${pageId}`,
              availablePageIds: ['ViewGuides', 'SearchDestinations', 'MyTrips', 'FavoriteGuides', 'Settings']
            }
          });
          return;
        }

        hilog.info(DOMAIN, TAG, `加载页面: ${pagePath}`);

        // 加载目标页面
        pageLoader.loadContent(pagePath)
          .then(() => {
            hilog.info(DOMAIN, TAG, `页面加载成功: ${pagePath}`);
            resolve({
              code: 0,
              result: {
                message: 'Intent execute success',
                pageId: pageId,
                pagePath: pagePath
              }
            });
          })
          .catch((err: BusinessError) => {
            hilog.error(DOMAIN, TAG, `页面加载失败: ${err.message}`);
            resolve({
              code: -1,
              result: {
                message: 'Intent execute failed',
                error: err.message,
                pageId: pageId,
                pagePath: pagePath
              }
            });
          });
      } catch (error) {
        hilog.error(DOMAIN, TAG, `执行一步达异常: ${JSON.stringify(error)}`);
        resolve({
          code: -1,
          result: {
            message: `Intent execute failed: ${error}`
          }
        });
      }
    });
  }

  /**
   * 根据pageId获取页面路径
   * 集中管理页面映射关系，便于维护
   *
   * @param pageId 功能页面标识
   * @returns 页面路径，如果pageId无效则返回null
   */
  private getPagePath(pageId: string): string | null {
    // 页面ID到页面路径的映射表
    const PAGE_MAP: Record<string, string> = {
      'ViewGuides': 'pages/guide/GuideListPage',
      'SearchDestinations': 'pages/search/SearchPage',
      'MyTrips': 'pages/trip/MyTripsPage',
      'FavoriteGuides': 'pages/favorite/FavoritePage',
      'Settings': 'pages/settings/SettingsPage'
    };

    const pagePath = PAGE_MAP[pageId];
    
    if (pagePath) {
      hilog.info(DOMAIN, TAG, `页面映射: ${pageId} → ${pagePath}`);
    } else {
      hilog.warn(DOMAIN, TAG, `未找到页面映射: ${pageId}`);
    }

    return pagePath || null;
  }
}
