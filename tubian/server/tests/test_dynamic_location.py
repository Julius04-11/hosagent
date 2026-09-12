"""定位驱动的状态机与重规划测试。"""
import asyncio

from app.core.journey_state_machine import assess_location, get_journey_state
from app.core.replanner import replan, should_replan
from app.core.route_planner import build_route_plans
from app.models import (
    JourneyContext, JourneyState, LocationData, TravelGoal,
    TravelPreference, WeatherData,
)


def _goal(**kw):
    base = dict(origin="杭州东站", destination="上海", deadline="19:00",
                budget=300, luggage=False, preference=TravelPreference.ON_TIME)
    base.update(kw)
    return TravelGoal(**base)


def _context(weather="多云", loc=None, now="16:30"):
    return JourneyContext(now=now, location=loc,
                          weather=WeatherData(city="上海", weather=weather, temperature=26))


def _main_plan():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context()))
    return goal, main


def test_location_driven_states():
    goal, plan = _main_plan()
    s, _ = get_journey_state(goal, plan, LocationData(lat=30.291, lng=120.211), None)
    assert s == JourneyState.PREPARE

    s2, _ = get_journey_state(goal, plan, LocationData(lat=31.197, lng=121.326), None)
    assert s2 == JourneyState.TRANSFER

    s3, _ = get_journey_state(goal, plan, LocationData(lat=31.231, lng=121.475), None)
    assert s3 == JourneyState.ARRIVED


def test_off_route_detected():
    goal, plan = _main_plan()
    a = assess_location(plan, LocationData(lat=30.0, lng=119.0))
    assert a["off_route"] is True


def test_off_route_triggers_replan():
    goal, plan = _main_plan()
    need, trigger = should_replan(goal, plan, _context(loc=LocationData(lat=30.0, lng=119.0)))
    assert need is True
    assert "偏离" in trigger


def test_behind_schedule_from_location():
    goal, plan = _main_plan()
    # 仍在杭州东站，但已 18:00（计划 16:30 出发），应触发「已错过出发时间」
    need, trigger = should_replan(goal, plan,
                                  _context(loc=LocationData(lat=30.291, lng=120.211), now="18:00"))
    assert need is True
    assert "出发" in trigger


def test_replan_returns_faster_plan():
    goal, plan = _main_plan()
    result = asyncio.run(replan(goal, plan, _context(loc=LocationData(lat=30.291, lng=120.211), now="18:00")))
    assert result is not None
    assert result.new_plan.eta <= plan.eta or result.new_plan.duration_minutes < plan.duration_minutes
