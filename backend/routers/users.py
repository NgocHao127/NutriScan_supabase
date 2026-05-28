from fastapi import APIRouter, Depends, Request
from dependencies import get_current_user_id
from services.user_service import get_or_create_user, update_user

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
    return result

@router.put("/me")
async def update_my_profile(
    data: dict,
    user_id: str = Depends(get_current_user_id)
):
    return await update_user(user_id, data)