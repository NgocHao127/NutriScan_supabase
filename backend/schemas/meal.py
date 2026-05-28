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
    protein: float = 0
    carbs: float = 0
    fat: float = 0
    image_url: Optional[str] = None
    items: List[FoodItem] = []
    meal_type: str = "Ăn vặt"
    meal_time: datetime
    note: Optional[str] = ""

class MealEntryResponse(BaseModel):
    id: str
    user_id: str
    name: str
    calories: float
    protein: float = 0
    carbs: float = 0
    fat: float = 0
    meal_type: str
    meal_time: datetime
    updated_at: datetime
    daily_record_id: Optional[int] = None

class MealItemResponse(BaseModel):
    id: int
    meal_id: str
    food_name: str
    calories: float = 0
    protein: float = 0
    carbs: float = 0
    fat: float = 0
    portion: str = '1 phần'
    quantity: float = 1

    class Config:
        from_attributes = True