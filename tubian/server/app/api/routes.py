"""REST 接口（《开发文档》§8）。

统一响应格式：{ success, data, message }。
"""
import logging
from datetime import date, timedelta
from time import perf_counter
from typing import List

from fastapi import APIRouter

from app.core.goal_parser import parse_goal
from app.core.journey_state_machine import assess_location, get_journey_state
from app.core.plan_b import generate_plan_b
from app.core.replanner import replan, should_replan
from app.core.route_planner import build_route_plans
from app.core.route_scorer import BAD_WEATHER, deadline_buffer
from app.models import (
    AgentDemoRequest, AgentToolInvokeRequest, ApiResponse, JourneyContext, ParseGoalRequest, PlanRouteRequest,
    ReplanRequest, ReverseGeocodeRequest, RoutePlan, TravelGoal, UpdateStatusRequest,
)
from app.agent import main_agent
from app.agent.tools import AgentToolError
from app.services.map_service import reverse_geocode_location
from app.services.weather_service import get_weather

router = APIRouter(prefix="/api")
logger = logging.getLogger(__name__)


def _dump(model):
    return model.model_dump(by_alias=True, mode="json")


def _error(message: str) -> ApiResponse:
    return ApiResponse(success=False, data=None, message=message)


def _public_map_debug(map_debug: dict) -> dict:
    """移动端只需要来源说明，避免传输高德原始响应拖慢请求。"""
    return {
        "provider": map_debug.get("provider"),
        "label": map_debug.get("label"),
    }


async def _context_with_weather(goal: TravelGoal, now: str, location, depart_late: int = 0) -> JourneyContext:
    try:
        weather = await get_weather(goal.destination)
    except RuntimeError as exc:
        logger.warning("实时天气不可用，本次不使用天气上下文：%s", exc)
        weather = None
    return JourneyContext(now=now, location=location, weather=weather, depart_late_minutes=depart_late)


def _build_risk_tips(goal: TravelGoal, plan: RoutePlan, context: JourneyContext) -> List[str]:
    tips: List[str] = []
    weather = context.weather.weather if context.weather else ""
    if weather in BAD_WEATHER:
        tips.append("目的地可能出现降雨，建议减少步行距离")
    if goal.luggage and plan.walk_distance_meters > 800:
        tips.append("携带行李，长距离步行体验较差")
    departure = plan.segments[0].start_time if plan.segments else None
    if departure and deadline_buffer(departure, goal.deadline, plan.duration_minutes) < 0:
        tips.append("主方案可能无法在截止时间前到达")
    return tips


@router.get("/health")
async def health() -> ApiResponse:
    return ApiResponse(success=True, data={"status": "ok"}, message="")


@router.post("/parse-goal")
async def api_parse_goal(req: ParseGoalRequest) -> ApiResponse:
    goal, missing = parse_goal(req.text)
    return ApiResponse(
        success=True,
        data={"goal": _dump(goal), "missingFields": missing},
        message="",
    )


@router.post("/plan-route")
async def api_plan_route(req: PlanRouteRequest) -> ApiResponse:
    try:
        goal = req.goal
        now = req.now or goal.departure_time or "16:30"
        context = await _context_with_weather(goal, now=now, location=req.location)
        main_plan, all_plans, map_debug = await build_route_plans(goal, context, include_map_debug=True)
        backups = await generate_plan_b(goal, main_plan, context, all_plans[1:])
        tips = _build_risk_tips(goal, main_plan, context)
        return ApiResponse(
            success=True,
            data={
                "mainPlan": _dump(main_plan),
                "backupPlans": [_dump(b) for b in backups],
                "riskTips": tips,
                "mapDebug": _public_map_debug(map_debug),
            },
            message="",
        )
    except RuntimeError as exc:
        logger.warning("路线规划失败：%s", exc)
        return _error(str(exc))


@router.post("/reverse-geocode")
async def api_reverse_geocode(req: ReverseGeocodeRequest) -> ApiResponse:
    try:
        return ApiResponse(success=True, data=await reverse_geocode_location(req.location), message="")
    except (RuntimeError, ValueError) as exc:
        logger.warning("定位反查城市失败：%s", exc)
        return _error(str(exc))


