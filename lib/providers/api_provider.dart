import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/user_service.dart';
import '../core/services/meal_service.dart';
import '../core/services/food_service.dart';

String _resolveBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://192.168.2.8:8000'; // IP LAN thật
  if (Platform.isWindows) return 'http://localhost:8000';
  return 'http://localhost:8000';
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: _resolveBaseUrl());
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(apiServiceProvider));
});

final mealServiceProvider = Provider<MealService>((ref) {
  return MealService(ref.watch(apiServiceProvider));
});

final foodServiceProvider = Provider<FoodService>((ref) {
  return FoodService(ref.watch(apiServiceProvider));
});
