"""路线生成：候选路线 -> 组装 RoutePlan -> 评分排序。

返回 (主方案, 全部方案[按分数降序])。主方案为评分最高者。
"""
from typing import List, Tuple

from app.core.explanation import build_reason
from app.core.route_scorer import estimate_reliability, score_route
from app.models import (
    JourneyContext, PlanType, RoutePlan, RouteSegment, TravelGoal,
)
from app.services.map_service import get_candidate_routes
from app.utils.time_util import add_minutes, to_minutes

# 未指定出发时间时的默认值（演示用）
DEFAULT_DEPARTURE = "16:30"


async def build_route_plans(goal: TravelGoal, context: JourneyContext) -> Tuple[RoutePlan, List[RoutePlan]]:
    candidates = await get_candidate_routes(goal)
    # 明确填写的出发时间优先；否则使用调用方当前时间，避免调试/重规划时永远从 16:30 起算。
    departure = goal.departure_time or context.now or DEFAULT_DEPARTURE

    plans: List[RoutePlan] = []
    for idx, cand in enumerate(candidates):
        plans.append(_assemble_plan(cand, idx, goal, departure))

    scored: List[Tuple[float, RoutePlan]] = [
        (score_route(p, goal, context), p) for p in plans
    ]
    scored.sort(key=lambda x: -x[0])

    ordered = [p for _, p in scored]
    return ordered[0], ordered


def _assemble_plan(candidate: dict, idx: int, goal: TravelGoal, departure: str) -> RoutePlan:
    segments: List[RouteSegment] = []
    cursor = departure
    total_cost = 0.0

    for s in candidate["segments"]:
        start = cursor
        dur = int(s["duration_minutes"])
        end = add_minutes(cursor, dur)
        segments.append(RouteSegment(
            mode=s["mode"],
            from_=s["from"],
            to=s["to"],
            start_time=start,
            end_time=end,
            duration_minutes=dur,
            distance_meters=s.get("distance_meters"),
            cost=s.get("cost"),
        ))
        total_cost += float(s.get("cost") or 0)
        cursor = end

    duration = to_minutes(cursor) - to_minutes(departure)
    eta = cursor
    prob, risk = estimate_reliability(eta, goal.deadline)

    plan = RoutePlan(
        plan_id=f"plan_{idx}",
        type=PlanType.MAIN,
        eta=eta,
        cost=round(total_cost, 1),
        duration_minutes=duration,
        walk_distance_meters=int(candidate["walk_distance_meters"]),
        transfer_count=int(candidate["transfer_count"]),
        risk_level=risk,
        on_time_probability=prob,
        segments=segments,
        reason="",
    )
    plan.reason = build_reason(plan, goal)
    return plan
