import asyncio
import shutil
from pathlib import Path

import pytest
import pytest
from httpx import AsyncClient, ASGITransport


def _ensure_event_loop():
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)


_ensure_event_loop()

from app.config import settings
from app.main import app
from app.db import pool


@pytest.fixture
async def async_client(anyio_backend) -> AsyncClient:
    if anyio_backend != "asyncio":
        pytest.skip("Backend tests require asyncio")

    transport = ASGITransport(app=app)
    if pool.closed:
        await pool.open(wait=True)

    try:
        async with AsyncClient(
            transport=transport, base_url="http://testserver"
        ) as client:
            yield client
    finally:
        # Keep pool open across tests to avoid psycopg_pool reopen errors.
        pass


@pytest.fixture(autouse=True)
def _temp_media_root(tmp_path):
    original = settings.media_root
    temp_root = tmp_path / "media"
    temp_root.mkdir(parents=True, exist_ok=True)
    settings.media_root = str(temp_root)
    try:
        yield Path(settings.media_root)
    finally:
        settings.media_root = original
        shutil.rmtree(temp_root, ignore_errors=True)
