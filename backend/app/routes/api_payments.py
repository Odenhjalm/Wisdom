import json
import logging

import stripe
from fastapi import APIRouter, HTTPException, Request, status
from starlette.concurrency import run_in_threadpool

from .. import repositories, schemas
from ..auth import CurrentUser
from ..config import settings

router = APIRouter(prefix="/payments", tags=["payments"])
logger = logging.getLogger(__name__)


@router.post("/stripe/create-session", response_model=schemas.CheckoutSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_stripe_session(
    payload: schemas.CheckoutSessionRequest,
    current: CurrentUser,
):
    if not settings.stripe_secret_key:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Stripe is not configured")

    order = await repositories.get_user_order(payload.order_id, current["id"])
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    if order.get("status") == "paid":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Order already paid")

    amount_cents = int(order.get("amount_cents") or 0)
    if amount_cents <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Order amount is missing")

    currency = (order.get("currency") or "sek").lower()

    stripe.api_key = settings.stripe_secret_key

    checkout_kwargs: dict[str, object] = {
        "mode": "payment",
        "payment_method_types": ["card"],
        "client_reference_id": str(order["id"]),
        "metadata": {
            "order_id": str(order["id"]),
            "user_id": str(order["user_id"]),
            "currency": currency,
        },
        "line_items": [
            {
                "price_data": {
                    "currency": currency,
                    "unit_amount": amount_cents,
                    "product_data": {"name": "Wisdom order"},
                },
                "quantity": 1,
            }
        ],
        "success_url": payload.success_url,
        "cancel_url": payload.cancel_url,
    }
    if payload.customer_email:
        checkout_kwargs["customer_email"] = payload.customer_email

    try:
        session = await run_in_threadpool(lambda: stripe.checkout.Session.create(**checkout_kwargs))
    except stripe.error.StripeError as exc:  # type: ignore[attr-defined]
        logger.exception("Stripe checkout session failed: %s", exc)
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to create checkout session") from exc

    await repositories.set_order_checkout_reference(
        order_id=order["id"],
        checkout_id=session.get("id"),
        payment_intent=session.get("payment_intent"),
    )

    url = session.get("url")
    if not url:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Session missing URL")

    return schemas.CheckoutSessionResponse(url=url, id=session.get("id"))


@router.post("/webhooks/stripe", status_code=status.HTTP_200_OK)
async def stripe_webhook(request: Request):
    if not settings.stripe_webhook_secret:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Stripe webhook secret missing")

    body = await request.body()
    signature = request.headers.get("stripe-signature")
    if not signature:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing Stripe signature")

    try:
        event = stripe.Webhook.construct_event(
            payload=body.decode("utf-8"),
            sig_header=signature,
            secret=settings.stripe_webhook_secret,
        )
    except ValueError as exc:
        logger.warning("Invalid payload: %s", exc)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid payload") from exc
    except stripe.error.SignatureVerificationError as exc:  # type: ignore[attr-defined]
        logger.warning("Invalid signature: %s", exc)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid signature") from exc

    event_type = event.get("type")
    data_object = event.get("data", {}).get("object", {})

    if event_type == "checkout.session.completed":
        await _handle_checkout_completed(data_object)
    elif event_type == "payment_intent.succeeded":
        await _handle_payment_intent(data_object)
    else:
        logger.info("Unhandled Stripe event type: %s", event_type)

    return {"status": "ok"}


async def _handle_checkout_completed(session: dict[str, object]) -> None:
    order_id = session.get("metadata", {}).get("order_id") if isinstance(session.get("metadata"), dict) else None
    payment_intent = session.get("payment_intent")
    if not order_id:
        logger.warning("Checkout session missing order_id metadata")
        return

    order = await repositories.get_order(order_id)
    if not order:
        logger.warning("Order %s not found during webhook", order_id)
        return

    amount_cents = int(session.get("amount_total") or order.get("amount_cents") or 0)
    currency = (session.get("currency") or order.get("currency") or "sek").lower()

    await repositories.mark_order_paid(order_id)
    await repositories.record_payment(
        order_id=order_id,
        provider="stripe",
        provider_reference=str(payment_intent) if payment_intent else None,
        status="paid",
        amount_cents=amount_cents,
        currency=currency,
        metadata={"event": "checkout.session.completed"},
        payload=session if isinstance(session, dict) else json.loads(json.dumps(session)),
    )


async def _handle_payment_intent(intent: dict[str, object]) -> None:
    charges = intent.get("charges", {})
    data_list = charges.get("data", []) if isinstance(charges, dict) else []
    if not data_list:
        logger.debug("Payment intent without charges data")
        return
    charge = data_list[0]
    metadata = charge.get("metadata", {}) if isinstance(charge, dict) else {}
    order_id = metadata.get("order_id")
    if not order_id:
        logger.debug("Payment intent missing order_id metadata")
        return

    order = await repositories.get_order(order_id)
    if not order:
        logger.warning("Order %s not found for payment intent", order_id)
        return

    amount_cents = int(charge.get("amount") or order.get("amount_cents") or 0)
    currency = (charge.get("currency") or order.get("currency") or "sek").lower()

    await repositories.mark_order_paid(order_id)
    await repositories.record_payment(
        order_id=order_id,
        provider="stripe",
        provider_reference=str(intent.get("id")),
        status="paid",
        amount_cents=amount_cents,
        currency=currency,
        metadata={"event": "payment_intent.succeeded"},
        payload=intent if isinstance(intent, dict) else json.loads(json.dumps(intent)),
    )
