from pydantic import BaseModel, Field, HttpUrl
from typing import Optional
from datetime import datetime

class FoodBase(BaseModel):
    name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    serving_size: float = 100
    serving_unit: str = 'g'
    image_url: Optional[str] = None


class FoodResponse(FoodBase):
    id: Optional[int] = None
    id: int
    source: Optional[str] = None
    status: Optional[str] = None
    external_id: Optional[str] = None
    image_url: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


class FoodCustomCreate(FoodBase):
    """
    Payload user tự thêm món.
    Client tự upload ảnh lên Supabase Storage, chỉ gửi URL về đây.
    """
    serving_size: float = Field(default=100, gt=0)
    serving_unit: str = Field(default='g', max_length=20)
    image_url: Optional[HttpUrl] = None


class FoodCustomResponse(BaseModel):
    message: str
    food_id: int