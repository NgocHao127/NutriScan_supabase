import 'meal_entry_model.dart';

// Dữ liệu nguyên thủy (Khớp 100% với Database)
class DailyRecordModel {
  final String userId;
  final DateTime recordDate;
  final double? caloriesGoal;
  final int? proteinGoal;
  final int? carbsGoal;
  final int? fatGoal;
  final double caloriesConsumed;
  final double caloriesBurned;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealEntryModel> meals;

  DailyRecordModel({
    required this.userId,
    required this.recordDate,
    this.caloriesGoal,
    this.proteinGoal,
    this.carbsGoal,
    this.fatGoal,
    this.caloriesConsumed = 0,
    this.caloriesBurned = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.meals = const [],
  });

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) {
    // Xử lý meals an toàn
    List<MealEntryModel> meals = [];
    final mealsData = json['meals'];
    if (mealsData is List) {
      meals = mealsData
          .map((m) => MealEntryModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return DailyRecordModel(
      userId: json['user_id'] ?? '',
      // Nếu không có record_date, dùng ngày hôm nay
      recordDate: DateTime.parse(json['record_date']?.toString() ??
          json['date']?.toString() ??
          DateTime.now().toIso8601String().substring(0, 10)),
      caloriesGoal:
          (json['calories_goal'] ?? json['daily_calories_goal'] ?? 2000)
              .toDouble(),
      proteinGoal: json['protein_goal'],
      carbsGoal: json['carbs_goal'],
      fatGoal: json['fat_goal'],
      caloriesConsumed:
          (json['total_calories'] ?? json['calories_consumed'] ?? 0).toDouble(),
      caloriesBurned: (json['calories_burned'] ?? 0).toDouble(),
      protein: (json['total_protein'] ?? 0).toDouble(),
      carbs: (json['total_carbs'] ?? 0).toDouble(),
      fat: (json['total_fat'] ?? 0).toDouble(),
      meals: meals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'record_date': recordDate.toIso8601String().substring(0, 10),
      if (caloriesGoal != null) 'daily_calories_goal': caloriesGoal,
      'calories_consumed': caloriesConsumed,
      'calories_burned': caloriesBurned,
      'total_protein': protein,
      'total_carbs': carbs,
      'total_fat': fat,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }
}

// Logic giao diện & Bù trừ dữ liệu
extension DailyRecordExtension on DailyRecordModel? {
  int get safeConsumed => this?.caloriesConsumed.toInt() ?? 0;
  int get safeGoal => this?.caloriesGoal?.toInt() ?? 2000;
  int get safeProtein => this?.protein.toInt() ?? 0;
  int get safeCarbs => this?.carbs.toInt() ?? 0;
  int get safeFat => this?.fat.toInt() ?? 0;

  double get progressRatio {
    if (safeGoal == 0) return 0.0;
    return (safeConsumed / safeGoal).clamp(0.0, 1.0);
  }
}
