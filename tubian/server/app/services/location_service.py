"""定位服务。

真实定位由 HarmonyOS 客户端获取并随请求传入；后端在缺少定位时使用
Mock 兜底（需求文档 §13：定位失败允许手动选择当前位置）。
"""
from app.models import LocationData

# 杭州东站附近 Mock 定位
_MOCK = LocationData(lat=30.246, lng=120.210, accuracy=30)


async def get_location() -> LocationData:
    """返回兜底定位（MVP 固定杭州东站附近）。"""
    return _MOCK
