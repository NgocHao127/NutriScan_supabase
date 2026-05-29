import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_record_model.dart';
import 'api_provider.dart';

// Dùng autoDispose để tự động làm mới dữ liệu khi người dùng thoát/vào lại màn hình
final todayRecordProvider =
    FutureProvider.autoDispose<DailyRecordModel?>((ref) async {
  final mealService = ref.watch(mealServiceProvider);
  try {
    final data = await mealService.getDailyRecord();
    if (data.isEmpty) return null;
    final record = DailyRecordModel.fromJson(data);
    print('=== DAILY RECORD ===');
    print('  calories: ${record.caloriesConsumed}');
    print('  protein: ${record.protein}');
    print('  carbs: ${record.carbs}');
    print('  fat: ${record.fat}');
    print('  meals count: ${record.meals.length}');
    for (final meal in record.meals) {
      for (final item in meal.items) {
      }
    }
    return record;
  } catch (e) {
    print('=== TODAY ERROR: $e ===');
    // Trả về null thay vì throw — hiện EmptyMealState thay vì error
    return null;
  }
});
