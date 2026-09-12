import { router } from '@kit.ArkUI';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { RecommendationSection, RecommendationItem } from '../../components/RecommendationSection';
import { RecommendationService } from '../../services/RecommendationService';
import { ErrorHandler } from '../../utils/ErrorHandler';

interface TechItem {
  id: string;
  name: string;
  image: string;
  description: string;
  tags: string[];
  location: string;
  type: 'AR体验' | 'VR体验' | '智能导览' | '科技展览' | '数字互动';
}

@Entry
@Component
export struct TechPage {
  @State techList: TechItem[] = [
    {
      id: '1',
      name: 'AR实景导航',
      image: 'https://picsum.photos/id/331/400/300',
      description: '使用AR技术提供实景导航服务，让旅行更智能',
      tags: ['AR', '导航', '智能'],
      location: '全城覆盖',
      type: 'AR体验'
    },
    {
      id: '2',
      name: 'VR虚拟旅游',
      image: 'https://picsum.photos/id/332/400/300',
      description: '通过VR技术体验虚拟旅游，提前感受景点魅力',
      tags: ['VR', '虚拟', '体验'],
      location: '各大景点',
      type: 'VR体验'
    },
    {
      id: '3',
      name: '智能语音导览',
      image: 'https://picsum.photos/id/333/400/300',
      description: 'AI智能语音导览，提供个性化讲解服务',
      tags: ['AI', '语音', '导览'],
      location: '主要景点',
      type: '智能导览'
    },
    {
      id: '4',
      name: '科技展览馆',
      image: 'https://picsum.photos/id/334/400/300',
      description: '展示最新科技产品，体验前沿科技',
      tags: ['展览', '科技', '互动'],
      location: '科技馆',
      type: '科技展览'
    },
    {
      id: '5',
      name: '数字互动体验',
      image: 'https://picsum.photos/id/335/400/300',
      description: '多媒体数字互动体验，沉浸式感受',
      tags: ['互动', '数字', '沉浸'],
      location: '各大展馆',
      type: '数字互动'
    }
  ];

  @State searchKeyword: string = '';
  @State recommendations: RecommendationItem[] = [];
  @State selectedCategory: string = '全部';

  aboutToAppear() {
    this.loadRecommendations();
  }

  private loadRecommendations() {
    this.recommendations = RecommendationService.getTechRecommendations();
  }

  build() {
    Column() {
      TopNavigationBar({
        title: '科技体验',
        showBack: true,
        showSearch: true
      })

      // 搜索栏
      TextInput({ placeholder: '搜索科技体验...' })
        .width('90%')
        .height(40)
        .margin({ top: 12, bottom: 16 })
        .borderRadius(20)
        .backgroundColor('#f5f5f5')
        .padding({ left: 16, right: 16 })
        .fontSize(14)
        .onChange((value: string) => {
          this.searchKeyword = value;
        })

      // 分类筛选
      this.CategoryFilter()

      // 推荐区域
      if (this.recommendations.length > 0) {
        RecommendationSection({
          title: '🔥 热门科技体验',
          items: this.recommendations,
          categoryType: 'tech'
        })
      }

      // 科技体验列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredTechList ?? [], (item: TechItem) => {
            this.TechCard(item)
          }, (item: TechItem) => item.id)  // 添加keyGenerator
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }

  get filteredTechList(): TechItem[] {
    if (!this.techList || !Array.isArray(this.techList)) {
      return [];
    }
    
    let filtered = this.techList;
    
    // 分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(item => item.type === this.selectedCategory);
    }
    
    // 搜索筛选
    if (this.searchKeyword) {
      filtered = filtered.filter(item => 
        item.name.includes(this.searchKeyword) ||
        (item.tags ?? []).some(tag => tag.includes(this.searchKeyword)) ||
        item.type.includes(this.searchKeyword) ||
        item.location.includes(this.searchKeyword)
      );
    }
    
    return filtered;
  }

  @Builder TechCard(item: TechItem) {
    Row() {
      Image(item.image)
        .width(100)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column({ space: 8 }) {
        Row() {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .layoutWeight(1)

          Text(item.type)
            .fontSize(11)
            .fontColor('#8b5cf6')
            .backgroundColor('#f3e8ff')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(4)
        }
        .width('100%')

        Text(item.description)
          .fontSize(13)
          .fontColor('#6b7280')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 6 }) {
          ForEach((item.tags ?? []), (tag: string, index: number) => {
            Text(tag)
              .fontSize(11)
              .fontColor('#8b5cf6')
              .backgroundColor('#ede9fe')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }, (tag: string, index: number) => `${item.id}-tag-${index}`)  // 添加keyGenerator
        }
        .width('100%')

        Row({ space: 4 }) {
          Text('📍')
            .fontSize(12)
          Text(item.location)
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      ErrorHandler.safeExecute(async (): Promise<void> => {
        await router.pushUrl({
          url: 'pages/activity/ActivityDetailPage',
          params: { id: item.id, type: 'tech' }
        });
      }, (error: Error): void => ErrorHandler.handleRouterError(error, '科技体验详情'));
    })
  }

  @Builder CategoryFilter() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(['全部', 'AR体验', 'VR体验', '智能导览', '科技展览', '数字互动'], (category: string) => {
          Text(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? Color.White : '#6366f1')
            .backgroundColor(this.selectedCategory === category ? '#6366f1' : '#eef2ff')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .onClick(() => {
              this.selectedCategory = category;
            })
        }, (category: string) => `category-${category}`)  // 添加keyGenerator
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ bottom: 16 })
  }
}

