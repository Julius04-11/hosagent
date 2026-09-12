# 途变 HarmonyOS 客户端

本目录提供「途变」HarmonyOS 客户端（ArkTS/ArkUI）的**源码**。

## 推荐组装方式（在 DevEco Studio 中）

由于 HarmonyOS 工程包含大量 IDE 自动生成的构建配置（hvigor、签名、SDK 版本等），
最稳妥的做法是：

1. 用 **DevEco Studio 新建一个 Empty Ability 工程**（模板会自动生成 `AppScope/`、`hvigor/`、
   `build-profile.json5`、`oh-package.json5`、`entry/` 等完整脚手架）。
2. 将本目录下的 `entry/src/main/ets/` 整个目录**覆盖复制**到新工程的 `entry/src/main/ets/`。
3. 在 `entry/src/main/resources/base/profile/main_pages.json` 中登记 7 个页面（见同目录示例）。
4. 在 `entry/src/main/module.json5` 中补齐定位 / 网络 / 通知权限（见同目录示例）。
5. 同步 `entry/src/main/ets/services/ApiService.ets` 里的 `BASE_URL` 为后端地址
   （真机联调改为局域网 IP，如 `http://192.168.1.100:8000`）。

> 说明：本目录已包含 `entry/src/main/module.json5`、`main_pages.json`、`string.json`、
> `entryability/EntryAbility.ets` 等**参考配置**，但以 DevEco 生成的脚手架为准，避免 SDK 版本差异。

## 源码结构

```text
entry/src/main/ets/
├─ entryability/EntryAbility.ets   # 入口 Ability
├─ pages/                          # 7 个页面
├─ components/                     # 6 个通用组件
├─ models/                         # 数据模型
├─ services/                       # 网络/定位/通知/存储
├─ stores/JourneyStore.ets         # 全局行程状态
└─ utils/                          # 时间/格式化/风险/样式常量
```

## 页面流程

```text
HomePage → ConstraintPage → PlanPage → JourneyPage → ReplanPage → SummaryPage
                                     ↑____________________|（切换方案后回到 JourneyPage）
```

## 联调与 Mock

- `ApiService` 默认**优先请求后端**，网络异常时**自动回退到内置 Mock**（《开发文档》§12.1/§13）。
- 因此即使后端未启动，客户端也能完整跑通演示流程。
- 后端地址在 `services/ApiService.ets` 顶部 `BASE_URL` 常量中配置。
