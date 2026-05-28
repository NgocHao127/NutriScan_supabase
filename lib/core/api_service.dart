import 'dart:async';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'api_exception.dart';
import 'constants.dart';
import '../global.dart';

/// HTTP engine: Dio setup, token inject, token refresh, force logout.
/// Dùng Supabase Auth thay vì Firebase Auth.
class ApiService {
  late final Dio _dio;
  final SupabaseClient _supabase;

  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;

  void Function()? onForceLogout;

  ApiService({required String baseUrl, SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client {
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

  // ─── Interceptors ──────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    print('=== API ERROR: ${response?.statusCode} ${response?.data} ===');
    if (response == null) {
      handler.next(error);
      return;
    }

    final responseData = response.data;
    final Map<String, dynamic>? body = (responseData is Map)
        ? responseData.map((k, v) => MapEntry(k.toString(), v))
        : null;

    final errorCode = body?['error_code'] as String?;

    // TOKEN_EXPIRED → refresh Supabase session
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
    await _supabase.auth.signOut();
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('/login');
    }
  }

  /// Refresh Supabase session, chống race condition.
  Future<Response?> _handleTokenExpired(DioException error) async {
    if (_isRefreshing) {
      final newToken = await _refreshCompleter!.future;
      if (newToken.isEmpty) return null;
      return _retryRequest(error.requestOptions, newToken);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String>();

    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _refreshCompleter!.complete('');
        return null;
      }
      final refreshed = await _supabase.auth.refreshSession();
      if (refreshed.session == null) {
        _refreshCompleter!.complete('');
        return null;
      }
      final newToken = refreshed.session!.accessToken;
      _refreshCompleter!.complete(newToken);
      return _retryRequest(error.requestOptions, newToken);
    } catch (_) {
      _refreshCompleter!.complete('');
      return null;
    } finally {
      _isRefreshing = false;
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

  // ─── Các method HTTP cơ bản ────────────────────────
  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  // ─── Helper ép kiểu ──────────────
  Map<String, dynamic>? mapFromResponse(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
