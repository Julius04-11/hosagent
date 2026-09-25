"""主 Agent 工具注册、参数校验和服务调用测试。"""
from fastapi.testclient import TestClient

from app.agent import main_agent
from app.main import app

client = TestClient(app)


def test_main_agent_registers_train_and_amap_tools():
    functions = {item["function"]["name"]: item["function"] for item in main_agent.tool_definitions()}
    assert set(functions) == {
        "query_train_ticket_availability",
        "query_train_timetable",
        "query_amap_routes",
        "reverse_geocode_amap_location",
    }
    schema = functions["query_train_ticket_availability"]["parameters"]
    assert schema["required"] == ["departureStation", "arrivalStation", "queryDate"]
    assert schema["additionalProperties"] is False


def test_agent_tool_endpoint_calls_train_service(monkeypatch):
    async def fake_query(departure_station, arrival_station, query_date):
        return {"provider": "apihz", "departureStation": departure_station, "arrivalStation": arrival_station}

    monkeypatch.setattr("app.agent.tools.get_ticket_availability", fake_query)
    response = client.post("/api/agent/tools/query_train_ticket_availability/invoke", json={
        "arguments": {"departureStation": "杭州东", "arrivalStation": "上海虹桥", "queryDate": "2026-10-01"}
    })
    assert response.status_code == 200
    assert response.json() == {
        "success": True,
        "data": {"provider": "apihz", "departureStation": "杭州东", "arrivalStation": "上海虹桥"},
        "message": "",
    }


def test_agent_tool_endpoint_calls_amap_service(monkeypatch):
    async def fake_routes(goal):
        assert goal.origin == "杭州东站"
        assert goal.destination == "上海虹桥站"
        return [{"segments": [{"mode": "高铁"}]}]

    monkeypatch.setattr("app.agent.tools.get_candidate_routes", fake_routes)
    response = client.post("/api/agent/tools/query_amap_routes/invoke", json={
        "arguments": {"origin": "杭州东站", "destination": "上海虹桥站"}
    })
    assert response.status_code == 200
    assert response.json()["data"]["candidateRoutes"] == [{"segments": [{"mode": "高铁"}]}]


def test_agent_tool_rejects_unknown_name():
    response = client.post("/api/agent/tools/not_registered/invoke", json={"arguments": {}})
    assert response.status_code == 200
    assert response.json()["success"] is False
    assert "未注册工具" in response.json()["message"]
