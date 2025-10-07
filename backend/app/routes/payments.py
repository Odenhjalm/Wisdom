import json
import logging

import stripe
from fastapi import APIRouter, HTTPException, Request, status
from starlette.concurrency import run_in_threadpool

from .. import models, schemas
from ..auth import CurrentUser
from ..config import settings

router = APIRouter(prefix="/payments", tags=["payments"])

logger = logging.getLogger(__name__)


@router.get("/plans", response_model=schemas.SubscriptionPlanListResponse)
async def payments_plans():  # noqa: D401 - simple data fetch
    items = await models.list_subscription_plans()
    return {"items": items}


@router.get(
    "/subscription",
    response_model=schemas.SubscriptionStatusResponse,
)
async def payments_subscription(current: CurrentUser):
    subscription = await models.active_subscription_for(current["id"])
    status_value = (subscription or {}).get("status")
    has_active = status_value not in {None, "canceled", "unpaid", "incomplete_expired"}
    return {"has_active": has_active, "subscription": subscription}


@router.post(
    "/coupons/preview",
    response_model=schemas.CouponPreviewResponse,
)
async def payments_coupon_preview(payload: schemas.CouponPreviewRequest):
    result = await models.preview_coupon(str(payload.plan_id), payload.code)
    return result


@router.post(
    "/coupons/redeem",
    response_model=schemas.CouponRedeemResponse,
)
async def payments_coupon_redeem(
    payload: schemas.CouponRedeemRequest,
    current: CurrentUser,
):
    ok, reason, subscription = await models.redeem_coupon(
        current["id"], str(payload.plan_id), payload.code
    )
    return {"ok": ok, "reason": reason, "subscription": subscription}


@router.post(
    "/orders/course",
    response_model=schemas.OrderResponse,
    status_code=status.HTTP_201_CREATED,
)
async def payments_create_course_order(
    payload: schemas.OrderCourseCreateRequest,
    current: CurrentUser,
):
    order = await models.start_course_order(
        current["id"],
        str(payload.course_id),
        payload.amount_cents,
        payload.currency or "sek",
        payload.metadata,
    )
    return {"order": order}


@router.post(
    "/orders/service",
    response_model=schemas.OrderResponse,
    status_code=status.HTTP_201_CREATED,
)
async def payments_create_service_order(
    payload: schemas.OrderServiceCreateRequest,
    current: CurrentUser,
):
    order = await models.start_service_order(
        current["id"],
        str(payload.service_id),
        payload.amount_cents,
        payload.currency or "sek",
        payload.metadata,
    )
    return {"order": order}


@router.get(
    "/orders/{order_id}",
    response_model=schemas.OrderResponse,
)
async def payments_get_order(order_id: str, current: CurrentUser):
    order = await models.get_order(order_id, current["id"])
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return {"order": order}


@router.post(
    "/create-checkout-session",
    response_model=schemas.CheckoutSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
async def payments_create_checkout_session(
    payload: schemas.CreateCheckoutSessionRequest,
    current: CurrentUser,
):
    if not settings.stripe_secret_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Stripe är inte konfigurerat.",
        )

    order = await models.get_order(str(payload.order_id), current["id"])
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    if order.get("status") == "paid":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ordern är redan betald")

    amount_cents = int(order.get("amount_cents") or 0)
    if amount_cents <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Orderbelopp saknas")

    currency = (order.get("currency") or "sek").lower()
    description = "Wisdom order"

    course_id = order.get("course_id")
    service_id = order.get("service_id")
    if course_id:
        course = await get_course_title_safe(str(course_id))
        if course:
            description = f"Kurs: {course}"
    elif service_id:
        service = await get_service_title_safe(str(service_id))
        if service:
            description = f"Tjänst: {service}"

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
                    "product_data": {"name": description},
                },
                "quantity": 1,
            }
        ],
        "success_url": payload.success_url,
        "cancel_url": payload.cancel_url,
    }
    if payload.customer_email:
        checkout_kwargs["customer_email"] = payload.customer_email

    stripe.api_key = settings.stripe_secret_key

    try:
        session = await run_in_threadpool(
            lambda: stripe.checkout.Session.create(**checkout_kwargs)
        )
    except stripe.error.StripeError as error:  # type: ignore[attr-defined]
        logger.exception("Stripe checkout session failed: %s", error)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Kunde inte skapa Stripe-session.",
        ) from error

    await models.set_order_checkout_reference(
        str(order["id"]),
        checkout_id=session.get("id"),
        payment_intent=session.get("payment_intent"),
    )

    url = session.get("url")
    if not url:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Stripe-session saknar URL.",
        )

    return {"url": url, "id": session.get("id")}


