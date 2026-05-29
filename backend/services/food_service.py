import httpx
from supabase import create_client, Client
from config import get_settings
import structlog

logger = structlog.get_logger()
settings = get_settings()
supabase: Client = create_client(
    settings.SUPABASE_URL, 
    settings.SUPABASE_SERVICE_ROLE_KEY
)


# ─── Bước 1: Tìm trong Local DB ───────────────────────────────────────────────

async def search_local_db(query: str, user_id: str = None) -> list[dict]:
    """
    - APPROVED: tất cả user đều thấy
    - PENDING + created_by = user_id: chỉ user đó thấy
    """
    # Lấy món APPROVED
    approved = supabase.table("foods")\
        .select("*")\
        .ilike("name", f"%{query}%")\
        .eq("status", "APPROVED")\
        .limit(10)\
        .execute()

    results = approved.data or []

    # Lấy món PENDING của chính user
    if user_id:
        pending = supabase.table("foods")\
            .select("*")\
            .ilike("name", f"%{query}%")\
            .eq("status", "PENDING")\
            .eq("created_by", user_id)\
            .limit(5)\
            .execute()
        results += pending.data or []

    return results


# ─── Bước 2: Fallback — Gọi API ngoài (mock) ──────────────────────────────────

async def fetch_from_external_api(query: str) -> list[dict]:
    """
    Mock FatSecret/Nutritionix.
    Parse image_url nếu API trả về — lưu luôn vào DB qua cache-aside.
    """
    # TODO: Thay bằng httpx.AsyncClient() gọi API thật
    # async with httpx.AsyncClient() as client:
    #     resp = await client.get(
    #         "https://api.fatsecret.com/...",
    #         params={"query": query},
    #         headers={"Authorization": f"Bearer {settings.FATSECRET_TOKEN}"}
    #     )
    #     raw = resp.json()["foods"]["food"]
    #     return [
    #         {
    #             "name": item["food_name"],
    #             "calories": float(item["calories"]),
    #             "protein": float(item["protein"]),
    #             "carbs": float(item["carbohydrate"]),
    #             "fat": float(item["fat"]),
    #             "serving_size": 100,
    #             "serving_unit": "g",
    #             "source": "API",
    #             "status": "APPROVED",
    #             "external_id": item["food_id"],
    #             "image_url": item.get("food_images", {}).get("food_image", [{}])[0].get("image_url"),  # parse nếu có
    #         }
    #         for item in raw
    #     ]

    # Mock data
    if "cơm" in query.lower():
        return [{
            "name": f"Cơm trắng (mock)",
            "calories": 130.0,
            "protein": 2.7,
            "carbs": 28.2,
            "fat": 0.3,
            "serving_size": 100,
            "serving_unit": "g",
            "source": "API",
            "status": "APPROVED",
            "external_id": "mock_001",
            "image_url": "https://example.com/images/com_trang.jpg",
        }]
    return []


async def cache_to_db(foods: list[dict]) -> list[dict]:
    """Cache-Aside: insert ngầm vào DB, bỏ qua nếu đã tồn tại (upsert by name)."""
    if not foods:
        return []
    try:
        res = supabase.table("foods")\
            .upsert(foods, on_conflict="name")\
            .execute()
        return res.data or foods
    except Exception as e:
        logger.warning("cache_to_db_failed", error=str(e))
        return foods  # vẫn trả data dù cache fail


# ─── Bước 3: Fallback — Hỏi AI (mock Gemini) ──────────────────────────────────

async def fetch_from_ai(query: str) -> list[dict]:
    """
    Mock Gemini. Trả về ước tính macro, status=PENDING chờ duyệt.
    TODO: Thay bằng call Gemini thật.
    """
    # async with httpx.AsyncClient() as client:
    #     resp = await client.post(
    #         f"https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent",
    #         json={"contents": [{"parts": [{"text": f"Estimate nutrition per 100g for: {query}"}]}]},
    #         params={"key": settings.GEMINI_API_KEY}
    #     )
    #     return _parse_gemini_response(resp.json(), query)

    logger.info("ai_fallback_used", query=query)
    return [{
        "name": query,
        "calories": 150.0,
        "protein": 5.0,
        "carbs": 20.0,
        "fat": 5.0,
        "serving_size": 100,
        "serving_unit": "g",
        "source": "AI",
        "status": "PENDING",  # chờ admin duyệt
    }]


# ─── Waterfall orchestrator ────────────────────────────────────────────────────

async def search_food_waterfall(query: str, user_id: str = None) -> list[dict]:
    """
    Luồng Waterfall 3 bước:
    Local DB → External API (cache-aside) → AI (pending)
    """

    # Bước 1: Local DB
    local = await search_local_db(query, user_id=user_id)
    if local:
        return local

    # Bước 2: External API
    external = await fetch_from_external_api(query)
    if external:
        cached = await cache_to_db(external)
        return cached

    # Bước 3: AI fallback — chỉ gọi khi query đủ dài (>= 3 ký tự)
    # và không cache tự động — trả về để user xác nhận trước
    if len(query.strip()) < 3:
        return []  # quá ngắn, không gọi AI
    
    ai_result = await fetch_from_ai(query)
    # KHÔNG cache ngay — chỉ trả về để user xem
    # User phải nhấn "Xác nhận" mới lưu vào DB
    return ai_result


# ─── User custom food ──────────────────────────────────────────────────────────

async def create_custom_food(data: dict, user_id: str) -> dict:
    """
    Bước 4: User tự thêm món.
    source=USER, status=PENDING, created_by=user_id.
    """
    payload = {
        **data,
        "source": "USER",
        "status": "PENDING",
        "created_by": user_id,
    }
    res = supabase.table("foods").insert(payload).execute()
    return res.data[0]