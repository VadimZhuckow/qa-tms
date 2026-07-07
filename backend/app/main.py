from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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

# TODO: Add routers
# from app.routers import workspaces, test_cases, test_runs
# app.include_router(workspaces.router, prefix="/api/workspaces", tags=["Workspaces"])
# app.include_router(test_cases.router, prefix="/api/test-cases", tags=["Test Cases"])
# app.include_router(test_runs.router, prefix="/api/test-runs", tags=["Test Runs"])
