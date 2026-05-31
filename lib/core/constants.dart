class ApiConstants {
  // Android emulator: http://10.0.2.2:8000
  // iOS simulator: http://127.0.0.1:8000 hoặc http://localhost:8000
  // Thiết bị thật: IP LAN của máy tính (ví dụ: http://192.168.1.15:8000)
  static const String baseUrl = 'http://192.168.2.8:8000';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
