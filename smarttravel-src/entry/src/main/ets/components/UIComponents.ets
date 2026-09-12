import { router } from '@kit.ArkUI';

// 统一的颜色主题
export class ThemeColors {
  static readonly primary = '#3b82f6';
  static readonly primaryLight = '#dbeafe';
  static readonly secondary = '#f59e0b';
  static readonly success = '#10b981';
  static readonly warning = '#f59e0b';
  static readonly error = '#ef4444';
  static readonly textPrimary = '#1f2937';
  static readonly textSecondary = '#6b7280';
  static readonly textTertiary = '#9ca3af';
  static readonly background = '#f8fafc';
  static readonly cardBackground = Color.White;
  static readonly border = '#e5e7eb';
}

// 统一的字体大小
export class FontSizes {
  static readonly xs = 10;
  static readonly sm = 12;
  static readonly base = 14;
  static readonly lg = 16;
  static readonly xl = 18;
  static readonly xxl = 20;
  static readonly xxxl = 24;
}

// 统一的间距
export class Spacing {
  static readonly xs = 4;
  static readonly sm = 8;
  static readonly base = 12;
  static readonly lg = 16;
  static readonly xl = 20;
  static readonly xxl = 24;
  static readonly xxxl = 32;
}

// 统一的圆角
export class BorderRadius {
  static readonly sm = 8;
  static readonly base = 12;
  static readonly lg = 16;
  static readonly xl = 20;
  static readonly full = 24;
}

// 统一的阴影
export class Shadows {
  static readonly sm = {
    radius: 2,
    color: 'rgba(0,0,0,0.05)',
    offsetX: 0,
    offsetY: 1
  };
  
  static readonly base = {
    radius: 4,
    color: 'rgba(0,0,0,0.05)',
    offsetX: 0,
    offsetY: 2
  };
  
  static readonly lg = {
    radius: 8,
    color: 'rgba(0,0,0,0.1)',
    offsetX: 0,
    offsetY: 4
  };
}

// 现代化卡片组件
@Component
export struct ModernCard {
  @Prop content: () => void;
  @Prop padding?: number = Spacing.lg;
  @Prop margin?: { top?: number, bottom?: number, left?: number, right?: number };
  @Prop borderRadius?: number = BorderRadius.base;
  @Prop shadow?: any = Shadows.base;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.padding)
    .backgroundColor(ThemeColors.cardBackground)
    .borderRadius(this.borderRadius)
    .shadow(this.shadow)
    .margin(this.margin || {})
  }
}

// 现代化按钮组件
@Component
export struct ModernButton {
  @Prop text: string = '';
  @Prop type: 'primary' | 'secondary' | 'outline' = 'primary';
  @Prop size: 'sm' | 'base' | 'lg' = 'base';
  @Prop disabled: boolean = false;
  @Prop onClick?: () => void;

  private getButtonStyle() {
    const styles = {
      primary: {
        backgroundColor: this.disabled ? '#e5e7eb' : ThemeColors.primary,
        fontColor: this.disabled ? '#9ca3af' : Color.White,
        border: { width: 0, color: Color.Transparent }
      },
      secondary: {
        backgroundColor: this.disabled ? '#f3f4f6' : ThemeColors.primaryLight,
        fontColor: this.disabled ? '#9ca3af' : ThemeColors.primary,
        border: { width: 0, color: Color.Transparent }
      },
      outline: {
        backgroundColor: Color.Transparent,
        fontColor: this.disabled ? '#9ca3af' : ThemeColors.primary,
        border: { width: 1, color: this.disabled ? '#e5e7eb' : ThemeColors.primary }
      }
    };
    return styles[this.type];
  }

  private getButtonSize() {
    const sizes = {
      sm: { height: 32, padding: { left: 12, right: 12, top: 6, bottom: 6 }, fontSize: FontSizes.sm },
      base: { height: 40, padding: { left: 16, right: 16, top: 8, bottom: 8 }, fontSize: FontSizes.base },
      lg: { height: 48, padding: { left: 20, right: 20, top: 12, bottom: 12 }, fontSize: FontSizes.lg }
    };
    return sizes[this.size];
  }

  build() {
    Button(this.text)
      .width('100%')
      .height(this.getButtonSize().height)
      .fontSize(this.getButtonSize().fontSize)
      .fontColor(this.getButtonStyle().fontColor)
      .backgroundColor(this.getButtonStyle().backgroundColor)
      .border(this.getButtonStyle().border)
      .borderRadius(BorderRadius.full)
      .padding(this.getButtonSize().padding)
      .enabled(!this.disabled)
      .onClick(() => {
        if (this.onClick && !this.disabled) {
          this.onClick();
        }
      })
  }
}

// 现代化输入框组件
@Component
export struct ModernInput {
  @Prop placeholder: string = '';
  @Prop value: string = '';
  @Prop onTextChange?: (value: string) => void;
  @Prop disabled: boolean = false;

