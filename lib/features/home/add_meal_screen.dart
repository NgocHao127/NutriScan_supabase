import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriscan/core/utils/food_emoji_mapper.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';
import '../../models/meal_item_model.dart';
import '../../core/utils/food_emoji_mapper.dart';

import 'widgets/meal/add_food_sheet.dart';
import 'widgets/meal/nutrition_chip.dart';

import 'home_controller/add_meal_controller.dart';
import 'home_controller/add_meal_state.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final String? initialMealType;

  const AddMealScreen({super.key, this.initialMealType});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _mealNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Truyền initialMealType vào controller sau frame đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(addMealControllerProvider.notifier)
          .initMealType(widget.initialMealType);
    });
  }

  @override
  void dispose() {
    _mealNameCtrl.dispose();
    super.dispose();
  }

  // Lắng nghe status thay đổi để hiện Snackbar / pop
  void _listenStatus(AddMealState state) {
    if (state.status == AddMealStatus.saved) {
      if (state.calorieExceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '⚠️ Đã vượt ${state.consumedCalories}/${state.goalCalories} kcal!'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu bữa ăn!'),
          backgroundColor: AppColors.primaryMid,
        ),
      );
      context.pop(true);
    } else if (state.status == AddMealStatus.error &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMealControllerProvider);
    final controller = ref.read(addMealControllerProvider.notifier);

    // Lắng nghe status
    ref.listen(addMealControllerProvider, (_, next) => _listenStatus(next));

    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealInfo(context, controller, state),
                    const SizedBox(height: 20),
                    _buildNutritionSummary(context, controller, state),
                    const SizedBox(height: 20),
                    _buildFoodList(context, controller, state),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildSaveButton(context, state, controller),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thêm bữa ăn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.fs(17),
                    fontWeight: FontWeight.w500,
                  )),
              Text('Ghi lại thủ công',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.fs(11),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfo(
      BuildContext context, AddMealController controller, AddMealState state) {
    final mealTypes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn vặt'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên bữa ăn
        Text('Tên bữa ăn (tuỳ chọn)',
            style: TextStyle(
              fontSize: context.fs(11),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: _mealNameCtrl,
          onChanged: controller.updateMealName,
          decoration: InputDecoration(
            hintText: 'VD: Cơm trưa văn phòng',
            hintStyle:
                TextStyle(color: AppColors.textHint, fontSize: context.fs(13)),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryMid, width: 1.5),
            ),
          ),
          style:
              TextStyle(fontSize: context.fs(13), color: AppColors.textPrimary),
        ),

        const SizedBox(height: 16),

        // Loại bữa
        Text('Loại bữa',
            style: TextStyle(
              fontSize: context.fs(11),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 8),
        Row(
          children: mealTypes.map((type) {
            final selected = state.selectedMealType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectMealType(type),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          selected ? AppColors.primary : AppColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.fs(10),
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionSummary(
      BuildContext context, AddMealController controller, AddMealState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(context.cardRadius),
      ),
      child: Row(
        children: [
          NutritionChip(
            label: 'Calo',
            value: '${state.totalCalories.toInt()}',
            unit: 'kcal',
          ),
          NutritionChip(
            label: 'Protein',
            value: '${state.totalProtein.toInt()}',
            unit: 'g',
          ),
          NutritionChip(
            label: 'Carb',
            value: '${state.totalCarbs.toInt()}',
            unit: 'g',
          ),
          NutritionChip(
            label: 'Fat',
            value: '${state.totalFat.toInt()}',
            unit: 'g',
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(
      BuildContext context, AddMealController controller, AddMealState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Món ăn (${state.foods.length})',
                style: TextStyle(
                  fontSize: context.fs(13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                )),
            GestureDetector(
              onTap: () => _addFood(controller),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add,
                        size: context.fs(12), color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Thêm món',
                        style: TextStyle(
                          fontSize: context.fs(11),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.isEmpty)
          GestureDetector(
            onTap: () => _addFood(controller),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(context.cardRadius),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 40,
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Nhấn để thêm món ăn',
                      style: TextStyle(
                        fontSize: context.fs(13),
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          )
        else
          ...state.foods.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final food = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(context.cardRadius),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: FoodEmojiMapper.getCategoryColor(food.foodName)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          FoodEmojiMapper.getEmoji(food.foodName),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.foodName,
                            style: TextStyle(
                              fontSize: context.fs(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: FoodEmojiMapper.getCategoryColor(
                                          food.foodName)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  FoodEmojiMapper.getCategory(food.foodName),
                                  style: TextStyle(
                                    fontSize: context.fs(9),
                                    color: FoodEmojiMapper.getCategoryColor(
                                        food.foodName),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'P${food.protein.toInt()} C${food.carbs.toInt()} F${food.fat.toInt()}',
                                style: TextStyle(
                                  fontSize: context.fs(10),
                                  color: AppColors.textHint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => controller.removeFood(i),
                                child: Icon(Icons.close,
                                    size: 18, color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSaveButton(
      BuildContext context, AddMealState state, AddMealController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPad),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isSaving ? null : controller.save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Lưu bữa ăn',
                  style: TextStyle(
                    fontSize: context.fs(14),
                    fontWeight: FontWeight.w500,
                  )),
        ),
      ),
    );
  }

  Future<void> _addFood(AddMealController controller) async {
    final result = await showModalBottomSheet<MealItemModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFoodSheet(),
    );
    if (result != null) controller.addFood(result);
  }
}
