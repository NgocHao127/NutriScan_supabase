from supabase import create_client, Client
from backend.config import get_settings
import structlog

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

async def get_or_create_user(uid: str, email: str):
    # Tìm user trong bảng 'profiles'
    res = supabase.table("profiles").select("*").eq("uid", uid).execute()
    if res.data:
        return res.data[0]
    # Tạo mới
    new_user = {
        "uid": uid,
        "email": email,
        "daily_calorie_goal": 2000.0
    }
    create_res = supabase.table("profiles").insert(new_user).execute()
    return create_res.data[0]