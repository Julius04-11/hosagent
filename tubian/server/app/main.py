"""途变 Agent 后端入口。"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.routes import router

app = FastAPI(title="途变 Agent 服务", version="0.1.0", description="全域行程自适应 Agent 决策后端")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

# 独立后端调试页：与 API 同源部署，避免依赖鸿蒙客户端或额外前端工具链。
app.mount("/", StaticFiles(directory="app/static", html=True), name="debug-console")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
