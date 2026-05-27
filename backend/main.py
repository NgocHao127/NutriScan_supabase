from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.routers import auth, food, users
from logging_config import setup_logging
from backend.middleware import app_exception_handler, general_exception_handler
from backend.exceptions import AppException
from backend.routers import meals

setup_logging()

app = FastAPI(title="NutriScan API", version="1.0.0")

# CORS – cho phép mọi nguồn gốc (mobile app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(food.router, prefix="/food", tags=["Food"])
app.include_router(meals.router, prefix="/meal", tags=["Meals"])

@app.get("/health")
def health():
    return {"status": "ok"}

# Kiểm tra kết nối Supabase & Firebase
@app.get("/ready")
async def ready():
    from backend.config import get_settings
    from supabase import create_client
    s = get_settings()
    supabase = create_client(s.SUPABASE_URL, s.SUPABASE_SERVICE_ROLE_KEY)
    # Đơn giản kiểm tra query
    supabase.table("meal_entries").select("id", limit=1).execute()
    return {"supabase": "ok"}