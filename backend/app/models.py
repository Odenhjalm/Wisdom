import json
import hashlib
from datetime import datetime, timedelta, timezone
from typing import Iterable
from urllib.parse import quote

from psycopg import InterfaceError, errors
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb

from .db import get_conn, pool
from .auth import hash_password
from .repositories import (
    create_order as repo_create_order,
    create_user as repo_create_user,
    get_order as repo_get_order,
    get_profile as repo_get_profile,
    get_user_by_email as repo_get_user_by_email,
    get_user_by_id as repo_get_user_by_id,
    get_user_order as repo_get_user_order,
    list_services as repo_list_services,
    mark_order_paid as repo_mark_order_paid,
    set_order_checkout_reference as repo_set_order_checkout_reference,
    update_profile as repo_update_profile,
    upsert_refresh_token as repo_upsert_refresh_token,
)


async def _fetchone(cur):
    try:
        return await cur.fetchone()
    except InterfaceError:
        return None


async def create_media_object(
    *,
    owner_id: str | None,
    storage_path: str,
    storage_bucket: str,
    content_type: str | None,
    byte_size: int,
    checksum: str | None,
    original_name: str | None,
) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.media_objects (
                    owner_id,
                    storage_path,
                    storage_bucket,
                    content_type,
                    byte_size,
                    checksum,
                    original_name,
                    updated_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, now())
                ON CONFLICT (storage_path, storage_bucket) DO UPDATE
                  SET owner_id = COALESCE(excluded.owner_id, app.media_objects.owner_id),
                      content_type = excluded.content_type,
                      byte_size = excluded.byte_size,
                      checksum = COALESCE(excluded.checksum, app.media_objects.checksum),
                      original_name = COALESCE(excluded.original_name, app.media_objects.original_name),
                      updated_at = now()
                RETURNING id, owner_id, storage_path, storage_bucket, content_type, byte_size, checksum, original_name
                """,
                (
                    owner_id,
                    storage_path,
                    storage_bucket,
                    content_type,
                    byte_size,
                    checksum,
                    original_name,
                ),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def cleanup_media_object(media_id: str) -> None:
    if not media_id:
        return
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                DELETE FROM app.media_objects mo
                WHERE mo.id = %s
                  AND NOT EXISTS (
                    SELECT 1 FROM app.lesson_media lm WHERE lm.media_id = mo.id
                  )
                  AND NOT EXISTS (
                    SELECT 1 FROM app.profiles p WHERE p.avatar_media_id = mo.id
                  )
                """,
                (media_id,),
            )
            await conn.commit()


async def get_media_object(media_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, owner_id, storage_path, storage_bucket, content_type, byte_size, checksum, original_name
            FROM app.media_objects
            WHERE id = %s
            """,
            (media_id,),
        )
        return await _fetchone(cur)


def _hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


async def register_refresh_token(
    user_id: str, token: str, jti: str, expires_at: datetime
) -> None:
    token_hash = _hash_refresh_token(token)
    await repo_upsert_refresh_token(
        user_id=user_id,
        jti=jti,
        token_hash=token_hash,
        expires_at=expires_at,
    )


async def validate_refresh_token(jti: str, token: str) -> dict | None:
    token_hash = _hash_refresh_token(token)
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                SELECT id, user_id, token_hash, expires_at, revoked_at, rotated_at
                FROM app.refresh_tokens
                WHERE jti = %s
                FOR UPDATE
                """,
                (jti,),
            )
            row = await _fetchone(cur)
            if not row:
                await conn.rollback()
                return None

            if row.get("revoked_at") is not None or row.get("rotated_at") is not None:
                await conn.rollback()
                return None

            expires_at = row.get("expires_at")
            if expires_at and isinstance(expires_at, datetime):
                if expires_at < datetime.now(timezone.utc):
                    await cur.execute(
                        "UPDATE app.refresh_tokens SET revoked_at = now() WHERE jti = %s",
                        (jti,),
                    )
                    await conn.commit()
                    return None

            if row.get("token_hash") != token_hash:
                await cur.execute(
                    "UPDATE app.refresh_tokens SET revoked_at = now() WHERE jti = %s",
                    (jti,),
                )
                await conn.commit()
                return None

            await cur.execute(
                """
                UPDATE app.refresh_tokens
                SET rotated_at = now(), last_used_at = now()
                WHERE jti = %s
                """,
                (jti,),
            )
            await conn.commit()
            return row


async def record_auth_event(
    user_id: str | None,
    email: str | None,
    event: str,
    ip_address: str | None,
    user_agent: str | None,
    metadata: dict | None = None,
) -> None:
    ip_value = ip_address if ip_address and ip_address != "unknown" else None
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor() as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.auth_events (user_id, email, event, ip_address, user_agent, metadata)
                VALUES (%s, %s, %s, %s::inet, %s, %s)
                """,
                (
                    user_id,
                    email.lower() if email else None,
                    event,
                    ip_value,
                    user_agent,
                    Jsonb(metadata or {}),
                ),
            )
            await conn.commit()


async def get_user_by_email(email: str):
    return await repo_get_user_by_email(email)


async def get_user_by_id(user_id: str):
    return await repo_get_user_by_id(user_id)


async def create_user(email: str, password: str, display_name: str):
    hashed = hash_password(password)
    result = await repo_create_user(
        email=email,
        hashed_password=hashed,
        display_name=display_name,
    )
    return result["user"]["id"]


async def is_teacher_user(user_id: str) -> bool:
    profile = await get_profile(user_id)
    if not profile:
        return False
    if profile.get("is_admin"):
        return True
    if (profile.get("role_v2") or "user") in {"teacher", "admin"}:
        return True

    async with get_conn() as cur:
        await cur.execute(
            "SELECT 1 FROM app.teacher_permissions WHERE profile_id = %s AND (can_edit_courses = true OR can_publish = true) LIMIT 1",
            (user_id,),
        )
        if await _fetchone(cur):
            return True

        await cur.execute(
            "SELECT 1 FROM app.teacher_approvals WHERE user_id = %s AND approved_at IS NOT NULL LIMIT 1",
            (user_id,),
        )
        row = await _fetchone(cur)
        return row is not None


async def teacher_courses(user_id: str) -> Iterable[dict]:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(
                    """
                    SELECT id, title, slug, description, cover_url, video_url,
                           is_free_intro, is_published, price_cents, created_at, updated_at, branch
                    FROM app.courses
                    WHERE created_by = %s
                    ORDER BY updated_at DESC
                    """,
                    (user_id,),
                )
            except errors.UndefinedColumn:
                await conn.rollback()
                await cur.execute(
                    """
                    SELECT id, title, slug, description,
                           is_free_intro, is_published, price_cents,
                           created_at, updated_at
                    FROM app.courses
                    WHERE created_by = %s
                    ORDER BY updated_at DESC
                    """,
                    (user_id,),
                )
            return await cur.fetchall()


async def user_certificates(user_id: str, verified_only: bool = False) -> Iterable[dict]:
    clauses = ["user_id = %s"]
    params = [user_id]
    if verified_only:
        clauses.append("status = 'verified'")
    query = """
        SELECT id, user_id, title, status, notes, evidence_url, created_at, updated_at
        FROM app.certificates
        WHERE {where}
        ORDER BY updated_at DESC
    """.format(where=" AND ".join(clauses))
    async with get_conn() as cur:
        await cur.execute(query, params)
        return await cur.fetchall()


async def teacher_application_certificate(user_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, user_id, title, status, notes, evidence_url, created_at, updated_at
            FROM app.certificates
            WHERE user_id = %s AND lower(title) = lower(%s)
            ORDER BY updated_at DESC
            LIMIT 1
            """,
            (user_id, "Läraransökan"),
        )
        return await _fetchone(cur)


