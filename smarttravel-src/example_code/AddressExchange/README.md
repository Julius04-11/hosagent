# animateTo实现地址左右交换动画

## 介绍

地址交换动画是旅游园区类应用中高频使用场景之一，如用户在订票、打车、导航时会使用到地址交换操作。

本示例使用[animateTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-uicontext-uicontext#animateto)实现出发地与目的地地址左右交换动画。

## 效果预览

<img src="screenshots/change.gif" width="200">

## 使用说明

加载完成后显示地址交换动画页面，点击中间的图标，左右两边地址交换。

## 实现思路

通过[animateTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-uicontext-uicontext#animateto)修改偏移量与旋转角度的值，实现动态更新左右两边地址的显示，完成动画效果。

```
Text(this.cityNameStart)
  .translate({ x: this.translateX }) // 偏移量绑定地址文字实现位置移动
Image($r('app.media.rola'))
  .rotate({ angle: this.rotateAngle }) // 旋转角度绑定图标实现旋转
this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
  this.translateX = this.distance; // 修改偏移量
  this.rotateAngle += this.rotateAddAngle; // 修改旋转角度
})
```

## 约束与限制

- 本示例支持API Version 16 Release及以上版本。
- 本示例支持HarmonyOS 5.0.4 Release SDK及以上版本。
- 本示例需要使用DevEco Studio 5.0.4 Release及以上版本进行编译运行。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  └──HistorySearchModel.ets               // 历史数据
│  ├──pages
│  │  └──BuyingTickets.ets                    // 购票主页
│  └──view
│     └──AddressExchangeView.ets              // 地址转换
└──entry/src/main/resources                   // 应用资源目录
```

## 参考文档

[animateTo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-uicontext-uicontext#animateto)