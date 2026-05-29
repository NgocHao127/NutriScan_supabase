from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import foods, users, meals, weekly_summary
from logging_config import setup_logging
from middleware import app_exception_handler, general_exception_handler
from exceptions import AppException

setup_logging()

app = FastAPI(title="NutriScan API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)

app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(foods.router, prefix="/foods", tags=["Foods"])
app.include_router(meals.router, prefix="/meal", tags=["Meals"])
app.include_router(weekly_summary.router, prefix="/api", tags=["Weekly Summary"])

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/ready")
async def ready():
    from config import get_settings
    from supabase import create_client
    s = get_settings()
    supabase = create_client(s.SUPABASE_URL, s.SUPABASE_SERVICE_ROLE_KEY)
    supabase.table("meal_entries").select("id").limit(1).execute()
    return {"supabase": "ok"}
