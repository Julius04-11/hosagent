// 动画工具类 - 使用正确的组件引用类型

// 定义变换类型接口
interface TransformValue {
  x: number;
  y: number;
}

// 定义旋转值接口
interface RotateValue {
  angle: number;
}

// 定义缩放值接口
interface ScaleValue {
  x: number;
  y: number;
}

// 定义组件引用类型
interface ComponentRef {
  text?: string;
  scale?: (value: ScaleValue) => void;
  opacity?: (value: number) => void;
  translate?: (value: TransformValue) => void;
  rotate?: (value: RotateValue) => void;
}

// 动画工具类
export class AnimationUtils {
  
  // 地址交换动画
  public static async swapAddresses(
    uiContext: UIContext,
    departureRef: ComponentRef,
    destinationRef: ComponentRef,
    duration: number = 500
  ): Promise<void> {
    return new Promise((resolve) => {
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseInOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        // 交换地址内容
        if (departureRef.text !== undefined && destinationRef.text !== undefined) {
          const tempText = departureRef.text;
          departureRef.text = destinationRef.text;
          destinationRef.text = tempText;
        }
      });
    });
  }

  // 气泡弹出动画
  public static bubblePopIn(
    uiContext: UIContext,
    targetRef: ComponentRef,
    duration: number = 300
  ): Promise<void> {
    return new Promise((resolve) => {
      // 初始状态：缩放为0，透明度为0
      if (targetRef.scale) {
        targetRef.scale({ x: 0, y: 0 });
      }
      if (targetRef.opacity) {
        targetRef.opacity(0);
      }
      
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.scale) {
          targetRef.scale({ x: 1, y: 1 });
        }
        if (targetRef.opacity) {
          targetRef.opacity(1);
        }
      });
    });
  }

  // 气泡弹出动画
  public static bubblePopOut(
    uiContext: UIContext,
    targetRef: ComponentRef,
    duration: number = 200
  ): Promise<void> {
    return new Promise((resolve) => {
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseIn,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.scale) {
          targetRef.scale({ x: 0, y: 0 });
        }
        if (targetRef.opacity) {
          targetRef.opacity(0);
        }
      });
    });
  }

  // 标记点添加动画
  public static markerAddAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef,
    duration: number = 400
  ): Promise<void> {
    return new Promise((resolve) => {
      // 初始状态
      if (targetRef.scale) {
        targetRef.scale({ x: 0, y: 0 });
      }
      if (targetRef.opacity) {
        targetRef.opacity(0);
      }
      
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.scale) {
          targetRef.scale({ x: 1, y: 1 });
        }
        if (targetRef.opacity) {
          targetRef.opacity(1);
        }
      });
    });
  }

  // 标记点删除动画
  public static markerRemoveAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef,
    duration: number = 300
  ): Promise<void> {
    return new Promise((resolve) => {
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseIn,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.scale) {
          targetRef.scale({ x: 0, y: 0 });
        }
        if (targetRef.opacity) {
          targetRef.opacity(0);
        }
      });
    });
  }

  // 收藏状态切换动画
  public static favoriteToggleAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef,
    isFavorite: boolean,
    duration: number = 200
  ): Promise<void> {
    return new Promise((resolve) => {
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseInOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.scale) {
          if (isFavorite) {
            targetRef.scale({ x: 1.2, y: 1.2 });
          } else {
            targetRef.scale({ x: 0.8, y: 0.8 });
          }
        }
      });
      
      // 恢复原始大小
      setTimeout(() => {
        uiContext.animateTo({
          duration: duration,
          curve: Curve.EaseInOut
        }, () => {
          if (targetRef.scale) {
            targetRef.scale({ x: 1, y: 1 });
          }
        });
      }, duration);
    });
  }

  // 页面切换动画
  public static pageTransitionAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef,
    direction: 'left' | 'right' | 'up' | 'down' = 'right',
    duration: number = 300
  ): Promise<void> {
    return new Promise((resolve) => {
      // 初始状态
      const initialTransform = AnimationUtils.getInitialTransform(direction);
      if (targetRef.translate) {
        targetRef.translate(initialTransform);
      }
      if (targetRef.opacity) {
        targetRef.opacity(0);
      }
      
      uiContext.animateTo({
        duration: duration,
        curve: Curve.EaseOut,
        onFinish: () => {
          resolve();
        }
      }, () => {
        if (targetRef.translate) {
          targetRef.translate({ x: 0, y: 0 });
        }
        if (targetRef.opacity) {
          targetRef.opacity(1);
        }
      });
    });
  }

  // 获取初始变换状态
  private static getInitialTransform(direction: string): TransformValue {
    switch (direction) {
      case 'left':
        return { x: -300, y: 0 };
      case 'right':
        return { x: 300, y: 0 };
      case 'up':
        return { x: 0, y: -300 };
      case 'down':
        return { x: 0, y: 300 };
      default:
        return { x: 300, y: 0 };
    }
  }

  // 加载动画
  public static loadingAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef,
    duration: number = 1000
  ): void {
    uiContext.animateTo({
      duration: duration,
      iterations: -1, // 无限循环
      curve: Curve.Linear
    }, () => {
      if (targetRef.rotate) {
        targetRef.rotate({ angle: 360 });
      }
    });
  }

  // 停止加载动画
  public static stopLoadingAnimation(
    uiContext: UIContext,
    targetRef: ComponentRef
  ): void {
    uiContext.animateTo({
      duration: 0
    }, () => {
      if (targetRef.rotate) {
        targetRef.rotate({ angle: 0 });
      }
    });
  }
}