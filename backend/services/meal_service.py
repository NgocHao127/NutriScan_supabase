from supabase import create_client, Client
from config import get_settings
from datetime import datetime, timezone
import structlog
from exceptions import AppException, ErrorCode

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

async def save_meal(entry: dict, user_id: str, client_updated_at: str | None):
    # Chỉ giữ các field có trong bảng
    allowed_fields = {'id', 'user_id', 'name', 'meal_type', 'meal_time', 'calories', 'updated_at'}
    entry = {k: v for k, v in entry.items() if k in allowed_fields}

    if 'recorded_at' in entry:
        entry['meal_time'] = entry.pop('recorded_at')

    entry["user_id"] = user_id
    entry["updated_at"] = datetime.now(timezone.utc).isoformat()

    result = supabase.table("meal_entries").upsert(entry).execute()
    return result.data[0]

async def get_daily_record(user_id: str, date_str: str = None):
    """
    Lấy tổng hợp dinh dưỡng trong ngày cho user.
    """
    if not date_str:
        date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        
    # Tạo khoảng thời gian trong ngày để query chính xác trên Supabase
    start_date = f"{date_str}T00:00:00+00:00"
    end_date = f"{date_str}T23:59:59+00:00"
    
    response = supabase.table("meal_entries").select("*")\
        .eq("user_id", user_id)\
        .gte("meal_time", start_date)\
        .lte("meal_time", end_date)\
        .execute()
        
    entries = response.data
    
    # Tính tổng lượng calo trực tiếp từ entry
    total_calories = sum(entry.get("calories", 0.0) for entry in entries)
    
    # Tính macros bằng cách duyệt qua items bên trong mỗi entry
    total_protein = sum(sum(item.get("protein", 0.0) for item in entry.get("items", [])) for entry in entries)
    total_carbs = sum(sum(item.get("carbs", 0.0) for item in entry.get("items", [])) for entry in entries)
    total_fat = sum(sum(item.get("fat", 0.0) for item in entry.get("items", [])) for entry in entries)
    
    return {
        "date": date_str,
        "total_calories": total_calories,
        "total_protein": total_protein,
        "total_carbs": total_carbs,
        "total_fat": total_fat,
        "meals": entries
    }
