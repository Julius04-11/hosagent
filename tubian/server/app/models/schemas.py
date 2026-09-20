"""数据模型定义（前后端契约，与《开发文档》§6 一致）。

使用 Pydantic v2；所有字段以 snake_case 命名（Python 侧），
JSON 序列化统一为 camelCase（by_alias），对齐《开发文档》§6/§10。
"""
from enum import Enum
from typing import Any, List, Optional

from pydantic import BaseModel, ConfigDict


def _to_camel(snake: str) -> str:
    first, *rest = snake.split("_")
    return first + "".join(w.capitalize() for w in rest)


class CamelModel(BaseModel):
    model_config = ConfigDict(alias_generator=_to_camel, populate_by_name=True)


class TravelPreference(str, Enum):
    ON_TIME = "准时优先"
    BUDGET = "省钱优先"
    LESS_WALK = "少步行"
    LESS_TRANSFER = "少换乘"
    COMFORT = "舒适优先"


class RiskLevel(str, Enum):
    LOW = "低"
    MEDIUM = "中"
    HIGH = "高"


class SegmentMode(str, Enum):
    HIGH_SPEED_RAIL = "高铁"
    TRAIN = "火车"
    SUBWAY = "地铁"
    BUS = "公交"
    WALK = "步行"
    RIDE_HAIL = "网约车"


class PlanType(str, Enum):
    MAIN = "主方案"
    PLAN_B = "Plan B"
    REPLAN = "重规划方案"


class JourneyState(str, Enum):
    PREPARE = "出发准备"
    TO_STATION = "去车站"
    WAITING = "候车"
    ON_BOARD = "乘车"
    TRANSFER = "到站换乘"
    TO_DEST = "前往目的地"
    ARRIVING = "入场或入住准备"
    ARRIVED = "已抵达"


class Companion(CamelModel):
    type: str  # 老人 / 儿童 / 朋友 ...
    count: int = 1


class TravelProfile(CamelModel):
    motion_sick: bool = False              # 晕车 -> motionSick
    heavy_luggage: bool = False            # 大件行李 -> heavyLuggage
    with_elderly: bool = False             # 带老人/小孩 -> withElderly
    budget_sensitive: bool = False         # 预算敏感 -> budgetSensitive
    time_sensitive: bool = False           # 时间敏感 -> timeSensitive


class TravelGoal(CamelModel):
    origin: str
    destination: str
    departure_time: Optional[str] = None   # "HH:MM" -> departureTime
    deadline: str                          # "HH:MM"
    budget: Optional[float] = None
    luggage: bool = False
    preference: TravelPreference = TravelPreference.ON_TIME
    companions: List[Companion] = []
    accept_ride_hail: Optional[bool] = None  # -> acceptRideHail
    transport_modes: List[str] = []        # 偏好交通方式 -> transportModes
    travel_profile: Optional[TravelProfile] = None  # -> travelProfile


class RouteSegment(CamelModel):
    mode: SegmentMode
    from_: str                             # -> "from"（Python 关键字，用 from_ 表示）
    to: str
    start_time: Optional[str] = None       # -> startTime
    end_time: Optional[str] = None         # -> endTime
    duration_minutes: int                  # -> durationMinutes
    distance_meters: Optional[int] = None  # -> distanceMeters
    cost: Optional[float] = None
    note: Optional[str] = None


class RoutePlan(CamelModel):
    plan_id: str                           # -> planId
    type: PlanType
    eta: str
    cost: float
    duration_minutes: int
    walk_distance_meters: int
    transfer_count: int
    risk_level: RiskLevel
    on_time_probability: float
    segments: List[RouteSegment]
    reason: str


class LocationData(CamelModel):
    lat: float
    lng: float
    accuracy: Optional[float] = None
    timestamp: Optional[int] = None


class WeatherData(CamelModel):
    city: str
    weather: str
    temperature: Optional[float] = None
    warning: Optional[str] = None


class JourneyContext(CamelModel):
    now: Optional[str] = None
    location: Optional[LocationData] = None
    weather: Optional[WeatherData] = None
    depart_late_minutes: int = 0           # -> departLateMinutes


class ReplanResult(CamelModel):
    trigger: str
    old_plan_status: str                   # -> oldPlanStatus
    new_plan: RoutePlan                    # -> newPlan
    extra_cost: float                      # -> extraCost
    action: str
    explanation: str
    risk_level: RiskLevel


# ---- 接口请求/响应 ----

class ParseGoalRequest(CamelModel):
    text: str


class PlanRouteRequest(CamelModel):
    goal: TravelGoal
    location: Optional[LocationData] = None
    # 调试页/调用方提供的模拟出发时间；未提供时才回退到目标中的出发时间或演示默认值。
    now: Optional[str] = None


class ReverseGeocodeRequest(CamelModel):
    location: LocationData


class ReverseGeocodeResult(CamelModel):
    city: str
    district: Optional[str] = None
    formatted_address: Optional[str] = None


class UpdateStatusRequest(CamelModel):
    goal: TravelGoal
    plan: RoutePlan
    location: Optional[LocationData] = None
    now: Optional[str] = None


class ReplanRequest(CamelModel):
    goal: TravelGoal
    current_plan: RoutePlan                # -> currentPlan
    context: JourneyContext


class ApiResponse(CamelModel):
    success: bool
    data: Optional[Any] = None
    message: str = ""
