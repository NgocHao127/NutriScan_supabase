from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from typing import Optional
from config import get_settings
from supabase import create_client, Client

router = APIRouter()

settings = get_settings()
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

# -------------------------------------------------------------
# MOCK DEPENDENCY: Tạm thời lấy trực tiếp user_id từ HTTP Header
# -------------------------------------------------------------
async def get_current_user_id(x_user_id: str = Header(..., description="Tạm thời truyền UUID Supabase vào header này")):
    if not x_user_id:
        raise HTTPException(status_code=401, detail="Thiếu X-User-Id trong Header")
    return x_user_id

# -------------------------------------------------------------

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
    profile: UserProfileUpdate, 
    user_id: str = Depends(get_current_user_id)  # Sử dụng Mock Dependency
):
    update_data = profile.model_dump(exclude_unset=True)
    if not update_data:
        return {"message": "Không có dữ liệu để cập nhật"}
    
    # Query thẳng vào bảng profiles bằng trường id của Supabase
    result = supabase.table("profiles").update(update_data).eq("id", user_id).execute()
    
    if result.data:
        return result.data[0]
    raise HTTPException(status_code=404, detail="Không tìm thấy User")
