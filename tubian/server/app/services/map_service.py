"""地图路线服务：高德 Web 服务 API。

运行时使用高德地理编码、公交与驾车路径规划；仅当 ``MAP_PROVIDER=mock``
时使用本地测试数据。
"""
import asyncio
import logging
import math
import os
from typing import Any, Dict, List, Optional, Tuple, Union

import httpx

# Load server/.env once before reading provider configuration.
import app.settings  # noqa: F401
from app.models import TravelGoal

logger = logging.getLogger(__name__)

AMAP_GEOCODE_URL = "https://restapi.amap.com/v3/geocode/geo"
AMAP_REGEOCODE_URL = "https://restapi.amap.com/v3/geocode/regeo"
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
    if isinstance(seconds, dict):
        seconds = seconds.get("duration")
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


def _raw_seconds(route: Dict[str, Any]) -> Any:
    """从高德 v5 dict 中提取原始时长（秒），不做分钟转换。

    高德 v5 在 show_fields=cost 时，时长常嵌套在 cost.duration 中，
    而非顶层 duration 字段；公交 busline 还可能用 time 字段。
    """
    value = route.get("duration")
    if isinstance(value, dict):
        value = value.get("duration")
    if value in (None, "") and isinstance(route.get("cost"), dict):
        value = route["cost"].get("duration")
    if value in (None, ""):
        value = route.get("time")
    return value


def _duration_minutes(route: Dict[str, Any]) -> int:
    """高德 v5 的 duration 可能位于路线顶层或 show_fields 返回的 cost 对象内。"""
    return _minutes(_raw_seconds(route))


def _stop_name(stop: Any, fallback: str) -> str:
    if isinstance(stop, dict):
        return str(stop.get("name") or fallback)
    return fallback


def _route_segment(mode: str, start: str, end: str, duration: Any,
                   distance: Any = None, cost: Any = None, note: Optional[str] = None) -> Dict[str, Any]:
    return {
        "mode": mode,
        "from": start,
        "to": end,
        "duration_minutes": _minutes(duration),
        "distance_meters": _meters(distance),
        "cost": _cost(cost),
        "note": note,
    }


def _rail_mode(railway: Dict[str, Any]) -> str:
    """高德把普速、高铁等都放在 railway 中，不能一律标成地铁。"""
    text = " ".join(str(railway.get(key) or "") for key in ("name", "trip", "type"))
    return "高铁" if "高铁" in text or str(railway.get("trip") or "").upper().startswith(("G", "D", "C")) else "火车"


def _expand_transit_segments(transit: Dict[str, Any], origin: str, destination: str) -> List[Dict[str, Any]]:
    """将高德 transit 的原始 segments 展开为可读的换乘步骤。

    高德会在一个 segment 内同时给出接驳出租车和铁路，也会把地铁、公交、步行
    分散在不同 segment 中；保留每一段才能说明用户要如何换乘。
    """
    expanded: List[Dict[str, Any]] = []
    current = origin
    raw_segments = transit.get("segments") or []

    for index, raw in enumerate(raw_segments):
        if not isinstance(raw, dict):
            continue

        taxi = raw.get("taxi") or {}
        if taxi:
            end = str(taxi.get("endname") or "接驳点")
            expanded.append(_route_segment(
                "网约车", str(taxi.get("startname") or current), end,
                taxi.get("drivetime") or taxi.get("duration"), taxi.get("distance"), taxi.get("price"),
                "高德接驳出租车",
            ))
            current = end

        railway = raw.get("railway") or {}
        if railway:
            start = _stop_name(railway.get("departure_stop"), current)
            end = _stop_name(railway.get("arrival_stop"), destination)
            label = str(railway.get("name") or railway.get("trip") or "铁路行程")
            kind = str(railway.get("type") or "")
            expanded.append(_route_segment(
                _rail_mode(railway), start, end, railway.get("time") or railway.get("duration"),
                railway.get("distance"), None, " · ".join(part for part in (label, kind) if part),
            ))
            current = end

        bus = raw.get("bus") or {}
        for line in bus.get("buslines") or []:
            start = _stop_name(line.get("departure_stop"), current)
            end = _stop_name(line.get("arrival_stop"), destination)
            text = " ".join(str(line.get(key) or "") for key in ("name", "type"))
            mode = "地铁" if "地铁" in text or "metro" in text.lower() else "公交"
            via = line.get("via_num")
            note = str(line.get("name") or mode)
            if via not in (None, ""):
                note = f"{note} · 经过 {via} 站"
            expanded.append(_route_segment(
                mode, start, end, _raw_seconds(line), line.get("distance"), line.get("cost"), note,
            ))
            current = end

        walking = raw.get("walking") or {}
        if walking:
            # 高德步行段常没有站点名称；末段明确落到用户输入的目的地，其余保留为换乘步行。
            is_last = not any(isinstance(next_raw, dict) and any(next_raw.values()) for next_raw in raw_segments[index + 1:])
            end = destination if is_last else "下一换乘点"
            expanded.append(_route_segment(
                "步行", current, end, _raw_seconds(walking), walking.get("distance"), 0,
                "步行接驳" if not is_last else "步行至目的地",
            ))
            current = end

    return expanded


async def _geocode(client: httpx.AsyncClient, address: str, key: str) -> tuple[str, str]:
    address = (address or "").strip()
    if not address:
        raise ValueError("出发地或目的地为空，无法调用高德地理编码")
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


