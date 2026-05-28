import jwt
import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from config import get_settings
import structlog

logger = structlog.get_logger()
settings = get_settings()
security = HTTPBearer()

# Cache JWKS
_jwks_cache = None

async def _get_jwks():
    global _jwks_cache
    if _jwks_cache is None:
        async with httpx.AsyncClient() as client:
            resp = await client.get(f"{settings.SUPABASE_URL}/auth/v1/.well-known/jwks.json")
            _jwks_cache = resp.json()
    return _jwks_cache

async def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    token = credentials.credentials
    try:
        # Lấy JWKS trước
        jwks = await _get_jwks()
        header = jwt.get_unverified_header(token)
        
        key = next(
            (k for k in jwks.get("keys", []) if k.get("kid") == header.get("kid")),
            None
        )
        if not key:
            raise ValueError("Không tìm thấy public key")

        public_key = jwt.algorithms.ECAlgorithm.from_jwk(key)
        
        payload = jwt.decode(
            token,
            public_key,
            algorithms=["ES256"],
            audience="authenticated",
            leeway=30  # cho phép lệch 30 giây
        )
        
        user_id = payload.get("sub")
        if not user_id:
            raise ValueError("Không tìm thấy user_id")
        return user_id

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Phiên đăng nhập đã hết hạn")
    except Exception as e:
        logger.error("Lỗi xác thực Token", error=str(e))
        raise HTTPException(status_code=401, detail="Token không hợp lệ")