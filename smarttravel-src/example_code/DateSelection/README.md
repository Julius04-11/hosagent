# 选择日期范围
## 介绍
选择日期范围是旅游园区类应用中高频使用场景之一，如用户在预订酒店时需要选择住宿日期。

本示例使用[Stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-stack)层叠布局和[Grid](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-grid)组件实现选择日期范围后的颜色变化效果。

## 效果预览
<img src="screenshots/dataselection.gif" width="200">

## 实现思路
1. 通过[Grid](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-grid)组件实现日历的日期排列，调用DateUtils.isDayLaterThan函数比较所选日期的早晚，确定日期范围。
2. 通过[Stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-stack)布局，为选中的[GridItem](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-griditem)添加颜色叠加效果。
```
 GridItem(){
   Stack(){
     Text(day.toString())
       .onClick(() => {
        //确定日期范围
        DateUtils.isDayLaterThan(this.startMonth, this.startDay, monthItem.num, day);          
       })
     // 叠加颜色
     Text()
       .backgroundColor();
   }
 }
```
## 约束与限制
* 本示例支持API Version 20 Release及以上版本。
* 本示例支持HarmonyOS 6.0.0 Release SDK及以上版本。
* 本示例需要使用DevEco Studio 6.0.0 Release及以上版本进行编译运行。
## 工程目录
```
├──entry/src/main/ets                  // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets  
│  ├──model
│  │  ├──DataType.ets                  // 数据类型
│  │  ├──GetDate.ets                   // 获取数据
│  │  ├──MonthDataSource.ets           // LazyForEach数据源
│  │  └──TabBarData.ets                // 导航栏数据
│  ├──pages
│  │  ├──CalendarPage.ets              // 日期选择页
│  │  └──MainPage.ets                  // 主页
│  └──util
│     └──DateUtils.ets                 // 日期处理工具类
└──entry/src/main/resources            // 应用资源目录
```
## 参考文档
[Grid](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-grid)

[Stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-stack)

[GridItem](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-griditem)