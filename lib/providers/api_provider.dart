import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  // Xác định baseUrl theo platform
  String baseUrl;
  if (kIsWeb) {
    baseUrl = 'http://localhost:8000'; // hoặc domain thật
  } else if (Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8000';
  } else if (Platform.isIOS) {
    baseUrl = 'http://localhost:8000';
  } else {
    // Windows, macOS, Linux
    baseUrl = 'http://localhost:8000';
  }

  final api = ApiService(baseUrl: baseUrl);

  return api;
});
