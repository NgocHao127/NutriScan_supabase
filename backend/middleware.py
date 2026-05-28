from fastapi import Request
from fastapi.responses import JSONResponse
from exceptions import AppException
import structlog

logger = structlog.get_logger()

async def app_exception_handler(request: Request, exc: AppException):
    logger.warning("app_exception", error_code=exc.error_code, message=exc.message)
    return JSONResponse(
        status_code=409 if exc.error_code == "CONFLICT" else 400,
        content={"error_code": exc.error_code, "message": exc.message, "payload": exc.payload},
    )

async def general_exception_handler(request: Request, exc: Exception):
    logger.exception("unhandled_exception")
    return JSONResponse(
        status_code=500,
        content={"error_code": "INTERNAL_ERROR", "message": "Lỗi hệ thống"},
    )