@router.post("/update-status")
async def api_update_status(req: UpdateStatusRequest) -> ApiResponse:
    try:
        now = req.now or "16:30"
        context = await _context_with_weather(req.goal, now=now, location=req.location)
        state, action = get_journey_state(req.goal, req.plan, req.location, now)
        need, reason = should_replan(req.goal, req.plan, context)

        data = {
            "currentState": state.value,
            "nextAction": action,
            "needReplan": need,
            "reason": reason,
        }
        if req.location is not None:
            a = assess_location(req.plan, req.location)
            data["distanceToDestination"] = a["dest_distance_m"]
            data["offRoute"] = a["off_route"]

        return ApiResponse(success=True, data=data, message="")
    except RuntimeError as exc:
        logger.warning("状态更新失败：%s", exc)
        return _error(str(exc))


@router.post("/replan")
async def api_replan(req: ReplanRequest) -> ApiResponse:
    try:
        # 若客户端未传天气，则拉取目的地天气补全上下文
        context = req.context
        if context.weather is None:
            try:
                context.weather = await get_weather(req.goal.destination)
            except RuntimeError as exc:
                logger.warning("实时天气不可用，本次重规划不使用天气上下文：%s", exc)

        result = await replan(req.goal, req.current_plan, context)
        if result is None:
            return ApiResponse(success=True, data=None, message="当前无需重规划")
        return ApiResponse(success=True, data=_dump(result), message="")
    except RuntimeError as exc:
        logger.warning("重规划失败：%s", exc)
        return _error(str(exc))


@router.get("/agent/tools")
async def api_agent_tools() -> ApiResponse:
    """提供给模型适配层的 OpenAI Function Calling 工具定义。"""
    return ApiResponse(success=True, data={"tools": main_agent.tool_definitions()}, message="")


@router.post("/agent/tools/{tool_name}/invoke")
async def api_invoke_agent_tool(tool_name: str, req: AgentToolInvokeRequest) -> ApiResponse:
    """执行模型选中的工具；密钥始终保留在服务端。"""
    try:
        data = await main_agent.invoke_tool(tool_name, req.arguments)
        return ApiResponse(success=True, data=data, message="")
    except (AgentToolError, RuntimeError) as exc:
        logger.warning("Agent 工具 %s 调用失败：%s", tool_name, exc)
        return ApiResponse(success=False, data=None, message=str(exc))


def _tool_trace(step: int, tool_name: str, decision: str, arguments: dict, data=None, error: str = "", elapsed_ms: int = 0) -> dict:
    """向调试前端提供可审计决策摘要，避免暴露模型私有推理。"""
    return {
        "step": step,
        "kind": "tool",
        "toolName": tool_name,
        "decision": decision,
        "arguments": arguments,
        "status": "success" if not error else "failed",
        "elapsedMs": elapsed_ms,
        "result": data,
        "error": error,
    }


def _choose_train(candidates: list[dict]) -> dict | None:
    for candidate in candidates:
        seats = candidate.get("seats") or []
        if any(str(seat.get("availability")) not in {"无", "0", "", "None"} for seat in seats if isinstance(seat, dict)):
            return candidate
    return candidates[0] if candidates else None


def _station_query_name(place: str) -> str:
    """12306 查询更兼容不带“站”后缀的站名；不改变展示给用户的原始目标。"""
    return place.strip().removesuffix("站")