  build() {
    TextInput({ placeholder: this.placeholder, text: this.value })
      .width('100%')
      .height(48)
      .fontSize(FontSizes.base)
      .fontColor(ThemeColors.textPrimary)
      .placeholderColor(ThemeColors.textTertiary)
      .backgroundColor(this.disabled ? '#f9fafb' : Color.White)
      .border({ width: 1, color: this.disabled ? '#e5e7eb' : ThemeColors.border, radius: BorderRadius.full })
      .padding({ left: 16, right: 16 })
      .enabled(!this.disabled)
      .onChange((value: string) => {
        if (this.onTextChange) {
          this.onTextChange(value);
        }
      })
  }
}

// 现代化标签组件
@Component
export struct ModernTag {
  @Prop text: string = '';
  @Prop type: 'default' | 'primary' | 'success' | 'warning' | 'error' = 'default';
  @Prop size: 'sm' | 'base' = 'base';

  private getTagStyle() {
    const styles = {
      default: { backgroundColor: '#f3f4f6', fontColor: ThemeColors.textSecondary },
      primary: { backgroundColor: ThemeColors.primaryLight, fontColor: ThemeColors.primary },
      success: { backgroundColor: '#d1fae5', fontColor: ThemeColors.success },
      warning: { backgroundColor: '#fef3c7', fontColor: ThemeColors.warning },
      error: { backgroundColor: '#fee2e2', fontColor: ThemeColors.error }
    };
    return styles[this.type];
  }

  build() {
    Text(this.text)
      .fontSize(this.size === 'sm' ? FontSizes.xs : FontSizes.sm)
      .fontColor(this.getTagStyle().fontColor)
      .backgroundColor(this.getTagStyle().backgroundColor)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(BorderRadius.sm)
  }
}

// 现代化头像组件
@Component
export struct ModernAvatar {
  @Prop src: Resource | string = '';
  @Prop size: number = 40;
  @Prop border: boolean = false;
  @Prop borderColor: string = ThemeColors.primary;

  build() {
    Image(this.src)
      .width(this.size)
      .height(this.size)
      .borderRadius(this.size / 2)
      .objectFit(ImageFit.Cover)
      .border(this.border ? { width: 2, color: this.borderColor } : { width: 0, color: Color.Transparent })
  }
}

// 现代化列表项组件
@Component
export struct ModernListItem {
  @Prop title: string = '';
  @Prop subtitle?: string = '';
  @Prop icon?: string = '';
  @Prop avatar?: Resource | string = '';
  @Prop rightContent?: () => void;
  @Prop onClick?: () => void;

  build() {
    Row() {
      // 左侧内容
      Row() {
        if (this.avatar) {
          ModernAvatar({ src: this.avatar, size: 40 })
            .margin({ right: 12 })
        } else if (this.icon) {
          Text(this.icon)
            .fontSize(20)
            .margin({ right: 12 })
        }

        Column() {
          Text(this.title)
            .fontSize(FontSizes.base)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.textPrimary)
            .alignSelf(ItemAlign.Start)

          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(FontSizes.sm)
              .fontColor(ThemeColors.textSecondary)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .layoutWeight(1)

      // 右侧内容
      if (this.rightContent) {
        this.rightContent()
      }
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor(ThemeColors.cardBackground)
    .borderRadius(BorderRadius.base)
    .shadow(Shadows.sm)
    .margin({ bottom: Spacing.sm })
    .onClick(() => {
      if (this.onClick) {
        this.onClick();
      }
    })
  }
}

// 现代化分割线组件
@Component
export struct ModernDivider {
  @Prop color: string = ThemeColors.border;
  @Prop height: number = 1;
  @Prop margin: number = Spacing.lg;

  build() {
    Row()
      .width('100%')
      .height(this.height)
      .backgroundColor(this.color)
      .margin({ top: this.margin, bottom: this.margin })
  }
}

// 现代化加载组件
@Component
export struct ModernLoading {
  @Prop size: number = 24;
  @Prop color: string = ThemeColors.primary;

  build() {
    LoadingProgress()
      .width(this.size)
      .height(this.size)
      .color(this.color)
  }
}

// 现代化空状态组件
@Component
export struct ModernEmpty {
  @Prop icon: string = '📭';
  @Prop title: string = '暂无数据';
  @Prop description?: string = '';
  @Prop actionText?: string = '';
  @Prop onAction?: () => void;

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: Spacing.lg })

      Text(this.title)
        .fontSize(FontSizes.lg)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: Spacing.sm })

      if (this.description) {
        Text(this.description)
          .fontSize(FontSizes.base)
          .fontColor(ThemeColors.textSecondary)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Spacing.lg })
      }

      if (this.actionText && this.onAction) {
        ModernButton({
          text: this.actionText,
          type: 'primary',
          onClick: this.onAction
        })
          .width(120)
      }
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
