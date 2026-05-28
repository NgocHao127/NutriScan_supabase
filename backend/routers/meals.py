from fastapi import APIRouter, Depends, HTTPException, Query
from dependencies import get_current_user_id
from schemas.meal import MealEntryCreate, MealEntryResponse # Trỏ đúng tên schema mới
from services.meal_service import save_meal, get_daily_record
from exceptions import AppException
import structlog

router = APIRouter()
logger = structlog.get_logger()

@router.post("/log", response_model=MealEntryResponse)
async def log_meal(
    entry: MealEntryCreate, 
    user_id: str = Depends(get_current_user_id)
):
    try:
        # mode='json' tự convert datetime thành string
        result = await save_meal(entry.model_dump(mode='json'), user_id, None)
        return result
    except AppException:
        raise
    except Exception as e:
        logger.exception("log_meal_failed", error=str(e))
        raise HTTPException(status_code=500, detail="Lưu thất bại")

@router.get("/daily")
async def daily_summary(
    date: str = Query(None), 
    user_id: str = Depends(get_current_user_id)
):
    record = await get_daily_record(user_id, date)
    return record
