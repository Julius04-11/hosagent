"""个人免费铁路查询适配器。

接口盒子提供的免费 12306 查询接口用于课程项目演示。上游账户凭据仅由后端读取，
不向 Agent、鸿蒙客户端或日志响应泄露；查询结果均是短时快照，不能用于出票。
"""
from datetime import date, datetime, timezone
import hashlib
import os
from typing import Any

import httpx

import app.settings  # noqa: F401  # 读取 server/.env

APIHZ_TICKET_URL = "https://cn.apihz.cn/api/12306/api.php"
APIHZ_TIMETABLE_URL = "https://cn.apihz.cn/api/12306/api3.php"
REQUEST_TIMEOUT_SECONDS = 10.0
_DEMO_TRIPS: dict[str, dict[str, str]] = {}


def _credentials() -> tuple[str, str]:
    user_id = os.getenv("APIHZ_USER_ID", "").strip()
    api_key = os.getenv("APIHZ_API_KEY", "").strip()
    if not user_id or not api_key:
        raise RuntimeError("未配置 APIHZ_USER_ID 或 APIHZ_API_KEY，无法使用列车查询工具")
    return user_id, api_key


def _use_demo_provider() -> bool:
    """仅在明确要求离线演示时使用内置数据，默认始终调用真实上游。"""
    return os.getenv("TRAIN_PROVIDER", "apihz").strip().lower() == "mock"


async def _request(url: str, params: dict[str, str]) -> dict[str, Any]:
    user_id, api_key = _credentials()
    try:
        async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT_SECONDS) as client:
            response = await client.get(url, params={"id": user_id, "key": api_key, **params})
            response.raise_for_status()
            payload = response.json()
    except httpx.HTTPError as exc:
        raise RuntimeError("列车查询服务暂时不可用，请稍后重试") from exc
    except ValueError as exc:
        raise RuntimeError("列车查询服务返回了无法解析的数据") from exc

    if not isinstance(payload, dict):
        raise RuntimeError("列车查询服务返回了异常数据")
    if str(payload.get("code", "")) != "200":
        message = str(payload.get("msg") or payload.get("message") or "未知错误")
        raise RuntimeError(f"列车查询失败：{message}")
    return payload


def _records(payload: dict[str, Any]) -> list[dict[str, Any]]:
    records = payload.get("datas") or payload.get("data") or []
    return [item for item in records if isinstance(item, dict)] if isinstance(records, list) else []


def _availability(value: Any) -> str:
    if value in (-1, "-1"):
        return "有"
    if value in (0, "0", "") or value is None:
        return "无"
    return str(value)


def _queried_at() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def _demo_train_order(departure_station: str, arrival_station: str, query_date: date, offset: int) -> str:
    seed = f"{departure_station}|{arrival_station}|{query_date.isoformat()}|{offset}".encode("utf-8")
    return "DEMO" + hashlib.sha256(seed).hexdigest()[:10].upper()


def _demo_ticket_availability(departure_station: str, arrival_station: str, query_date: date) -> dict[str, Any]:
    """生成与输入绑定的稳定演示结果，避免答辩时依赖外网。"""
    templates = [("07:45", "10:12", "有", "12"), ("10:20", "13:05", "8", "有"), ("14:10", "17:18", "无", "3")]
    candidates = []
    for offset, (departure_time, arrival_time, second_class, first_class) in enumerate(templates, start=1):
        train_order = _demo_train_order(departure_station, arrival_station, query_date, offset)
        _DEMO_TRIPS[train_order] = {
            "departureStation": departure_station,
            "arrivalStation": arrival_station,
            "departureTime": departure_time,
            "arrivalTime": arrival_time,
        }
        candidates.append({
            "trainCode": f"G{100 + offset * 27}",
            "trainOrder": train_order,
            "departureStation": departure_station,
            "arrivalStation": arrival_station,
            "departureTime": departure_time,
            "arrivalTime": arrival_time,
            "duration": "约2小时30分",
            "departureDate": query_date.isoformat(),
            "seats": [
                {"seatType": "商务座", "availability": "有" if offset != 3 else "无"},
                {"seatType": "一等座", "availability": first_class},
                {"seatType": "二等座", "availability": second_class},
                {"seatType": "无座", "availability": "有" if offset == 2 else "无"},
            ],
        })
    return {
        "provider": "mock",
        "dataSource": "内置演示列车数据",
        "queriedAt": _queried_at(),
        "departureStation": departure_station,
        "arrivalStation": arrival_station,
        "queryDate": query_date.isoformat(),
        "candidates": candidates,
        "notice": "当前为演示数据，用于展示 Agent 的工具调用与行程规划流程，并非实时 12306 余票。",
    }


