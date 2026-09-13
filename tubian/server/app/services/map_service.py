"""地图路线服务：高德 Web 服务 API + 稳定的本地 Mock 兜底。

设置 ``AMAP_API_KEY`` 后自动启用高德地理编码、公交与驾车路径规划；未配置
密钥或上游返回异常时保留原有候选路线，保证比赛演示和离线开发都可进行。
"""
import asyncio
import logging
import math
import os
from typing import Any, Dict, List, Optional

import httpx

# Load server/.env once before reading provider configuration.
import app.settings  # noqa: F401
from app.models import TravelGoal

logger = logging.getLogger(__name__)

AMAP_GEOCODE_URL = "https://restapi.amap.com/v3/geocode/geo"
AMAP_DRIVING_URL = "https://restapi.amap.com/v5/direction/driving"
AMAP_TRANSIT_URL = "https://restapi.amap.com/v5/direction/transit/integrated"
REQUEST_TIMEOUT_SECONDS = 10.0


def _route(segments: List[Dict[str, Any]], walk: int, transfer: int) -> Dict[str, Any]:
    return {"segments": segments, "walk_distance_meters": walk, "transfer_count": transfer}


def _demo_hangzhou_shanghai(destination: str) -> List[Dict[str, Any]]:
    """杭州 -> 上海演示路线，用于无 Key/网络异常的可靠降级。"""
    dest_near = f"{destination}附近"
    return [
        _route(
            segments=[
                {"mode": "高铁", "from": "杭州东站", "to": "上海虹桥站", "duration_minutes": 55, "distance_meters": 165000, "cost": 110},
                {"mode": "地铁", "from": "上海虹桥站", "to": dest_near, "duration_minutes": 38, "distance_meters": 12600, "cost": 6},
                {"mode": "步行", "from": dest_near, "to": destination, "duration_minutes": 15, "distance_meters": 850, "cost": 0},
            ],
            walk=850, transfer=2,
        ),
        _route(
            segments=[
                {"mode": "高铁", "from": "杭州东站", "to": "上海虹桥站", "duration_minutes": 55, "distance_meters": 165000, "cost": 110},
                {"mode": "网约车", "from": "上海虹桥站", "to": f"{destination}室内入口", "duration_minutes": 25, "distance_meters": 9000, "cost": 55},
            ],
            walk=50, transfer=1,
        ),
        _route(
            segments=[
                {"mode": "网约车", "from": "杭州东站", "to": destination, "duration_minutes": 150, "distance_meters": 175000, "cost": 420},
            ],
            walk=0, transfer=0,
        ),
    ]


def _build_generic_routes(origin: str, destination: str) -> List[Dict[str, Any]]:
    return [
        _route(
            segments=[
                {"mode": "地铁", "from": f"{origin}站", "to": f"{destination}附近", "duration_minutes": 40, "distance_meters": 12000, "cost": 6},
                {"mode": "步行", "from": f"{destination}附近", "to": destination, "duration_minutes": 12, "distance_meters": 700, "cost": 0},
            ],
            walk=700, transfer=1,
        ),
        _route(
            segments=[
                {"mode": "网约车", "from": origin, "to": destination, "duration_minutes": 30, "distance_meters": 15000, "cost": 45},
            ],
            walk=30, transfer=0,
        ),
        _route(
            segments=[
                {"mode": "公交", "from": f"{origin}站", "to": f"{destination}站", "duration_minutes": 50, "distance_meters": 13000, "cost": 4},
                {"mode": "步行", "from": f"{destination}站", "to": destination, "duration_minutes": 8, "distance_meters": 500, "cost": 0},
            ],
            walk=500, transfer=2,
        ),
    ]


def _fallback_routes(goal: TravelGoal) -> List[Dict[str, Any]]:
    origin = (goal.origin or "").strip() or "出发地"
    destination = (goal.destination or "").strip() or "目的地"
    if "杭州" in origin and "上海" in destination:
        return _demo_hangzhou_shanghai(destination)
    return _build_generic_routes(origin, destination)


def _minutes(seconds: Any) -> int:
    return max(1, math.ceil(float(seconds or 0) / 60))


def _meters(value: Any) -> int:
    return max(0, int(float(value or 0)))


def _cost(value: Any) -> float:
    """兼容高德 v5 在不同路线类型下返回标量或 cost 对象的费用字段。"""
    if isinstance(value, dict):
        for key in ("transit_fee", "taxi_fee", "taxi_cost", "price", "fee", "cost"):
            if key in value and value[key] not in (None, ""):
                return _cost(value[key])
        return 0.0
    try:
        return float(value or 0)
    except (TypeError, ValueError):
        return 0.0


