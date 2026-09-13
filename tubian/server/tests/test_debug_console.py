"""后端调试页面应与 API 同源提供，便于无需鸿蒙客户端时验证服务。"""
from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_debug_console_and_assets_are_served():
    page = client.get("/")
    assert page.status_code == 200
    assert "TOUBIAN / BACKEND CONSOLE" in page.text

    script = client.get("/app.js")
    assert script.status_code == 200
    assert "simulateRain" in script.text
