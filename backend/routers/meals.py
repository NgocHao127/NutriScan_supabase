from fastapi import APIRouter, Depends, HTTPException, Query
from backend.dependencies import get_current_user, CurrentUser
from backend.schemas.meal import MealEntry, MealEntryResponse
from backend.services.meal_service import save_meal, get_daily_record
from backend.exceptions import AppException
import structlog

router = APIRouter()
logger = structlog.get_logger()

@router.post("/log", response_model=MealEntryResponse)
async def log_meal(entry: MealEntry, current_user: CurrentUser = Depends(get_current_user)):
    try:
        result = await save_meal(entry.dict(), current_user.uid, entry.updated_at)
        return result
    except AppException:
        raise
    except Exception as e:
        logger.exception("log_meal_failed")
        raise HTTPException(status_code=500, detail="Lưu thất bại")

@router.get("/daily")
async def daily_summary(date: str = Query(None), current_user: CurrentUser = Depends(get_current_user)):
    record = await get_daily_record(current_user.uid, date)
    return record