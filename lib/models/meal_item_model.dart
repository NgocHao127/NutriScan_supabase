class MealItemModel {
  final int? id;
  final String? mealId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portion;
  final double quantity;
  final DateTime? mealTime;

  MealItemModel({
    this.id,
    this.mealId,
    required this.foodName,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.portion = '1 phần',
    this.quantity = 1,
    this.mealTime,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id'] ?? 0,
      mealId: json['meal_id'] ?? '',
      foodName: json['food_name'] ?? json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      portion: json['portion'] ?? '1 phần',
      quantity: (json['quantity'] ?? 1).toDouble(),
      mealTime: json['meal_time'] != null  // thêm — lấy từ meal_entry parent
          ? DateTime.parse(json['meal_time']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'portion': portion,
      'quantity': quantity,
      'meal_time': mealTime,
    };
  }
}
