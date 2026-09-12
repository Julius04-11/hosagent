"""重规划测试。"""
import asyncio

from app.core.replanner import replan, should_replan
from app.core.route_planner import build_route_plans
from app.models import JourneyContext, TravelGoal, TravelPreference, WeatherData


def _goal(**kw):
    base = dict(origin="杭州东站", destination="上海", deadline="19:00",
                budget=300, luggage=False, preference=TravelPreference.ON_TIME)
    base.update(kw)
    return TravelGoal(**base)


def _context(weather="多云", late=0):
    return JourneyContext(now="16:30", depart_late_minutes=late,
                          weather=WeatherData(city="上海", weather=weather, temperature=26))


def test_rain_triggers_replan():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context("多云")))
    assert main.walk_distance_meters > 500

    need, trigger = should_replan(goal, main, _context("暴雨"))
    assert need is True
    assert "步行" in trigger or "天气" in trigger


def test_replan_switches_to_less_walk():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context("多云")))
    result = asyncio.run(replan(goal, main, _context("暴雨")))
    assert result is not None
    assert result.new_plan.walk_distance_meters < main.walk_distance_meters
    assert result.explanation


def test_late_departure_triggers_replan():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context("多云")))
    need, trigger = should_replan(goal, main, _context("多云", late=15))
    assert need is True
