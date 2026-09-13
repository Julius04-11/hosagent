"""pytest 配置：将 server/ 目录加入 sys.path，使 `app` 包可导入。"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# 单元测试不得因网络或第三方 API 配额波动而不稳定；实时集成测试自行显式开启。
os.environ.setdefault("WEATHER_PROVIDER", "mock")
os.environ.setdefault("MAP_PROVIDER", "mock")
