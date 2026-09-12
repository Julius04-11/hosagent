"""路线生成与评分测试。"""
import asyncio

from app.core.route_planner import build_route_plans
from app.models import JourneyContext, TravelGoal, TravelPreference, WeatherData


def _goal(**kw):
    base = dict(origin="杭州东站", destination="上海", deadline="19:00",
                budget=300, luggage=False, preference=TravelPreference.ON_TIME)
    base.update(kw)
    return TravelGoal(**base)


def _context(weather="多云"):
    return JourneyContext(now="16:30",
                          weather=WeatherData(city="上海", weather=weather, temperature=26))


def test_no_luggage_cheap_rail_wins():
    """无行李 + 准时优先：便宜的「高铁+地铁+步行」应为主方案。"""
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context()))
    assert main.walk_distance_meters == 850
    assert main.transfer_count == 2


def test_luggage_prefers_less_walk():
    """带行李：应偏向步行更少的方案。"""
    goal = _goal(luggage=True)
    main, _ = asyncio.run(build_route_plans(goal, _context()))
    assert main.walk_distance_meters <= 50


def test_rain_penalizes_long_walk():
    """暴雨下长步行方案应降分（重规划会切到少步行）。"""
    from app.core.route_scorer import score_route
    goal = _goal()
    _, all_plans = asyncio.run(build_route_plans(goal, _context("多云")))
    long_walk = [p for p in all_plans if p.walk_distance_meters > 800][0]

    normal_score = score_route(long_walk, goal, _context("多云"))
    rain_score = score_route(long_walk, goal, _context("暴雨"))
    assert rain_score < normal_score