async def upsert_teacher_application(user_id: str) -> dict:
    existing = await teacher_application_certificate(user_id)
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            if existing:
                await cur.execute(
                    """
                    UPDATE app.certificates
                    SET status = 'pending', notes = %s, updated_at = now()
                    WHERE id = %s
                    RETURNING id, user_id, title, status, notes, evidence_url, created_at, updated_at
                    """,
                    (
                        "Ansökan inskickad via app",
                        existing["id"],
                    ),
                )
                row = await _fetchone(cur)
            else:
                await cur.execute(
                    """
                    INSERT INTO app.certificates (user_id, title, status, notes)
                    VALUES (%s, %s, 'pending', %s)
                    RETURNING id, user_id, title, status, notes, evidence_url, created_at, updated_at
                    """,
                    (user_id, "Läraransökan", "Ansökan inskickad via app"),
                )
                row = await _fetchone(cur)
            await conn.commit()
            return row


async def add_certificate(
    user_id: str,
    *,
    title: str,
    status: str = "pending",
    notes: str | None = None,
    evidence_url: str | None = None,
) -> dict:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.certificates (user_id, title, status, notes, evidence_url)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id, user_id, title, status, notes, evidence_url, created_at, updated_at
                """,
                (user_id, title, status, notes, evidence_url),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def certificates_of(user_id: str, verified_only: bool = False) -> Iterable[dict]:
    return await user_certificates(user_id, verified_only)


async def teacher_status(user_id: str) -> dict:
    is_teacher = await is_teacher_user(user_id)
    verified = await user_certificates(user_id, True)
    application = await teacher_application_certificate(user_id)
    return {
        "is_teacher": is_teacher,
        "verified_certificates": len(verified),
        "has_application": application is not None,
    }


async def update_user_password(user_id: str, password: str) -> None:
    hashed = hash_password(password)
    async with get_conn() as cur:
        await cur.execute(
            """
            UPDATE auth.users
            SET encrypted_password = %s,
                updated_at = now()
            WHERE id = %s
            """,
            (hashed, user_id),
        )


async def create_course_for_user(user_id: str, data: dict) -> dict | None:
    price_value = data.get("price_cents")
    try:
        price_cents = int(price_value) if price_value is not None else 0
    except (TypeError, ValueError):
        price_cents = 0

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(
                    """
                    INSERT INTO app.courses (title, slug, description, cover_url, video_url, is_free_intro,
                                             price_cents, is_published, created_by, branch)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id, title, slug, description, cover_url, video_url, is_free_intro,
                              price_cents, is_published, created_by, created_at, updated_at, branch
                    """,
                    (
                        data.get("title"),
                        data.get("slug"),
                        data.get("description"),
                        data.get("cover_url"),
                        data.get("video_url"),
                        bool(data.get("is_free_intro", False)),
                        price_cents,
                        bool(data.get("is_published", False)),
                        user_id,
                        data.get("branch"),
                    ),
                )
            except errors.UndefinedColumn:
                await conn.rollback()
                await cur.execute(
                    """
                    INSERT INTO app.courses (title, slug, description, is_free_intro,
                                             price_cents, is_published, created_by)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    RETURNING id, title, slug, description, is_free_intro,
                              price_cents, is_published, created_by, created_at, updated_at
                    """,
                    (
                        data.get("title"),
                        data.get("slug"),
                        data.get("description"),
                        bool(data.get("is_free_intro", False)),
                        price_cents,
                        bool(data.get("is_published", False)),
                        user_id,
                    ),
                )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def update_course_for_user(user_id: str, course_id: str, patch: dict) -> dict | None:
    if not await is_course_owner(user_id, course_id):
        return None

    fields = []
    params = []
    for key in ("title", "slug", "description", "cover_url", "video_url", "is_free_intro", "price_cents", "is_published", "branch"):
        if key in patch:
            fields.append(f"{key} = %s")
            params.append(patch[key])
    if not fields:
        return await get_course(course_id=course_id)

    params.extend([course_id, user_id])

    query = """
        UPDATE app.courses
        SET {set_clause}, updated_at = now()
        WHERE id = %s AND created_by = %s
        RETURNING id, title, slug, description, cover_url, video_url,
                  is_free_intro, price_cents, is_published, created_by,
                  created_at, updated_at, branch
    """.format(set_clause=", ".join(fields))

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(query, params)
            except errors.UndefinedColumn:
                await conn.rollback()
                fallback_fields = []
                fallback_params = []
                for key in ("title", "slug", "description", "is_free_intro", "price_cents", "is_published"):
                    if key in patch:
                        fallback_fields.append(f"{key} = %s")
                        fallback_params.append(patch[key])

                if not fallback_fields:
                    return await get_course(course_id=course_id)

                fallback_params.extend([course_id, user_id])
                fallback_query = """
                    UPDATE app.courses
                    SET {set_clause}, updated_at = now()
                    WHERE id = %s AND created_by = %s
                    RETURNING id, title, slug, description, is_free_intro,
                              price_cents, is_published, created_by,
                              created_at, updated_at
                """.format(set_clause=", ".join(fallback_fields))
                await cur.execute(fallback_query, fallback_params)
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def delete_course_for_user(user_id: str, course_id: str) -> bool:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "DELETE FROM app.courses WHERE id = %s AND created_by = %s",
                (course_id, user_id),
            )
            deleted = cur.rowcount > 0
            await conn.commit()
            return deleted

async def list_courses(
    *,
    published_only: bool = True,
    free_intro: bool | None = None,
    search: str | None = None,
    limit: int | None = None,
) -> Iterable[dict]:
    clauses: list[str] = []
    params: list = []
    if published_only:
        clauses.append("is_published = true")
    if free_intro is not None:
        clauses.append("is_free_intro = %s")
        params.append(free_intro)
    if search:
        clauses.append("(lower(title) LIKE %s OR lower(description) LIKE %s)")
        pattern = f"%{search.lower()}%"
        params.extend([pattern, pattern])

    query = """
        SELECT id, slug, title, description, cover_url, video_url,
               is_free_intro, price_cents, is_published,
               created_by, created_at, updated_at
        FROM app.courses
    """
    if clauses:
        query += " WHERE " + " AND ".join(clauses)
    query += " ORDER BY created_at DESC"
    if limit is not None:
        query += " LIMIT %s"
        params.append(limit)

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(query, params)
            except errors.UndefinedColumn:
                await conn.rollback()
                fallback_query = query.replace(
                    "cover_url, video_url,\n               ", ""
                )
                await cur.execute(fallback_query, params)
            return await cur.fetchall()


async def list_intro_courses(limit: int = 5) -> Iterable[dict]:
    return await list_courses(free_intro=True, limit=limit)


async def list_popular_courses(limit: int = 6) -> Iterable[dict]:
    return await list_courses(published_only=True, limit=limit)


async def list_teachers(limit: int = 20) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT user_id, display_name, photo_url, bio
            FROM app.profiles
            WHERE role_v2 = 'teacher' OR is_admin = true
            ORDER BY display_name NULLS LAST
            LIMIT %s
            """,
            (limit,),
        )
        return await cur.fetchall()


async def list_services(limit: int = 6) -> Iterable[dict]:
    services: list[dict] = []
    async for service in repo_list_services(status="active"):
        services.append(service)
        if len(services) >= limit:
            break
    return services


async def get_course(course_id: str | None = None, slug: str | None = None):
    if not course_id and not slug:
        raise ValueError("course_id or slug required")

    clauses = []
    params = []
    if course_id:
        clauses.append("id = %s")
        params.append(course_id)
    if slug:
        clauses.append("slug = %s")
        params.append(slug)

    query = """
        SELECT id, slug, title, description, cover_url, video_url,
               is_free_intro, price_cents, is_published,
               created_by, created_at, updated_at
        FROM app.courses
        WHERE {where}
        LIMIT 1
    """.format(where=" AND ".join(clauses))

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(query, params)
            except errors.UndefinedColumn:
                await conn.rollback()
                fallback_query = query.replace(
                    "cover_url, video_url,\n               ", ""
                )
                await cur.execute(fallback_query, params)
            return await _fetchone(cur)


