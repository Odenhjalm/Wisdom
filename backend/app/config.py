from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AnyUrl


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: AnyUrl = "postgresql://oden:1124vattnaRn@localhost:5432/wisdom"
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    jwt_expires_minutes: int = 15
    jwt_refresh_expires_minutes: int = 60 * 24
    media_root: str = "media"
    stripe_checkout_base: str | None = None
    stripe_secret_key: str | None = None
    stripe_webhook_secret: str | None = None


settings = Settings()