@router.post(
    "/create-subscription",
    response_model=schemas.CreateSubscriptionResponse,
    status_code=status.HTTP_201_CREATED,
)
async def payments_create_subscription(
    payload: schemas.CreateSubscriptionRequest,
    current: CurrentUser,
):
    if not settings.stripe_secret_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Stripe är inte konfigurerat.",
        )

    user_id = str(payload.user_id)
    if user_id != str(current["id"]):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Åtkomst nekad")

    price_id = payload.price_id.strip()
    if not price_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="priceId saknas")

    email = await models.get_user_email(user_id)
    if not email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Användaren saknar e-postadress")

    stripe.api_key = settings.stripe_secret_key

    customer_id = await models.stripe_customer_id_for_user(user_id)
    if not customer_id:
        try:
            customer = await run_in_threadpool(
                lambda: stripe.Customer.create(  # type: ignore[attr-defined]
                    email=email,
                    metadata={"user_id": user_id},
                )
            )
        except stripe.error.StripeError as error:  # type: ignore[attr-defined]
            logger.exception("Kunde inte skapa Stripe-kund: %s", error)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Stripe-kund kunde inte skapas.",
            ) from error
        customer_id = customer.get("id")
        if not customer_id:
            raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Stripe returnerade inget kund-ID")
        await models.save_stripe_customer_id(user_id, customer_id)

    try:
        subscription = await run_in_threadpool(
            lambda: stripe.Subscription.create(  # type: ignore[attr-defined]
                customer=customer_id,
                items=[{"price": price_id}],
                payment_behavior="default_incomplete",
                expand=["latest_invoice.payment_intent"],
            )
        )
    except stripe.error.StripeError as error:  # type: ignore[attr-defined]
        logger.exception("Kunde inte skapa Stripe-subscription: %s", error)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Stripe-subscription kunde inte skapas.",
        ) from error

    subscription_id = subscription.get("id")
    if not subscription_id:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Stripe returnerade inget subscription-ID")

    latest_invoice = subscription.get("latest_invoice") or {}
    payment_intent = (latest_invoice.get("payment_intent") or {}) if isinstance(latest_invoice, dict) else {}
    client_secret = payment_intent.get("client_secret")
    status_value = subscription.get("status") or "incomplete"

    await models.upsert_subscription_record(
        user_id=user_id,
        subscription_id=subscription_id,
        status=status_value,
        customer_id=customer_id,
        price_id=price_id,
    )

    return {
        "subscription_id": subscription_id,
        "client_secret": client_secret,
        "status": status_value,
    }


@router.post(
    "/purchases/claim",
    response_model=schemas.PurchaseClaimResponse,
)
async def payments_claim_purchase(
    payload: schemas.PurchaseClaimRequest,
    current: CurrentUser,
):
    ok = await models.claim_purchase_with_token(current["id"], str(payload.token))
    return {"ok": ok}


