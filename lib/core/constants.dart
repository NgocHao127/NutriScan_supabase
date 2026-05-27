class ApiConstants {
  // Thay đổi URL này cho đúng với môi trường chạy backend của bạn
  // Android emulator: 10.0.2.2, iOS simulator: localhost, máy thật: IP máy chạy backend
  static const String baseUrl = '';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
