from supabase import create_client, Client
from config import get_settings
from datetime import datetime, timezone
import structlog
from exceptions import AppException, ErrorCode

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

async def save_meal(entry: dict, user_id: str, client_updated_at: str | None):
    items = entry.get("items", [])
    
    # Lấy ngày từ meal_time
    meal_time = entry.get("meal_time", "")
    date_str = meal_time[:10] if meal_time else datetime.now(timezone.utc).strftime("%Y-%m-%d")
    start_of_day = f"{date_str}T00:00:00+00:00"
    end_of_day = f"{date_str}T23:59:59+00:00"
    meal_type = entry.get("meal_type", "Ăn vặt")

    # Kiểm tra đã có meal_entry cùng ngày + cùng meal_type chưa
    existing = supabase.table("meal_entries")\
        .select("id, calories, protein, carbs, fat")\
        .eq("user_id", user_id)\
        .eq("meal_type", meal_type)\
        .gte("meal_time", start_of_day)\
        .lte("meal_time", end_of_day)\
        .execute()
    
    meal_id = None # khai báo trước

    if existing.data:
        # Cập nhật tổng vào meal_entry cũ
        meal_id = existing.data[0]["id"]
        old = existing.data[0]
        updated = {
            "calories": old["calories"] + entry.get("calories", 0),
            "protein": old["protein"] + entry.get("protein", 0),
            "carbs": old["carbs"] + entry.get("carbs", 0),
            "fat": old["fat"] + entry.get("fat", 0),
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }
        supabase.table("meal_entries").update(updated).eq("id", meal_id).execute()
        
        # Fetch lại full record để có meal_time và các field khác
        result_data = supabase.table("meal_entries")\
            .select("*")\
            .eq("id", meal_id)\
            .single()\
            .execute().data
    else:  # ← bị thiếu else này
        allowed_fields = {'id', 'user_id', 'name', 'meal_type', 'meal_time', 'calories', 'protein', 'carbs', 'fat', 'updated_at'}
        new_entry = {k: v for k, v in entry.items() if k in allowed_fields}
        new_entry["user_id"] = user_id
        new_entry["updated_at"] = datetime.now(timezone.utc).isoformat()
        result = supabase.table("meal_entries").insert(new_entry).execute()
        meal_id = result.data[0]["id"]
        result_data = result.data[0]

    print(f"=== meal_id before insert: {meal_id} ===")
    print(f"=== existing.data: {existing.data} ===")
    # Insert meal_items mới
    if items:
        meal_items = [
            {
                "meal_id": meal_id,
                "food_name": item.get("name", ""),
                "calories": item.get("calories", 0),
                "protein": item.get("protein", 0),
                "carbs": item.get("carbs", 0),
                "fat": item.get("fat", 0),
                "portion": item.get("portion", "1 phần"),
                "meal_time": entry.get("meal_time"),
            }
            for item in items
        ]
        supabase.table("meal_items").insert(meal_items).execute()

    return result_data

async def get_daily_record(user_id: str, date_str: str = None):
    if not date_str:
        date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        
    start_date = f"{date_str}T00:00:00+00:00"
    end_date = f"{date_str}T23:59:59+00:00"

    # Lấy calorie_goal từ profiles
    profile = supabase.table("profiles")\
        .select("calorie_goal, protein_goal, carbs_goal, fat_goal")\
        .eq("uid", user_id)\
        .single()\
        .execute()

    calorie_goal = profile.data.get("calorie_goal", 2000) if profile.data else 2000
    protein_goal = profile.data.get("protein_goal", 0) if profile.data else 0
    carbs_goal = profile.data.get("carbs_goal", 0) if profile.data else 0
    fat_goal = profile.data.get("fat_goal", 0) if profile.data else 0
    
    # Join meal_items vào meal_entries
    response = supabase.table("meal_entries").select("*, meal_items(*)")\
        .eq("user_id", user_id)\
        .gte("meal_time", start_date)\
        .lte("meal_time", end_date)\
        .execute()
        
    entries = response.data
    
    total_calories = sum(entry.get("calories", 0.0) for entry in entries)
    total_protein = sum(entry.get("protein", 0.0) for entry in entries)
    total_carbs = sum(entry.get("carbs", 0.0) for entry in entries)
    total_fat = sum(entry.get("fat", 0.0) for entry in entries)
    
    return {
        "date": date_str,
        "total_calories": total_calories,
        "total_protein": total_protein,
        "total_carbs": total_carbs,
        "total_fat": total_fat,
        "calories_goal": calorie_goal,
        "protein_goal": protein_goal,
        "carbs_goal": carbs_goal,
        "fat_goal": fat_goal,  
        "meals": entries
    }