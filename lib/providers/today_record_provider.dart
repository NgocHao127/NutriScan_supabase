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
    if (data.isEmpty) return null;
    final record = DailyRecordModel.fromJson(data);
    print('=== DAILY RECORD ===');
    print('  calories: ${record.caloriesConsumed}');
    print('  protein: ${record.protein}');
    print('  carbs: ${record.carbs}');
    print('  fat: ${record.fat}');
    print('  meals count: ${record.meals.length}');
    for (final meal in record.meals) {
      print('  --- meal: ${meal.name} (${meal.mealType})');
      print(
          '      calories: ${meal.calories} protein: ${meal.protein} carbs: ${meal.carbs} fat: ${meal.fat}');
      print('      items count: ${meal.items.length}');
      for (final item in meal.items) {
        print(
            '      --- item: ${item.foodName} cal=${item.calories} p=${item.protein} c=${item.carbs} f=${item.fat}');
      }
    }
    return record;
  } catch (e) {
    print('=== TODAY ERROR: $e ===');
    // Trả về null thay vì throw — hiện EmptyMealState thay vì error
    return null;
  }
});
