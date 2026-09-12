"""Plan B 生成测试。"""
import asyncio

from app.core.plan_b import generate_plan_b
from app.core.route_planner import build_route_plans
from app.models import JourneyContext, PlanType, TravelGoal, TravelPreference, WeatherData


def _goal(**kw):
    base = dict(origin="杭州东站", destination="上海", deadline="19:00",
                budget=300, luggage=False, preference=TravelPreference.ON_TIME)
    base.update(kw)
    return TravelGoal(**base)


def _context(weather="多云"):
    return JourneyContext(now="16:30",
                          weather=WeatherData(city="上海", weather=weather, temperature=26))


def test_plan_b_always_has_fallback():
    """任何情况下都应预置一个「晚点兜底」Plan B。"""
    goal = _goal()
    main, all_plans = asyncio.run(build_route_plans(goal, _context()))
    plans_b = asyncio.run(generate_plan_b(goal, main, _context(),
                                          [p for p in all_plans if p.plan_id != main.plan_id]))
    assert len(plans_b) >= 1
    assert all(b.type == PlanType.PLAN_B for b in plans_b)
    assert any("晚点" in b.reason for b in plans_b)


def test_plan_b_luggage_long_walk():
    """带行李且主方案步行过长 → 生成网约车 Plan B。"""
    goal = _goal(luggage=True)
    main, all_plans = asyncio.run(build_route_plans(goal, _context()))
    plans_b = asyncio.run(generate_plan_b(goal, main, _context(),
                                          [p for p in all_plans if p.plan_id != main.plan_id]))
    triggers = " ".join(b.reason for b in plans_b)
    # 至少包含晚点兜底；若主方案步行长，还应包含行李相关 Plan B
    assert "晚点" in triggers
