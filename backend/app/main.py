from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Импортируем ВСЕ модели чтобы они зарегистрировались
from app.models import workspace, user, project, suite, test_case, test_run, test_result

from app.routers import test_cases_router

app = FastAPI(
    title="QA TMS API",
    description="Test Management System API",
    version="0.1.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "QA TMS API is running! 🚀", "docs": "/docs"}

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "database": "connected"}

# Подключаем роутеры
app.include_router(test_cases_router, prefix="/api/test-cases", tags=["Test Cases"])
