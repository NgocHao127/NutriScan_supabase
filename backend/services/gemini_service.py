import google.generativeai as genai
from backend.config import get_settings
import structlog
import re
import json
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logger = structlog.get_logger()
settings = get_settings()
genai.configure(api_key=settings.GEMINI_API_KEY)

model = genai.GenerativeModel('gemini-1.5-flash')  # nếu dùng cho ảnh có thể cần 'gemini-pro-vision'

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type(Exception),
    reraise=False
)
async def analyze_food_image(image_bytes: bytes) -> list[dict]:
    try:
        prompt = """
        Phân tích món ăn trong ảnh. Trả về JSON list chứa các đối tượng:
        [
          {"name": "Tên món", "calories": 123, "protein": 10.0, "carbs": 20.0, "fat": 5.0, "portion": "1 đĩa"}
        ]
        Chỉ trả về JSON, không giải thích gì thêm.
        """
        response = model.generate_content([prompt, {"mime_type": "image/jpeg", "data": image_bytes}])
        text = response.text.strip()
        logger.debug("gemini_response", text=text)

        # Tìm JSON array
        match = re.search(r'\[.*\]', text, re.DOTALL)
        if match:
            result = json.loads(match.group())
            if isinstance(result, list):
                return result
        raise ValueError("Không tìm thấy JSON hợp lệ")
    except Exception as e:
        logger.warning("gemini_fallback_used", error=str(e))
        # Fallback: trả về một món ước lượng
        return [{"name": "Món ăn", "calories": 350, "protein": 15, "carbs": 30, "fat": 12, "portion": "1 phần"}]