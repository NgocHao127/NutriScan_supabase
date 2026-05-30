import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'scan_state.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/today_record_provider.dart';
import '../../../models/meal_item_model.dart';
import '../../../models/meal_entry_model.dart';

class ScanController extends AutoDisposeNotifier<ScanState> {
  final _picker = ImagePicker();

  @override
  ScanState build() => const ScanState();

  // ── Chụp ảnh ─────────────────────────────────────────────
  Future<void> pickAndAnalyze() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;
    await _analyzeImage(image);
  }

  Future<void> _analyzeImage(XFile image) async {
    state = state.copyWith(
      status:       ScanStatus.loading,
      errorMessage: null,
    );
    try {
      final foodService = ref.read(foodServiceProvider);
      final result      = await foodService.analyzeFood(image.path);

      final foods = (result as List).map((item) {
        return MealItemModel(
          foodName: item['name']    ?? 'Món ăn',
          calories: (item['calories'] ?? 0).toDouble(),
          protein:  (item['protein']  ?? 0).toDouble(),
          carbs:    (item['carbs']    ?? 0).toDouble(),
          fat:      (item['fat']      ?? 0).toDouble(),
          portion:  item['portion']  ?? '1 phần',
        );
      }).toList();

      if (foods.isEmpty) throw Exception('Không nhận diện được món ăn');

      state = state.copyWith(
        status:        ScanStatus.result,
        detectedFoods: foods,
        portion:       1,
      );
    } catch (e) {
      state = state.copyWith(
        status:       ScanStatus.scanning,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Tăng/giảm khẩu phần ──────────────────────────────────
  void incrementPortion() =>
      state = state.copyWith(portion: state.portion + 1);

  void decrementPortion() {
    if (state.portion > 1) {
      state = state.copyWith(portion: state.portion - 1);
    }
  }

  // ── Lưu vào nhật ký ──────────────────────────────────────
  Future<bool> saveToDiary(double actualCalories) async {
    state = state.copyWith(isSaving: true);
    try {
      final mealService = ref.read(mealServiceProvider);
      final user        = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Chưa đăng nhập');

      final foods = state.detectedFoods;
      if (foods.isEmpty) throw Exception('Không có món ăn');
      final food = foods.first;

      final meal = MealEntryModel(
        id:       const Uuid().v4(),
        userId:   user.id,
        name:     food.foodName,
        mealType: 'Ăn vặt',
        mealTime: DateTime.now(),
        calories: actualCalories,
        protein:  food.protein  * state.portion,
        carbs:    food.carbs    * state.portion,
        fat:      food.fat      * state.portion,
        items:    [food],
      );

      await mealService.logMeal(meal.toJson());
      ref.invalidate(todayRecordProvider);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  // ── Reset về màn hình chụp ────────────────────────────────
  void retry() {
    state = const ScanState();
  }
}

final scanControllerProvider =
    AutoDisposeNotifierProvider<ScanController, ScanState>(
  ScanController.new,
);