async def list_modules(course_id: str) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, course_id, title, position, created_at
            FROM app.modules
            WHERE course_id = %s
            ORDER BY position
            """,
            (course_id,),
        )
        return await cur.fetchall()


async def list_lessons(module_id: str) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, module_id, title, position, is_intro, content_markdown,
                   created_at
            FROM app.lessons
            WHERE module_id = %s
            ORDER BY position
            """,
            (module_id,),
        )
        return await cur.fetchall()


async def list_course_lessons(course_id: str) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT l.id, l.module_id, l.title, l.position, l.is_intro, l.content_markdown
            FROM app.lessons l
            JOIN app.modules m ON m.id = l.module_id
            WHERE m.course_id = %s
            ORDER BY m.position, l.position
            """,
            (course_id,),
        )
        return await cur.fetchall()


async def get_module_row(module_id: str):
    async with get_conn() as cur:
        await cur.execute(
            "SELECT id, course_id, title, position FROM app.modules WHERE id = %s",
            (module_id,),
        )
        return await _fetchone(cur)


async def get_lesson(lesson_id: str):
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, module_id, title, position, is_intro, content_markdown
            FROM app.lessons
            WHERE id = %s
            """,
            (lesson_id,),
        )
        return await _fetchone(cur)


async def list_lesson_media(lesson_id: str) -> list[dict]:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                SELECT
                  lm.id,
                  lm.lesson_id,
                  lm.kind,
                  coalesce(mo.storage_path, lm.storage_path) AS storage_path,
                  coalesce(mo.storage_bucket, lm.storage_bucket, 'lesson-media') AS storage_bucket,
                  lm.media_id,
                  lm.position,
                  lm.duration_seconds,
                  mo.content_type,
                  mo.byte_size,
                  mo.original_name,
                  lm.created_at
                FROM app.lesson_media lm
                LEFT JOIN app.media_objects mo ON mo.id = lm.media_id
                WHERE lm.lesson_id = %s
                ORDER BY lm.position
                """,
                (lesson_id,),
            )
            rows = await cur.fetchall()
    items: list[dict] = []
    for row in rows:
        item = dict(row)
        if not item.get("storage_bucket"):
            item["storage_bucket"] = "lesson-media"
        item["download_url"] = f"/studio/media/{item['id']}"
        items.append(item)
    return items


async def add_lesson_media_entry(
    *,
    lesson_id: str,
    kind: str,
    storage_path: str | None,
    storage_bucket: str,
    position: int,
    media_id: str | None,
    duration_seconds: int | None = None,
) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                WITH inserted AS (
                  INSERT INTO app.lesson_media (
                    lesson_id,
                    kind,
                    storage_path,
                    storage_bucket,
                    media_id,
                    position,
                    duration_seconds
                  )
                  VALUES (%s, %s, %s, %s, %s, %s, %s)
                  RETURNING id, lesson_id, kind, storage_path, storage_bucket, media_id, position, duration_seconds, created_at
                )
                SELECT
                  i.id,
                  i.lesson_id,
                  i.kind,
                  coalesce(mo.storage_path, i.storage_path) AS storage_path,
                  coalesce(mo.storage_bucket, i.storage_bucket, 'lesson-media') AS storage_bucket,
                  i.media_id,
                  i.position,
                  i.duration_seconds,
                  mo.content_type,
                  mo.byte_size,
                  mo.original_name,
                  i.created_at
                FROM inserted i
                LEFT JOIN app.media_objects mo ON mo.id = i.media_id
                """,
                (
                    lesson_id,
                    kind,
                    storage_path,
                    storage_bucket,
                    media_id,
                    position,
                    duration_seconds,
                ),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def delete_lesson_media_entry(media_id: str) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                WITH deleted AS (
                  DELETE FROM app.lesson_media
                  WHERE id = %s
                  RETURNING id, lesson_id, storage_path, storage_bucket, media_id
                )
                SELECT
                  d.id,
                  d.lesson_id,
                  coalesce(mo.storage_path, d.storage_path) AS storage_path,
                  coalesce(mo.storage_bucket, d.storage_bucket, 'lesson-media') AS storage_bucket,
                  d.media_id,
                  mo.content_type,
                  mo.byte_size,
                  mo.original_name
                FROM deleted d
                LEFT JOIN app.media_objects mo ON mo.id = d.media_id
                """,
                (media_id,),
            )
            row = await _fetchone(cur)
            await conn.commit()
    if row and row.get("media_id"):
        await cleanup_media_object(row["media_id"])
    return row


async def reorder_media(lesson_id: str, ordered_ids: list[str]) -> None:
    if not ordered_ids:
        return
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            for index, media_id in enumerate(ordered_ids, start=1):
                await cur.execute(
                    "UPDATE app.lesson_media SET position = %s WHERE id = %s AND lesson_id = %s",
                    (index, media_id, lesson_id),
                )
            await conn.commit()


async def get_media(media_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT
              lm.id,
              lm.lesson_id,
              lm.kind,
              coalesce(mo.storage_path, lm.storage_path) AS storage_path,
              coalesce(mo.storage_bucket, lm.storage_bucket, 'lesson-media') AS storage_bucket,
              lm.media_id,
              mo.content_type,
              mo.byte_size,
              mo.original_name
            FROM app.lesson_media lm
            LEFT JOIN app.media_objects mo ON mo.id = lm.media_id
            WHERE lm.id = %s
            """,
            (media_id,),
        )
        return await _fetchone(cur)


async def is_course_owner(user_id: str, course_id: str) -> bool:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT created_by FROM app.courses WHERE id = %s",
            (course_id,),
        )
        row = await _fetchone(cur)
    return row is not None and row.get("created_by") == user_id


async def module_course_id(module_id: str) -> str | None:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT course_id FROM app.modules WHERE id = %s",
            (module_id,),
        )
        row = await _fetchone(cur)
    return row.get("course_id") if row else None


async def lesson_course_ids(lesson_id: str) -> tuple[str | None, str | None]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT l.module_id, m.course_id
            FROM app.lessons l
            JOIN app.modules m ON m.id = l.module_id
            WHERE l.id = %s
            """,
            (lesson_id,),
        )
        row = await _fetchone(cur)
    if not row:
        return None, None
    return row.get("module_id"), row.get("course_id")


async def add_module(course_id: str, title: str, position: int) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.modules (course_id, title, position)
                VALUES (%s, %s, %s)
                RETURNING id, course_id, title, position
                """,
                (course_id, title, position),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def update_module(module_id: str, patch: dict) -> dict | None:
    fields = []
    params = []
    for key in ("title", "position"):
        if key in patch:
            fields.append(f"{key} = %s")
            params.append(patch[key])
    if not fields:
        return await get_module_row(module_id)
    params.append(module_id)

    query = """
        UPDATE app.modules
        SET {set_clause}, updated_at = now()
        WHERE id = %s
        RETURNING id, course_id, title, position
    """.format(set_clause=", ".join(fields))

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(query, params)
            except errors.UndefinedColumn:
                await conn.rollback()
                fallback_query = """
                    UPDATE app.modules
                    SET {set_clause}
                    WHERE id = %s
                    RETURNING id, course_id, title, position
                """.format(set_clause=", ".join(fields))
                await cur.execute(fallback_query, params)
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def delete_module(module_id: str) -> bool:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "DELETE FROM app.modules WHERE id = %s",
                (module_id,),
            )
            deleted = cur.rowcount > 0
            await conn.commit()
            return deleted


