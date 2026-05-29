import uuid
from fastapi import APIRouter, UploadFile, File, Depends, Query, HTTPException
import supabase
from dependencies import get_current_user_id
from services.gemini_service import analyze_food_image
from services.food_service import search_food_waterfall, create_custom_food, cache_to_db
from schemas.food import FoodResponse, FoodCustomCreate, FoodCustomResponse
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

@router.get("/search", response_model=list[FoodResponse])
async def search_foods(
    query: str = Query(..., min_length=1, max_length=100),
    user_id: str = Depends(get_current_user_id),
):
    """
    Tìm kiếm món ăn theo Waterfall 3 bước:
    1. Local DB (APPROVED)
    2. External API → cache vào DB
    3. AI Gemini → lưu PENDING vào DB
    """
    try:
        results = await search_food_waterfall(query, user_id=user_id)
        return results
    except Exception as e:
        logger.exception("search_foods_failed", query=query, error=str(e))
        raise HTTPException(status_code=500, detail="Tìm kiếm thất bại")


@router.post("/custom", response_model=FoodCustomResponse)
async def add_custom_food(
    body: FoodCustomCreate,
    user_id: str = Depends(get_current_user_id),
):
    """
    Bước 4: User tự thêm món ăn.
    Lưu với source=USER, status=PENDING — chờ admin duyệt.
    """
    try:
        food = await create_custom_food(body.model_dump(), user_id)
        return FoodCustomResponse(
            message="Đã gửi món ăn. Vui lòng chờ kiểm duyệt.",
            food_id=food["id"],
        )
    except Exception as e:
        logger.exception("add_custom_food_failed", error=str(e))
        raise HTTPException(status_code=500, detail="Thêm món thất bại")
    
@router.post("/confirm-ai")
async def confirm_ai_food(
    body: FoodCustomCreate,
    user_id: str = Depends(get_current_user_id),
):
    """
    User xác nhận món ăn từ AI → lưu vào DB với status PENDING.
    Chỉ gọi sau khi user đã xem kết quả AI và đồng ý.
    """
    payload = body.model_dump()
    payload['source'] = 'AI'
    payload['status'] = 'PENDING'
    cached = await cache_to_db([payload])
    return {"message": "Đã lưu, chờ kiểm duyệt.", "food_id": cached[0]["id"]}

@router.post("/upload-image")
async def upload_food_image(
    file: UploadFile = File(...),
    user_id: str = Depends(get_current_user_id),
):
    try:
        contents = await file.read()
        file_name = f"user/{uuid.uuid4()}.jpg"
        
        supabase.storage.from_("food-images").upload(
            file_name,
            contents,
            file_options={"content-type": file.content_type or "image/jpeg"}
        )
        
        url = supabase.storage.from_("food-images").get_public_url(file_name)
        return {"image_url": url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload thất bại: {str(e)}")