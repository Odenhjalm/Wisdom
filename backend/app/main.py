from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .db import pool
from .routes import (
    admin,
    api_auth,
    api_feed,
    api_orders,
    api_payments,
    api_profiles,
    api_services,
    api_sfu,
    community,
    courses,
    landing,
    studio,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    Path(settings.media_root).mkdir(parents=True, exist_ok=True)
    await pool.open(wait=True)
    try:
        yield
    finally:
        await pool.close()


app = FastAPI(title="Wisdom Local Backend", version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_auth.router)
app.include_router(api_services.router)
app.include_router(api_orders.router)
app.include_router(api_payments.router)
app.include_router(api_feed.router)
app.include_router(api_sfu.router)
app.include_router(api_profiles.router)
app.include_router(admin.router)
app.include_router(community.router)
app.include_router(courses.config_router)
app.include_router(courses.router)
app.include_router(landing.router)
app.include_router(studio.router)


@app.get("/")
def health():
    return {
        "ok": True,
        "database_url": settings.database_url.unicode_string(),
        "message": "Local backend ready"
    }
