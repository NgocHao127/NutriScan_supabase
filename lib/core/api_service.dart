import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'api_exception.dart';
import 'constants.dart';
import '../global.dart';

class ApiService {
  late final Dio _dio;
  final FirebaseAuth _auth;

  bool _isRefeshing = false;
  Completer<String>? _refreshCompleter;

  // Callback force logout – sẽ được gán từ bên ngoài (provider)
  void Function()? onForceLogout;

  ApiService({required String baseUrl, FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  // Gắn Firebase token vào header
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // Xử lý lỗi từ server
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    if (response == null) {
      handler.next(error);
      return;
    }

    // Ép kiểu an toàn từ dynamic
    final responseData = response.data;
    final Map<String, dynamic>? body = (responseData is Map)
        ? responseData.map((k, v) => MapEntry(k.toString(), v))
        : null;

    final errorCode = body?['error_code'] as String?;

    // TOKEN_EXPIRED → refresh token
    if (response.statusCode == 401 && errorCode == 'TOKEN_EXPIRED') {
      final retried = await _handleTokenExpired(error);
      if (retried != null) {
        handler.resolve(retried);
      } else {
        await _forceLogout();
        handler.reject(error);
      }
      return;
    }

    // TOKEN_INVALID → force logout
    if (response.statusCode == 401 && errorCode == 'TOKEN_INVALID') {
      await _forceLogout();
      handler.reject(error);
      return;
    }

    // Các lỗi khác → bọc thành ApiException
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        error: ApiException(
          errorCode: errorCode ?? 'UNKNOWN',
          message: body?['message']?.toString() ?? 'Lỗi không xác định',
          httpStatus: response.statusCode ?? 0,
          payload: body?['payload'],
        ),
        response: response,
        type: DioExceptionType.badResponse,
      ),
    );
  }

  Future<void> _forceLogout() async {
    await _auth.signOut();
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('/login');
    }
  }

  // Refresh token với Completer chống race condition
  Future<Response?> _handleTokenExpired(DioException error) async {
    if (_isRefeshing) {
      // Nếu đã có request đang refresh → chờ kết quả
      final newToken = await _refreshCompleter!.future;
      if (newToken.isEmpty) return null;
      return _retryRequest(error.requestOptions, newToken);
    }

    _isRefeshing = true;
    _refreshCompleter = Completer<String>();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _refreshCompleter!.complete('');
        return null;
      }
      final newToken = await user.getIdToken(true); // force refresh
      if (newToken == null) {
        _refreshCompleter!.complete('');
        return null;
      }

      _refreshCompleter!.complete(newToken);
      return _retryRequest(error.requestOptions, newToken);
    } catch (_) {
      _refreshCompleter!.complete('');
      return null;
    } finally {
      _isRefeshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Response> _retryRequest(RequestOptions options, String newToken) {
    final newHeaders = Map<String, dynamic>.from(options.headers);
    newHeaders['Authorization'] = 'Bearer $newToken';
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(method: options.method, headers: newHeaders),
    );
  }

  // ─── Các method API cụ thể ─────────────────────────

  // POST /auth/login – gửi Firebase ID token lên backend để tạo/sync user
  Future<void> login(String idToken) async {
    await post('/auth/login', data: {'idToken': idToken});
  }

  // GET /users/me – lấy thông tin profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/users/me');
    return _mapFromResponse(response.data) ?? {};
  }

  // POST /food/analyze – phân tích ảnh món ăn
  Future<List<dynamic>> analyzeFood(String imagePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'food.jpg'),
    });
    final response = await post('/food/analyze', data: formData);
    final body = _mapFromResponse(response.data);
    final items = body?['items'];
    return (items is List) ? items : [];
  }

  // POST /meal/log – lưu bữa ăn mới
  Future<Map<String, dynamic>> logMeal(
    Map<String, dynamic> mealData,
    String? updatedAt,
  ) async {
    mealData['updated_at'] = updatedAt;
    final response = await post('/meal/log', data: mealData);
    return _mapFromResponse(response.data) ?? {};
  }

  // GET /meal/daily – lấy tổng hợp dinh dưỡng ngày
  Future<Map<String, dynamic>> getDailyRecord({String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    final response = await get('/meal/daily', params: params);
    return _mapFromResponse(response.data) ?? {};
  }

  // PUT /user/me - cập nhật thông tin cá nhân
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await put('/users/me', data: data);
    return _mapFromResponse(response.data) ?? {};
  }

  // ─── Các method HTTP cơ bản ────────────────────────
  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  // ─── Helper ép kiểu chung ──────────────
  Map<String, dynamic>? _mapFromResponse(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
