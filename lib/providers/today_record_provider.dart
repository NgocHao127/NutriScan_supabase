import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_record_model.dart';
import 'api_provider.dart';
import 'dart:async';

// Dùng autoDispose để tự động làm mới dữ liệu khi người dùng thoát/vào lại màn hình
final todayRecordProvider =
    FutureProvider.autoDispose<DailyRecordModel?>((ref) async {
  final mealService = ref.watch(mealServiceProvider);
  try {
    final data = await mealService.getDailyRecord();
    print('=== DAILY RECORD DATA: $data ===');
    if (data.isEmpty) return null;
    return DailyRecordModel.fromJson(data);
  } catch (e) {
    print('=== TODAY ERROR: $e ===');
    // Trả về null thay vì throw — hiện EmptyMealState thay vì error
    return null;
  }
});
