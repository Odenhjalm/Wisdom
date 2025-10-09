from datetime import datetime, timedelta, timezone
import hashlib
import uuid
from typing import Annotated, Any

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from passlib.context import CryptContext

from .config import settings
from .db import get_conn

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
oauth2_optional_scheme = OAuth2PasswordBearer(
    tokenUrl="/auth/login", auto_error=False
)


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)


def create_access_token(
    sub: str,
    expires_minutes: int | None = None,
    *,
    claims: dict[str, Any] | None = None,
) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=expires_minutes or settings.jwt_expires_minutes
    )
    to_encode: dict[str, Any] = {"sub": sub, "exp": expire, "token_type": "access"}
    if claims:
        to_encode.update(claims)
    return jwt.encode(to_encode, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def create_refresh_token(
    sub: str, expires_minutes: int | None = None
) -> tuple[str, str, datetime]:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=expires_minutes or settings.jwt_refresh_expires_minutes
    )
    jti = str(uuid.uuid4())
    to_encode: dict[str, Any] = {
        "sub": sub,
        "exp": expire,
        "token_type": "refresh",
        "jti": jti,
    }
    token = jwt.encode(to_encode, settings.jwt_secret, algorithm=settings.jwt_algorithm)
    return token, jti, expire


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id: str | None = payload.get("sub")
        token_type = payload.get("token_type", "access")
        if user_id is None:
            raise credentials_exception
        if token_type != "access":
            raise credentials_exception
    except JWTError as exc:
        raise credentials_exception from exc

    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT u.id,
                   u.email,
                   COALESCE(p.role_v2, 'user') AS role_v2,
                   COALESCE(p.is_admin, false) AS is_admin,
                   p.display_name,
                   p.bio,
                   p.photo_url
            FROM auth.users AS u
            LEFT JOIN app.profiles AS p ON p.user_id = u.id
            WHERE u.id = %s
            LIMIT 1
            """,
            (user_id,),
        )
        row = await cur.fetchone()
    if not row:
        raise credentials_exception
    data = dict(row)
    data.setdefault("role_v2", "user")
    data["is_admin"] = bool(data.get("is_admin"))
    return data


async def get_optional_user(token: Annotated[str | None, Depends(oauth2_optional_scheme)]):
    if not token:
        return None
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id: str | None = payload.get("sub")
        token_type = payload.get("token_type", "access")
        if user_id is None:
            return None
        if token_type != "access":
            return None
    except JWTError:
        return None

    async with get_conn() as cur:
        await cur.execute(
            """
            SELECT u.id,
                   u.email,
                   COALESCE(p.role_v2, 'user') AS role_v2,
                   COALESCE(p.is_admin, false) AS is_admin,
                   p.display_name,
                   p.bio,
                   p.photo_url
            FROM auth.users AS u
            LEFT JOIN app.profiles AS p ON p.user_id = u.id
            WHERE u.id = %s
            LIMIT 1
            """,
            (user_id,),
        )
        row = await cur.fetchone()
    if not row:
        return None
    data = dict(row)
    data.setdefault("role_v2", "user")
    data["is_admin"] = bool(data.get("is_admin"))
    return data


CurrentUser = Annotated[dict, Depends(get_current_user)]
OptionalCurrentUser = Annotated[dict | None, Depends(get_optional_user)]