async def upsert_lesson(
    *,
    lesson_id: str | None,
    module_id: str,
    title: str | None = None,
    content_markdown: str | None = None,
    position: int | None = None,
    is_intro: bool | None = None,
) -> dict | None:
    if lesson_id is None:
        async with pool.connection() as conn:  # type: ignore
            async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
                await cur.execute(
                    """
                    INSERT INTO app.lessons (module_id, title, content_markdown, position, is_intro)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id, module_id, title, content_markdown, position, is_intro
                    """,
                    (
                        module_id,
                        title,
                        content_markdown,
                        position or 0,
                        is_intro or False,
                    ),
                )
                row = await _fetchone(cur)
                await conn.commit()
                return row
    else:
        fields = []
        params = []
        if title is not None:
            fields.append("title = %s")
            params.append(title)
        if content_markdown is not None:
            fields.append("content_markdown = %s")
            params.append(content_markdown)
        if position is not None:
            fields.append("position = %s")
            params.append(position)
        if is_intro is not None:
            fields.append("is_intro = %s")
            params.append(is_intro)
        if not fields:
            return await get_lesson(lesson_id)
        params.append(lesson_id)
        query = """
            UPDATE app.lessons
            SET {set_clause}, updated_at = now()
            WHERE id = %s
            RETURNING id, module_id, title, content_markdown, position, is_intro
        """.format(set_clause=", ".join(fields))

        async with pool.connection() as conn:  # type: ignore
            async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
                try:
                    await cur.execute(query, params)
                except errors.UndefinedColumn:
                    await conn.rollback()
                    fallback_query = """
                        UPDATE app.lessons
                        SET {set_clause}
                        WHERE id = %s
                        RETURNING id, module_id, title, content_markdown, position, is_intro
                    """.format(set_clause=", ".join(fields))
                    await cur.execute(fallback_query, params)
                row = await _fetchone(cur)
                await conn.commit()
                return row


async def delete_lesson(lesson_id: str) -> bool:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "DELETE FROM app.lessons WHERE id = %s",
                (lesson_id,),
            )
            deleted = cur.rowcount > 0
            await conn.commit()
            return deleted


async def set_lesson_intro(lesson_id: str, is_intro: bool) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(
                    """
                    UPDATE app.lessons
                    SET is_intro = %s, updated_at = now()
                    WHERE id = %s
                    RETURNING id, module_id, title, position, is_intro
                    """,
                    (is_intro, lesson_id),
                )
            except errors.UndefinedColumn:
                await conn.rollback()
                await cur.execute(
                    """
                    UPDATE app.lessons
                    SET is_intro = %s
                    WHERE id = %s
                    RETURNING id, module_id, title, position, is_intro
                    """,
                    (is_intro, lesson_id),
                )
            row = await _fetchone(cur)
            await conn.commit()
            return row



async def get_profile(user_id: str):
    return await repo_get_profile(user_id)


async def update_profile(
    user_id: str,
    *,
    display_name: str | None = None,
    bio: str | None = None,
    photo_url: str | None = None,
    avatar_media_id: str | None = None,
) -> dict | None:
    return await repo_update_profile(
        user_id,
        display_name=display_name,
        bio=bio,
        photo_url=photo_url,
        avatar_media_id=avatar_media_id,
    )


async def free_course_limit() -> int:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT free_course_limit FROM app.app_config WHERE id = 1"
        )
        row = await _fetchone(cur)
    if not row or row.get("free_course_limit") is None:
        return 5
    value = row["free_course_limit"]
    if isinstance(value, int):
        return value
    if isinstance(value, (float, complex)):
        return int(value)
    if isinstance(value, str):
        try:
            return int(value)
        except ValueError:
            return 5
    return 5


async def free_consumed_count(user_id: str) -> int:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT COUNT(*)::int
            FROM app.enrollments e
            JOIN app.courses c ON c.id = e.course_id
            WHERE e.user_id = %s
              AND e.source = 'free_intro'
              AND c.is_free_intro = true
            """,
            (user_id,),
        )
        row = await _fetchone(cur)
    return row.get("count", 0) if row else 0


async def is_enrolled(user_id: str, course_id: str) -> bool:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT 1
            FROM app.enrollments
            WHERE user_id = %s AND course_id = %s
            LIMIT 1
            """,
            (user_id, course_id),
        )
        row = await _fetchone(cur)
    return row is not None


async def enroll_free_intro(user_id: str, course_id: str) -> bool:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT is_free_intro FROM app.courses WHERE id = %s",
            (course_id,),
        )
        course = await _fetchone(cur)
        if not course or not course.get("is_free_intro"):
            return False

        await cur.execute(
            """
            INSERT INTO app.enrollments (user_id, course_id, source)
            VALUES (%s, %s, 'free_intro')
            ON CONFLICT (user_id, course_id) DO NOTHING
            """,
            (user_id, course_id),
        )
        await cur.connection.commit()  # type: ignore[attr-defined]
    return True


async def list_my_courses(user_id: str) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT c.id, c.slug, c.title, c.description, c.cover_url, c.is_free_intro,
                   c.price_cents, c.is_published, c.created_at, c.updated_at
            FROM app.enrollments e
            JOIN app.courses c ON c.id = e.course_id
            WHERE e.user_id = %s
            ORDER BY c.created_at DESC
            """,
            (user_id,),
        )
        return await cur.fetchall()


async def latest_order_for_course(user_id: str, course_id: str):
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, status, amount_cents, created_at
            FROM app.orders
            WHERE user_id = %s AND course_id = %s
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (user_id, course_id),
        )
        row = await _fetchone(cur)
    return dict(row) if row else None


async def course_access_snapshot(user_id: str, course_id: str) -> dict:
    enrolled = await is_enrolled(user_id, course_id)
    latest_order = await latest_order_for_course(user_id, course_id)
    free_consumed = await free_consumed_count(user_id)
    free_limit = await free_course_limit()
    subscription = await active_subscription_for(user_id)
    status_value = (subscription or {}).get("status")
    has_active_subscription = status_value not in {
        None,
        "canceled",
        "unpaid",
        "incomplete_expired",
    }
    has_access = enrolled or has_active_subscription
    return {
        "enrolled": enrolled,
        "has_active_subscription": has_active_subscription,
        "has_access": has_access,
        "free_consumed": free_consumed,
        "free_limit": free_limit,
        "latest_order": latest_order,
    }


async def set_order_checkout_reference(
    order_id: str, *, checkout_id: str, payment_intent: str | None
) -> dict | None:
    return await repo_set_order_checkout_reference(
        order_id=order_id,
        checkout_id=checkout_id,
        payment_intent=payment_intent,
    )


async def get_user_email(user_id: str) -> str | None:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT email FROM app.profiles WHERE user_id = %s LIMIT 1",
            (user_id,),
        )
        row = await _fetchone(cur)
    if row and row.get("email"):
        return row.get("email")

    async with get_conn() as cur:
        await cur.execute(
            "SELECT email FROM auth.users WHERE id = %s LIMIT 1",
            (user_id,),
        )
        row = await _fetchone(cur)
    if row and row.get("email"):
        return row.get("email")
    return None


async def stripe_customer_id_for_user(user_id: str) -> str | None:
    async with get_conn() as cur:
        await cur.execute(
            "SELECT customer_id FROM app.stripe_customers WHERE user_id = %s",
            (user_id,),
        )
        row = await _fetchone(cur)
    return row.get("customer_id") if row else None


async def save_stripe_customer_id(user_id: str, customer_id: str) -> None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.stripe_customers (user_id, customer_id, created_at, updated_at)
                VALUES (%s, %s, now(), now())
                ON CONFLICT (user_id) DO UPDATE
                  SET customer_id = excluded.customer_id,
                      updated_at = now()
                """,
                (user_id, customer_id),
            )
            await conn.commit()


