from fastapi import APIRouter, Depends, Request
from dependencies import get_current_user_id
from services.user_service import get_or_create_user, update_user
from core.nutrition_calculator import calc_bmi, bmi_category, calculate_nutrition

router = APIRouter()

@router.get("/me")
async def get_my_profile(
    request: Request,
    user_id: str = Depends(get_current_user_id)
):
    import jwt as pyjwt
    token = request.headers.get("Authorization", "").replace("Bearer ", "")
    email = None
    name = None
    try:
        payload = pyjwt.decode(token, options={"verify_signature": False})
        print(f"=== JWT PAYLOAD: {payload} ===")
        email = payload.get("email")
        name = payload.get("user_metadata", {}).get("name")
        print(f"=== email={email}, name={name} ===")
    except Exception as e:
        print(f"=== JWT ERROR: {e} ===")
    
    result = await get_or_create_user(user_id, email=email, name=name)

    # Tính BMI nếu có đủ thông số
    weight = result.get('weight')
    height = result.get('height')
    if weight and height:
        bmi = calc_bmi(float(weight), float(height))
        result['bmi'] = bmi
        result['bmi_category'] = bmi_category(bmi)

    return result

@router.put("/me")
async def update_my_profile(
    data: dict,
    user_id: str = Depends(get_current_user_id)
):
    weight = data.get('weight')
    gender = data.get('gender')
    activity_level = data.get('activity_level')
    goal = data.get('goal')
    body_shape = data.get('body_shape', 'Bình thường')

    if all([weight, gender, activity_level, goal]):
        result = calculate_nutrition(
            weight=float(weight),
            gender=gender,
            activity_level=activity_level,
            goal=goal,
            body_shape=body_shape,
        )
        data['calorie_goal'] = result.calorie_goal
        data['protein_goal'] = result.protein_goal
        data['carbs_goal'] = result.carbs_goal
        data['fat_goal'] = result.fat_goal
        print(f"=== NUTRITION: tdee={result.tdee} cal={result.calorie_goal} ===")

    return await update_user(user_id, data)
