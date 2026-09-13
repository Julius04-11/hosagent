"""路线规划应把调用方的模拟出发时间写入时间轴和 ETA。"""
import asyncio

from app.core.route_planner import build_route_plans
from app.models import JourneyContext, TravelGoal


def test_context_now_controls_departure_and_eta():
    goal = TravelGoal(origin="深圳", destination="广州", deadline="23:00")
    early, _ = asyncio.run(build_route_plans(goal, JourneyContext(now="16:30")))
    late, _ = asyncio.run(build_route_plans(goal, JourneyContext(now="18:00")))

    assert early.segments[0].start_time == "16:30"
    assert late.segments[0].start_time == "18:00"
    assert early.eta != late.eta
