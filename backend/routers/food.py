from fastapi import APIRouter, UploadFile, File, Depends
from backend.dependencies import get_current_user, CurrentUser
from backend.services.gemini_service import analyze_food_image
import structlog

router = APIRouter()
logger = structlog.get_logger()

@router.post("/analyze")
async def analyze_food(file: UploadFile = File(...), current_user: CurrentUser = Depends(get_current_user)):
    contents = await file.read()
    items = await analyze_food_image(contents)
    return {"items": items}