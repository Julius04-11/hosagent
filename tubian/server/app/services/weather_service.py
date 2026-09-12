"""天气服务。

MVP 使用内存 Mock 数据；接口签名已为真实 API 预留注入点，
接入和风天气 / 高德天气时，仅需在 get_weather 内替换实现。
"""
from typing import Optional

from app.models import WeatherData

# 内存 Mock，可被 override_weather 修改以模拟「暴雨」等事件
_STORE: dict[str, WeatherData] = {
    "上海": WeatherData(city="上海", weather="多云", temperature=26, warning=None),
    "杭州": WeatherData(city="杭州", weather="阴", temperature=24, warning=None),
    "深圳": WeatherData(city="深圳", weather="晴", temperature=30, warning=None),
}


async def get_weather(city: str) -> WeatherData:
    """按城市名（或含城市名地点）返回天气。未知城市返回默认多云。

    支持传「上海演唱会场馆」这类地点名，内部按包含关系匹配「上海」。
    """
    for key, data in _STORE.items():
        if key in city or city in key:
            return data
    return WeatherData(city=city, weather="多云", temperature=25, warning=None)


def override_weather(city: str, weather: str,
                     temperature: Optional[float] = None,
                     warning: Optional[str] = None) -> None:
    """覆盖某城市天气（用于演示/测试触发天气事件）。"""
    cur = _STORE.get(city)
    _STORE[city] = WeatherData(
        city=city,
        weather=weather,
        temperature=temperature if temperature is not None else (cur.temperature if cur else 25),
        warning=warning,
    )
