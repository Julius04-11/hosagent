"""接口盒子列车查询适配器的字段归一化测试。"""
import asyncio
from datetime import date

import httpx

from app.services import train_service


class FakeAsyncClient:
    payload = {}
    calls = []

    def __init__(self, *, timeout):
        self.timeout = timeout

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, traceback):
        return None

    async def get(self, url, params):
        self.calls.append((url, params))
        return httpx.Response(200, request=httpx.Request("GET", url, params=params), json=self.payload)


def test_ticket_availability_normalizes_free_provider_response(monkeypatch):
    FakeAsyncClient.calls = []
    FakeAsyncClient.payload = {"code": 200, "datas": [{
        "train_number": "G123", "train_order": "76000G123000", "depart_name": "杭州东",
        "arrive_name": "上海虹桥", "depart_time": "08:00", "arrive_time": "09:00",
        "duration": "01:00", "date": "2026-10-01",
        "seats": [{"type": "二等座", "stock": -1}, {"type": "一等座", "stock": 0}],
    }]}
    monkeypatch.setenv("APIHZ_USER_ID", "test-user")
    monkeypatch.setenv("APIHZ_API_KEY", "test-key")
    monkeypatch.setattr(train_service.httpx, "AsyncClient", FakeAsyncClient)

    data = asyncio.run(train_service.get_ticket_availability("杭州东", "上海虹桥", date(2026, 10, 1)))
    assert data["candidates"][0]["trainOrder"] == "76000G123000"
    assert data["candidates"][0]["seats"] == [
        {"seatType": "二等座", "availability": "有"}, {"seatType": "一等座", "availability": "无"},
    ]
    assert FakeAsyncClient.calls[0][1]["key"] == "test-key"
    assert "key" not in str(data)


def test_timetable_normalizes_stops(monkeypatch):
    FakeAsyncClient.calls = []
    FakeAsyncClient.payload = {"code": "200", "datas": [{
        "station_no": "01", "station_name": "杭州东", "arrive_time": "----",
        "start_time": "08:00", "stopover_time": "----",
    }]}
    monkeypatch.setenv("APIHZ_USER_ID", "test-user")
    monkeypatch.setenv("APIHZ_API_KEY", "test-key")
    monkeypatch.setattr(train_service.httpx, "AsyncClient", FakeAsyncClient)

    data = asyncio.run(train_service.get_train_timetable("76000G123000", date(2026, 10, 1)))
    assert data["stops"] == [{
        "stationSequence": "01", "stationName": "杭州东", "arrivalTime": "----",
        "departureTime": "08:00", "stopoverTime": "----",
    }]
    assert FakeAsyncClient.calls[0][1]["train_order"] == "76000G123000"


def test_demo_provider_works_for_any_station_without_credentials(monkeypatch):
    monkeypatch.delenv("APIHZ_USER_ID", raising=False)
    monkeypatch.delenv("APIHZ_API_KEY", raising=False)
    monkeypatch.setenv("TRAIN_PROVIDER", "mock")

    tickets = asyncio.run(train_service.get_ticket_availability("深圳北", "广州南", date(2026, 10, 1)))
    assert tickets["provider"] == "mock"
    assert tickets["candidates"][0]["departureStation"] == "深圳北"
    assert tickets["candidates"][0]["arrivalStation"] == "广州南"

    timetable = asyncio.run(train_service.get_train_timetable(tickets["candidates"][0]["trainOrder"], date(2026, 10, 1)))
    assert timetable["provider"] == "mock"
    assert timetable["stops"][0]["stationName"] == "深圳北"
    assert timetable["stops"][-1]["stationName"] == "广州南"
