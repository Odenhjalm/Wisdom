from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException, status
from jose import jwt

from .. import repositories, schemas
from ..auth import CurrentUser
from ..config import settings

router = APIRouter(prefix="/sfu", tags=["sfu"])


@router.post("/token", response_model=schemas.LiveKitTokenResponse)
async def create_livekit_token(payload: schemas.LiveKitTokenRequest, current: CurrentUser):
    if not settings.livekit_api_key or not settings.livekit_api_secret or not settings.livekit_ws_url:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="LiveKit configuration missing")

    seminar = await repositories.get_seminar(payload.seminar_id)
    if not seminar:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Seminar not found")

    allowed = await repositories.user_can_access_seminar(current["id"], payload.seminar_id)
    if not allowed:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No access to seminar")

    room_name = seminar.get("livekit_room") or f"seminar-{seminar['id']}"
    now = datetime.now(timezone.utc)
    expires = now + timedelta(hours=1)

    claims = {
        "iss": settings.livekit_api_key,
        "sub": settings.livekit_api_key,
        "nbf": int(now.timestamp()),
        "exp": int(expires.timestamp()),
        "name": seminar.get("title") or "Wisdom Seminar",
        "identity": str(current["id"]),
        "grants": {
            "video": {
                "roomJoin": True,
                "room": room_name,
                "canPublish": True,
                "canSubscribe": True,
                "canPublishData": True,
            },
            "metadata": {
                "seminar_id": str(seminar["id"]),
                "user_id": str(current["id"]),
            },
        },
    }

    token = jwt.encode(
        claims,
        settings.livekit_api_secret,
        algorithm="HS256",
    )
    return schemas.LiveKitTokenResponse(ws_url=settings.livekit_ws_url, token=token)
