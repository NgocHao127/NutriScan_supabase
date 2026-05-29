import '../../../models/meal_item_model.dart';

enum AddMealStatus { idle, saving, saved, error }

class AddMealState {
  final String mealName;
  final String selectedMealType;
  final List<MealItemModel> foods;
  final AddMealStatus status;
  final String? errorMessage;
  final bool calorieExceeded;
  final int consumedCalories;
  final int goalCalories;

  const AddMealState({
    this.mealName = '',
    this.selectedMealType = 'Bữa sáng',
    this.foods = const [],
    this.status = AddMealStatus.idle,
    this.errorMessage,
    this.calorieExceeded = false,
    this.consumedCalories = 0,
    this.goalCalories = 2000,
  });

  double get totalCalories => foods.fold(0, (s, f) => s + f.calories);
  double get totalProtein  => foods.fold(0, (s, f) => s + f.protein);
  double get totalCarbs    => foods.fold(0, (s, f) => s + f.carbs);
  double get totalFat      => foods.fold(0, (s, f) => s + f.fat);
  bool   get isEmpty       => foods.isEmpty;
  bool   get isSaving      => status == AddMealStatus.saving;

  AddMealState copyWith({
    String? mealName,
    String? selectedMealType,
    List<MealItemModel>? foods,
    AddMealStatus? status,
    String? errorMessage,
    bool? calorieExceeded,
    int? consumedCalories,
    int? goalCalories,
  }) {
    return AddMealState(
      mealName:          mealName          ?? this.mealName,
      selectedMealType:  selectedMealType  ?? this.selectedMealType,
      foods:             foods             ?? this.foods,
      status:            status            ?? this.status,
      errorMessage:      errorMessage      ?? this.errorMessage,
      calorieExceeded:   calorieExceeded   ?? this.calorieExceeded,
      consumedCalories:  consumedCalories  ?? this.consumedCalories,
      goalCalories:      goalCalories      ?? this.goalCalories,
    );
  }
}