async def list_subscription_plans() -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, name, price_cents, interval, is_active
            FROM public.subscription_plans
            WHERE is_active = true
            ORDER BY price_cents, name
            """
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def active_subscription_for(user_id: str) -> dict | None:
    async with get_conn() as cur:
        try:
            await cur.execute(
                """
                SELECT id, user_id, subscription_id, status, customer_id, price_id, created_at, updated_at
                FROM app.subscriptions
                WHERE user_id = %s
                ORDER BY updated_at DESC
                LIMIT 1
                """,
                (user_id,),
            )
        except errors.UndefinedTable:
            return None
        row = await _fetchone(cur)
    return dict(row) if row else None


async def preview_coupon(plan_id: str, code: str | None) -> dict:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, price_cents
            FROM public.subscription_plans
            WHERE id = %s AND is_active = true
            LIMIT 1
            """,
            (plan_id,),
        )
        plan = await _fetchone(cur)
    if not plan:
        return {"valid": False, "pay_amount_cents": 0}

    price_cents = int(plan.get("price_cents") or 0)
    normalized_code = (code or "").strip()
    if not normalized_code:
        return {"valid": False, "pay_amount_cents": price_cents}

    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT code, max_redemptions, redeemed_count
            FROM public.coupons
            WHERE code = %s
              AND (expires_at IS NULL OR expires_at > now())
              AND (plan_id IS NULL OR plan_id = %s)
            LIMIT 1
            """,
            (normalized_code, plan_id),
        )
        coupon = await _fetchone(cur)
    if not coupon:
        return {"valid": False, "pay_amount_cents": price_cents}

    max_redemptions = coupon.get("max_redemptions")
    redeemed_count = int(coupon.get("redeemed_count") or 0)
    if max_redemptions is not None and redeemed_count >= int(max_redemptions):
        return {"valid": False, "pay_amount_cents": price_cents}

    return {"valid": True, "pay_amount_cents": 0}


async def redeem_coupon(user_id: str, plan_id: str, code: str) -> tuple[bool, str | None, dict | None]:
    normalized_code = code.strip()
    if not normalized_code:
        return False, "invalid_coupon", None

    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                SELECT id, name, interval
                FROM public.subscription_plans
                WHERE id = %s AND is_active = true
                LIMIT 1
                """,
                (plan_id,),
            )
            plan = await _fetchone(cur)
            if not plan:
                await conn.rollback()
                return False, "invalid_plan", None

            await cur.execute(
                """
                SELECT code, plan_id, grants, max_redemptions, redeemed_count, expires_at
                FROM public.coupons
                WHERE code = %s
                  AND (expires_at IS NULL OR expires_at > now())
                  AND (plan_id IS NULL OR plan_id = %s)
                FOR UPDATE
                LIMIT 1
                """,
                (normalized_code, plan_id),
            )
            coupon = await _fetchone(cur)
            if not coupon:
                await conn.rollback()
                return False, "invalid_coupon", None

            max_redemptions = coupon.get("max_redemptions")
            redeemed_count = int(coupon.get("redeemed_count") or 0)
            if max_redemptions is not None and redeemed_count >= int(max_redemptions):
                await conn.rollback()
                return False, "coupon_redeemed", None

            await cur.execute(
                "UPDATE public.coupons SET redeemed_count = redeemed_count + 1 WHERE code = %s",
                (normalized_code,),
            )

            interval_text = (plan.get("interval") or "month").lower()
            if interval_text.startswith("year"):
                period_end = datetime.now(timezone.utc) + timedelta(days=365)
            else:
                period_end = datetime.now(timezone.utc) + timedelta(days=30)

            await cur.execute(
                """
                INSERT INTO public.subscriptions (user_id, plan_id, status, current_period_end, created_at)
                VALUES (%s, %s, 'active', %s, now())
                RETURNING id, user_id, plan_id, status, current_period_end, created_at
                """,
                (user_id, plan_id, period_end),
            )
            subscription_row = await _fetchone(cur)

            grants = coupon.get("grants") or {}
            if isinstance(grants, Jsonb):
                grants = grants.obj
            if isinstance(grants, str):
                try:
                    grants = json.loads(grants)
                except ValueError:
                    grants = {}
            if not isinstance(grants, dict):
                grants = {}

            role_target = grants.get("role")
            teacher_grant = grants.get("teacher") in (True, "true", "True", 1, "1")
            raw_areas = grants.get("certified_areas") if grants else []
            certified_areas = []
            if isinstance(raw_areas, list):
                certified_areas = [str(area) for area in raw_areas if str(area).strip()]

            if role_target:
                await cur.execute(
                    "SELECT raw_app_meta_data FROM auth.users WHERE id = %s FOR UPDATE",
                    (user_id,),
                )
                user_row = await _fetchone(cur)
                raw_meta = user_row.get("raw_app_meta_data") if user_row else {}
                if isinstance(raw_meta, str):
                    try:
                        raw_meta = json.loads(raw_meta)
                    except ValueError:
                        raw_meta = {}
                if isinstance(raw_meta, dict):
                    raw_meta["role"] = role_target
                else:
                    raw_meta = {"role": role_target}
                await cur.execute(
                    "UPDATE auth.users SET raw_app_meta_data = %s WHERE id = %s",
                    (Jsonb(raw_meta), user_id),
                )

            if teacher_grant:
                await cur.execute(
                    """
                    INSERT INTO app.teacher_permissions (profile_id, can_edit_courses, can_publish, granted_by, granted_at)
                    VALUES (%s, true, true, %s, now())
                    ON CONFLICT (profile_id) DO UPDATE
                      SET can_edit_courses = true,
                          can_publish = true,
                          granted_at = COALESCE(app.teacher_permissions.granted_at, excluded.granted_at)
                    """,
                    (user_id, user_id),
                )

            for area in certified_areas:
                await cur.execute(
                    """
                    INSERT INTO public.user_certifications (user_id, area)
                    VALUES (%s, %s)
                    ON CONFLICT (user_id, area) DO NOTHING
                    """,
                    (user_id, area),
                )

            await conn.commit()
            subscription = dict(subscription_row) if subscription_row else None
            return True, None, subscription


async def start_course_order(
    user_id: str,
    course_id: str,
    amount_cents: int,
    currency: str,
    metadata: dict | None = None,
) -> dict:
    return await repo_create_order(
        user_id=user_id,
        service_id=None,
        course_id=course_id,
        amount_cents=amount_cents,
        currency=currency or "sek",
        metadata=metadata,
    )


async def start_service_order(
    user_id: str,
    service_id: str,
    amount_cents: int,
    currency: str,
    metadata: dict | None = None,
) -> dict:
    return await repo_create_order(
        user_id=user_id,
        service_id=service_id,
        course_id=None,
        amount_cents=amount_cents,
        currency=currency or "sek",
        metadata=metadata,
    )


async def get_order(order_id: str, user_id: str) -> dict | None:
    return await repo_get_user_order(order_id, user_id)


async def get_order_by_id(order_id: str) -> dict | None:
    return await repo_get_order(order_id)


async def mark_order_paid(
    order_id: str,
    *,
    payment_intent: str | None,
    checkout_id: str | None,
) -> dict | None:
    order = await repo_mark_order_paid(
        order_id,
        payment_intent=payment_intent,
        checkout_id=checkout_id,
    )
    if not order:
        return None

    course_id = order.get("course_id")
    user_id = order.get("user_id")
    if course_id and user_id:
        async with pool.connection() as conn:  # type: ignore[attr-defined]
            async with conn.cursor() as cur:  # type: ignore[attr-defined]
                await cur.execute(
                    """
                    INSERT INTO app.enrollments (user_id, course_id, source)
                    VALUES (%s, %s, 'purchase')
                    ON CONFLICT (user_id, course_id) DO NOTHING
                    """,
                    (user_id, course_id),
                )
                await conn.commit()

    return order


