from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.dependencies import get_current_user, CurrentUser
from backend.config import get_settings
from supabase import create_client, Client

router = APIRouter()

# Khởi tạo Supabase client (nếu chưa có ở file này)
settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

# Định nghĩa model cho dữ liệu cập nhật
class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    goal: Optional[str] = None
    activity_level: Optional[str] = None
    calorie_goal: Optional[float] = None

@router.put("/me")
async def update_profile(
    profile: UserProfileUpdate,  # ✅ sửa đúng tên model
    current_user: CurrentUser = Depends(get_current_user)
):
    # Lọc các trường không null
    update_data = profile.dict(exclude_unset=True)
    if not update_data:
        return {"message": "No data to update"}
    
    # Cập nhật trong bảng profiles
    result = supabase.table("profiles").update(update_data).eq("uid", current_user.uid).execute()
    
    if result.data:
        return result.data[0]
    raise HTTPException(status_code=404, detail="User not found")