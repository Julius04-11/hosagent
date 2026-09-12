"""目标解析测试。"""
from app.core.goal_parser import parse_goal


def test_parse_demo_sentence():
    text = "我明天从杭州东站去上海看演唱会，带一个行李箱，预算300元，晚上7点前必须入场"
    goal, missing = parse_goal(text)
    assert goal.origin == "杭州东站"
    assert goal.destination == "上海"
    assert goal.deadline == "19:00"
    assert goal.budget == 300
    assert goal.luggage is True
    assert goal.preference.value == "准时优先"
    assert missing == []


def test_parse_missing_fields():
    goal, missing = parse_goal("我明天从杭州出发")
    assert "origin" not in missing          # 出发地已识别
    assert "destination" in missing
    assert "deadline" in missing


def test_parse_departure_and_deadline():
    goal, missing = parse_goal("明天下午3点出发，晚上7点前到上海")
    assert goal.departure_time == "15:00"
    assert goal.deadline == "19:00"


def test_parse_budget():
    goal, _ = parse_goal("从深圳去广州，预算500元")
    assert goal.origin == "深圳"
    assert goal.destination == "广州"
    assert goal.budget == 500