async def upsert_subscription_record(
    *,
    user_id: str,
    subscription_id: str,
    status: str,
    customer_id: str | None = None,
    price_id: str | None = None,
) -> dict:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.subscriptions (user_id, subscription_id, status, customer_id, price_id, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, now(), now())
                ON CONFLICT (subscription_id) DO UPDATE
                  SET user_id = excluded.user_id,
                      status = excluded.status,
                      customer_id = COALESCE(excluded.customer_id, app.subscriptions.customer_id),
                      price_id = COALESCE(excluded.price_id, app.subscriptions.price_id),
                      updated_at = now()
                RETURNING id, user_id, subscription_id, status, customer_id, price_id, created_at, updated_at
                """,
                (user_id, subscription_id, status, customer_id, price_id),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return dict(row)


async def update_subscription_status(
    subscription_id: str,
    *,
    status: str,
    customer_id: str | None = None,
    price_id: str | None = None,
) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.subscriptions
                   SET status = %s,
                       customer_id = COALESCE(%s, customer_id),
                       price_id = COALESCE(%s, price_id),
                       updated_at = now()
                 WHERE subscription_id = %s
                 RETURNING id, user_id, subscription_id, status, customer_id, price_id, created_at, updated_at
                """,
                (status, customer_id, price_id, subscription_id),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return dict(row) if row else None


async def get_subscription_record(subscription_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, user_id, subscription_id, status, customer_id, price_id
            FROM app.subscriptions
            WHERE subscription_id = %s
            LIMIT 1
            """,
            (subscription_id,),
        )
        row = await _fetchone(cur)
    return dict(row) if row else None


async def claim_purchase_with_token(user_id: str, token: str) -> bool:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                SELECT token, course_id, purchase_id
                FROM app.guest_claim_tokens
                WHERE token = %s
                  AND used = false
                  AND expires_at > now()
                FOR UPDATE
                LIMIT 1
                """,
                (token,),
            )
            claim_row = await _fetchone(cur)
            if not claim_row:
                await conn.rollback()
                return False

            course_id = claim_row.get("course_id")
            purchase_id = claim_row.get("purchase_id")

            await cur.execute(
                "UPDATE app.purchases SET user_id = %s WHERE id = %s",
                (user_id, purchase_id),
            )
            await cur.execute(
                "UPDATE app.guest_claim_tokens SET used = true WHERE token = %s",
                (token,),
            )
            if course_id:
                await cur.execute(
                    """
                    INSERT INTO app.enrollments (user_id, course_id, source)
                    VALUES (%s, %s, 'purchase')
                    ON CONFLICT (user_id, course_id) DO NOTHING
                    """,
                    (user_id, course_id),
                )

            await conn.commit()
            return True


async def course_quiz_info(course_id: str, user_id: str | None):
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(
                    "SELECT id FROM app.course_quizzes WHERE course_id = %s LIMIT 1",
                    (course_id,),
                )
            except errors.UndefinedTable:
                await conn.rollback()
                quiz = None
            else:
                quiz = await _fetchone(cur)

            certified = False
            if user_id:
                await cur.execute(
                    "SELECT 1 FROM app.certificates WHERE user_id = %s AND course_id = %s LIMIT 1",
                    (user_id, course_id),
                )
                row = await _fetchone(cur)
                certified = row is not None

            return {"quiz_id": quiz.get("id") if quiz else None, "certified": certified}


async def quiz_questions(quiz_id: str) -> Iterable[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, position, kind, prompt, options
            FROM app.quiz_questions
            WHERE quiz_id = %s
            ORDER BY position
            """,
            (quiz_id,),
        )
        return await cur.fetchall()


async def submit_quiz(quiz_id: str, user_id: str, answers: dict):
    async with get_conn() as cur:
        await cur.execute(
            "SELECT * FROM app.grade_quiz_and_issue_certificate(%s, %s::jsonb)",
            (quiz_id, Jsonb(answers)),
        )
        row = await _fetchone(cur)
    return row or {}


async def ensure_quiz_for_user(course_id: str, user_id: str) -> dict | None:
    if not await is_course_owner(user_id, course_id):
        return None
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            try:
                await cur.execute(
                    "SELECT id, course_id, title, pass_score, created_at FROM app.course_quizzes WHERE course_id = %s LIMIT 1",
                    (course_id,),
                )
            except errors.UndefinedTable:
                await conn.rollback()
                return None
            row = await _fetchone(cur)
            if row:
                return row
            await cur.execute(
                """
                INSERT INTO app.course_quizzes (course_id, title, pass_score, created_by)
                VALUES (%s, 'Quiz', 80, %s)
                RETURNING id, course_id, title, pass_score, created_at
                """,
                (course_id, user_id),
            )
            new_row = await _fetchone(cur)
            await conn.commit()
            return new_row


async def quiz_belongs_to_user(quiz_id: str, user_id: str) -> bool:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT cq.course_id, c.created_by
            FROM app.course_quizzes cq
            JOIN app.courses c ON c.id = cq.course_id
            WHERE cq.id = %s
            """,
            (quiz_id,),
        )
        row = await _fetchone(cur)
    if not row:
        return False
    return row.get("created_by") == user_id


async def upsert_quiz_question(quiz_id: str, data: dict) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            if data.get("id"):
                fields = []
                params = []
                for key in ("position", "kind", "prompt", "options", "correct"):
                    if key in data:
                        fields.append(f"{key} = %s")
                        value = data[key]
                        if key == "options" and value is not None:
                            value = Jsonb(value)
                        params.append(value)
                if not fields:
                    await cur.execute(
                        "SELECT id, quiz_id, position, kind, prompt, options, correct FROM app.quiz_questions WHERE id = %s",
                        (data["id"],),
                    )
                else:
                    params.extend([data["id"], quiz_id])
                    await cur.execute(
                        """
                        UPDATE app.quiz_questions
                        SET {set_clause}, updated_at = now()
                        WHERE id = %s AND quiz_id = %s
                        RETURNING id, quiz_id, position, kind, prompt, options, correct
                        """.format(set_clause=", ".join(fields)),
                        params,
                    )
            else:
                await cur.execute(
                    """
                    INSERT INTO app.quiz_questions (quiz_id, position, kind, prompt, options, correct)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id, quiz_id, position, kind, prompt, options, correct
                    """,
                    (
                        quiz_id,
                        data.get("position", 0),
                        data.get("kind", "single"),
                        data.get("prompt"),
                        Jsonb(data.get("options") or {}),
                        data.get("correct"),
                    ),
                )
            row = await _fetchone(cur)
            await conn.commit()
            return row


async def delete_quiz_question(question_id: str) -> bool:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "DELETE FROM app.quiz_questions WHERE id = %s",
                (question_id,),
            )
            deleted = cur.rowcount > 0
            await conn.commit()
            return deleted


def _as_string_list(value) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item) for item in value]
    if isinstance(value, str):
        return [value]
    return []


