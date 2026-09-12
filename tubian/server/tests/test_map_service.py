"""地图路线服务测试：非演示起终点也能生成具体路线。"""
import asyncio

from app.core.route_planner import build_route_plans
from app.models import JourneyContext, TravelGoal, TravelPreference
from app.services.map_service import get_candidate_routes


def _context():
    return JourneyContext(now="16:30")


def test_generic_routes_use_input_names():
    goal = TravelGoal(origin="深圳", destination="广州", deadline="20:00",
                      preference=TravelPreference.ON_TIME)
    routes = asyncio.run(get_candidate_routes(goal))
    assert len(routes) >= 2
    for r in routes:
        for seg in r["segments"]:
            joined = seg["from"] + seg["to"]
            assert "出发地" not in joined
            assert "目的地" not in joined
    modes = [seg["mode"] for r in routes for seg in r["segments"]]
    assert "网约车" in modes


def test_generic_plan_builds_and_scores():
    goal = TravelGoal(origin="深圳", destination="广州", deadline="20:00",
                      budget=200, luggage=True, preference=TravelPreference.ON_TIME)
    main, all_plans = asyncio.run(build_route_plans(goal, _context()))
    assert main.segments
    assert "深圳" in main.segments[0].from_
    # 带行李：应偏向步行更少的方案
    assert main.walk_distance_meters <= 700


def test_hangzhou_shanghai_demo_still_works():
    goal = TravelGoal(origin="杭州", destination="上海", deadline="19:00",
                      preference=TravelPreference.ON_TIME)
    routes = asyncio.run(get_candidate_routes(goal))
    modes = [seg["mode"] for r in routes for seg in r["segments"]]
    assert "高铁" in modes
