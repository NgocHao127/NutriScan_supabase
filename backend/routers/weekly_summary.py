from fastapi import APIRouter, Depends
from dependencies import get_current_user_id
from services.gemini_service import generate_weekly_summary
from supabase import create_client
from config import get_settings
from datetime import datetime, timezone, timedelta

router = APIRouter()
settings = get_settings()
supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

@router.get("/weekly-summary")
async def weekly_summary(user_id: str = Depends(get_current_user_id)):
    now = datetime.now(timezone.utc)
    
    # Tính Thứ 2 đầu tuần (weekday: 0=Thứ 2, 6=Chủ nhật)
    days_since_monday = now.weekday()  # 0 nếu hôm nay là Thứ 2
    monday = now - timedelta(days=days_since_monday)
    sunday = monday + timedelta(days=6)
    
    # Đặt về đầu ngày Thứ 2 và cuối ngày Chủ nhật
    start = monday.replace(hour=0, minute=0, second=0, microsecond=0)
    end   = sunday.replace(hour=23, minute=59, second=59, microsecond=0)

    response = supabase.table("meal_entries")\
        .select("calories, protein, carbs, fat, meal_time")\
        .eq("user_id", user_id)\
        .gte("meal_time", start.isoformat())\
        .lte("meal_time", end.isoformat())\
        .execute()

    entries = response.data or []

    total_calories = sum(e.get("calories", 0) for e in entries)
    total_protein  = sum(e.get("protein", 0) for e in entries)
    total_carbs    = sum(e.get("carbs", 0) for e in entries)
    total_fat      = sum(e.get("fat", 0) for e in entries)
    
    # Số ngày thực sự có ghi nhận trong tuần
    active_days = len(set(e["meal_time"][:10] for e in entries))
    days = max(active_days, 1)

    summary_data = {
        "week_start": start.strftime("%d/%m/%Y"),
        "week_end":   end.strftime("%d/%m/%Y"),
        "avg_calories": round(total_calories / days),
        "avg_protein":  round(total_protein / days, 1),
        "avg_carbs":    round(total_carbs / days, 1),
        "avg_fat":      round(total_fat / days, 1),
        "active_days":  active_days,
        "total_calories": round(total_calories),
    }

    comment = await generate_weekly_summary(summary_data)
    return {
        "summary": summary_data,
        "ai_comment": comment,
        "week_start": start.isoformat(),
        "week_end":   end.isoformat(),
    }