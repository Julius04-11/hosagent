"""天气服务：Open-Meteo 正式 API + 可控 Mock 兜底。

默认调用 Open-Meteo 的地理编码与实时天气接口；网络、地点解析等异常均回退
到本地数据，因此外部服务不可用不会中断行程规划。测试环境可设置
``WEATHER_PROVIDER=mock``，以保证测试不依赖网络。
"""
import logging
import os
import re
from typing import Optional

import httpx

# Load server/.env once before reading provider configuration.
import app.settings  # noqa: F401
from app.models import WeatherData

logger = logging.getLogger(__name__)

GEOCODING_URL = "https://geocoding-api.open-meteo.com/v1/search"
FORECAST_URL = "https://api.open-meteo.com/v1/forecast"
REQUEST_TIMEOUT_SECONDS = 8.0

_DEFAULT_MOCK: dict[str, WeatherData] = {
    "上海": WeatherData(city="上海", weather="多云", temperature=26, warning=None),
    "杭州": WeatherData(city="杭州", weather="阴", temperature=24, warning=None),
    "深圳": WeatherData(city="深圳", weather="晴", temperature=30, warning=None),
}
# 仅保存测试/演示显式覆盖的值；不能与默认 Mock 混用，否则永远不会请求真实 API。
_OVERRIDES: dict[str, WeatherData] = {}


def _weather_text(code: int) -> str:
    """将 WMO 天气码映射为现有决策引擎使用的中文天气描述。"""
    if code == 0:
        return "晴"
    if code in {1, 2, 3}:
        return "多云"
    if code in {45, 48}:
        return "雾"
    if code in {51, 53, 55, 56, 57, 61, 80}:
        return "小雨"
    if code in {63, 81}:
        return "中雨"
    if code in {65, 82}:
        return "大雨"
    if code in {66, 67}:
        return "冻雨"
    if code in {71, 73, 75, 77, 85, 86}:
        return "暴雪"
    if code in {95, 96, 99}:
        return "雷暴"
    return "多云"


def _lookup_override(city: str) -> Optional[WeatherData]:
    for key, data in _OVERRIDES.items():
        if key in city or city in key:
            return data
    return None


def _mock_weather(city: str) -> WeatherData:
    for key, data in _DEFAULT_MOCK.items():
        if key in city or city in key:
            return data
    return WeatherData(city=city, weather="多云", temperature=25, warning=None)


def _location_queries(place: str) -> list[str]:
    """给地理编码提供原始地点及可用于天气的城市级候选名称。"""
    cleaned = re.sub(r"(?:附近|室内入口)$", "", place).strip()
    queries = [cleaned]
    city_match = re.search(r"[\u4e00-\u9fff]{2,12}(?:市|州|地区)", cleaned)
    if city_match:
        queries.append(city_match.group(0))
    for municipality in ("北京", "上海", "天津", "重庆"):
        if municipality in cleaned:
            queries.append(municipality)
    return list(dict.fromkeys(q for q in queries if q))


async def _get_open_meteo_weather(place: str) -> WeatherData:
    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT_SECONDS) as client:
        location = None
        for query in _location_queries(place):
            response = await client.get(
                GEOCODING_URL,
                params={"name": query, "count": 1, "language": "zh", "format": "json"},
            )
            response.raise_for_status()
            results = response.json().get("results") or []
            if results:
                location = results[0]
                break

        if location is None:
            raise ValueError(f"Open-Meteo 未找到地点：{place}")

        response = await client.get(
            FORECAST_URL,
            params={
                "latitude": location["latitude"],
                "longitude": location["longitude"],
                "current": "temperature_2m,weather_code,precipitation,wind_speed_10m",
                "timezone": "Asia/Shanghai",
            },
        )
        response.raise_for_status()
        current = response.json()["current"]
        weather = _weather_text(int(current["weather_code"]))
        # WMO 天气码是现象代码，不把普通降水误标为官方气象预警。
        warning = "强降水，建议减少步行" if weather in {"大雨", "雷暴", "暴雪"} else None
        return WeatherData(
            city=str(location.get("name") or place),
            weather=weather,
            temperature=float(current["temperature_2m"]),
            warning=warning,
        )


async def get_weather(city: str) -> WeatherData:
    """获取当前天气；显式模拟优先，真实 API 失败时自动回退 Mock。"""
    overridden = _lookup_override(city)
    if overridden is not None:
        return overridden

    if os.getenv("WEATHER_PROVIDER", "open_meteo").lower() == "mock":
        return _mock_weather(city)

    try:
        return await _get_open_meteo_weather(city)
    except (httpx.HTTPError, KeyError, TypeError, ValueError) as exc:
        logger.warning("实时天气获取失败，已回退 Mock：%s", exc)
        return _mock_weather(city)


def override_weather(city: str, weather: str,
                     temperature: Optional[float] = None,
                     warning: Optional[str] = None) -> None:
    """覆盖指定城市天气（用于演示与测试触发暴雨等事件）。"""
    cur = _mock_weather(city)
    _OVERRIDES[city] = WeatherData(
        city=city,
        weather=weather,
        temperature=temperature if temperature is not None else cur.temperature,
        warning=warning,
    )