async def list_community_posts(limit: int = 50) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT p.id,
                   p.author_id,
                   p.content,
                   p.media_paths,
                   p.created_at,
                   prof.display_name,
                   prof.photo_url,
                   prof.bio
            FROM app.posts p
            LEFT JOIN app.profiles prof ON prof.user_id = p.author_id
            ORDER BY p.created_at DESC
            LIMIT %s
            """,
            (limit,),
        )
        rows = await cur.fetchall()

    items: list[dict] = []
    for row in rows:
        media_paths = _as_string_list(row.get("media_paths"))
        profile = None
        if row.get("display_name") is not None or row.get("photo_url") is not None:
            profile = {
                "user_id": row.get("author_id"),
                "display_name": row.get("display_name"),
                "photo_url": row.get("photo_url"),
                "bio": row.get("bio"),
            }
        items.append(
            {
                "id": row.get("id"),
                "author_id": row.get("author_id"),
                "content": row.get("content"),
                "media_paths": media_paths,
                "created_at": row.get("created_at"),
                "profile": profile,
            }
        )
    return items


async def create_community_post(
    author_id: str,
    content: str,
    media_paths: list[str] | None = None,
) -> dict:
    payload = Jsonb(media_paths or []) if media_paths else Jsonb([])
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                WITH inserted AS (
                    INSERT INTO app.posts (author_id, content, media_paths)
                    VALUES (%s, %s, %s)
                    RETURNING id, author_id, content, media_paths, created_at
                )
                SELECT i.id,
                       i.author_id,
                       i.content,
                       i.media_paths,
                       i.created_at,
                       prof.display_name,
                       prof.photo_url,
                       prof.bio
                FROM inserted i
                LEFT JOIN app.profiles prof ON prof.user_id = i.author_id
                """,
                (author_id, content, payload),
            )
            row = await _fetchone(cur)
            await conn.commit()

    media = _as_string_list(row.get("media_paths")) if row else []
    profile = None
    if row and (row.get("display_name") is not None or row.get("photo_url") is not None):
        profile = {
            "user_id": row.get("author_id"),
            "display_name": row.get("display_name"),
            "photo_url": row.get("photo_url"),
            "bio": row.get("bio"),
        }
    return {
        "id": row.get("id") if row else None,
        "author_id": author_id,
        "content": content,
        "media_paths": media,
        "created_at": row.get("created_at") if row else None,
        "profile": profile,
    }


async def list_teacher_directory(limit: int = 100) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT td.user_id,
                   td.headline,
                   td.specialties,
                   td.rating,
                   td.created_at,
                   prof.display_name,
                   prof.photo_url,
                   prof.bio,
                   COALESCE(cert.count, 0) AS verified_certificates
            FROM app.teacher_directory td
            LEFT JOIN app.profiles prof ON prof.user_id = td.user_id
            LEFT JOIN (
                SELECT user_id, COUNT(*) FILTER (WHERE status = 'verified') AS count
                FROM app.certificates
                GROUP BY user_id
            ) cert ON cert.user_id = td.user_id
            ORDER BY td.created_at DESC
            LIMIT %s
            """,
            (limit,),
        )
        rows = await cur.fetchall()

    items: list[dict] = []
    for row in rows:
        specialties = _as_string_list(row.get("specialties"))
        rating = row.get("rating")
        if rating is not None:
            rating = float(rating)
        profile = None
        if row.get("display_name") is not None or row.get("photo_url") is not None:
            profile = {
                "user_id": row.get("user_id"),
                "display_name": row.get("display_name"),
                "photo_url": row.get("photo_url"),
                "bio": row.get("bio"),
            }
        items.append(
            {
                "user_id": row.get("user_id"),
                "headline": row.get("headline"),
                "specialties": specialties,
                "rating": rating,
                "created_at": row.get("created_at"),
                "profile": profile,
                "verified_certificates": int(row.get("verified_certificates") or 0),
            }
        )
    return items


async def get_teacher_directory_item(user_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT td.user_id,
                   td.headline,
                   td.specialties,
                   td.rating,
                   td.created_at,
                   prof.display_name,
                   prof.photo_url,
                   prof.bio,
                   COALESCE(cert.count, 0) AS verified_certificates
            FROM app.teacher_directory td
            LEFT JOIN app.profiles prof ON prof.user_id = td.user_id
            LEFT JOIN (
                SELECT user_id, COUNT(*) FILTER (WHERE status = 'verified') AS count
                FROM app.certificates
                GROUP BY user_id
            ) cert ON cert.user_id = td.user_id
            WHERE td.user_id = %s
            LIMIT 1
            """,
            (user_id,),
        )
        row = await _fetchone(cur)

    if not row:
        return None

    specialties = _as_string_list(row.get("specialties"))
    rating = row.get("rating")
    if rating is not None:
        rating = float(rating)
    profile = None
    if row.get("display_name") is not None or row.get("photo_url") is not None:
        profile = {
            "user_id": row.get("user_id"),
            "display_name": row.get("display_name"),
            "photo_url": row.get("photo_url"),
            "bio": row.get("bio"),
        }
    return {
        "user_id": row.get("user_id"),
        "headline": row.get("headline"),
        "specialties": specialties,
        "rating": rating,
        "created_at": row.get("created_at"),
        "profile": profile,
        "verified_certificates": int(row.get("verified_certificates") or 0),
    }


async def list_teacher_services(user_id: str) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, title, description, price_cents, duration_min,
                   certified_area, active, created_at
            FROM app.services
            WHERE provider_id = %s
            ORDER BY created_at DESC
            """,
            (user_id,),
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def service_detail(service_id: str) -> tuple[dict | None, dict | None]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT
                s.id,
                s.provider_id,
                s.title,
                s.description,
                s.price_cents,
                s.duration_min,
                s.certified_area,
                s.active,
                s.created_at,
                p.user_id AS provider_user_id,
                p.display_name AS provider_display_name,
                p.photo_url AS provider_photo_url,
                p.bio AS provider_bio
            FROM app.services s
            LEFT JOIN app.profiles p ON p.user_id = s.provider_id
            WHERE s.id = %s
            LIMIT 1
            """,
            (service_id,),
        )
        row = await _fetchone(cur)
    if not row:
        return None, None
    row_dict = dict(row)
    service_keys = {
        "id",
        "provider_id",
        "title",
        "description",
        "price_cents",
        "duration_min",
        "certified_area",
        "active",
        "created_at",
    }
    service = {key: row_dict.get(key) for key in service_keys if key in row_dict}
    provider = None
    provider_user_id = row_dict.get("provider_user_id")
    if provider_user_id:
        provider = {
            "user_id": provider_user_id,
            "display_name": row_dict.get("provider_display_name"),
            "photo_url": row_dict.get("provider_photo_url"),
            "bio": row_dict.get("provider_bio"),
        }
    return service, provider


async def list_tarot_requests_for_user(user_id: str) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, requester_id, reader_id, question, status,
                   deliverable_url, created_at, updated_at
            FROM app.tarot_requests
            WHERE requester_id = %s
            ORDER BY created_at DESC
            """,
            (user_id,),
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def create_tarot_request(user_id: str, question: str) -> dict:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.tarot_requests (requester_id, question)
                VALUES (%s, %s)
                RETURNING id, requester_id, reader_id, question, status,
                          deliverable_url, created_at, updated_at
                """,
                (user_id, question),
            )
            row = await _fetchone(cur)
            await conn.commit()
            return dict(row)


async def list_teacher_meditations(user_id: str) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, teacher_id, title, description, audio_path,
                   duration_seconds, is_public, created_at
            FROM app.meditations
            WHERE teacher_id = %s
            ORDER BY created_at DESC
            """,
            (user_id,),
        )
        rows = await cur.fetchall()
    items: list[dict] = []
    for row in rows:
        item = dict(row)
        item["audio_url"] = _build_audio_url(row.get("audio_path"))
        items.append(item)
    return items


async def verified_certificate_counts(user_ids: list[str]) -> dict[str, int]:
    if not user_ids:
        return {}
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT user_id, COUNT(*) AS count
            FROM app.certificates
            WHERE status = 'verified' AND user_id = ANY(%s)
            GROUP BY user_id
            """,
            (user_ids,),
        )
        rows = await cur.fetchall()
    return {row["user_id"]: int(row["count"]) for row in rows}


