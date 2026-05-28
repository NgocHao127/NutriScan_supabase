import 'food_model.dart';

class MealEntryModel {
  final String id; 
  final String userId; // UUID từ Supabase, không phải Firebase UID nữa
  final String name;
  final String mealType;
  final DateTime mealTime;
  final double calories;
  final List<FoodItem> items;
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
    this.items = const [],
    this.imageUrl,
    this.note,
    this.updatedAt,
  });

  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    List<FoodItem> foodItems = [];
    final itemsData = json['items'];
    if (itemsData is List) {
      foodItems = itemsData
          .map((i) => FoodItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return MealEntryModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      mealType: json['meal_type'] ?? 'Ăn vặt',
      mealTime: DateTime.parse(json['recorded_at'] ?? DateTime.now().toUtc().toIso8601String()).toLocal(),
      calories: (json['calories'] ?? 0).toDouble(),
      items: foodItems,
      imageUrl: json['image_url'],
      note: json['note'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'meal_type': mealType,
      'recorded_at': mealTime.toUtc().toIso8601String(),
      'calories': calories,
      'items': items.map((e) => e.toJson()).toList(),
      if (imageUrl != null) 'image_url': imageUrl,
      if (note != null) 'note': note,
    };
  }
}