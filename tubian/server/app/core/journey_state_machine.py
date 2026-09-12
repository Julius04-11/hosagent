"""旅程状态机（定位驱动，需求文档 §7.6）。

- 传入 location（定位坐标）时，根据「到起点/换乘点/目的地的距离」判断阶段，
  返回具体的下一步动作（含剩余距离）；
- 无定位时回退到「时间驱动」（按分段时间推进）。
"""
from typing import Optional, Tuple

from app.models import JourneyState, LocationData, RoutePlan, TravelGoal
from app.utils.geo import get_coords, haversine
from app.utils.time_util import to_minutes

# 距离阈值（米）
DEST_ARRIVED_M = 500       # 视为已抵达
DEST_ARRIVING_M = 1500     # 视为接近目的地
ORIGIN_NEAR_M = 800        # 仍在出发地附近
TRANSFER_NEAR_M = 600      # 已到换乘点
OFF_ROUTE_M = 3000         # 距最近路线点超过该值视为偏离

# 阶段 -> 动作模板（时间驱动兜底用）
_ACTIONS = {
    JourneyState.PREPARE: "建议 {time} 出门，带好证件、雨具和行李",
    JourneyState.TO_STATION: "前往 {place}，预计 {time} 出发，留意检票口",
    JourneyState.WAITING: "在 {place} 候车，留意检票时间和车次信息",
    JourneyState.ON_BOARD: "乘车中，注意下一站 {place} 的下车出口",
    JourneyState.TRANSFER: "到站换乘，建议按需选择地铁或网约车",
    JourneyState.TO_DEST: "前往目的地，注意入口与集合点，留意天气影响",
    JourneyState.ARRIVING: "接近目的地，准备入场或入住",
    JourneyState.ARRIVED: "已抵达，查看本次出行总结",
}


def _fmt_dist(m: float) -> str:
    if m < 1000:
        return f"{int(m)}米"
    return f"{m / 1000:.1f}公里"


def assess_location(plan: RoutePlan, location: LocationData) -> dict:
    """评估当前定位相对路线的位置，返回距离/偏离信息。"""
    points = [s.from_ for s in plan.segments] + [plan.segments[-1].to]

    nearest = None
    nearest_d = float("inf")
    for p in points:
        c = get_coords(p)
        if c is None:
            continue
        d = haversine(location.lat, location.lng, c[0], c[1])
        if d < nearest_d:
            nearest_d = d
            nearest = p

    dest_d = None
    dc = get_coords(plan.segments[-1].to)
    if dc:
        dest_d = haversine(location.lat, location.lng, dc[0], dc[1])

    return {
        "nearest_point": nearest,
        "nearest_distance_m": round(nearest_d) if nearest_d != float("inf") else None,
        "dest_distance_m": round(dest_d) if dest_d is not None else None,
        "off_route": nearest_d > OFF_ROUTE_M,
    }


def get_journey_state(goal: TravelGoal, plan: RoutePlan,
                      location: Optional[LocationData] = None,
                      now: Optional[str] = None) -> Tuple[JourneyState, str]:
    """返回 (当前阶段, 下一步动作文案)。"""
    if location is not None:
        return _location_based(goal, plan, location)
    return _time_based(goal, plan, now or "12:00")


def _location_based(goal: TravelGoal, plan: RoutePlan,
                    location: LocationData) -> Tuple[JourneyState, str]:
    a = assess_location(plan, location)
    dest_d = a["dest_distance_m"]

    # 目的地邻近
    if dest_d is not None and dest_d < DEST_ARRIVED_M:
        return JourneyState.ARRIVED, "已抵达目的地，本次行程结束"
    if dest_d is not None and dest_d < DEST_ARRIVING_M:
        return JourneyState.ARRIVING, "已接近目的地，准备入场或入住"

    # 仍在出发地附近
    origin = plan.segments[0].from_
    oc = get_coords(origin)
    if oc:
        od = haversine(location.lat, location.lng, oc[0], oc[1])
        if od < ORIGIN_NEAR_M:
            return JourneyState.PREPARE, f"你还在出发地「{origin}」附近，建议尽快出发"

    # 换乘点邻近
    for i in range(len(plan.segments) - 1):
        tp = plan.segments[i].to
        tc = get_coords(tp)
        if tc:
            td = haversine(location.lat, location.lng, tc[0], tc[1])
            if td < TRANSFER_NEAR_M:
                next_mode = plan.segments[i + 1].mode.value
                return JourneyState.TRANSFER, f"已到换乘点「{tp}」，下一步换乘{next_mode}"

    # 偏离路线
    if a["off_route"] and a["nearest_distance_m"] is not None:
        return JourneyState.TO_DEST, \
            f"当前偏离原路线约 {_fmt_dist(a['nearest_distance_m'])}，建议重新规划"

    # 途中
    if dest_d is not None:
        return JourneyState.TO_DEST, f"正在前往目的地，还剩约 {_fmt_dist(dest_d)}"
    return JourneyState.TO_DEST, "正在前往目的地"


def _time_based(goal: TravelGoal, plan: RoutePlan, now: str) -> Tuple[JourneyState, str]:
    segs = plan.segments
    if not segs:
        return JourneyState.PREPARE, _ACTIONS[JourneyState.PREPARE].format(time="12:00", place=goal.destination)

    now_m = to_minutes(now)
    dep = to_minutes(segs[0].start_time or "00:00")
    arr = to_minutes(segs[-1].end_time or "23:59")

    if now_m < dep - 30:
        state = JourneyState.PREPARE
    elif now_m < dep:
        state = JourneyState.TO_STATION
    elif now_m < arr:
        state = _locate_segment_state(now_m, segs)
    elif now_m < arr + 15:
        state = JourneyState.ARRIVING
    else:
        state = JourneyState.ARRIVED

    first = segs[0]
    last = segs[-1]
    return state, _ACTIONS[state].format(time=first.start_time or now, place=last.to or goal.destination)


def _locate_segment_state(now_m: int, segs) -> JourneyState:
    for i, s in enumerate(segs):
        s_start = to_minutes(s.start_time or "00:00")
        s_end = to_minutes(s.end_time or "23:59")
        if s_start <= now_m <= s_end:
            if i == len(segs) - 1:
                return JourneyState.TO_DEST
            if s.mode.value in ("高铁", "公交"):
                return JourneyState.ON_BOARD
            return JourneyState.TRANSFER
    return JourneyState.TO_DEST
