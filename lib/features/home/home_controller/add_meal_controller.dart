import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriscan/models/daily_record_model.dart';
import 'package:uuid/uuid.dart';
import 'add_meal_state.dart';
import '../../../models/meal_entry_model.dart';
import '../../../models/meal_item_model.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/today_record_provider.dart';
import '../../../core/services/notification_service.dart';

class AddMealController extends AutoDisposeNotifier<AddMealState> {
  @override
  AddMealState build() {
    return AddMealState(
      selectedMealType: _detectMealType(),
    );
  }

  // ── Detect meal type theo giờ ────────────────────────────
  String _detectMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 10) return 'Bữa sáng';
    if (hour > 10 && hour <= 14) return 'Bữa trưa';
    if (hour >= 17 && hour < 22) return 'Bữa tối';
    return 'Ăn vặt';
  }

  // ── Khởi tạo với initialMealType từ route ───────────────
  void initMealType(String? initialMealType) {
    if (initialMealType != null) {
      state = state.copyWith(selectedMealType: initialMealType);
    }
  }

  // ── Cập nhật tên bữa ─────────────────────────────────────
  void updateMealName(String name) {
    state = state.copyWith(mealName: name);
  }

  // ── Chọn loại bữa ────────────────────────────────────────
  void selectMealType(String type) {
    state = state.copyWith(selectedMealType: type);
  }

  // ── Thêm / xóa món ───────────────────────────────────────
  void addFood(MealItemModel food) {
    state = state.copyWith(foods: [...state.foods, food]);
  }

  void removeFood(int index) {
    final updated = [...state.foods]..removeAt(index);
    state = state.copyWith(foods: updated);
  }

  // ── Lưu bữa ăn ───────────────────────────────────────────
  Future<bool> save() async {
    if (state.isEmpty) {
      state = state.copyWith(
        status: AddMealStatus.error,
        errorMessage: 'Vui lòng thêm ít nhất 1 món ăn',
      );
      return false;
    }

    state = state.copyWith(status: AddMealStatus.saving);

    try {
      final mealService = ref.read(mealServiceProvider);
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Chưa đăng nhập');

      final meal = MealEntryModel(
        id: const Uuid().v4(),
        userId: user.id,
        name: state.mealName.isEmpty ? state.selectedMealType : state.mealName,
        mealType: state.selectedMealType,
        mealTime: DateTime.now(),
        calories: state.totalCalories,
        protein: state.totalProtein,
        carbs: state.totalCarbs,
        fat: state.totalFat,
        items: state.foods,
      );

      await mealService.logMeal(meal.toJson());
      ref.invalidate(todayRecordProvider);

      // Kiểm tra vượt calo
      final record = await ref.read(todayRecordProvider.future);
      final goal = record.safeGoal;
      final consumed = record.safeConsumed;

      if (consumed > goal) {
        // Trigger local notification (delay 3s cho trường hợp thoát app)
        NotificationService().showImmediateCalorieWarning(
          consumed: consumed,
          goal: goal,
        );
        state = state.copyWith(
          status: AddMealStatus.saved,
          calorieExceeded: true,
          consumedCalories: consumed,
          goalCalories: goal,
        );
      } else {
        state = state.copyWith(status: AddMealStatus.saved);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AddMealStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final addMealControllerProvider =
    AutoDisposeNotifierProvider<AddMealController, AddMealState>(
  AddMealController.new,
);
