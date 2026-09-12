"""目标解析：自然语言 -> TravelGoal。

MVP 使用「规则 + 正则/关键词」提取字段；缺失关键字段返回 missing_fields，
由客户端引导进入表单补充。预留 parse_with_llm() 供后续接入大模型结构化输出。
"""
import re
from typing import List, Optional, Tuple

from app.models import Companion, TravelGoal, TravelPreference
from app.utils.time_util import parse_chinese_time

_PREFERENCE_KEYWORDS = [
    ("准时优先", TravelPreference.ON_TIME),
    ("准时", TravelPreference.ON_TIME),
    ("省钱", TravelPreference.BUDGET),
    ("经济", TravelPreference.BUDGET),
    ("少步行", TravelPreference.LESS_WALK),
    ("少走路", TravelPreference.LESS_WALK),
    ("少换乘", TravelPreference.LESS_TRANSFER),
    ("不换乘", TravelPreference.LESS_TRANSFER),
    ("舒适", TravelPreference.COMFORT),
]

_LUGGAGE_KEYWORDS = ["行李", "行李箱", "箱子", "背包", "大包小包"]

_ACTIVITY_STOP = r"(?=看|听|参加|办理|考试|面试|开会|开会|入职|坐|换|乘|，|。|$| )"


def parse_goal(text: str) -> Tuple[TravelGoal, List[str]]:
    """解析一句话目标，返回 (TravelGoal, missing_fields)。"""
    text = (text or "").strip()

    origin = _extract_origin(text)
    destination = _extract_destination(text)
    deadline = _extract_deadline(text)
    departure_time = _extract_departure_time(text)
    budget = _extract_budget(text)
    luggage = any(k in text for k in _LUGGAGE_KEYWORDS)
    preference = _extract_preference(text)
    companions = _extract_companions(text)

    missing: List[str] = []
    if not origin:
        missing.append("origin")
    if not destination:
        missing.append("destination")
    if not deadline:
        missing.append("deadline")

    goal = TravelGoal(
        origin=origin,
        destination=destination,
        departure_time=departure_time,
        deadline=deadline or "23:59",
        budget=budget,
        luggage=luggage,
        preference=preference,
        companions=companions,
    )
    return goal, missing


def _extract_origin(text: str) -> str:
    m = re.search(r"从(.+?)(?:去|到|出发|前往)", text)
    if m:
        return m.group(1).strip()
    m = re.search(r"在(.+?)(?:出发|上车)", text)
    return m.group(1).strip() if m else ""


def _extract_destination(text: str) -> str:
    m = re.search(r"(?:去|到|前往)(.+?)" + _ACTIVITY_STOP, text)
    if m:
        return m.group(1).strip()
    return ""


def _extract_deadline(text: str) -> Optional[str]:
    # 截止时间：时间表达式后紧跟「前/必须/截止/入场/之前/以内」
    m = re.search(
        r"((?:凌晨|早上|上午|中午|下午|傍晚|晚上|夜里)?\s*[0-9一二两三四五六七八九十]+点(?:半)?|\d{1,2}[:：]\d{2})"
        r"[^，。]{0,8}(?:前|必须|截止|入场|之前|以内)",
        text,
    )
    if m:
        return parse_chinese_time(m.group(1))
    return None


def _extract_departure_time(text: str) -> Optional[str]:
    # 出发时间：时间表达式后紧跟「出发/走/出门/上车」
    m = re.search(
        r"((?:凌晨|早上|上午|中午|下午|傍晚|晚上|夜里)?\s*[0-9一二两三四五六七八九十]+点(?:半)?|\d{1,2}[:：]\d{2})"
        r"[^，。]{0,4}(?:出发|走|出门|上车)",
        text,
    )
    if m:
        return parse_chinese_time(m.group(1))
    return None


def _extract_budget(text: str) -> Optional[float]:
    m = re.search(r"预算\s*(\d+)", text)
    if m:
        return float(m.group(1))
    m = re.search(r"(\d+)\s*元\s*(?:以内|预算|以内预算)", text)
    if m:
        return float(m.group(1))
    return None


def _extract_preference(text: str) -> TravelPreference:
    for kw, pref in _PREFERENCE_KEYWORDS:
        if kw in text:
            return pref
    return TravelPreference.ON_TIME


def _extract_companions(text: str) -> List[Companion]:
    result: List[Companion] = []
    if re.search(r"带(?:老人|爸妈|父母|奶奶|爷爷)", text):
        result.append(Companion(type="老人"))
    if re.search(r"带(?:小孩|孩子|娃|儿童)", text):
        result.append(Companion(type="儿童"))
    if re.search(r"(?:和|带|跟)朋友", text):
        result.append(Companion(type="朋友"))
    return result


async def parse_with_llm(text: str) -> Tuple[TravelGoal, List[str]]:
    """预留：接入大模型做结构化抽取（需求文档 §8.4 / §11.1）。

    当前实现退化为规则解析；接入时在此调用 LLM 并校验字段。
    """
    return parse_goal(text)
