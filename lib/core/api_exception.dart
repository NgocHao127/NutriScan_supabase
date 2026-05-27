class ApiException implements Exception {
  final String errorCode;
  final String message;
  final int httpStatus;
  final dynamic payload; // dữ liệu kèm theo (ví dụ: conflict server data)

  const ApiException({
    required this.errorCode,
    required this.message,
    required this.httpStatus,
    this.payload,
  });

  bool get isTokenExpired => errorCode == 'TOKEN_EXPIRED';
  bool get isTokenInvalid => errorCode == 'TOKEN_INVALID';
  bool get isConflict => errorCode == 'CONFLICT';
  bool get isNotFound => errorCode == 'NOT_FOUND';
  bool get isForbidden => errorCode == 'FORBIDDEN';
  bool get requiresLogout =>
      isTokenInvalid; // force logout khi token không hợp lệ

  @override
  String toString() => 'ApiException($errorCode): $message';
}
