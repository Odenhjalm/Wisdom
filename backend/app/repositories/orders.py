from __future__ import annotations

from typing import Any
from uuid import UUID

from psycopg.rows import dict_row
from psycopg.types.json import Jsonb

from ..db import get_conn, pool


async def create_order(
    *,
    user_id: str | UUID,
    service_id: str | UUID | None,
    course_id: str | UUID | None,
    amount_cents: int,
    currency: str,
    metadata: dict[str, Any] | None = None,
) -> dict[str, Any]:
    async with pool.connection() as conn:  # type: ignore[attr-defined]
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                INSERT INTO app.orders (user_id, service_id, course_id, amount_cents, currency, status, metadata)
                VALUES (%s, %s, %s, %s, %s, 'pending', %s)
                RETURNING id, user_id, service_id, course_id, amount_cents,
                          currency, status, stripe_checkout_id,
                          stripe_payment_intent, metadata, created_at, updated_at
                """,
                (
                    user_id,
                    service_id,
                    course_id,
                    amount_cents,
                    currency,
                    Jsonb(metadata or {}),
                ),
            )
            row = await cur.fetchone()
            await conn.commit()
            return dict(row)


async def get_order(order_id: str | UUID) -> dict[str, Any] | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, user_id, service_id, course_id, amount_cents,
                   currency, status, stripe_checkout_id,
                   stripe_payment_intent, metadata, created_at, updated_at
            FROM app.orders
            WHERE id = %s
            LIMIT 1
            """,
            (order_id,),
        )
        row = await cur.fetchone()
        return dict(row) if row else None


async def get_user_order(order_id: str | UUID, user_id: str | UUID) -> dict[str, Any] | None:
    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT id, user_id, service_id, course_id, amount_cents,
                   currency, status, stripe_checkout_id,
                   stripe_payment_intent, metadata, created_at, updated_at
            FROM app.orders
            WHERE id = %s AND user_id = %s
            LIMIT 1
            """,
            (order_id, user_id),
        )
        row = await cur.fetchone()
        return dict(row) if row else None


async def set_order_checkout_reference(
    *,
    order_id: str | UUID,
    checkout_id: str | None,
    payment_intent: str | None,
) -> dict[str, Any] | None:
    async with pool.connection() as conn:  # type: ignore[attr-defined]
        async with conn.cursor(row_factory=dict_row) as cur:  # type: ignore[attr-defined]
            await cur.execute(
                """
                UPDATE app.orders
                   SET stripe_checkout_id = %s,
                       stripe_payment_intent = COALESCE(%s, stripe_payment_intent),
                       updated_at = now()
                 WHERE id = %s
                 RETURNING id, user_id, service_id, course_id, amount_cents,
                           currency, status, stripe_checkout_id, stripe_payment_intent,
                           metadata, created_at, updated_at
                """,
                (checkout_id, payment_intent, order_id),
            )
            row = await cur.fetchone()
            await conn.commit()
            return dict(row) if row else None