@router.post("/agent/demo")
async def api_run_agent_demo(req: AgentDemoRequest) -> ApiResponse:
    """执行一次真实工具编排，专供本机测试前端展示完整执行链路。"""
    goal, missing = parse_goal(req.text)
    trace = [{
        "step": 1,
        "kind": "decision",
        "title": "理解出行目标",
        "decision": "从自然语言中提取出发地、目的地、截止时间和偏好，再决定需要的外部数据。",
        "status": "success" if not missing else "blocked",
        "result": {"goal": _dump(goal), "missingFields": missing},
    }]
    if missing:
        return ApiResponse(success=True, data={
            "agentMode": "规则编排 + 真实工具调用",
            "trace": trace,
            "recommendation": "信息不完整，暂不调用外部工具；请补充出发地、目的地或时间。",
        }, message="")

    query_date = date.today() + timedelta(days=1)
    ticket_args = {
        "departureStation": _station_query_name(goal.origin),
        "arrivalStation": _station_query_name(goal.destination),
        "queryDate": query_date.isoformat(),
    }
    started = perf_counter()
    try:
        tickets = await main_agent.invoke_tool("query_train_ticket_availability", ticket_args)
        elapsed = round((perf_counter() - started) * 1000)
        candidates = tickets.get("candidates") or []
        selected_train = _choose_train(candidates)
        trace.append(_tool_trace(
            2, "query_train_ticket_availability",
            "目标包含跨城出行，先查明日可选车次与余票，筛选有可用席别的车次。",
            ticket_args,
            {"provider": tickets.get("provider"), "candidateCount": len(candidates), "selectedTrain": selected_train},
            elapsed_ms=elapsed,
        ))
    except (AgentToolError, RuntimeError) as exc:
        selected_train = None
        trace.append(_tool_trace(
            2, "query_train_ticket_availability",
            "目标包含跨城出行，尝试查询车次与余票。",
            ticket_args, error=str(exc), elapsed_ms=round((perf_counter() - started) * 1000),
        ))

    if selected_train and selected_train.get("trainOrder"):
        timetable_args = {"trainOrder": selected_train["trainOrder"], "queryDate": query_date.isoformat()}
        started = perf_counter()
        try:
            timetable = await main_agent.invoke_tool("query_train_timetable", timetable_args)
            elapsed = round((perf_counter() - started) * 1000)
            stops = timetable.get("stops") or []
            trace.append(_tool_trace(
                3, "query_train_timetable",
                "已选定具体车次，查询经停站与到发时刻，用于判断换乘窗口。",
                timetable_args,
                {"provider": timetable.get("provider"), "stopCount": len(stops), "firstStop": stops[0] if stops else None, "lastStop": stops[-1] if stops else None},
                elapsed_ms=elapsed,
            ))
        except (AgentToolError, RuntimeError) as exc:
            trace.append(_tool_trace(
                3, "query_train_timetable",
                "已选定具体车次，尝试查询经停站与到发时刻。",
                timetable_args, error=str(exc), elapsed_ms=round((perf_counter() - started) * 1000),
            ))

    amap_args = {"origin": goal.origin, "destination": goal.destination}
    started = perf_counter()
    try:
        routes = await main_agent.invoke_tool("query_amap_routes", amap_args)
        elapsed = round((perf_counter() - started) * 1000)
        candidates = routes.get("candidateRoutes") or []
        trace.append(_tool_trace(
            4, "query_amap_routes",
            "同时查询高德候选路线，作为铁路方案之外的地面交通与兜底方案参考。",
            amap_args,
            {"candidateCount": len(candidates), "firstRoute": candidates[0] if candidates else None},
            elapsed_ms=elapsed,
        ))
    except (AgentToolError, RuntimeError) as exc:
        trace.append(_tool_trace(
            4, "query_amap_routes",
            "尝试查询高德候选路线，补充地面交通与兜底方案。",
            amap_args, error=str(exc), elapsed_ms=round((perf_counter() - started) * 1000),
        ))

    if selected_train:
        recommendation = f"优先关注 {selected_train.get('trainCode') or '已选车次'}：{selected_train.get('departureTime') or '待确认'} 出发，{selected_train.get('arrivalTime') or '待确认'} 到达；再结合高德路线安排接驳。"
    else:
        recommendation = "未获得可用车次时，仍可依据高德候选路线生成地面交通备选方案。"
    trace.append({
        "step": 5,
        "kind": "decision",
        "title": "汇总建议",
        "decision": "汇总工具结果，给出可解释的下一步，而不是暴露不可审计的内部思维链。",
        "status": "success",
        "result": {"recommendation": recommendation},
    })
    return ApiResponse(success=True, data={
        "agentMode": "规则编排 + 真实工具调用",
        "trace": trace,
        "recommendation": recommendation,
    }, message="")
