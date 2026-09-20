"""REST 接口（《开发文档》§8）。

统一响应格式：{ success, data, message }。
"""
from typing import List
import logging

from fastapi import APIRouter

from app.core.goal_parser import parse_goal
from app.core.journey_state_machine import assess_location, get_journey_state
from app.core.plan_b import generate_plan_b
from app.core.replanner import replan, should_replan
from app.core.route_planner import build_route_plans
from app.core.route_scorer import BAD_WEATHER, deadline_buffer
from app.models import (
    ApiResponse, JourneyContext, ParseGoalRequest, PlanRouteRequest,
    ReplanRequest, ReverseGeocodeRequest, RoutePlan, TravelGoal, UpdateStatusRequest,
)
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
