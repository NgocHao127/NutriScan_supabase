from enum import Enum

class ErrorCode(str, Enum):
    TOKEN_EXPIRED = "TOKEN_EXPIRED"
    TOKEN_INVALID = "TOKEN_INVALID"
    CONFLICT = "CONFLICT"
    NOT_FOUND = "NOT_FOUND"
    INTERNAL_ERROR = "INTERNAL_ERROR"

class AppException(Exception):
    def __init__(self, error_code: ErrorCode, message: str, payload: dict = None):
        self.error_code = error_code
        self.message = message
        self.payload = payload