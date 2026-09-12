# 气泡提醒开启定位

## 介绍

气泡提醒开启定位是旅游园区类应用中高频使用的场景之一，如用户为了精准获取周边景点及住宿信息，需要打开定位权限。

本示例使用[Popup](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-popup)实现气泡提示弹窗：在用户首次进入首页后，检查是否开启定位权限，没有开启则左上角地址弹出气泡，提示开启定位权限，开启权限后气泡不再提示。


## 效果预览

<img src="screenshots/locationpermission.gif" width="200">

## 实现思路

1. 生命周期函数aboutToAppear中调用函数checkPermissions()检查是否已经授权，若未授权，弹出气泡提示。

2. 通过[bindPopup](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-popup#bindpopup)绑定气泡，气泡弹出时，点击去打开按钮，请求位置权限代码，通过弹窗向用户申请权限。

    ```
    .bindPopup(this.handlePopup, {
        builder: this.locationPopupBuilder,
        placement: Placement.Bottom,
        offset: { x: 0, y: 0 },
        enableArrow: true,
        showInSubWindow: true,
        autoCancel: true,
        popupColor: 'rgba(56, 55, 54,0.9)', 
        backgroundBlurStyle: BlurStyle.NONE,
        width: '96%',
        radius: 3,
        onStateChange: (e) => {
            if (!e.isVisible) {
              this.handlePopup = false
            }
        }
    })
    ```

## 约束与限制

* 本示例支持 API Version 16 Release及以上版本。
* 本示例支持 HarmonyOS 5.0.4 Release SDK及以上版本。
* 本示例需要使用DevEco Studio 5.0.4 Release及以上版本进行编译运行。

## 权限说明

* 获取模糊位置权限：[ohos.permission.LOCATION](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/permissions-for-all-user#ohospermissionlocation)。
* 获取精确位置权限：[ohos.permission.APPROXIMATELY_LOCATION](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/permissions-for-all-user#ohospermissionapproximately_location)。

## 工程目录

```
├──entry/src/main/ets			    // 代码区
│  ├──components
│  │  └──LocationPopup.ets		    // 位置气泡组件
│  ├──constant
│  │  └──StyleConstant.ets		    // 常量
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──TabIndex.ets			    // 主页
│  └──view
│     ├──HomePageView.ets		    // 首页内容模块
│     └──TabMainView.ets		    // 首页Tab模块
└──entry/src/main/resources		    // 应用资源目录
```

## 参考文档

[Popup控制](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-popup)