async def list_reviews_for_service(service_id: str) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, service_id, reviewer_id, rating, comment, created_at
            FROM app.reviews
            WHERE service_id = %s
            ORDER BY created_at DESC
            """,
            (service_id,),
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def add_review_for_service(
    service_id: str,
    reviewer_id: str,
    rating: int,
    comment: str | None = None,
) -> dict:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.reviews (service_id, reviewer_id, rating, comment)
                VALUES (%s, %s, %s, %s)
                RETURNING id, service_id, reviewer_id, rating, comment, created_at
                """,
                (service_id, reviewer_id, int(rating), comment),
            )
            row = await _fetchone(cur)
            await conn.commit()
    return dict(row)


async def list_channel_messages(channel: str) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, channel, sender_id, content, created_at
            FROM app.messages
            WHERE channel = %s AND sender_id IS NOT NULL
            ORDER BY created_at
            """,
            (channel,),
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def create_channel_message(
    channel: str,
   sender_id: str,
   content: str,
) -> dict:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.messages (channel, sender_id, content)
                VALUES (%s, %s, %s)
                RETURNING id, channel, sender_id, content, created_at
                """,
                (channel, sender_id, content),
            )
            row = await _fetchone(cur)
            await conn.commit()
    return dict(row)


def _build_audio_url(audio_path: str | None) -> str | None:
    if not audio_path:
        return None
    sanitized = audio_path.lstrip('/')
    return f"/community/meditations/audio?path={quote(sanitized)}"


async def list_public_meditations(limit: int = 100) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, teacher_id, title, description, audio_path,
                   duration_seconds, is_public, created_at
            FROM app.meditations
            WHERE is_public = true
            ORDER BY created_at DESC
            LIMIT %s
            """,
            (limit,),
        )
        rows = await cur.fetchall()

    items: list[dict] = []
    for row in rows:
        item = dict(row)
        item["audio_url"] = _build_audio_url(row.get("audio_path"))
        items.append(item)
    return items


async def get_profile_row(user_id: str) -> dict | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT user_id, email, display_name, bio, photo_url, role_v2, is_admin
            FROM app.profiles
            WHERE user_id = %s
            LIMIT 1
            """,
            (user_id,),
        )
        row = await _fetchone(cur)
    return dict(row) if row else None


async def is_admin_user(user_id: str) -> bool:
    profile = await get_profile_row(user_id)
    if not profile:
        return False
    if profile.get("is_admin"):
        return True
    role = (profile.get("role_v2") or "").lower()
    return role == "admin"


async def list_teacher_applications() -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT c.id,
                   c.user_id,
                   c.title,
                   c.status,
                   c.notes,
                   c.evidence_url,
                   c.created_at,
                   c.updated_at,
                   prof.display_name,
                   prof.email,
                   prof.role_v2,
                   ta.approved_by,
                   ta.approved_at
            FROM app.certificates c
            LEFT JOIN app.profiles prof ON prof.user_id = c.user_id
            LEFT JOIN app.teacher_approvals ta ON ta.user_id = c.user_id
            WHERE lower(c.title) = lower(%s)
            ORDER BY c.created_at DESC
            """,
            ("Läraransökan",),
        )
        rows = await cur.fetchall()

    items: list[dict] = []
    for row in rows:
        item = dict(row)
        approval = None
        if row.get("approved_at") is not None or row.get("approved_by") is not None:
            approval = {
                "approved_by": row.get("approved_by"),
                "approved_at": row.get("approved_at"),
            }
        if approval:
            item["approval"] = approval
        items.append(item)
    return items


async def list_recent_certificates(limit: int = 200) -> list[dict]:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, user_id, title, status, notes, evidence_url,
                   created_at, updated_at
            FROM app.certificates
            ORDER BY created_at DESC
            LIMIT %s
            """,
            (limit,),
        )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def set_certificate_status(cert_id: str, status: str) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.certificates
                SET status = %s, updated_at = now()
                WHERE id = %s
                RETURNING id, user_id, title, status, notes, evidence_url, created_at, updated_at
                """,
                (status, cert_id),
            )
            row = await _fetchone(cur)
            await conn.commit()
    return dict(row) if row else None


async def approve_teacher_user(user_id: str, reviewer_id: str) -> None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "UPDATE app.profiles SET role_v2 = 'teacher', updated_at = now() WHERE user_id = %s",
                (user_id,),
            )
            await cur.execute(
                """
                INSERT INTO app.teacher_approvals (user_id, approved_by, approved_at)
                VALUES (%s, %s, now())
                ON CONFLICT (user_id)
                DO UPDATE SET approved_by = EXCLUDED.approved_by, approved_at = EXCLUDED.approved_at
                """,
                (user_id, reviewer_id),
            )
            await cur.execute(
                """
                UPDATE app.certificates
                SET status = 'verified', updated_at = now()
                WHERE user_id = %s AND lower(title) = lower(%s)
                """,
                (user_id, "Läraransökan"),
            )
            await conn.commit()


async def reject_teacher_user(user_id: str, reviewer_id: str) -> None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.certificates
                SET status = 'rejected', updated_at = now()
                WHERE user_id = %s AND lower(title) = lower(%s)
                """,
                (user_id, "Läraransökan"),
            )
            await cur.execute(
                "DELETE FROM app.teacher_approvals WHERE user_id = %s",
                (user_id,),
            )
            await conn.commit()


async def follow_user(follower_id: str, followee_id: str) -> None:
    if follower_id == followee_id:
        raise ValueError("Cannot follow self")
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.follows (follower_id, followee_id)
                VALUES (%s, %s)
                ON CONFLICT (follower_id, followee_id) DO NOTHING
                """,
                (follower_id, followee_id),
            )
            await conn.commit()


async def unfollow_user(follower_id: str, followee_id: str) -> None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                "DELETE FROM app.follows WHERE follower_id = %s AND followee_id = %s",
                (follower_id, followee_id),
            )
            await conn.commit()


async def is_following_user(follower_id: str, followee_id: str) -> bool:
    if not follower_id or not followee_id:
        return False
    async with get_conn() as cur:
        await cur.execute(
            "SELECT 1 FROM app.follows WHERE follower_id = %s AND followee_id = %s LIMIT 1",
            (follower_id, followee_id),
        )
        row = await _fetchone(cur)
        return row is not None


async def list_notifications_for_user(
    user_id: str, unread_only: bool = False
) -> list[dict]:
    async with get_conn() as cur:
        if unread_only:
            await cur.execute(
                """
                SELECT id, kind, payload, is_read, created_at
                FROM app.notifications
                WHERE user_id = %s AND is_read = false
                ORDER BY created_at DESC
                LIMIT 200
                """,
                (user_id,),
            )
        else:
            await cur.execute(
                """
                SELECT id, kind, payload, is_read, created_at
                FROM app.notifications
                WHERE user_id = %s
                ORDER BY created_at DESC
                LIMIT 200
                """,
                (user_id,),
            )
        rows = await cur.fetchall()
    return [dict(row) for row in rows]


async def mark_notification_read(
    notification_id: str, user_id: str, is_read: bool
) -> dict | None:
    async with pool.connection() as conn:  # type: ignore
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.notifications
                SET is_read = %s
                WHERE id = %s AND user_id = %s
                RETURNING id, user_id, kind, payload, is_read, created_at
                """,
                (is_read, notification_id, user_id),
            )
            row = await _fetchone(cur)
            await conn.commit()
    return dict(row) if row else None


async def profile_overview(
    target_user_id: str,
    viewer_id: str | None = None,
) -> dict | None:
    profile = await get_profile_row(target_user_id)
    if not profile:
        return None
    is_following = False
    if viewer_id and viewer_id != target_user_id:
        is_following = await is_following_user(viewer_id, target_user_id)
    services = await list_teacher_services(target_user_id)
    meditations = await list_teacher_meditations(target_user_id)
    return {
        "profile": profile,
        "is_following": is_following,
        "services": services,
        "meditations": meditations,
    }