@router.post("/cancel-subscription", status_code=status.HTTP_200_OK)
async def payments_cancel_subscription(
    payload: schemas.CancelSubscriptionRequest,
    current: CurrentUser,
):
    if not settings.stripe_secret_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Stripe är inte konfigurerat.",
        )

    subscription_id = payload.subscription_id.strip()
    if not subscription_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="subscriptionId saknas")

    record = await models.get_subscription_record(subscription_id)
    if record and str(record.get("user_id")) != str(current["id"]):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Åtkomst nekad")

    stripe.api_key = settings.stripe_secret_key

    try:
        await run_in_threadpool(
            lambda: stripe.Subscription.delete(subscription_id)  # type: ignore[attr-defined]
        )
    except stripe.error.InvalidRequestError as error:  # type: ignore[attr-defined]
        logger.warning("Stripe-subscription fanns inte: %s", error)
    except stripe.error.StripeError as error:  # type: ignore[attr-defined]
        logger.exception("Stripe avbröt inte subscription: %s", error)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Kunde inte avbryta subscription hos Stripe.",
        ) from error

    await models.update_subscription_status(subscription_id, status="canceled")
    return {"subscription_id": subscription_id, "status": "canceled"}


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def payments_webhook(request: Request):
    if not settings.stripe_secret_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Stripe är inte konfigurerat.",
        )

    payload = await request.body()
    signature = request.headers.get("Stripe-Signature")

    stripe.api_key = settings.stripe_secret_key

    if settings.stripe_webhook_secret:
        try:
            event = stripe.Webhook.construct_event(  # type: ignore[attr-defined]
                payload, signature, settings.stripe_webhook_secret
            )
        except ValueError as error:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ogiltigt payload") from error
        except stripe.error.SignatureVerificationError as error:  # type: ignore[attr-defined]
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ogiltig signatur") from error
    else:
        try:
            event = json.loads(payload)
        except json.JSONDecodeError as error:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ogiltigt JSON") from error

    event_type = event.get("type")
    data_object = (event.get("data") or {}).get("object") or {}

    if event_type in {"checkout.session.completed", "checkout.session.async_payment_succeeded"}:
        order_id = data_object.get("client_reference_id") or (
            (data_object.get("metadata") or {}).get("order_id")
        )
        if order_id:
            payment_intent = data_object.get("payment_intent")
            checkout_id = data_object.get("id")
            order = await models.get_order_by_id(str(order_id))
            if not order:
                logger.warning("Webhook for okänt order-id: %s", order_id)
            else:
                await models.mark_order_paid(
                    str(order_id),
                    payment_intent=str(payment_intent) if payment_intent else None,
                    checkout_id=checkout_id,
                )

        subscription_id = data_object.get("subscription")
        if subscription_id:
            status_value = data_object.get("status") or "active"
            await models.update_subscription_status(
                str(subscription_id),
                status=status_value,
                customer_id=str(data_object.get("customer")) if data_object.get("customer") else None,
            )
        elif not order_id:
            logger.warning("Webhook saknar identifierare för order eller subscription: %s", data_object)

    elif event_type == "invoice.payment_succeeded":
        subscription_id = data_object.get("subscription")
        if subscription_id:
            await models.update_subscription_status(str(subscription_id), status="active")

    elif event_type == "invoice.payment_failed":
        subscription_id = data_object.get("subscription")
        if subscription_id:
            await models.update_subscription_status(str(subscription_id), status="past_due")

    elif event_type == "customer.subscription.updated":
        subscription_id = data_object.get("id")
        if subscription_id:
            await models.update_subscription_status(
                str(subscription_id),
                status=data_object.get("status") or "active",
                customer_id=str(data_object.get("customer")) if data_object.get("customer") else None,
                price_id=_extract_price_id_from_subscription(data_object),
            )

    elif event_type == "customer.subscription.deleted":
        subscription_id = data_object.get("id")
        if subscription_id:
            await models.update_subscription_status(str(subscription_id), status="canceled")

    return {"ok": True}


async def get_course_title_safe(course_id: str) -> str | None:
    try:
        course = await models.get_course(course_id=course_id)
    except Exception as error:  # pragma: no cover - defensiv guard
        logger.debug("Kunde inte hämta kurs %s: %s", course_id, error)
        return None
    if not course:
        return None
    return course.get("title")


async def get_service_title_safe(service_id: str) -> str | None:
    try:
        service, _ = await models.service_detail(service_id)
    except Exception as error:  # pragma: no cover
        logger.debug("Kunde inte hämta tjänst %s: %s", service_id, error)
        return None
    if not service:
        return None
    return service.get("title")


def _extract_price_id_from_subscription(subscription: dict) -> str | None:
    items = subscription.get("items")
    if not isinstance(items, dict):
        return None
    data = items.get("data")
    if not isinstance(data, list) or not data:
        return None
    first_item = data[0]
    if not isinstance(first_item, dict):
        return None
    price = first_item.get("price")
    if isinstance(price, dict):
        return price.get("id")
    return None