def _duration_minutes(route: Dict[str, Any]) -> int:
    """高德 v5 的 duration 可能位于路线顶层或 show_fields 返回的 cost 对象内。"""
    value = route.get("duration")
    if isinstance(value, dict):
        value = value.get("duration")
    if value in (None, "") and isinstance(route.get("cost"), dict):
        value = route["cost"].get("duration")
    return _minutes(value)


async def _geocode(client: httpx.AsyncClient, address: str, key: str) -> tuple[str, str]:
    response = await client.get(AMAP_GEOCODE_URL, params={"address": address, "key": key})
    response.raise_for_status()
    payload = response.json()
    if payload.get("status") != "1" or not payload.get("geocodes"):
        raise ValueError(f"高德地理编码失败：{payload.get('info', 'unknown error')}")
    geocode = payload["geocodes"][0]
    city_code = str(geocode.get("citycode") or "")
    if not city_code:
        raise ValueError(f"高德地理编码未返回 citycode：{address}")
    return str(geocode["location"]), city_code


def _transit_candidate(payload: Dict[str, Any], origin: str, destination: str) -> Optional[Dict[str, Any]]:
    route = payload.get("route") or {}
    transits = route.get("transits") or route.get("paths") or []
    if not transits:
        return None
    transit = transits[0]
    segments = transit.get("segments") or []
    all_text = str(segments)
    mode = "地铁" if "地铁" in all_text or "metro" in all_text.lower() else "公交"
    duration = _duration_minutes(transit)
    distance = _meters(transit.get("distance"))
    walk = _meters(transit.get("walking_distance"))
    cost_data = transit.get("cost") or {}
    nested_transit_fee = cost_data.get("transit_fee") if isinstance(cost_data, dict) else None
    cost = _cost(transit.get("transit_fee") or nested_transit_fee or cost_data)
    transfer_count = max(0, len(segments) - 1)
    return _route(
        segments=[{
            "mode": mode, "from": origin, "to": destination,
            "duration_minutes": duration, "distance_meters": distance, "cost": cost,
        }],
        walk=walk,
        transfer=transfer_count,
    )


def _driving_candidate(payload: Dict[str, Any], origin: str, destination: str) -> Optional[Dict[str, Any]]:
    route = payload.get("route") or {}
    paths = route.get("paths") or []
    if not paths:
        return None
    path = paths[0]
    return _route(
        segments=[{
            "mode": "网约车", "from": origin, "to": destination,
            "duration_minutes": _duration_minutes(path),
            "distance_meters": _meters(path.get("distance")),
            "cost": _cost(route.get("taxi_cost") or route.get("cost") or path.get("cost")),
        }],
        walk=0,
        transfer=0,
    )


async def _get_amap_routes(goal: TravelGoal, key: str) -> List[Dict[str, Any]]:
    origin, destination = goal.origin.strip(), goal.destination.strip()
    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT_SECONDS) as client:
        (origin_coord, origin_city), (destination_coord, destination_city) = await asyncio.gather(
            _geocode(client, origin, key), _geocode(client, destination, key),
        )
        transit_params = {
            "origin": origin_coord, "destination": destination_coord, "city1": origin_city,
            "city2": destination_city, "strategy": 0, "show_fields": "cost", "key": key,
        }
        driving_params = {
            "origin": origin_coord, "destination": destination_coord, "strategy": 32,
            "show_fields": "cost", "key": key,
        }
        transit_resp, driving_resp = await asyncio.gather(
            client.get(AMAP_TRANSIT_URL, params=transit_params),
            client.get(AMAP_DRIVING_URL, params=driving_params),
        )
        transit_resp.raise_for_status()
        driving_resp.raise_for_status()
        transit_payload, driving_payload = transit_resp.json(), driving_resp.json()

    candidates = []
    transit = _transit_candidate(transit_payload, origin, destination)
    driving = _driving_candidate(driving_payload, origin, destination)
    if transit:
        candidates.append(transit)
    if driving:
        candidates.append(driving)
    if not candidates:
        raise ValueError("高德路线规划未返回可用方案")
    return candidates


async def get_candidate_routes(goal: TravelGoal) -> List[Dict[str, Any]]:
    """获取候选路线；高德不可用时按原始 Mock 规则降级。"""
    key = os.getenv("AMAP_API_KEY", "").strip()
    provider = os.getenv("MAP_PROVIDER", "auto").lower()
    if provider == "mock" or not key:
        return _fallback_routes(goal)

    try:
        return await _get_amap_routes(goal, key)
    except (httpx.HTTPError, KeyError, TypeError, ValueError) as exc:
        logger.warning("高德路径规划失败，已回退 Mock：%s", exc)
        return _fallback_routes(goal)
