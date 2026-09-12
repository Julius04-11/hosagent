"""旅程状态机测试。"""
import asyncio

from app.core.journey_state_machine import get_journey_state
from app.core.route_planner import build_route_plans
from app.models import JourneyContext, JourneyState, TravelGoal, TravelPreference, WeatherData


def _goal():
    return TravelGoal(origin="杭州东站", destination="上海", deadline="19:00",
                      budget=300, luggage=False, preference=TravelPreference.ON_TIME)


def _context():
    return JourneyContext(now="16:30",
                          weather=WeatherData(city="上海", weather="多云", temperature=26))


def test_state_progression():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context()))
    dep = main.segments[0].start_time  # "16:30"

    state_before, _ = get_journey_state(goal, main, None, "15:00")
    assert state_before == JourneyState.PREPARE

    state_onboard, _ = get_journey_state(goal, main, None, "17:00")
    assert state_onboard in (JourneyState.ON_BOARD, JourneyState.TO_STATION)

    state_arrived, _ = get_journey_state(goal, main, None, "20:00")
    assert state_arrived == JourneyState.ARRIVED


def test_next_action_not_empty():
    goal = _goal()
    main, _ = asyncio.run(build_route_plans(goal, _context()))
    for now in ["15:00", "17:00", "20:00"]:
        _, action = get_journey_state(goal, main, None, now)
        assert action and len(action) > 0
