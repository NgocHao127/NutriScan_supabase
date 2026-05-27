import 'package:isar/isar.dart';
import 'food_model.dart';

part 'meal_entry_model.g.dart';

@Collection()
class MealEntryModel {
  Id isarId = Isar.autoIncrement; // ID cục bộ của Isar
  @Index(unique: true, replace: true)
  late String serverId; // UID do client tạo hoặc server trả về
  late String userId; // Firebase UID
  late String name;
  late String mealType;
  late DateTime mealTime;
  late double calories;

  List<FoodItem> items = []; // danh sách món ăn (từ phân tích ảnh)
  String? imageUrl;
  String? note;
  String? updatedAt; // timestamp server để giải quyết conflict

  bool pendingSync = false; // true nếu chưa đồng bộ lên server

  MealEntryModel({
    this.isarId = Isar.autoIncrement,
    required this.serverId,
    required this.userId,
    this.name = '',
    this.mealType = 'Ăn vặt',
    required this.mealTime,
    this.calories = 0,
    this.items = const [],
    this.imageUrl,
    this.note,
    this.updatedAt,
    this.pendingSync = false,
  });

  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    // Xử lý items an toàn
    List<FoodItem> foodItems = [];
    final itemsData = json['items'];
    if (itemsData is List) {
      foodItems = itemsData
          .map((i) => FoodItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return MealEntryModel(
      serverId: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      mealType: json['meal_type'] ?? 'Ăn vặt',
      mealTime: DateTime.parse(json['recorded_at']
        ?? DateTime.now().toUtc().toIso8601String()),
      calories: (json['calories'] ?? 0).toDouble(),
      items: foodItems,
      imageUrl: json['image_url'],
      note: json['note'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'user_id': userId,
      'name': name,
      'meal_type': mealType,
      'recorded_at': mealTime.toUtc().toIso8601String(),
      'calories': calories,
      'items': items.map((e) => e.toJson()).toList(),
      'image_url': imageUrl,
      'note': note,
      'updated_at': updatedAt,
    };
  }
}
