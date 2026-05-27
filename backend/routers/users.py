from fastapi import APIRouter, Depends
from backend.dependencies import get_current_user, CurrentUser
from backend.services.user_service import get_or_create_user

router = APIRouter()

@router.get("/me")
async def get_my_profile(current_user: CurrentUser = Depends(get_current_user)):
    return await get_or_create_user(current_user.uid, current_user.email)