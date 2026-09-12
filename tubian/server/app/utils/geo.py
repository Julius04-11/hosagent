"""地理坐标与距离计算工具。

MVP 内置少量地点坐标（演示/常见城市），用于「定位驱动的状态机与重规划」；
接入真实地图/地理编码 API 后，替换 get_coords 即可获得全量准确坐标。
"""
import math
from typing import Optional, Tuple

# 地点名 -> (纬度, 经度)
PLACE_COORDS: dict[str, Tuple[float, float]] = {
    "杭州东站": (30.2910, 120.2110),
    "杭州": (30.2741, 120.1551),
    "上海虹桥站": (31.1970, 121.3260),
    "上海": (31.2304, 121.4737),
    "演唱会场馆": (31.2310, 121.4750),
    "深圳": (22.5431, 114.0579),
    "广州": (23.1291, 113.2644),
    "北京": (39.9042, 116.4074),
    "南京": (32.0603, 118.7969),
    "苏州": (31.2989, 120.5853),
}


def haversine(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """两点球面距离（米）。"""
    r = 6371000.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def get_coords(place: str) -> Optional[Tuple[float, float]]:
    """地点名 -> 坐标；精确匹配优先，否则最长子串匹配（更具体的地点优先）。"""
    if not place:
        return None
    if place in PLACE_COORDS:
        return PLACE_COORDS[place]
    best: Optional[Tuple[float, float]] = None
    best_len = 0
    for key, coords in PLACE_COORDS.items():
        if key in place and len(key) > best_len:
            best = coords
            best_len = len(key)
    return best
