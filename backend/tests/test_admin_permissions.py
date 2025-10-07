import base64
import json
import uuid

import pytest

from app import db


pytestmark = pytest.mark.anyio("asyncio")


def auth_header(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


async def register_user(client, email: str, password: str, display_name: str):
    register_resp = await client.post(
        "/auth/register",
        json={
            "email": email,
            "password": password,
            "display_name": display_name,
        },
    )
    assert register_resp.status_code == 201, register_resp.text

    login_resp = await client.post(
        "/auth/login",
        json={"email": email, "password": password},
    )
    assert login_resp.status_code == 200, login_resp.text
    tokens = login_resp.json()
    access_token = tokens["access_token"]

    profile_resp = await client.get("/profiles/me", headers=auth_header(access_token))
    assert profile_resp.status_code == 200, profile_resp.text
    user_id = str(profile_resp.json()["user_id"])
    return access_token, tokens["refresh_token"], user_id


async def promote_to_admin(user_id: str):
    async with db.pool.connection() as conn:  # type: ignore
        async with conn.cursor() as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.profiles
                SET is_admin = true,
                    role_v2 = COALESCE(role_v2, 'user'),
                    updated_at = now()
                WHERE user_id = %s
                """,
                (user_id,),
            )
            await conn.commit()


async def cleanup_user(user_id: str):
    async with db.pool.connection() as conn:  # type: ignore
        async with conn.cursor() as cur:  # type: ignore[attr-defined]
            await cur.execute("DELETE FROM auth.users WHERE id = %s", (user_id,))
            await conn.commit()


async def profile_role(user_id: str) -> tuple[str, bool]:
    async with db.pool.connection() as conn:  # type: ignore
        async with conn.cursor() as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "SELECT role_v2, is_admin FROM app.profiles WHERE user_id = %s",
                (user_id,),
            )
            row = await cur.fetchone()
            assert row is not None
            return row[0], bool(row[1])


def decode_token(token: str) -> dict[str, object]:
    _, payload, _ = token.split('.')
    padding = '=' * (-len(payload) % 4)
    decoded = base64.urlsafe_b64decode(payload + padding)
    return json.loads(decoded)


async def test_admin_guard_for_teacher_approval(async_client):
    admin_email = f"admin_{uuid.uuid4().hex[:8]}@example.com"
    candidate_email = f"candidate_{uuid.uuid4().hex[:8]}@example.com"
    password = "Passw0rd!"

    admin_token, admin_refresh, admin_id = await register_user(
        async_client, admin_email, password, "Admin"
    )
    _, candidate_refresh, candidate_id = await register_user(
        async_client, candidate_email, password, "Candidate"
    )

    try:
        # Non-admin call should be forbidden.
        resp = await async_client.post(
            f"/admin/teachers/{candidate_id}/approve",
            headers=auth_header(admin_token),
        )
        assert resp.status_code == 403

        # Promote and reuse the same token; guard reads from DB on each request.
        await promote_to_admin(admin_id)

        resp = await async_client.post(
            f"/admin/teachers/{candidate_id}/approve",
            headers=auth_header(admin_token),
        )
        assert resp.status_code == 204

        role, is_admin = await profile_role(candidate_id)
        assert role == "teacher"
        assert is_admin is False

        resp = await async_client.post(
            f"/admin/teachers/{candidate_id}/reject",
            headers=auth_header(admin_token),
        )
        assert resp.status_code == 204

        # Refreshing the token should pick up the new admin claims.
        refresh_resp = await async_client.post(
            "/auth/refresh",
            json={"refresh_token": admin_refresh},
        )
        assert refresh_resp.status_code == 200, refresh_resp.text
        refreshed = refresh_resp.json()
        claims = decode_token(refreshed["access_token"])
        assert claims.get("is_admin") is True
        assert claims.get("is_teacher") is True
    finally:
        await cleanup_user(admin_id)
        await cleanup_user(candidate_id)
