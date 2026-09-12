# 地图添加标记并收藏地址

## 介绍

地图添加标记并收藏地址是旅游园区类应用中高频使用场景之一，如用户在查看地图时， 可以长按地图某处添加标记，并可以收藏该地址。  
本示例基于[MapComponent](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent)和[位置服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-geolocationmanager)实现长按添加标记、展示地址信息以及收藏该地址的功能。

## 效果预览图

<img src="screenshots/AddAndCollectMapMarker.gif" width="200">

## 约束与限制

- 本示例支持API Version 17 Release及以上版本。
- 本示例支持HarmonyOS 5.0.5 Release SDK及以上版本。
- 本示例需要使用DevEco Studio 5.0.5 Release及以上版本进行编译运行。

## 使用说明

本示例需要开通[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)并打开设备“位置”开关，具体步骤如下：

1. 打开设备“位置”开关。
2. 登录AppGallery Connect网站，选择“我的项目”。
3. 在项目列表中找到您的项目，在项目下的应用列表中选择需要打开“[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)”的应用。
4. 选择API管理，找到“地图服务”开关，打开开关。
5. 确认已经开启“[地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516)”开放能力，并完成[手动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。
6. 签名完成后，项目即可正常使用。
7. 运行demo，进入地图页。
8. 长按地图某处添加标记并展示标记点信息。
9. 点击“收藏”按钮可收藏该地址。
10. 点击“点击查看”按钮，可以查看已收藏的地址列表。

## 权限说明

获取位置信息权限：[ohos.permission.LOCATION](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/permissions-for-all-user#ohospermissionlocation)。
获取模糊位置信息权限：[ohos.permission.APPROXIMATELY_LOCATION](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/permissions-for-all-user#ohospermissionapproximately_location)。

## 实现思路

- 基于[on('mapLongClick')](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map#section0257247133915)和[addMarker()](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map#section0810361284)实现长按添加标记。

```
this.mapEventManager.on('mapLongClick', this.mapLongClickcallback)
mapLongClickcallback = (position: mapCommon.LatLng) => {
  let markerOptions: mapCommon.MarkerOptions = {
    position: { latitude: position.latitude, longitude: position.longitude },
    icon: $r('app.media.ic_location_blue'),
    clickable: true,
    draggable: false,
    flat: true,
    zIndex: 1
  }
  this.mapController?.addMarker(markerOptions)
}
```

- 根据长按处的经纬度，基于[geoLocationManager.getAddressesFromLocation()](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-geolocationmanager#geolocationmanagergetaddressesfromlocation)获取地址信息。
```
let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
  {
    "latitude": position.latitude,
    "longitude": position.longitude,
    "maxItems": 1
  }

geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, async (err, data) => {
  if (data) {
    this.currmarker.detailAddress = data[0].placeName as string
    this.currmarker.simpleAddress =
      `${data[0].countryName}${data[0].administrativeArea}${data[0].locality}${data[0].subLocality}`
  }
})
```

## 工程目录

```
├──entry/src/main/ets                  // 代码区
│  ├──components
│  │  ├──AddressDialog.ets             // 地址信息组件
│  │  └──CollectListDialog.ets         // 收藏列表组件
│  ├──constants
│  │  └──StyleConstants.ets            // 常量
│  ├──entryability
│  │  └──EntryAbility.ets    
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets  
│  └──pages
│     └──MapPage.ets                   // 地图页
└──entry/src/main/resources            // 应用资源目录
```

## 依赖模块

无

## 参考文档

[MapComponent（地图组件）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-mapcomponent)  
[map（地图显示功能）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/map-map)  
[@ohos.geoLocationManager（位置服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-geolocationmanager)  
[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)  
[配置调试签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)