# 地图指定位置名称标记

## 介绍

地图指定位置名称标记是旅游园区类应用中的高频使用场景之一，如对地图中商家、景点、车站等指定位置标记具体名称，便于用户查看。

本示例通过[MapComponent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent)与地图[标记](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-marker)实现对地图指定位置添加标记的功能。

## 效果预览

<img src="screenshots/MapMarker.gif" width="200">

## 实现思路

1. 设置[mapOptions](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-common#section816451553012)对[MapComponent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent)地图组件进行初始化属性，通过参数mapCallback设置地图初始化回调。

```
MapComponent({
  mapOptions: this.mapOptions, // Map组件初始化属性
  mapCallback: this.callback, // 地图初始化回调
  customInfoWindow: this.customInfoWindow // 自定义信息窗
})
```

2. 使用[MarkerOptions](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-common#section559041743210)设置Marker属性，使用[MapComponentController](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map#section816451553012)的[addMarker](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map#section0810361284)方法在地图上添加标记。

```
let markerOptions: mapCommon.MarkerOptions = {
  ... // Marker属性设置
}
let marker = await this.mapController?.addMarker(markerOptions); // 在地图上添加标记
```

3. 使用[on('markerClick')](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map#section65841542135716)监听标记点击事件，点击时打开[customInfoWindow](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent#section7379125210145)自定义信息窗实现标记图片放大效果。

```
this.mapController?.on('markerClick', (marker) => {
  marker.setInfoWindowVisible(true)
});
```

## 约束与限制

- 本示例支持API Version 17 Release及以上版本。
- 本示例支持HarmonyOS 5.0.5 Release SDK及以上版本。
- 本示例需要使用DevEco Studio 5.0.5 Release及以上版本进行编译运行。

## 使用说明

本示例需要开通[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)，并进行相应配置，具体步骤如下：

1. 登录AppGallery Connect网站，选择“我的项目”。
2. 在项目列表中找到您的项目，在项目下的应用列表中选择需要打开“[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)”的应用。
3. 选择API管理，找到“地图服务”开关，打开开关。
4. 确认已经开启“[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)”开放能力，并完成[手动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。
5. 签名完成后，项目即可正常使用。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──components
│  │  ├──ShopDetail.ets                       // 商店详情
│  │  └──TopContent.ets                       // 顶部内容
│  ├──entryability
│  │  └──EntryAbility.ets                     // 程序入口
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──model
│  │  └──DataModel.ets                        // 接口数据
│  └──pages
│     └──Map.ets                              // 地图首页
└──entry/src/main/resources                   // 应用资源目录
```

## 参考文档

[MapComponent（地图组件）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent)

[标记](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-marker)

[mapCommon（地图属性模型）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-common)

[map（地图显示功能）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map)

[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)

[配置调试签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)