"""时间处理辅助函数。

本工程 MVP 只处理「同一天内」的时间（演示场景为单日行程）。
"""
from typing import Optional


def to_minutes(hhmm: str) -> int:
    """'18:42' -> 1122 分钟（自 00:00 起）。"""
    hhmm = hhmm.strip()
    if ":" in hhmm:
        h, m = hhmm.split(":", 1)
    else:
        # 兼容纯数字如 "1900"
        h, m = hhmm[:-2], hhmm[-2:]
    return int(h) * 60 + int(m)


def to_hhmm(minutes: int) -> str:
    """1122 -> '18:42'（跨天取模，MVP 内同一日）。"""
    minutes = minutes % (24 * 60)
    return f"{minutes // 60:02d}:{minutes % 60:02d}"


def add_minutes(hhmm: str, delta: int) -> str:
    return to_hhmm(to_minutes(hhmm) + delta)


def minutes_until(hhmm_from: str, hhmm_to: str) -> int:
    """from 到 to 的分钟差（可正可负）。"""
    return to_minutes(hhmm_to) - to_minutes(hhmm_from)


def parse_chinese_time(text: str) -> Optional[str]:
    """解析中文时间表达，返回 'HH:MM' 或 None。

    支持：'晚上7点' / '19:00' / '下午3点半' / '中午12点' / '早上8点' 等。
    """
    import re

    # 直接的数字时间：19:00 / 19：00 / 7:30
    m = re.search(r"(\d{1,2})[:：](\d{2})", text)
    if m:
        h, mm = int(m.group(1)), int(m.group(2))
        return f"{h:02d}:{mm:02d}"

    # 时段 + 中文数字 + 点/点半
    period = {"凌晨": 0, "早上": 0, "上午": 0, "中午": 12,
              "下午": 12, "傍晚": 12, "晚上": 12, "夜里": 12}
    period_offset = 0
    for k, v in period.items():
        if k in text:
            period_offset = v
            break

    # 输入框粘贴或语音转写常把“7点”写为“7 点”，两种形式都应识别。
    m = re.search(r"([0-9一二两三四五六七八九十]+)\s*点\s*(半)?", text)
    if m:
        digit = m.group(1)
        num = _cn_digit(digit)
        half = 30 if m.group(2) else 0
        hour = period_offset + num
        # 处理 12 点制：晚上 12 点应为 0 点后的 12，此处按自然小时
        if hour == 24:
            hour = 0
        return f"{hour:02d}:{half:02d}"

    return None


def _cn_digit(s: str) -> int:
    """中文/数字 -> int。"""
    if s.isdigit():
        return int(s)
    cn = {"一": 1, "二": 2, "两": 2, "三": 3, "四": 4, "五": 5,
          "六": 6, "七": 7, "八": 8, "九": 9, "十": 10}
    if s == "十":
        return 10
    if "十" in s:
        a, _, b = s.partition("十")
        return (cn.get(a, 1) if a else 1) * 10 + (cn.get(b, 0) if b else 0)
    return cn.get(s, 0)
