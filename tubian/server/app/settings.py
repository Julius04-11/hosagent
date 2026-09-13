"""运行时配置。

本地开发时读取 server/.env；部署环境中的同名环境变量优先，避免把密钥写入代码。
"""
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[1] / ".env")
