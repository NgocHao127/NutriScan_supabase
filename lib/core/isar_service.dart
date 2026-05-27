import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meal_entry_model.dart';
import '../models/daily_record_model.dart';

class IsarService {
  late Isar isar;

  static Future<IsarService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([MealEntryModelSchema], directory: dir.path);
    return IsarService._internal(isar);
  }

  IsarService._internal(this.isar);

  // Lưu một bữa ăn (upsert)
  Future<void> saveMeal(MealEntryModel meal) async {
    await isar.writeTxn(() => isar.mealEntryModels.put(meal));
  }

  // Lấy tất cả bữa ăn của một ngày
  Future<List<MealEntryModel>> getMealsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return isar.mealEntryModels.filter().mealTimeBetween(start, end).findAll();
  }

  // Lấy tất cả bữa ăn đang chờ đồng bộ
  Future<List<MealEntryModel>> getPendingMeals() async {
    return isar.mealEntryModels.filter().pendingSyncEqualTo(true).findAll();
  }

  // Xoá tất cả bữa ăn của một ngày (khi cập nhật từ server)
  Future<void> deleteMealsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final meals = await isar.mealEntryModels
        .filter()
        .mealTimeBetween(start, end)
        .findAll();
    await isar.writeTxn(() async {
      // Dùng isarid để xóa
      final ids = meals.map((e) => e.isarId).toList();
      isar.mealEntryModels.deleteAll(ids);
    });
  }

  Future<DailyRecordModel?> getDailyRecordByDate(DateTime date) async {
    final meals = await getMealsByDate(date);
    if (meals.isEmpty) return null;
    final totalCalories = meals.fold(0.0, (sum, m) => sum + m.calories);
    final totalProtein = meals.fold(
      0.0,
      (sum, m) => sum + m.items.fold(0.0, (s, i) => s + i.protein),
    );
    final totalCarbs = meals.fold(
      0.0,
      (sum, m) => sum + m.items.fold(0.0, (s, i) => s + i.carbs),
    );
    final totalFat = meals.fold(
      0.0,
      (sum, m) => sum + m.items.fold(0.0, (s, i) => s + i.fat),
    );
    return DailyRecordModel(
      userId: meals.first.userId,
      recordDate: date,
      caloriesConsumed: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      meals: meals,
    );
  }

  Future<void> cacheDailyRecord(DailyRecordModel record) async {
    // Mỗi meal trong record đã được lưu riêng khi gọi saveMeal.
    // Nếu muốn lưu tổng hợp, có thể tạo một collection riêng, nhưng không bắt buộc.
    // Ở đây ta không làm gì thêm.
    return;
  }
}
