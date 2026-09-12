"""Plan B 生成（《开发文档》§9.4）。"""
from typing import List

from app.core.explanation import build_plan_b_reason
from app.core.route_scorer import BAD_WEATHER
from app.models import JourneyContext, PlanType, RoutePlan, TravelGoal
from app.utils.time_util import to_minutes


async def generate_plan_b(goal: TravelGoal, main_plan: RoutePlan,
                          context: JourneyContext,
                          alternatives: List[RoutePlan]) -> List[RoutePlan]:
    """针对已知风险预置 Plan B（去重）。alternatives 为除主方案外的候选。"""
    plans_b: List[RoutePlan] = []
    seen_triggers = set()

    def _add(trigger: str, strategy: str) -> None:
        if trigger in seen_triggers:
            return
        alt = _pick_alternative(alternatives, main_plan, strategy)
        if alt is None:
            return
        alt = alt.model_copy(deep=True)
        alt.plan_id = f"{main_plan.plan_id}_b{len(plans_b)}"
        alt.type = PlanType.PLAN_B
        alt.reason = build_plan_b_reason(trigger, alt)
        plans_b.append(alt)
        seen_triggers.add(trigger)

    weather = context.weather.weather if context.weather else ""

    # 始终预置一个「晚点/赶不上」兜底方案（需求文档 §4.1 / §7.5）
    _add("高铁晚点或赶不上", "准时")

    if goal.luggage and main_plan.walk_distance_meters > 800:
        _add("携带行李且步行距离过长", "网约车")
    if weather in BAD_WEATHER and main_plan.walk_distance_meters > 500:
        _add("天气恶劣且步行距离过长", "网约车")
    if context.depart_late_minutes > 10:
        _add("出门晚于计划 10 分钟", "准时")
    if main_plan.transfer_count >= 3:
        _add("换乘次数过多", "少换乘")
    if to_minutes(main_plan.eta) > to_minutes(goal.deadline):
        _add("预计到达时间超过截止时间", "准时")

    return plans_b


def _pick_alternative(alternatives: List[RoutePlan], main_plan: RoutePlan,
                      strategy: str) -> RoutePlan | None:
    """从备选里按策略挑一个，且必须与主方案不同。"""
    if not alternatives:
        return None
    cands = [a for a in alternatives if a.plan_id != main_plan.plan_id]
    if not cands:
        cands = alternatives

    if strategy == "网约车":
        # 优先含网约车段、步行最短
        cands = sorted(cands, key=lambda p: (
            0 if any(s.mode.value == "网约车" for s in p.segments) else 1,
            p.walk_distance_meters,
        ))
    elif strategy == "准时":
        cands = sorted(cands, key=lambda p: (-p.on_time_probability, to_minutes(p.eta)))
    elif strategy == "少换乘":
        cands = sorted(cands, key=lambda p: p.transfer_count)
    else:
        cands = sorted(cands, key=lambda p: p.walk_distance_meters)

    return cands[0] if cands else None
