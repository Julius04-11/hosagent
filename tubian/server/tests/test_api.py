"""REST 接口联调测试（走完整主链路）。"""
from fastapi.testclient import TestClient

from app.main import app
from app.services.weather_service import override_weather

client = TestClient(app)


def test_health():
    r = client.get("/api/health")
    assert r.status_code == 200
    assert r.json()["success"] is True


def test_full_flow():
    # 1. 目标解析
    r = client.post("/api/parse-goal", json={
        "text": "我明天从杭州东站去上海看演唱会，晚上7点前必须入场"
    })
    assert r.status_code == 200
    data = r.json()["data"]
    goal = data["goal"]
    assert goal["origin"] == "杭州东站"
    assert goal["deadline"] == "19:00"
    assert data["missingFields"] == []

    # 2. 路线规划
    r = client.post("/api/plan-route", json={"goal": goal, "now": "16:30"})
    body = r.json()
    assert body["success"] is True
    main_plan = body["data"]["mainPlan"]
    backups = body["data"]["backupPlans"]
    assert main_plan["planId"]
    assert main_plan["segments"][0]["startTime"] == "16:30"
    assert len(backups) >= 1
    assert body["data"]["mapDebug"]["provider"] in {"amap", "mock"}

    # 3. 状态更新
    r = client.post("/api/update-status", json={
        "goal": goal, "plan": main_plan, "now": "17:00"
    })
    status = r.json()["data"]
    assert "currentState" in status
    assert "nextAction" in status

    # 4. 触发暴雨 → 重规划
    override_weather("上海", "暴雨", warning="暴雨黄色预警")
    r = client.post("/api/replan", json={
        "goal": goal,
        "currentPlan": main_plan,
        "context": {"now": "17:00", "weather": {"city": "上海", "weather": "暴雨"}},
    })
    replan_body = r.json()
    assert replan_body["success"] is True
    assert replan_body["data"] is not None
    assert replan_body["data"]["trigger"]
    assert "explanation" in replan_body["data"]
