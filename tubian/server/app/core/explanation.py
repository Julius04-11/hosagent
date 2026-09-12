"""推荐原因 / 重规划文案生成（《开发文档》§5.4 文案规范：短、明确、可执行）。"""
from app.models import JourneyContext, RoutePlan, TravelGoal


def build_reason(plan: RoutePlan, goal: TravelGoal) -> str:
    """主方案推荐理由。"""
    parts = []
    if plan.on_time_probability >= 0.85:
        parts.append("预计可准时到达")
    elif plan.on_time_probability >= 0.6:
        parts.append("到达时间较紧张")
    else:
        parts.append("可能无法在截止时间前到达")

    if goal.budget is not None:
        if plan.cost <= goal.budget:
            parts.append(f"费用约 {plan.cost:.0f} 元，在预算内")
        else:
            parts.append(f"费用约 {plan.cost:.0f} 元，超出预算")

    if plan.walk_distance_meters > 500:
        parts.append(f"步行约 {plan.walk_distance_meters} 米")
    if plan.transfer_count >= 2:
        parts.append(f"换乘 {plan.transfer_count} 次")

    return "；".join(parts) + "。"


def _plan_label(plan: RoutePlan) -> str:
    modes = " + ".join(s.mode.value for s in plan.segments)
    return f"{modes}方案"


def build_plan_b_reason(trigger: str, plan: RoutePlan) -> str:
    """Plan B 卡片文案。"""
    return (f"针对「{trigger}」，备选为{_plan_label(plan)}："
            f"预计 {plan.eta} 到达，费用约 {plan.cost:.0f} 元。")


def build_replan_explanation(current: RoutePlan, new: RoutePlan,
                             trigger: str, goal: TravelGoal) -> str:
    """重规划原因解释，模板对齐需求文档 §6.4 示例文案。"""
    extra = round(new.cost - current.cost, 1)
    if extra > 0:
        cost_text = f"费用增加约 {extra:.0f} 元"
    elif extra < 0:
        cost_text = f"费用减少约 {-extra:.0f} 元"
    else:
        cost_text = "费用基本不变"

    return (f"原计划预计 {current.eta} 到达，{trigger}。"
            f"建议切换为{_plan_label(new)}，预计 {new.eta} 到达，{cost_text}。")


def build_next_action_hint(state_value: str, plan: RoutePlan) -> str:
    """用于状态机 next_action 的基础提示（详见 journey_state_machine）。"""
    _ = (state_value, plan)
    return ""
