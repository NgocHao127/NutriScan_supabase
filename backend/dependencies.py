from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth, credentials, initialize_app
import os
import structlog

logger = structlog.get_logger()
security = HTTPBearer()

# Khởi tạo Firebase Admin SDK một lần duy nhất khi server chạy
try:
    # Lấy đường dẫn đến file key từ biến môi trường bạn đã cấu hình
    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        default_app = initialize_app(cred)
        logger.info(f"Firebase Admin SDK initialized with credentials from: {cred_path}")
    else:
        # Fallback cho môi trường như Google Cloud, nơi có sẵn credentials mặc định
        default_app = initialize_app()
        logger.info("Firebase Admin SDK initialized with default application credentials")
except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
    # Có thể raise exception hoặc chỉ log, tùy vào yêu cầu của bạn

# Lớp CurrentUser bạn đã có
class CurrentUser:
    def __init__(self, uid: str, email: str | None = None):
        self.uid = uid
        self.email = email

# Hàm xác thực người dùng, được dùng cho các endpoint cần bảo vệ
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> CurrentUser:
    token = credentials.credentials
    try:
        # Giải mã và xác minh token nhận được từ header Authorization
        decoded_token = auth.verify_id_token(token)
        return CurrentUser(
            uid=decoded_token["uid"],
            email=decoded_token.get("email")
        )
    except auth.ExpiredIdTokenError:
        logger.warning("Token expired", uid=decoded_token.get("uid"))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token hết hạn",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except auth.RevokedIdTokenError:
        logger.warning("Token revoked", uid=decoded_token.get("uid"))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token đã bị thu hồi",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        logger.exception("Token verification failed", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token không hợp lệ",
            headers={"WWW-Authenticate": "Bearer"},
        )