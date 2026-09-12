import { ARNavigationView } from '../../components/ARNavigationComponents';
import { TopNavigationBar } from '../../components/TopNavigationBar';
import { router } from '@kit.ArkUI';

/**
 * AR导航页面
 * 提供AR实景导航功能
 */
@Entry
@Component
export struct ARNavigationPage {
  @State pageTitle: string = 'AR实景导航';

  build() {
    Column() {
      // 顶部导航栏
      TopNavigationBar({
        title: this.pageTitle,
        showBack: true,
        showSearch: false,
        showNotification: false,
        showProfile: false
      })

      // AR导航主界面
      ARNavigationView()
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
