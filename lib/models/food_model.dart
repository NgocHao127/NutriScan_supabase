import 'package:isar/isar.dart';

part 'food_model.g.dart';

@embedded
class FoodItem {
  late String name;
  late double calories;
  late double protein;
  late double carbs;
  late double fat;
  late String? portion;

  FoodItem({
    this.name = '',
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.portion,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      portion: json['portion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'portion': portion,
    };
  }
}
