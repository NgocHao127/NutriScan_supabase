from supabase import create_client, Client
from backend.config import get_settings
from datetime import datetime, timezone
import structlog
from backend.exceptions import AppException, ErrorCode

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

async def save_meal(entry: dict, user_id: str, client_updated_at: str | None):
    """
    Lưu meal entry vào Supabase. Xử lý conflict nếu bản ghi đã tồn tại.
    """
    # Kiểm tra tồn tại
    existing = supabase.table("meal_entries").select("id, updated_at").eq("id", entry["id"]).execute()
    if existing.data and len(existing.data) > 0:
        server_updated_str = existing.data[0]["updated_at"]
        # Chuyển server_updated_str sang datetime
        server_dt = datetime.fromisoformat(server_updated_str.replace('Z', '+00:00'))
        client_dt = None
        if client_updated_at:  # Đã sửa: dùng client_updated_at thay vì server_updated_at
            try:
                client_dt = datetime.fromisoformat(client_updated_at.replace('Z', '+00:00'))
            except ValueError:
                # Nếu client gửi sai format, coi như không có version
                pass
        if client_dt and server_dt > client_dt:
            # Conflict: server mới hơn
            server_data = supabase.table("meal_entries").select("*").eq("id", entry["id"]).single().execute().data
            raise AppException(ErrorCode.CONFLICT, "Dữ liệu trên máy chủ mới hơn", payload=server_data)
    
    # Gán user_id (lấy từ token, không tin client)
    entry["user_id"] = user_id
    entry["updated_at"] = datetime.now(timezone.utc).isoformat()
    
    result = supabase.table("meal_entries").upsert(entry).execute()
    return result.data[0]

async def get_daily_record(user_id: str, date: str = None):
    """
    Lấy tổng hợp dinh dưỡng trong ngày cho user.
    """
    if not date:
        date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    # Lấy tất cả meal_entries của ngày hôm đó (recorded_at like 'date%')
    response = supabase.table("meal_entries").select("*").eq("user_id", user_id).like("recorded_at", f"{date}%").execute()
    entries = response.data
    total_calories = sum(sum(item["calories"] for item in entry["items"]) for entry in entries)
    total_protein = sum(sum(item["protein"] for item in entry["items"]) for entry in entries)
    total_carbs = sum(sum(item["carbs"] for item in entry["items"]) for entry in entries)
    total_fat = sum(sum(item["fat"] for item in entry["items"]) for entry in entries)
    return {
        "date": date,
        "total_calories": total_calories,
        "total_protein": total_protein,
        "total_carbs": total_carbs,
        "total_fat": total_fat,
        "meals": entries
    }