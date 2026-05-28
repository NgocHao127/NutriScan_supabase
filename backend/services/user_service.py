from supabase import create_client, Client
from config import get_settings
import structlog

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

async def get_or_create_user(user_id: str, email: str = None, name: str = None):
    res = supabase.table("profiles").select("*").eq("uid", user_id).execute()
    if res.data:
        return res.data[0]

    new_user = {"uid": user_id, "email": email, "name": name}
    create_res = supabase.table("profiles").insert(new_user).execute()
    return create_res.data[0]

async def update_user(user_id: str, data: dict):
    print(f"=== UPDATE USER: uid={user_id}, data={data} ===")
    res = supabase.table("profiles").update(data).eq("uid", user_id).execute()
    print(f"=== UPDATE RESULT: {res.data} ===")
    return res.data[0]