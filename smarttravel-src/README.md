# SmartTravel - 智慧旅游应用

<div align="center">

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-5.0+-blue.svg)
![ArkTS](https://img.shields.io/badge/ArkTS-Latest-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

基于 HarmonyOS 5.0+ 开发的智慧旅游应用，提供旅游攻略、景点导览、酒店预订、行程规划等一站式旅游服务。

[功能特性](#功能特性) • [技术栈](#技术栈) • [项目结构](#项目结构) • [快速开始](#快速开始) • [开发指南](#开发指南)

</div>

---

## 📱 功能特性

### 核心功能
- **🗺️ 旅游攻略** - 精选旅游攻略，图文并茂，支持收藏和分享
- **📍 景点导览** - AR 实景导航，语音讲解，智能推荐
- **🏨 酒店预订** - 酒店搜索、预订、评价一站式服务
- **📅 行程规划** - 智能行程规划，多日游路线推荐
- **🎫 活动报名** - 旅游活动报名、签到、互动
- **💬 社区互动** - 用户评价、照片分享、旅行日记

### 智能特性
- **🤖 AI 智能助手** - 集成 HarmonyOS 智能体框架，语音交互
- **🎯 个性化推荐** - 基于用户偏好的智能推荐系统
- **📊 数据分析** - 旅游数据统计与可视化
- **🔔 实时通知** - 实况窗展示导航、行程等实时信息

### 技术亮点
- **🎨 现代化 UI** - 遵循 HarmonyOS 设计规范，流畅动画
- **🌐 离线支持** - 本地数据库，支持离线浏览
- **📱 多设备适配** - 手机、平板、折叠屏完美适配
- **🔐 安全可靠** - 数据加密、权限管理、备份恢复

---

## 🛠️ 技术栈

### 开发框架
- **HarmonyOS 5.0+** - 鸿蒙操作系统
- **ArkTS** - 声明式 UI 开发语言
- **ArkUI** - 鸿蒙 UI 框架

### 核心能力
- **意图框架** - @InsightIntentLink、@InsightIntentPage、@InsightIntentFunction
- **智能体框架** - FunctionComponent 智能助手集成
- **实况窗** - LiveView 锁屏实时信息展示
- **定位服务** - GNSS + 网络定位
- **网络通信** - HTTP + RCP 高级网络请求
- **数据存储** - 关系型数据库 + 首选项

### 第三方库
- **地图服务** - 华为地图 Kit
- **AI 服务** - 华为 AI Kit
- **媒体播放** - AVPlayer 音视频播放

---

## 📂 项目结构

```
smarttravel/
├── entry/                          # 主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/      # 应用入口
│   │   │   ├── pages/             # 页面
│   │   │   │   ├── home/          # 首页
│   │   │   │   ├── guide/         # 攻略
│   │   │   │   ├── hotel/         # 酒店
│   │   │   │   ├── activity/      # 活动
│   │   │   │   ├── profile/       # 个人中心
│   │   │   │   └── ...
│   │   │   ├── components/        # 公共组件
│   │   │   ├── services/          # 业务服务
│   │   │   ├── utils/             # 工具类
│   │   │   ├── managers/          # 管理器
│   │   │   ├── database/          # 数据库
│   │   │   ├── intent/            # 意图框架
│   │   │   ├── agent/             # 智能体
│   │   │   └── liveview/          # 实况窗
│   │   ├── resources/             # 资源文件
│   │   │   ├── base/
│   │   │   │   ├── element/       # 颜色、字符串等
│   │   │   │   ├── media/         # 图片资源
│   │   │   │   └── profile/       # 配置文件
│   │   │   └── rawfile/           # 原始文件
│   │   │       └── data/          # JSON 数据
│   │   └── module.json5           # 模块配置
│   └── build-profile.json5        # 构建配置
├── docs/                          # 文档
├── scripts/                       # 脚本工具
├── .gitignore                     # Git 忽略配置
├── build-profile.json5            # 项目构建配置
├── hvigorfile.ts                  # Hvigor 构建脚本
└── README.md                      # 项目说明

```

---

## 🚀 快速开始

### 环境要求
- **DevEco Studio**: 5.0.0 或更高版本
- **HarmonyOS SDK**: API 12 或更高版本
- **Node.js**: 16.x 或更高版本

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/sjkncs/smarttravel.git
   cd smarttravel
   ```

2. **打开项目**
   - 启动 DevEco Studio
   - File → Open → 选择 smarttravel 目录

3. **同步依赖**
   - File → Sync and Refresh Project
   - 等待依赖下载完成

4. **运行项目**
   - 连接 HarmonyOS 设备或启动模拟器
   - 点击 Run 按钮（或按 Shift+F10）

---

## 📖 开发指南

### 代码规范
- 遵循 ArkTS 编码规范
- 使用 ESLint 进行代码检查
- 组件命名采用大驼峰（PascalCase）
- 变量命名采用小驼峰（camelCase）

### 提交规范
```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具链相关
```

### 分支管理
- `main` - 主分支，稳定版本
- `develop` - 开发分支
- `feature/*` - 功能分支
- `hotfix/*` - 紧急修复分支

---

## 🎯 核心功能实现

### 1. 意图框架接入
支持通过小艺语音快速打开应用功能：
- **@InsightIntentLink** - 基于 DeepLink 的页面跳转
- **@InsightIntentPage** - Navigation 架构页面跳转
- **@InsightIntentFunction** - 后台任务执行

### 2. 智能体集成
使用 FunctionComponent 提供智能对话入口：
- 图标组件 - 应用主入口
- 按钮组件 - 功能快捷入口
- 支持预设查询文本

### 3. 实况窗功能
锁屏沉浸式实时信息展示：
- 旅游导航实况窗
- 行程进度实况窗
- 景点排队实况窗

### 4. 定位服务
四种定位场景完整实现：
- 当前位置定位（单次）
- 实时位置定位（持续）
- 应用后台定位（长时任务）
- 历史定位获取（缓存）

### 5. 网络通信
HTTP + RCP 双重网络方案：
- HTTP 基础请求
- RCP 高级功能（缓存、拦截器、重试）
- 多表单提交
- 文件上传下载

---

## 📊 数据管理

### 本地数据库
使用关系型数据库存储：
- 攻略收藏
- 浏览历史
- 离线数据
- 用户偏好

### 数据同步
- 后台数据同步
- 增量更新
- 冲突解决

---

## 🔒 权限说明

应用需要以下权限：
- **位置权限** - 用于定位、导航功能
- **网络权限** - 用于数据获取
- **存储权限** - 用于缓存、离线数据
- **后台运行** - 用于实况窗、后台定位

---

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📝 更新日志

### v1.0.0 (2025-12-27)
- ✨ 初始版本发布
- ✅ 完成核心功能开发
- ✅ 集成意图框架
- ✅ 集成智能体框架
- ✅ 实现实况窗功能
- ✅ 完善定位服务
- ✅ 优化网络通信

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👨‍💻 作者

**sjkncs**
- GitHub: [@sjkncs](https://github.com/sjkncs)

---

## 🙏 致谢

- 感谢 HarmonyOS 团队提供的优秀开发框架
- 感谢所有贡献者的支持

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！**

Made with ❤️ by sjkncs

</div>
