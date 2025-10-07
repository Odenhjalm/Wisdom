from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .db import pool
from .routes import auth, profiles, courses, landing, studio, community, admin, payments


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

app.include_router(auth.router)
app.include_router(profiles.router)
app.include_router(courses.config_router)
app.include_router(courses.router)
app.include_router(landing.router)
app.include_router(studio.router)
app.include_router(community.router)
app.include_router(admin.router)
app.include_router(payments.router)


@app.get("/")
def health():
    return {
        "ok": True,
        "database_url": settings.database_url.unicode_string(),
        "message": "Local backend ready"
    }
