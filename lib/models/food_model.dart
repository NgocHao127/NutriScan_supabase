import 'meal_item_model.dart';

class FoodModel {
  final int? id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final String? source;
  final String? status;
  final String? imageUrl;
  final String? portion;

  FoodModel({
    this.id,
    this.name = '',
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.source,
    this.status,
    this.imageUrl,
    this.portion,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      servingSize: (json['serving_size'] ?? 100).toDouble(),
      servingUnit: json['serving_unit'] ?? 'g',
      source: json['source'],
      status: json['status'],
      imageUrl: json['image_url'],
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
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      if (portion != null) 'portion': portion,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// Convert sang MealItemModel để thêm vào bữa ăn
  MealItemModel toMealItem() {
    return MealItemModel(
      foodName: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      portion: portion ?? '$servingSize $servingUnit',
    );
  }
}
