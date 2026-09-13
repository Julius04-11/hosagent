# 途变 · 全域行程自适应 Agent

基于 HarmonyOS 的真实动态出行助手：在用户行程变化时**主动提醒、自动重规划**，并给出安全、准时、舒适的下一步行动。

本项目依据《需求文档》《开发文档》落地，Agent 决策大脑采用 **Python + FastAPI**（规则引擎），客户端采用 **HarmonyOS + ArkTS/ArkUI**。

---

## 目录结构

```text
tubian/
├─ 开发步骤.md                 # 开发步骤文档（落地路线图）
├─ README.md                   # 本文档
├─ server/                     # Agent 后端（FastAPI）
│  ├─ app/
│  │  ├─ main.py               # 入口
│  │  ├─ api/routes.py         # 4 个 REST 接口
│  │  ├─ core/                 # 决策核心（解析/评分/PlanB/状态机/重规划/解释）
│  │  ├─ models/schemas.py     # 数据模型（camelCase JSON）
│  │  └─ services/             # 天气/地图/定位 Mock 服务（可替换真实 API）
│  ├─ tests/                   # 16 个 pytest 用例
│  ├─ demo.py                  # 端到端演示脚本
│  └─ requirements.txt
└─ app/                        # HarmonyOS 客户端（ArkTS）
   └─ entry/src/main/ets/
      ├─ pages/                # 7 个页面
      ├─ components/           # 6 个通用组件
      ├─ models/               # 数据模型
      ├─ services/             # 网络/定位/通知/存储
      ├─ stores/               # 全局行程状态
      └─ utils/                # 工具与样式常量
```

---

## 快速开始：后端

```bash
cd server
pip install -r requirements.txt

# 启动服务（默认 8000 端口）
uvicorn app.main:app --reload

# 跑自动化测试
python -m pytest -q

# 跑端到端演示（无需启动服务，直接展示完整主链路）
python demo.py
```

### 真实数据配置

后端已接入 Open-Meteo 的地点解析与实时天气，默认生效且网络异常会自动回退 Mock。
地图路线使用高德 Web 服务 API；请在高德控制台创建 **Web 服务** 类型 Key，并仅通过
本机环境变量配置，不能提交到仓库：

完整的变量说明、Key 获取步骤与验证方式见 [`server/ENVIRONMENT.md`](server/ENVIRONMENT.md)。

```powershell
Copy-Item .env.example .env
$env:AMAP_API_KEY = '你的高德 Web 服务 Key'
$env:MAP_PROVIDER = 'amap'
```

执行真实 API 冒烟测试：

```powershell
$env:RUN_LIVE_API_TESTS = '1'
python -m pytest -q
```

未配置高德 Key 时，地图服务继续使用既有 Mock；这是一种明确降级，而不是伪造实时路线。

接口一览：

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/health` | GET | 健康检查 |
| `/api/parse-goal` | POST | 自然语言目标解析 |
| `/api/plan-route` | POST | 主方案 + Plan B + 风险提示 |
| `/api/update-status` | POST | 当前旅程阶段 + 下一步动作 |
| `/api/replan` | POST | 动态重规划 |

---

## 快速开始：客户端

见 [`app/README.md`](app/README.md)。核心思路：在 DevEco Studio 新建 Empty Ability 工程后，
将 `app/entry/src/main/ets/` 覆盖复制进去即可；`ApiService` 网络异常时自动回退 Mock，可脱离后端独立演示。

---

## 演示脚本（验收流程）

```text
1. 打开途变 App
2. 输入：我明天从杭州东站去上海看演唱会，晚上7点前必须入场
3. 识别目标（出发地/目的地/截止时间/偏好）
4. 主方案：高铁 + 地铁 + 步行（预计 18:18 到达，116 元，步行 850m）
5. Plan B：高铁 + 网约车（预置「高铁晚点」兜底）
6. 触发暴雨事件
7. 系统判断步行风险升高（should_replan = 天气恶劣且步行距离过长）
8. 推荐改为网约车到室内入口（预计 17:50 到达，费用增加约 49 元）
9. 展示额外费用与预计到达时间
10. 显示准时到达总结
```

> 后端 `python demo.py` 会同时演示：
> - 场景 A（准时优先、无行李）：暴雨触发重规划；
> - 场景 B（带行李箱）：Agent 主动避免 850 米长步行，改推网约车接驳。

---

## 设计要点

- **决策可解释**：所有关键判断由规则引擎 + 真实数据校验（需求文档 §8.4），不依赖大模型做最终决策。
- **评分模型**：准时率 / 预算 / 步行 / 换乘 / 天气风险 / 夜间安全 / 用户偏好，加权打分（开发文档 §9.3）。
- **Plan B 预置**：始终预置「晚点兜底」+ 按风险条件追加（行李 / 暴雨 / 出门晚 / 换乘多 / 超时）。
- **数据可替换**：天气/地图/定位为 Mock 实现，接口已预留真实 API（和风天气 / 高德地图 / HarmonyOS 定位）注入点。
- **契约一致**：后端 JSON 全部 camelCase，与《开发文档》§6/§10 及客户端模型一一对应。
