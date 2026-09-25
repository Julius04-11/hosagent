"""模型无关的主 Agent 工具运行时。"""
from typing import Any

from app.agent.tools import AgentToolRegistry, build_default_registry


class MainAgent:
    def __init__(self, tools: AgentToolRegistry) -> None:
        self._tools = tools

    def tool_definitions(self) -> list[dict[str, Any]]:
        return self._tools.definitions()

    async def invoke_tool(self, name: str, arguments: dict[str, Any]) -> dict[str, Any]:
        return await self._tools.invoke(name, arguments)


main_agent = MainAgent(build_default_registry())
