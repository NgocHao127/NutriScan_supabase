from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class FoodItem(BaseModel):
    name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    portion: str = ""

class MealEntry(BaseModel):
    id: str  # UUID client tạo
    image_url: Optional[str] = None
    items: List[FoodItem] = []
    meal_type: str = "snack"
    note: Optional[str] = ""
    recorded_at: datetime
    updated_at: Optional[str] = None  # phiên bản client biết

class MealEntryResponse(BaseModel):
    id: str
    user_id: str
    image_url: Optional[str]
    items: List[FoodItem]
    meal_type: str
    note: Optional[str]
    recorded_at: str
    updated_at: str  # server timestamp