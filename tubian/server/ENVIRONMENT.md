# 后端环境变量与第三方 API 配置

本文件说明 `tubian/server` 后端运行时所需的环境变量，以及高德 Web 服务 API Key 的申请、配置和验证方法。

## 配置文件

从模板创建本地配置文件：

```powershell
cd D:\environment\test\honmeng\final\hosagent\tubian\server
Copy-Item .env.example .env
```

后端启动时会读取 `server/.env`。该文件已经被 Git 忽略，**不得提交任何真实 Key**。生产部署应在部署平台中配置环境变量，而不应上传 `.env` 文件。

## 变量说明

| 变量 | 默认值 | 作用 |
|---|---|---|
| `WEATHER_PROVIDER` | `open_meteo` | 天气来源。设为 `open_meteo` 时调用真实天气；设为 `mock` 时使用本地演示数据。 |
| `MAP_PROVIDER` | `auto` | 地图来源。`auto` 在存在高德 Key 时启用真实路线，否则自动降级；`mock` 强制使用本地演示路线。 |
| `AMAP_API_KEY` | 空 | 高德 Web 服务 API Key。配置后启用高德地理编码、公交和驾车路径规划。 |
| `RUN_LIVE_API_TESTS` | `0` | 设为 `1` 时运行真实第三方 API 冒烟测试。默认不调用外部 API。 |

示例：

```dotenv
WEATHER_PROVIDER=open_meteo
MAP_PROVIDER=auto
AMAP_API_KEY=替换为你自己的高德Web服务Key
RUN_LIVE_API_TESTS=0
```

## 获取高德 Web 服务 API Key

1. 打开 [高德开放平台控制台](https://console.amap.com/) 并登录/注册开发者账号。
2. 在“应用管理”中创建应用。
3. 在该应用中添加 Key，**服务平台务必选择“Web 服务”**。
4. 复制生成的 Key，填入本机 `server/.env` 的 `AMAP_API_KEY`。
5. 重启后端服务，或重新启动测试命令。

路径规划使用高德 v5 的公交与驾车接口；公交接口需要由地理编码结果提供的 `city1/city2` citycode。详细参数以 [高德路径规划 2.0 文档](https://lbs.amap.com/api/webservice/guide/api/newroute) 和 [Key 创建说明](https://lbs.amap.com/api/webservice/guide/create-project/get-key) 为准。

## 验证配置

先安装依赖并运行不依赖外网的回归测试：

```powershell
python -m pip install -r requirements.txt
python -m pytest -q
```

随后验证真实第三方服务：

```powershell
$env:RUN_LIVE_API_TESTS = '1'
python -m pytest -q tests/test_live_api_integration.py
```

- Open-Meteo 实时天气测试无需 Key。
- 高德路线测试仅在 `AMAP_API_KEY` 存在时执行；若未配置则显示为跳过。
- 任一上游服务异常时，后端会记录告警并自动回退到 Mock 路线/天气，避免打断主流程。

## 安全约束

- 不要把 Key 写入 ArkTS 客户端、源码、测试夹具、截图或日志。
- 只在 FastAPI 后端持有高德 Key，由客户端调用后端接口。
- 若 Key 意外泄露，立即在高德控制台删除或轮换该 Key，并更新部署环境变量。
