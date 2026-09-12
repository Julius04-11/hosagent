"""动态重规划（《开发文档》§9.6，需求文档 §7.7）。"""
from typing import Optional, Tuple

from app.core.explanation import build_replan_explanation
from app.core.journey_state_machine import assess_location
from app.core.route_planner import build_route_plans
from app.core.route_scorer import BAD_WEATHER
from app.models import (
    JourneyContext, PlanType, ReplanResult, RiskLevel, RoutePlan, TravelGoal,
)
from app.utils.geo import get_coords, haversine
from app.utils.time_util import to_minutes


def should_replan(goal: TravelGoal, current_plan: RoutePlan,
                  context: JourneyContext) -> Tuple[bool, str]:
    """判断原计划是否失效，返回 (是否需要重规划, 触发原因)。

    在原有「天气/行李/出门晚/超时」基础上，新增定位驱动：
    - 定位偏离原路线；
    - 按当前定位估算无法在截止时间前到达。
    """
    eta = to_minutes(current_plan.eta)
    deadline = to_minutes(goal.deadline)
    weather = context.weather.weather if context.weather else ""

    if eta > deadline:
        return True, "预计到达时间超过截止时间"
    if weather in BAD_WEATHER and current_plan.walk_distance_meters > 500:
        return True, "天气恶劣且步行距离过长"
    if goal.luggage and current_plan.walk_distance_meters > 1000:
        return True, "携带行李且步行距离过长"
    if context.depart_late_minutes > 10:
        return True, "出门晚于计划 10 分钟"

    # —— 定位驱动判断 ——
    if context.location is not None:
        a = assess_location(current_plan, context.location)
        if a["off_route"]:
            return True, "当前定位偏离原路线"
        # 仍在出发地，但已过计划出发时间
        origin = current_plan.segments[0].from_
        oc = get_coords(origin)
        if oc is not None and context.now:
            od = haversine(context.location.lat, context.location.lng, oc[0], oc[1])
            first_start = current_plan.segments[0].start_time
            if od < 800 and first_start and to_minutes(context.now) > to_minutes(first_start):
                return True, "仍停留出发地，已错过计划出发时间"
    return False, ""


async def replan(goal: TravelGoal, current_plan: RoutePlan,
                 context: JourneyContext) -> Optional[ReplanResult]:
    """若需重规划，则在当前上下文中重新评分生成新方案并组装结果。"""
    need, trigger = should_replan(goal, current_plan, context)
    if not need:
        return None

    # 用新的上下文（如暴雨/出门晚）重新评分，选出最优方案
    new_main, all_plans = await build_route_plans(goal, context)
    # 偏离路线 -> 直达（网约车，换乘 0）；迟到/超时类 -> 最快方案
    if context.location is not None and assess_location(current_plan, context.location)["off_route"]:
        directs = [p for p in all_plans if p.transfer_count == 0]
        if directs:
            new_main = directs[0]
    elif trigger in ("仍停留出发地，已错过计划出发时间", "预计到达时间超过截止时间", "出门晚于计划 10 分钟"):
        new_main = min(all_plans, key=lambda p: p.duration_minutes)
    new_plan = new_main.model_copy(deep=True)
    new_plan.type = PlanType.REPLAN
    new_plan.plan_id = f"{current_plan.plan_id}_replan"

    extra_cost = round(new_plan.cost - current_plan.cost, 1)
    explanation = build_replan_explanation(current_plan, new_plan, trigger, goal)

    old_status = ("风险升高" if new_plan.risk_level != RiskLevel.LOW
                  else "风险可控")

    return ReplanResult(
        trigger=trigger,
        old_plan_status=old_status,
        new_plan=new_plan,
        extra_cost=extra_cost,
        action="建议切换方案，并按新方案出发",
        explanation=explanation,
        risk_level=new_plan.risk_level,
    )
