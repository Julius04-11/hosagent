"""端到端演示脚本：跑通「杭州 -> 上海演唱会」完整主链路。

运行： python demo.py
"""
import asyncio
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from app.core.goal_parser import parse_goal
from app.core.journey_state_machine import get_journey_state
from app.core.plan_b import generate_plan_b
from app.core.replanner import replan, should_replan
from app.core.route_planner import build_route_plans
from app.models import JourneyContext, LocationData, TravelGoal, TravelPreference, WeatherData
from app.services.weather_service import override_weather


def _print_plan(p):
    modes = " + ".join(s.mode.value for s in p.segments)
    print(f"    [{p.type.value}] {modes}")
    print(f"       eta={p.eta}  费用={p.cost:.0f}元  耗时={p.duration_minutes}min  "
          f"步行={p.walk_distance_meters}m  换乘={p.transfer_count}次  "
          f"风险={p.risk_level.value}  准时率={p.on_time_probability:.0%}")
    print(f"       理由：{p.reason}")


async def scenario_a():
    """场景 A：准时优先、无行李 —— 展示暴雨触发重规划。"""
    print("\n" + "=" * 64)
    print("场景 A：准时优先（无行李），主方案「高铁+地铁+步行」，暴雨触发重规划")
    print("=" * 64)
    text = "我明天从杭州东站去上海看演唱会，晚上7点前必须入场"
    goal, missing = parse_goal(text)
    print("\n[1] 目标解析：", goal.model_dump(mode="json"), " 缺失：", missing)

    ctx = JourneyContext(now="16:30", weather=WeatherData(city="上海", weather="多云", temperature=26))
    main, all_plans = await build_route_plans(goal, ctx)
    print("\n[2] 主方案：")
    _print_plan(main)

    backups = await generate_plan_b(goal, main, ctx, all_plans[1:])
    print("\n[3] Plan B（预置兜底）：")
    for b in backups:
        _print_plan(b)

    print("\n[4] 旅程状态机：")
    for now in ["16:00", "17:10", "18:50", "20:00"]:
        state, action = get_journey_state(goal, main, None, now)
        print(f"    {now}  →  {state.value} ｜ {action}")

    print("\n[5] 触发「暴雨」事件：")
    override_weather("上海", "暴雨", warning="暴雨黄色预警")
    ctx_rain = JourneyContext(now="17:00", weather=WeatherData(city="上海", weather="暴雨", warning="暴雨黄色预警"))
    need, trigger = should_replan(goal, main, ctx_rain)
    print(f"    should_replan = {need}（{trigger}）")
    result = await replan(goal, main, ctx_rain)
    if result:
        print("    重规划结果：")
        _print_plan(result.new_plan)
        print(f"    额外费用：{result.extra_cost:+.0f} 元")
        print(f"    解释：{result.explanation}")


async def scenario_b():
    """场景 B：带行李 —— 展示 Agent 主动减少长距离步行。"""
    print("\n" + "=" * 64)
    print("场景 B：带行李箱 —— Agent 主动避免长距离步行")
    print("=" * 64)
    text = "我明天从杭州东站去上海看演唱会，带一个行李箱，预算300元，晚上7点前必须入场"
    goal, missing = parse_goal(text)
    print("\n[1] 目标解析：", goal.model_dump(mode="json"), " 缺失：", missing)

    ctx = JourneyContext(now="16:30", weather=WeatherData(city="上海", weather="多云", temperature=26))
    main, all_plans = await build_route_plans(goal, ctx)
    print("\n[2] 主方案（应偏向少步行）：")
    _print_plan(main)

    backups = await generate_plan_b(goal, main, ctx, all_plans[1:])
    print("\n[3] Plan B：")
    for b in backups:
        _print_plan(b)


async def scenario_c():
    """场景 C：定位驱动的动态跟踪 —— 用户移动 -> 状态变化 -> 偏离触发重规划。"""
    print("\n" + "=" * 64)
    print("场景 C：定位驱动的动态跟踪与动态重规划")
    print("=" * 64)
    goal, _ = parse_goal("明天从杭州东站去上海看演唱会，晚上7点前必须入场")
    ctx = JourneyContext(now="16:30", weather=WeatherData(city="上海", weather="多云", temperature=26))
    main, _ = await build_route_plans(goal, ctx)
    print("\n[主方案]", " -> ".join(f"{s.mode}({s.from_}→{s.to})" for s in main.segments))

    steps = [
        ("杭州东站（起点）", 30.291, 120.211),
        ("上海虹桥站（换乘）", 31.197, 121.326),
        ("偏离路线", 30.0, 119.0),
        ("演唱会场馆（目的地）", 31.231, 121.475),
    ]
    print("\n[动态跟踪]")
    for label, lat, lng in steps:
        loc = LocationData(lat=lat, lng=lng)
        state, action = get_journey_state(goal, main, loc, None)
        c = JourneyContext(now="17:00", location=loc, weather=WeatherData(city="上海", weather="多云", temperature=26))
        need, reason = should_replan(goal, main, c)
        print(f"  📍 {label}  ->  [{state.value}] {action}")
        if need:
            result = await replan(goal, main, c)
            if result:
                print(f"       ⚠ 触发重规划：{result.trigger}")
                print(f"       新方案：{' + '.join(s.mode.value for s in result.new_plan.segments)} | eta={result.new_plan.eta} | 费用={result.new_plan.cost}")
                print(f"       解释：{result.explanation}")


async def main():
    await scenario_a()
    await scenario_b()
    await scenario_c()
    print("\n" + "=" * 64)
    print("演示完成")


if __name__ == "__main__":
    asyncio.run(main())