def _component_text(value: Any) -> str:
    if isinstance(value, list):
        return str(value[0] if value else "")
    return str(value or "")


async def reverse_geocode_location(location: Any) -> Dict[str, Optional[str]]:
    """使用高德逆地理编码将鸿蒙定位坐标转换为城市/地址。"""
    key = os.getenv("AMAP_API_KEY", "").strip()
    if not key:
        raise RuntimeError("未配置 AMAP_API_KEY，无法根据定位反查城市")

    params = {
        "location": f"{location.lng},{location.lat}",
        "key": key,
        "radius": 1000,
        "extensions": "base",
        "roadlevel": 0,
    }
    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT_SECONDS) as client:
        try:
            response = await client.get(AMAP_REGEOCODE_URL, params=params)
            response.raise_for_status()
            payload = response.json()
        except httpx.HTTPError as exc:
            raise RuntimeError(f"高德逆地理编码网络请求失败：{exc}") from exc

    if payload.get("status") != "1":
        raise RuntimeError(f"高德逆地理编码失败：{payload.get('info', 'unknown error')}")

    regeocode = payload.get("regeocode") or {}
    component = regeocode.get("addressComponent") or {}
    city = _component_text(component.get("city"))
    province = _component_text(component.get("province"))
    district = _component_text(component.get("district"))
    if not city and province.endswith("市"):
        city = province
    if not city:
        city = district or province
    if not city:
        raise RuntimeError("高德逆地理编码未返回城市信息")

    return {
        "city": city,
        "district": district or None,
        "formattedAddress": _component_text(regeocode.get("formatted_address")) or None,
    }


def _transit_candidate(payload: Dict[str, Any], origin: str, destination: str) -> Optional[Dict[str, Any]]:
    route = payload.get("route") or {}
    transits = route.get("transits") or route.get("paths") or []
    if not transits:
        return None
    transit = transits[0]
    segments = _expand_transit_segments(transit, origin, destination)
    if not segments:
        return None
    walk = _meters(transit.get("walking_distance"))
    cost_data = transit.get("cost") or {}
    nested_transit_fee = cost_data.get("transit_fee") if isinstance(cost_data, dict) else None
    cost = _cost(transit.get("transit_fee") or nested_transit_fee or cost_data)
    # 票价常只在 transit 顶层出现。将未分摊部分记到首段公共交通，确保方案总价
    # 与高德的 transit_fee 一致，同时页面能解释这笔费用来自公共交通行程。
    segment_cost = sum(float(segment.get("cost") or 0) for segment in segments)
    if cost > segment_cost:
        public_segment = next((segment for segment in segments if segment["mode"] in {"高铁", "火车", "地铁", "公交"}), segments[0])
        public_segment["cost"] = round(float(public_segment.get("cost") or 0) + cost - segment_cost, 1)
        suffix = "含高德公共交通总票价"
        public_segment["note"] = f"{public_segment.get('note')} · {suffix}" if public_segment.get("note") else suffix
    # 换乘只计算公共交通工具之间的切换；步行/接驳车不会被误报为一次换乘。
    public_modes = {"高铁", "火车", "地铁", "公交"}
    transfer_count = max(0, sum(s["mode"] in public_modes for s in segments) - 1)
    return _route(
        segments=segments,
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


async def _get_amap_routes(goal: TravelGoal, key: str) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
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
    return candidates, {
        "provider": "amap",
        "label": "高德 Web 服务路线响应",
        "responses": {"transit": transit_payload, "driving": driving_payload},
    }


def _filter_by_transport_modes(candidates: List[Dict[str, Any]], modes: List[str]) -> List[Dict[str, Any]]:
    """按用户偏好交通方式过滤候选路线。

    每条候选路线的 segments 包含 mode 字段（公交/地铁/高铁/网约车/步行/火车）。
    若路线所有非步行段的 mode 都在用户选择内，则保留。
    用户不选任何方式时不做过滤（= 不限）。
    """
    if not modes:
        return candidates
    mode_set = set(modes)
    filtered = []
    for cand in candidates:
        non_walk_modes = {s["mode"] for s in cand["segments"] if s["mode"] != "步行"}
        if not non_walk_modes or non_walk_modes.issubset(mode_set):
            filtered.append(cand)
    # 若过滤后为空（用户选的方式无可用路线），回退到全部候选，避免无方案可出
    return filtered if filtered else candidates


async def get_candidate_routes(goal: TravelGoal, include_debug: bool = False) -> Union[List[Dict[str, Any]], Tuple[List[Dict[str, Any]], Dict[str, Any]]]:
    """获取候选路线；生产联调模式不自动回退 Mock。"""
    key = os.getenv("AMAP_API_KEY", "").strip()
    provider = os.getenv("MAP_PROVIDER", "auto").lower()
    if provider == "mock":
        routes = _fallback_routes(goal)
        debug = {"provider": "mock", "label": "本地 Mock 路线", "responses": None}
        return (routes, debug) if include_debug else routes
    if not key:
        raise RuntimeError("未配置 AMAP_API_KEY，无法获取真实路线")

    try:
        routes, debug = await _get_amap_routes(goal, key)
        routes = _filter_by_transport_modes(routes, goal.transport_modes)
        return (routes, debug) if include_debug else routes
    except (httpx.HTTPError, KeyError, TypeError, ValueError) as exc:
        raise RuntimeError(f"高德路径规划失败：{exc}") from exc
