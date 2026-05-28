import google.generativeai as genai
from config import get_settings
import structlog
import json
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logger = structlog.get_logger()
settings = get_settings()
genai.configure(api_key=settings.GEMINI_API_KEY)

# Gemini 1.5 Flash rất tốt và đủ nhanh cho cả text và image
model = genai.GenerativeModel('gemini-1.5-flash')

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type(Exception),
    reraise=False
)
async def analyze_food_image(image_bytes: bytes) -> list[dict]:
    try:
        prompt = """
        Phân tích món ăn trong ảnh. Trả về một mảng JSON chứa các đối tượng có cấu trúc chính xác như sau:
        [
          {"name": "Tên món", "calories": 123.0, "protein": 10.0, "carbs": 20.0, "fat": 5.0, "portion": "1 đĩa"}
        ]
        """
        # Ép Gemini trả về định dạng JSON thuần túy
        response = model.generate_content(
            [prompt, {"mime_type": "image/jpeg", "data": image_bytes}],
            generation_config={"response_mime_type": "application/json"}
        )
        
        text = response.text.strip()
        logger.debug("gemini_response", text=text)

        # Parse thẳng luôn, không cần regex
        result = json.loads(text)
        if isinstance(result, list):
            return result
            
        raise ValueError("Kết quả không phải là một list JSON")
    except Exception as e:
        logger.warning("gemini_fallback_used", error=str(e))
        # Fallback: Trả về một món ước lượng an toàn
        return [{"name": "Món ăn chưa xác định", "calories": 350.0, "protein": 15.0, "carbs": 30.0, "fat": 12.0, "portion": "1 phần"}]
