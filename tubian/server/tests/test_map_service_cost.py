"""高德 v5 的费用字段可能是标量，也可能是嵌套的 cost 对象。"""
from app.services.map_service import _cost, _duration_minutes


def test_cost_accepts_scalar_and_v5_cost_object():
    assert _cost("12.5") == 12.5
    assert _cost({"transit_fee": "16"}) == 16
    assert _cost({"taxi_fee": "42.8"}) == 42.8
    assert _cost({"duration": "3600"}) == 0


def test_duration_accepts_top_level_and_v5_cost_object():
    assert _duration_minutes({"duration": "4800"}) == 80
    assert _duration_minutes({"cost": {"duration": "4800"}}) == 80
