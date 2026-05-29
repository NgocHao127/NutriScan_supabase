import 'package:flutter/material.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

import '../../widgets/meal_group_list.dart';

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
        MealGroupList(meals: meals),
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
        Expanded(child: MealGroupList(meals: meals)),
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

    final proteinGoal = (record?.proteinGoal ?? 150).toDouble();
    final carbsGoal = (record?.carbsGoal ?? 250).toDouble();
    final fatGoal = (record?.fatGoal ?? 65).toDouble();

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
