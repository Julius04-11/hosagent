"""地图路线服务。

根据输入的起终点名生成「具体」候选路线（真实地点名，而非「出发地/目的地」占位）。

- 内置「杭州 -> 上海」演示路线（高铁/地铁/网约车）；
- 其他起终点按通用模板生成：地铁+步行 / 网约车 / 公交+步行；
- 预留真实地图 API（高德 / 百度）注入点：接入后替换 get_candidate_routes
  即可获得准确的距离与耗时（当前为估算值）。
"""
from typing import Any, Dict, List

from app.models import TravelGoal


def _route(segments: List[Dict[str, Any]], walk: int, transfer: int) -> Dict[str, Any]:
    return {"segments": segments, "walk_distance_meters": walk, "transfer_count": transfer}


def _demo_hangzhou_shanghai(destination: str) -> List[Dict[str, Any]]:
    """杭州 -> 上海（含高铁换乘）演示路线，末段目的地用用户实际输入。"""
    dest_near = f"{destination}附近"
    return [
        _route(
            segments=[
                {"mode": "高铁", "from": "杭州东站", "to": "上海虹桥站",
                 "duration_minutes": 55, "distance_meters": 165000, "cost": 110},
                {"mode": "地铁", "from": "上海虹桥站", "to": dest_near,
                 "duration_minutes": 38, "distance_meters": 12600, "cost": 6},
                {"mode": "步行", "from": dest_near, "to": destination,
                 "duration_minutes": 15, "distance_meters": 850, "cost": 0},
            ],
            walk=850, transfer=2,
        ),
        _route(
            segments=[
                {"mode": "高铁", "from": "杭州东站", "to": "上海虹桥站",
                 "duration_minutes": 55, "distance_meters": 165000, "cost": 110},
                {"mode": "网约车", "from": "上海虹桥站", "to": f"{destination}室内入口",
                 "duration_minutes": 25, "distance_meters": 9000, "cost": 55},
            ],
            walk=50, transfer=1,
        ),
        _route(
            segments=[
                {"mode": "网约车", "from": "杭州东站", "to": destination,
                 "duration_minutes": 150, "distance_meters": 175000, "cost": 420},
            ],
            walk=0, transfer=0,
        ),
    ]


def _build_generic_routes(origin: str, destination: str) -> List[Dict[str, Any]]:
    """通用起终点 -> 三套具体候选路线（估算距离/耗时，接入真实地图 API 后替换）。"""
    return [
        # 地铁 + 步行：便宜，步行较多
        _route(
            segments=[
                {"mode": "地铁", "from": f"{origin}站", "to": f"{destination}附近",
                 "duration_minutes": 40, "distance_meters": 12000, "cost": 6},
                {"mode": "步行", "from": f"{destination}附近", "to": destination,
                 "duration_minutes": 12, "distance_meters": 700, "cost": 0},
            ],
            walk=700, transfer=1,
        ),
        # 网约车：快、少步行、稍贵
        _route(
            segments=[
                {"mode": "网约车", "from": origin, "to": destination,
                 "duration_minutes": 30, "distance_meters": 15000, "cost": 45},
            ],
            walk=30, transfer=0,
        ),
        # 公交 + 步行：最便宜、换乘/步行略多
        _route(
            segments=[
                {"mode": "公交", "from": f"{origin}站", "to": f"{destination}站",
                 "duration_minutes": 50, "distance_meters": 13000, "cost": 4},
                {"mode": "步行", "from": f"{destination}站", "to": destination,
                 "duration_minutes": 8, "distance_meters": 500, "cost": 0},
            ],
            walk=500, transfer=2,
        ),
    ]


async def get_candidate_routes(goal: TravelGoal) -> List[Dict[str, Any]]:
    """返回候选路线（尚未评分/组装成 RoutePlan）。"""
    origin = (goal.origin or "").strip() or "出发地"
    destination = (goal.destination or "").strip() or "目的地"

    if "杭州" in origin and "上海" in destination:
        return _demo_hangzhou_shanghai(destination)
    return _build_generic_routes(origin, destination)
