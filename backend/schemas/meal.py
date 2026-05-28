from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class FoodItem(BaseModel):
    name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    portion: Optional[str] = ""

class MealEntryCreate(BaseModel):
    id: str
    name: str
    calories: float
    image_url: Optional[str] = None
    items: List[FoodItem] = []
    meal_type: str = "Ăn vặt"
    note: Optional[str] = ""
    recorded_at: datetime

class MealEntryResponse(BaseModel):
    id: str
    user_id: str
    name: str
    calories: float
    meal_type: str
    meal_time: datetime
    updated_at: datetime
    daily_record_id: Optional[int] = None

    class Config:
        from_attributes = True