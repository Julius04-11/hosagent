"""路线评分与准时概率估算（《开发文档》§9.3）。

关键判断由规则引擎完成，不依赖大模型（需求文档 §8.4）。
"""
from typing import Tuple

from app.models import JourneyContext, RiskLevel, RoutePlan, TravelGoal, TravelPreference
from app.utils.time_util import to_minutes

# 触发「少步行 / 重规划」的恶劣天气集合
BAD_WEATHER = {"暴雨", "大雨", "台风", "暴雪", "雷暴"}


def estimate_reliability_from_buffer(buffer: int) -> Tuple[float, RiskLevel]:
    """根据到达截止缓冲分钟数，估算准时概率与风险等级。"""
    if buffer >= 30:
        prob = 0.95
    elif buffer >= 15:
        prob = 0.85
    elif buffer >= 0:
        prob = 0.70
    elif buffer >= -15:
        prob = 0.40
    else:
        prob = 0.15

    if prob >= 0.85:
        risk = RiskLevel.LOW
    elif prob >= 0.6:
        risk = RiskLevel.MEDIUM
    else:
        risk = RiskLevel.HIGH
    return prob, risk


def estimate_reliability(eta: str, deadline: str) -> Tuple[float, RiskLevel]:
    """根据「截止时间 - 预计到达」的缓冲，估算准时概率与风险等级。"""
    return estimate_reliability_from_buffer(to_minutes(deadline) - to_minutes(eta))


def deadline_buffer(departure: str, deadline: str, duration_minutes: int) -> int:
    """返回从 departure 出发后，抵达时距离 deadline 还剩多少分钟。"""
    available = to_minutes(deadline) - to_minutes(departure)
    if available < 0:
        available += 24 * 60
    return available - duration_minutes


def score_route(plan: RoutePlan, goal: TravelGoal, context: JourneyContext) -> float:
    """对一条路线打分，返回越高越优。"""
    score = 100.0
    departure = plan.segments[0].start_time if plan.segments else None
    buffer = deadline_buffer(departure, goal.deadline, plan.duration_minutes) if departure else to_minutes(goal.deadline) - to_minutes(plan.eta)
    eta = to_minutes(plan.eta)

    # 超时
    if buffer < 0:
        score -= 50

    # 超预算
    if goal.budget is not None and plan.cost > goal.budget:
        score -= 20

    # 软性成本项：预算内越便宜越好（小额，反映用户普遍偏好）
    if goal.budget is not None and goal.budget > 0 and plan.cost <= goal.budget:
        score += (goal.budget - plan.cost) / goal.budget * 10

    # 带行李长步行
    if goal.luggage and plan.walk_distance_meters > 800:
        score -= 15

    # 恶劣天气长步行
    weather = context.weather.weather if context.weather else ""
    if weather in BAD_WEATHER and plan.walk_distance_meters > 500:
        score -= 20

    # 换乘过多
    if plan.transfer_count >= 3:
        score -= 10

    # 偏好加成
    if goal.preference == TravelPreference.ON_TIME:
        score += plan.on_time_probability * 20
    elif goal.preference == TravelPreference.LESS_WALK:
        score -= plan.walk_distance_meters / 100.0
    elif goal.preference == TravelPreference.LESS_TRANSFER:
        score -= plan.transfer_count * 5
    elif goal.preference == TravelPreference.BUDGET:
        if goal.budget and goal.budget > 0:
            score += max(0.0, goal.budget - plan.cost) / goal.budget * 10

    # 夜间/凌晨安全：步行距离长则扣分
    hour = (eta // 60) % 24
    if (hour >= 22 or hour < 5) and plan.walk_distance_meters > 400:
        score -= 8

    # —— 出行习惯画像权重 ——
    profile = goal.travel_profile
    if profile:
        plan_modes = {s.mode.value for s in plan.segments}
        # 晕车：公交方案大幅扣分，优先地铁/高铁
        if profile.motion_sick and "公交" in plan_modes:
            score -= 20
        # 大件行李：步行距离长和换乘多都扣分
        if profile.heavy_luggage:
            if plan.walk_distance_meters > 400:
                score -= 15
            if plan.transfer_count >= 2:
                score -= 10
        # 带老人/小孩：步行多/换乘多/夜间扣分
        if profile.with_elderly:
            if plan.walk_distance_meters > 300:
                score -= 12
            if plan.transfer_count >= 2:
                score -= 8
        # 预算敏感：费用高扣分
        if profile.budget_sensitive and plan.cost > 50:
            score -= 10
        # 时间敏感：耗时长扣分
        if profile.time_sensitive and plan.duration_minutes > 60:
            score -= 15

    return round(score, 2)
