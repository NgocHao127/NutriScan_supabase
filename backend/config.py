from pydantic_settings import BaseSettings
from functools import lru_cache
import json

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_SERVICE_ROLE_KEY: str
    GEMINI_API_KEY: str
    FIREBASE_ADMIN_SDK_JSON: str = "android\\app\\nutriscan-176a2-firebase-adminsdk-fbsvc-06308efa58.json"   # chuỗi JSON của service account key
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings() -> Settings:
    return Settings()