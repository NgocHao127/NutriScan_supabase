from fastapi import APIRouter, Depends, HTTPException
from backend.dependencies import get_current_user, CurrentUser
from backend.services.user_service import get_or_create_user
import structlog

router = APIRouter()
logger = structlog.get_logger()

@router.post("/login")
async def login(current_user: CurrentUser = Depends(get_current_user)):
    # Lấy hoặc tạo profile trong Supabase
    profile = await get_or_create_user(current_user.uid, current_user.email)
    return profile