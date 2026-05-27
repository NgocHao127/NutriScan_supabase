import 'package:flutter/material.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

import '../../../models/daily_record_model.dart';
import '../../../models/meal_entry_model.dart';

class DailyTabView extends StatelessWidget {
  final DailyRecordModel? record;
  final List<MealEntryModel> meals;

  const DailyTabView({super.key, this.record, required this.meals});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: context.isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(context),

        const SizedBox(height: 12),
        CalorieProgressBar(
          consumed: (record?.caloriesConsumed ?? 0.0).toInt(),
          goal: (record?.caloriesGoal ?? 2000.0).toInt(),
        ),

        const SizedBox(height: 8),
        _buildMacroRow(context),

        const SizedBox(height: 14),
        MealsGroups(meals),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _buildSummaryCards(context),

              const SizedBox(height: 14),
              CalorieProgressBar(
                consumed: (record?.caloriesConsumed ?? 0.0).toInt(),
                goal: (record?.caloriesGoal ?? 2000.0).toInt(),
              ),

              const SizedBox(height: 8),
              _buildMacroRow(context),
            ],
          ),
        ),

        const SizedBox(width: 32),

        Expanded(child: MealsGroups(meals, useGrid: true)),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final consumed = (record?.caloriesConsumed ?? 0.0).toInt();
    final goal = (record?.caloriesGoal ?? 2000.0).toInt();
    final remaining = goal - consumed;

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            value: '$consumed',
            label: 'kcal nạp vào',
            sub: 'còn $remaining kcal',
          ),
        ),

        const SizedBox(width: 6),
        Expanded(
          child: MetricCard(
            value: '0', // Giữ nguyên UI, update thực tế sau
            label: 'kcal đốt cháy',
            sub: 'đi bộ 42 phút',
          ),
        ),

        const SizedBox(width: 6),
        Expanded(
          child: MetricCard(
            value: '$consumed',
            label: 'kcal ròng',
            sub: 'mục tiêu $goal',
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(BuildContext context) {
    final protein = record?.protein ?? 0.0;
    final carbs = record?.carbs ?? 0.0;
    final fat = record?.fat ?? 0.0;

    // Mục tiêu mẫu (có thể lấy từ user profile sau)
    const proteinGoal = 150.0;
    const carbsGoal = 250.0;
    const fatGoal = 65.0;

    return Row(
      children: [
        MacroMini(
          'P ${protein.toInt()}g',
          protein / proteinGoal.clamp(1.0, double.infinity),
          AppColors.protein,
        ),

        const SizedBox(width: 4),
        MacroMini(
          'C ${carbs.toInt()}g',
          carbs / carbsGoal.clamp(1.0, double.infinity),
          AppColors.carb,
        ),

        const SizedBox(width: 4),
        MacroMini(
          'F ${fat.toInt()}g',
          fat / fatGoal.clamp(1.0, double.infinity),
          AppColors.fat,
        ),
      ],
    );
  }
}

class MacroMini extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const MacroMini(this.label, this.progress, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: context.fs(10),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class MealsGroups extends StatelessWidget {
  final List<MealEntryModel> meals;
  final bool useGrid;

  const MealsGroups(this.meals, {super.key, this.useGrid = false});

  @override
  Widget build(BuildContext context) {
    final groupedMeals = <String, List<MealEntryModel>>{};
    for (final m in meals) {
      groupedMeals.putIfAbsent(m.mealType, () => []).add(m);
    }

    return Column(
      children: ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn vặt'].map((type) {
        final items = groupedMeals[type] ?? [];
        final totalCal = items.fold(0.0, (s, m) => s + m.calories).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: context.fs(11),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),

                if (items.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$totalCal kcal',
                    style: TextStyle(
                      fontSize: context.fs(11),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 6),
            if (items.isEmpty)
              AddBtn(type)
            else if (useGrid && items.length > 1)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemCount: items.length,
                itemBuilder: (_, index) => MealRow(items[index]),
              )
            else
              ...items.map((m) => MealRow(m)),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}

class MealRow extends StatelessWidget {
  final MealEntryModel meal;

  const MealRow(this.meal, {super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = context.iconSize(32, tablet: 36, desktop: 40);

    // Format thời gian từ DateTime
    final timeStr =
        "${meal.mealTime.hour.toString().padLeft(2, '0')}:${meal.mealTime.minute.toString().padLeft(2, '0')}";

    // Tính macro thực tế từ items
    double protein = 0, carbs = 0, fat = 0;
    for (var item in meal.items) {
      protein += item.protein;
      carbs += item.carbs;
      fat += item.fat;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: Center(
              child: Text(
                '🍲', // Thay emoji tuỳ ý
                style: TextStyle(fontSize: iconSize * 0.52),
              ),
            ),
          ),

          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.fs(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '1 phần · $timeStr',
                  style: TextStyle(
                    fontSize: context.fs(10),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories.toInt()} kcal',
                style: TextStyle(
                  fontSize: context.fs(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'P${protein.toInt()} · C${carbs.toInt()} · F${fat.toInt()}g',
                style: TextStyle(
                  fontSize: context.fs(10),
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddBtn extends StatelessWidget {
  final String mealType;

  const AddBtn(this.mealType, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: context.fs(13), color: AppColors.primary),

            const SizedBox(width: 4),
            Text(
              'Thêm $mealType',
              style: TextStyle(
                fontSize: context.fs(11),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
