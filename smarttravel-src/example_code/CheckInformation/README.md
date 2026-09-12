# 核对用户信息

## 介绍

核对用户信息是旅游园区类应用中的典型场景之一。

本示例基于[TextInput](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-textinput)组件实现手机号、身份证信息的输入及有效性的核对。

## 效果预览

<img src="screenshots/CheckInformation.gif" width="200">

## 实现思路

1. 使用[TextInput](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-textinput)组件编写输入框。
2. 使用正则定义函数检测手机号码是否有效。
```
export function checkPhoneNo(num: string) {
  const PHONE_REGEXP = new RegExp('^(?:(?:\\+|00)86)?1[3-9]\\d{9}$');
  return PHONE_REGEXP.test(num);
}
```
3. 定义身份证号码验证函数，检测身份证号码是否有效。
```
export function checkIDCardNo(id: string): boolean {
  if (id.length !== 18 || !PROVINCE_ID.includes(id.slice(0, 2)) ||
    !isValidDate(`${id.slice(6, 10)}-${id.slice(10, 12)}-${id.slice(12, 14)}`)) {
    return false;
  }
  let ans: number = 0;
  for (let i = 0; i < 17; i++) {
    if (id[i].charCodeAt(0) === 32) {
      return false;
    }
    ans += (2**(17 - i) % 11) * Number(id[i]);
  }
  let res = (12 - ans % 11) % 11;
  if (res === 10) {
    return id[17] === 'X' || id[17] === 'x';
  } else {
    return id[17] === res.toString();
  }
}
```

## 约束与限制

- 本示例支持API Version 17 Release及以上版本。
- 本示例支持HarmonyOS 5.0.5 Release SDK及以上版本。
- 本示例需要使用DevEco Studio 5.0.5 Release及以上版本进行编译运行。

## 工程目录

```
├──entry/src/main/ets                         // 代码区
│  ├──constants
│  │  └──StyleConstants.ets                   // 常量属性值
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  └──MainPage.ets                        // 入口页
│  └──utils
│     └──CheckInformation.ets                // 方法定义
└──entry/src/main/resources                  // 应用资源目录   
```

## 参考文档

[TextInput](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-textinput)