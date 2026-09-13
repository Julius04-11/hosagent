---
version: alpha
colors:
  ink: "#071A2A"
  surface: "#102B40"
  surfaceRaised: "#173A52"
  canvas: "#EAF0F2"
  signal: "#F5B544"
  signalSoft: "#FFE5A6"
  live: "#4FE0AE"
  danger: "#E5655A"
  text: "#F4F8F9"
  muted: "#A9BBC5"
typography:
  display:
    fontFamily: "Georgia, 'Noto Serif SC', serif"
  body:
    fontFamily: "'Noto Sans SC', 'Microsoft YaHei UI', system-ui, sans-serif"
  mono:
    fontFamily: "'Cascadia Code', Consolas, monospace"
rounded:
  card: "18px"
  control: "10px"
  pill: "999px"
spacing:
  page: "clamp(18px, 4vw, 56px)"
  gap: "16px"
components:
  panel:
    background: "#102B40"
    border: "1px solid rgba(234,240,242,0.12)"
  primaryAction:
    background: "#F5B544"
    color: "#071A2A"
---

## Overview

途变的调试界面采用“行程控制台”而不是消费者 App 的卡片陈列：它服务于后端开发者，首要任务是让请求、服务状态和响应链路一眼可见。视觉参考是夜间调度屏上的路线标记；标志性元素是琥珀色信号线，只用于主操作和当前执行状态。

## Colors

`ink`、`surface` 和 `surfaceRaised` 建立深蓝层次；`signal` 是唯一高饱和操作色；`live` 表示服务可达；`danger` 仅表示失败或重规划风险。页面必须保留高对比的浅色正文，不能用颜色作为唯一状态表达。

## Typography

衬线展示字体只用于页面标题和简短数据标题；中文操作文案使用系统无衬线字体；请求/响应 JSON 使用等宽字体。长文本优先完整显示或可滚动查看，不能依赖悬停才能获取关键信息。

## Layout

宽屏为“请求编排 / 响应观察”双栏，窄屏在 760px 以下自然堆叠。页面滚动归属文档本身；响应面板内部仅在 JSON 过长时滚动。运行中的按钮尺寸不变，响应区保留最小高度防止布局跳动。

## Elevation & Depth

通过边框、浅色内描边和低对比阴影区分面板，不使用漂浮式重阴影。背景中的细网格只提示坐标语境，不承载内容。

## Shapes

面板使用 18px 圆角，输入与按钮使用 10px 圆角，端点/状态标签使用胶囊形。没有装饰性图标；所有操作都有明确文字标签。

## Components

静态调试页的 CSS 变量是本文件 token 的唯一运行时映射，定义于 `server/app/static/styles.css` 的 `:root`。表单使用原生控件和显式 label；异步操作共享按钮的 idle/busy/error/success 状态，以及右侧的 `aria-live` 反馈区。

## Do's and Don'ts

- 应显示最后一次 API 响应和请求耗时，便于确认后端真实行为。
- 应在失败时保留用户输入与已获得的方案，给出可操作的错误信息。
- 不显示、复制或持久化服务端 Key。
- 不以浏览器弹窗承载错误或确认操作。
- 不把调试页面的深色控制台风格扩散到鸿蒙客户端 UI。
