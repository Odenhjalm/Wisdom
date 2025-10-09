import json
import uuid

import pytest

from app.config import settings


@pytest.mark.anyio
async def test_backend_api_smoke(async_client, monkeypatch):
    # Configure external integrations for deterministic behaviour
    settings.stripe_secret_key = "sk_test_dummy"
    settings.stripe_webhook_secret = "whsec_dummy"
    settings.livekit_api_key = "lk_test_key"
    settings.livekit_api_secret = "lk_test_secret"
    settings.livekit_ws_url = "wss://livekit.example.com"

    email = f"smoke_{uuid.uuid4().hex[:6]}@wisdom.local"
    password = "Secret123!"

    register_resp = await async_client.post(
        "/auth/register",
        json={
            "email": email,
            "password": password,
            "display_name": "Smoke Tester",
        },
    )
    assert register_resp.status_code == 201, register_resp.text
    tokens = register_resp.json()
    assert "access_token" in tokens and "refresh_token" in tokens

    auth_headers = {"Authorization": f"Bearer {tokens['access_token']}"}

    me_resp = await async_client.get("/auth/me", headers=auth_headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["email"] == email

    refresh_resp = await async_client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"]},
    )
    assert refresh_resp.status_code == 200
    new_tokens = refresh_resp.json()
    assert new_tokens["access_token"]

    services_resp = await async_client.get("/services?status=active", headers=auth_headers)
    assert services_resp.status_code == 200
    services_payload = services_resp.json()
    assert services_payload["items"], "expected seeded services"
    service_id = services_payload["items"][0]["id"]

    order_resp = await async_client.post(
        "/orders",
        headers=auth_headers,
        json={"service_id": service_id},
    )
    assert order_resp.status_code == 201
    order_payload = order_resp.json()["order"]
    order_id = order_payload["id"]

    def fake_checkout_create(**kwargs):
        return {
            "id": "cs_test_smoke",
            "url": "https://stripe.test/cs_test_smoke",
            "payment_intent": "pi_test_smoke",
        }

    def fake_construct_event(payload, sig_header, secret):
        body = json.loads(payload)
        return {
            "type": body.get("event_type", "checkout.session.completed"),
            "data": {"object": body},
        }

    monkeypatch.setattr("stripe.checkout.Session.create", fake_checkout_create)
    monkeypatch.setattr("stripe.Webhook.construct_event", fake_construct_event)

    checkout_resp = await async_client.post(
        "/payments/stripe/create-session",
        headers=auth_headers,
        json={
            "order_id": order_id,
            "success_url": "https://example.org/success",
            "cancel_url": "https://example.org/cancel",
        },
    )
    assert checkout_resp.status_code == 201
    checkout_payload = checkout_resp.json()
    assert checkout_payload["url"].startswith("https://stripe.test")

    webhook_payload = {
        "metadata": {"order_id": order_id},
        "payment_intent": "pi_test_smoke",
        "amount_total": order_payload["amount_cents"],
        "currency": order_payload["currency"],
    }
    webhook_resp = await async_client.post(
        "/payments/webhooks/stripe",
        content=json.dumps(webhook_payload),
        headers={"stripe-signature": "signature"},
    )
    assert webhook_resp.status_code == 200

    order_after_webhook = await async_client.get(f"/orders/{order_id}", headers=auth_headers)
    assert order_after_webhook.status_code == 200
    assert order_after_webhook.json()["order"]["status"] == "paid"

    feed_resp = await async_client.get("/feed", headers=auth_headers)
    assert feed_resp.status_code == 200
    assert isinstance(feed_resp.json()["items"], list)

    student_login = await async_client.post(
        "/auth/login",
        json={"email": "student@wisdom.local", "password": "password123"},
    )
    assert student_login.status_code == 200
    student_token = student_login.json()["access_token"]
    seminar_resp = await async_client.post(
        "/sfu/token",
        headers={"Authorization": f"Bearer {student_token}"},
        json={"seminar_id": "99999999-9999-4999-8999-999999999999"},
    )
    assert seminar_resp.status_code == 200
    assert seminar_resp.json()["ws_url"] == settings.livekit_ws_url
