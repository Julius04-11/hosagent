"""真实第三方 API 冒烟测试。

默认跳过，执行 ``$env:RUN_LIVE_API_TESTS='1'; python -m pytest -q`` 后启用。
高德测试还需要在环境变量中提供 ``AMAP_API_KEY``，密钥绝不写入仓库。
"""
import asyncio
import os

import pytest

from app.models import TravelGoal
from app.services.map_service import get_candidate_routes
from app.services.weather_service import get_weather

RUN_LIVE = os.getenv("RUN_LIVE_API_TESTS") == "1"


@pytest.mark.skipif(not RUN_LIVE, reason="设置 RUN_LIVE_API_TESTS=1 后才调用真实天气 API")
def test_open_meteo_live_weather():
    os.environ["WEATHER_PROVIDER"] = "open_meteo"
    weather = asyncio.run(get_weather("上海"))
    assert weather.city
    assert weather.temperature is not None
    assert weather.weather


@pytest.mark.skipif(
    not RUN_LIVE or not os.getenv("AMAP_API_KEY"),
    reason="设置 RUN_LIVE_API_TESTS=1 且提供 AMAP_API_KEY 后才调用高德 API",
)
def test_amap_live_routes():
    os.environ["MAP_PROVIDER"] = "amap"
    goal = TravelGoal(origin="杭州东站", destination="西湖", deadline="20:00")
    routes = asyncio.run(get_candidate_routes(goal))
    assert routes
    assert any(route["segments"] for route in routes)
