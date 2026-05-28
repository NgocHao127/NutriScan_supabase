import 'meal_item_model.dart';

class MealEntryModel {
  final String id;
  final String userId; // UUID từ Supabase, không phải Firebase UID nữa
  final String name;
  final String mealType;
  final DateTime mealTime;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealItemModel> items;
  final String? imageUrl;
  final String? note;
  final DateTime? updatedAt;

  MealEntryModel({
    required this.id,
    required this.userId,
    this.name = '',
    this.mealType = 'Ăn vặt',
    required this.mealTime,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.items = const [],
    this.imageUrl,
    this.note,
    this.updatedAt,
  });

  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    List<MealItemModel> mealItems = [];
    final itemsData = json['meal_items'];
    if (itemsData is List) {
      mealItems = itemsData
          .map((i) => MealItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return MealEntryModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      mealType: json['meal_type'] ?? 'Ăn vặt',
      mealTime: DateTime.parse(json['meal_time']?.toString() ??
              json['recorded_at']?.toString() ??
              DateTime.now().toUtc().toIso8601String())
          .toLocal(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(), // thêm
      carbs: (json['carbs'] ?? 0).toDouble(), // thêm
      fat: (json['fat'] ?? 0).toDouble(),
      items: mealItems,
      imageUrl: json['image_url'],
      note: json['note'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'meal_type': mealType,
      'meal_time': mealTime.toUtc().toIso8601String(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'items': items
          .map((e) => e.toJson())
          .toList(), // giữ để backend lưu meal_items
      if (imageUrl != null) 'image_url': imageUrl,
      if (note != null) 'note': note,
    };
  }
}
