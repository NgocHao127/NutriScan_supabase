from fastapi import APIRouter, UploadFile, File, Depends
from dependencies import get_current_user_id
from services.gemini_service import analyze_food_image
import structlog

router = APIRouter()
logger = structlog.get_logger()

@router.post("/analyze")
async def analyze_food(
    file: UploadFile = File(...), 
    user_id: str = Depends(get_current_user_id)  # Dùng tên hàm mới
):
    contents = await file.read()
    items = await analyze_food_image(contents)
    return {"items": items}
