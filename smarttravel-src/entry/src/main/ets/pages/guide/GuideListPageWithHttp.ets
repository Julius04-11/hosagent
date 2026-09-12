import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { ErrorHandler } from '../../utils/ErrorHandler';
import { SmartTravelApi, GuideData } from '../../api/SmartTravelApi';
import { NetworkService } from '../../services/NetworkService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'GuideListPageWithHttp';
const DOMAIN = 0xFF00;

/**
 * 攻略列表页面（集成 HTTP 请求）
 * 演示分页加载、下拉刷新、搜索等功能
 */
@Entry
@Component
export struct GuideListPageWithHttp {
  @State guides: GuideData[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State searchKeyword: string = '';
  @State showSearch: boolean = false;
  @State errorMessage: string = '';

  private api: SmartTravelApi = SmartTravelApi.getInstance();
  private networkService: NetworkService = NetworkService.getInstance();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.loadGuides();
  }

  /**
   * 加载攻略列表
   */
  private async loadGuides(page: number = 1): Promise<void> {
    // 检查网络状态
    if (!this.networkService.isInternetAvailable()) {
      this.errorMessage = '网络不可用，请检查网络连接';
      ErrorHandler.showToast(this.errorMessage);
      return;
    }

    if (page === 1) {
      this.isLoading = true;
      this.errorMessage = '';
    } else {
      this.isLoadingMore = true;
    }

    try {
      hilog.info(DOMAIN, TAG, `Loading guides page ${page}`);

      const newGuides = await this.api.getGuideList(page, this.pageSize);

      if (page === 1) {
        this.guides = newGuides;
      } else {
        this.guides = this.guides.concat(newGuides);
      }

      this.currentPage = page;
      this.hasMore = newGuides.length >= this.pageSize;

      hilog.info(DOMAIN, TAG, `Loaded ${newGuides.length} guides, total: ${this.guides.length}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load guides: ${JSON.stringify(error)}`);

      const err = error as Error;
      this.errorMessage = err.message || '加载失败';

      // 根据错误类型显示不同提示
      if (this.errorMessage.includes('timeout')) {
        ErrorHandler.showToast('网络超时，请重试');
      } else if (this.errorMessage.includes('network')) {
        ErrorHandler.showToast('网络错误，请检查网络连接');
      } else {
        ErrorHandler.showToast('加载失败，请重试');
      }

      // 如果是首次加载失败，显示错误状态
      if (page === 1) {
        this.guides = [];
      }
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
      this.isLoadingMore = false;
    }
  }

  /**
   * 下拉刷新
   */
  private async onRefresh(): Promise<void> {
    this.isRefreshing = true;
    await this.loadGuides(1);
  }

  /**
   * 加载更多
   */
  private async onLoadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    await this.loadGuides(this.currentPage + 1);
  }

  /**
   * 搜索攻略
   */
  private async searchGuides(): Promise<void> {
    if (!this.searchKeyword.trim()) {
      ErrorHandler.showToast('请输入搜索关键词');
      return;
    }

    // 检查网络状态
    if (!this.networkService.isInternetAvailable()) {
      ErrorHandler.showToast('网络不可用，请检查网络连接');
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      hilog.info(DOMAIN, TAG, `Searching guides: ${this.searchKeyword}`);

      const results = await this.api.searchGuides(this.searchKeyword);
      this.guides = results;
      this.hasMore = false; // 搜索结果不支持分页

      hilog.info(DOMAIN, TAG, `Found ${results.length} guides`);

      if (results.length === 0) {
        this.errorMessage = '未找到相关攻略';
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search failed: ${JSON.stringify(error)}`);
      this.errorMessage = '搜索失败，请重试';
      ErrorHandler.showToast(this.errorMessage);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 清空搜索
   */
  private clearSearch(): void {
    this.searchKeyword = '';
    this.showSearch = false;
    this.loadGuides(1);
  }

  /**
   * 查看攻略详情
   */
  private viewGuideDetail(guide: GuideData): void {
    router.pushUrl({
      url: 'pages/guide/GuideDetailPage',
      params: {
        guideId: guide.id
      }
    });
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '旅游攻略（HTTP版）',
        showBack: true,
        rightIcon: this.showSearch ? '' : '🔍',
        onRightClick: () => {
          this.showSearch = !this.showSearch;
        }
      })

      // 搜索框
      if (this.showSearch) {
        Row() {
          TextInput({ placeholder: '搜索攻略...', text: this.searchKeyword })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#f9f9f9')
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              this.searchGuides();
            })

          Button('搜索')
            .height(40)
            .fontSize(14)
            .margin({ left: 8 })
            .onClick(() => {
              this.searchGuides();
            })

          if (this.searchKeyword) {
            Button('清空')
              .height(40)
              .fontSize(14)
              .backgroundColor('#f0f0f0')
              .fontColor('#666')
              .margin({ left: 8 })
              .onClick(() => {
                this.clearSearch();
              })
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Color.White)
      }

      // 内容区域
      if (this.isLoading && this.guides.length === 0) {
        // 首次加载
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007AFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage && this.guides.length === 0) {
        // 加载失败
        Column() {
          Text('😢')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#666')
            .margin({ bottom: 16 })
          Button('重新加载')
            .onClick(() => {
              this.loadGuides(1);
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.guides.length === 0) {
        // 空状态
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无攻略')
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 攻略列表
        Refresh({ refreshing: this.isRefreshing }) {
          List({ scroller: this.scroller }) {
            ForEach(this.guides, (guide: GuideData) => {
              ListItem() {
                this.GuideItem(guide)
              }
            }, (guide: GuideData) => guide.id)

            // 加载更多指示器
            if (this.hasMore) {
              ListItem() {
                Row() {
                  if (this.isLoadingMore) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .margin({ right: 8 })
                    Text('加载中...')
                      .fontSize(14)
                      .fontColor('#666')
                  } else {
                    Text('上拉加载更多')
                      .fontSize(14)
                      .fontColor('#999')
                  }
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.Center)
              }
            } else if (this.guides.length > 0) {
              ListItem() {
                Text('没有更多了')
                  .fontSize(14)
                  .fontColor('#999')
                  .width('100%')
                  .height(50)
                  .textAlign(TextAlign.Center)
              }
            }
          }
          .width('100%')
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
          .onReachEnd(() => {
            this.onLoadMore();
          })
        }
        .onRefreshing(() => {
          this.onRefresh();
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  GuideItem(guide: GuideData) {
    Column() {
      Row() {
        // 封面图
        if (guide.images && guide.images.length > 0) {
          Image(guide.images[0])
            .width(80)
            .height(80)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
            .margin({ right: 12 })
        } else {
          Column() {
            Text('📷')
              .fontSize(32)
          }
          .width(80)
          .height(80)
          .borderRadius(8)
          .backgroundColor('#f0f0f0')
          .justifyContent(FlexAlign.Center)
          .margin({ right: 12 })
        }

        // 攻略信息
        Column() {
          Text(guide.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a1a1a')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Text(guide.content)
            .fontSize(13)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row() {
            Text(`作者: ${guide.author}`)
              .fontSize(12)
              .fontColor('#999')
              .layoutWeight(1)

            Text(guide.createTime)
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .onClick(() => {
        this.viewGuideDetail(guide);
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12, left: 12, right: 12 })
  }
}
