"""主 Agent 可调用的旅行能力注册表。"""
from dataclasses import dataclass
from typing import Any, Awaitable, Callable, Type

from pydantic import BaseModel, ValidationError

from app.models import (
    AmapReverseGeocodeRequest, AmapRouteQueryRequest, LocationData, TrainTicketAvailabilityRequest,
    TrainTimetableRequest, TravelGoal,
)
from app.services.map_service import get_candidate_routes, reverse_geocode_location
from app.services.train_service import get_ticket_availability, get_train_timetable

ToolHandler = Callable[[BaseModel], Awaitable[dict[str, Any]]]


class AgentToolError(RuntimeError):
    """工具选择或参数校验失败。"""


@dataclass(frozen=True)
class AgentTool:
    name: str
    description: str
    input_model: Type[BaseModel]
    handler: ToolHandler

    def definition(self) -> dict[str, Any]:
        schema = self.input_model.model_json_schema(by_alias=True, mode="validation")
        return {
            "type": "function",
            "function": {
                "name": self.name,
                "description": self.description,
                "parameters": {
                    "type": "object",
                    "properties": schema.get("properties", {}),
                    "required": schema.get("required", []),
                    "additionalProperties": False,
                },
            },
        }


class AgentToolRegistry:
    def __init__(self) -> None:
        self._tools: dict[str, AgentTool] = {}

    def register(self, tool: AgentTool) -> None:
        if tool.name in self._tools:
            raise ValueError(f"重复注册 Agent 工具：{tool.name}")
        self._tools[tool.name] = tool

    def definitions(self) -> list[dict[str, Any]]:
        return [tool.definition() for tool in self._tools.values()]

    async def invoke(self, name: str, arguments: dict[str, Any]) -> dict[str, Any]:
        tool = self._tools.get(name)
        if tool is None:
            raise AgentToolError(f"主 Agent 未注册工具：{name}")
        try:
            request = tool.input_model.model_validate(arguments)
        except ValidationError as exc:
            error = exc.errors(include_url=False)[0]
            raise AgentToolError(f"工具 {name} 参数不合法：{error.get('msg', '参数不合法')}") from exc
        return await tool.handler(request)


async def _query_train_ticket_availability(request: BaseModel) -> dict[str, Any]:
    assert isinstance(request, TrainTicketAvailabilityRequest)
    return await get_ticket_availability(request.departure_station, request.arrival_station, request.query_date)


async def _query_train_timetable(request: BaseModel) -> dict[str, Any]:
    assert isinstance(request, TrainTimetableRequest)
    return await get_train_timetable(request.train_order, request.query_date)


async def _query_amap_routes(request: BaseModel) -> dict[str, Any]:
    assert isinstance(request, AmapRouteQueryRequest)
    goal = TravelGoal(origin=request.origin, destination=request.destination, deadline="23:59")
    return {
        "candidateRoutes": await get_candidate_routes(goal),
        "notice": "路线由高德 Web 服务查询；未配置 Key 或上游失败时会回退到项目内置路线。",
    }


async def _reverse_geocode_amap_location(request: BaseModel) -> dict[str, Any]:
    assert isinstance(request, AmapReverseGeocodeRequest)
    location = LocationData(lat=request.lat, lng=request.lng, accuracy=request.accuracy)
    return {"provider": "amap", "location": await reverse_geocode_location(location)}


def build_default_registry() -> AgentToolRegistry:
    registry = AgentToolRegistry()
    registry.register(AgentTool(
        name="query_train_ticket_availability",
        description="查询指定出发站、到达站和日期的候选列车、到发时刻及各席别余票快照。用于选择可赶上的列车。",
        input_model=TrainTicketAvailabilityRequest,
        handler=_query_train_ticket_availability,
    ))
    registry.register(AgentTool(
        name="query_train_timetable",
        description="查询余票工具返回的 trainOrder 对应车次的经停站、到达时间和发车时间。用于解释指定车次与换乘。",
        input_model=TrainTimetableRequest,
        handler=_query_train_timetable,
    ))
    registry.register(AgentTool(
        name="query_amap_routes",
        description="使用高德地图查询出发地到目的地的候选公交、地铁、驾车与步行路线，返回耗时、距离、费用和换乘信息。",
        input_model=AmapRouteQueryRequest,
        handler=_query_amap_routes,
    ))
    registry.register(AgentTool(
        name="reverse_geocode_amap_location",
        description="将用户明确授权的经纬度反查为高德地址、城市和行政区，用于补全行程出发地。",
        input_model=AmapReverseGeocodeRequest,
        handler=_reverse_geocode_amap_location,
    ))
    return registry