def _demo_timetable(train_order: str, query_date: date) -> dict[str, Any]:
    trip = _DEMO_TRIPS.get(train_order, {})
    departure_station = trip.get("departureStation", "出发站")
    arrival_station = trip.get("arrivalStation", "到达站")
    departure_time = trip.get("departureTime", "08:00")
    arrival_time = trip.get("arrivalTime", "10:30")
    stops = [
        {"stationSequence": "01", "stationName": departure_station, "arrivalTime": "----", "departureTime": departure_time, "stopoverTime": "----"},
        {"stationSequence": "02", "stationName": "中途站", "arrivalTime": "09:05", "departureTime": "09:08", "stopoverTime": "03分"},
        {"stationSequence": "03", "stationName": arrival_station, "arrivalTime": arrival_time, "departureTime": "----", "stopoverTime": "----"},
    ]
    return {
        "provider": "mock",
        "dataSource": "内置演示列车数据",
        "queriedAt": _queried_at(),
        "trainOrder": train_order,
        "queryDate": query_date.isoformat(),
        "stops": stops,
        "notice": "当前为演示数据，用于展示 Agent 的工具调用与行程规划流程，并非实时列车时刻。",
    }


async def get_ticket_availability(
    departure_station: str, arrival_station: str, query_date: date,
) -> dict[str, Any]:
    """返回候选列车、首末站到发时刻和席别余票。"""
    if _use_demo_provider():
        return _demo_ticket_availability(departure_station, arrival_station, query_date)

    payload = await _request(APIHZ_TICKET_URL, {
        "add": departure_station,
        "end": arrival_station,
        "y": str(query_date.year),
        "m": str(query_date.month),
        "d": str(query_date.day),
    })
    candidates = []
    for item in _records(payload):
        seats = [
            {"seatType": str(seat.get("type") or "未知席别"), "availability": _availability(seat.get("stock"))}
            for seat in (item.get("seats") or [])
            if isinstance(seat, dict)
        ]
        candidates.append({
            "trainCode": item.get("train_number"),
            "trainOrder": item.get("train_order"),
            "departureStation": item.get("depart_name"),
            "arrivalStation": item.get("arrive_name"),
            "departureTime": item.get("depart_time"),
            "arrivalTime": item.get("arrive_time"),
            "duration": item.get("duration"),
            "departureDate": item.get("date"),
            "seats": seats,
        })
    return {
        "provider": "apihz",
        "dataSource": "接口盒子 12306 余票查询",
        "queriedAt": _queried_at(),
        "departureStation": departure_station,
        "arrivalStation": arrival_station,
        "queryDate": query_date.isoformat(),
        "candidates": candidates,
        "notice": "余票是第三方短时查询快照，仅用于行程规划；最终结果以铁路 12306 为准。",
    }


async def get_train_timetable(train_order: str, query_date: date) -> dict[str, Any]:
    """返回指定列车的经停站和每站到发时刻。"""
    if _use_demo_provider():
        return _demo_timetable(train_order, query_date)

    payload = await _request(APIHZ_TIMETABLE_URL, {
        "train_order": train_order,
        "y": str(query_date.year),
        "m": str(query_date.month),
        "d": str(query_date.day),
    })
    stops = []
    for item in _records(payload):
        stops.append({
            "stationSequence": item.get("station_no"),
            "stationName": item.get("station_name"),
            "arrivalTime": item.get("arrive_time"),
            "departureTime": item.get("start_time"),
            "stopoverTime": item.get("stopover_time"),
        })
    return {
        "provider": "apihz",
        "dataSource": "接口盒子 12306 经停站查询",
        "queriedAt": _queried_at(),
        "trainOrder": train_order,
        "queryDate": query_date.isoformat(),
        "stops": stops,
        "notice": "时刻表是第三方查询结果，仅用于行程规划；实际运行以铁路 12306 与车站公告为准。",
    }
