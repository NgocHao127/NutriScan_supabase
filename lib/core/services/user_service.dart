import '../api_service.dart';

/// Xử lý các API liên quan đến thông tin người dùng.
class UserService {
  final ApiService _api;
  UserService(this._api);

  /// GET /users/me – lấy thông tin profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get('/users/me');
      return _api.mapFromResponse(response.data) ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /users/me – cập nhật thông tin cá nhân
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put('/users/me', data: data);
    return _api.mapFromResponse(response.data) ?? {};
  }
}
