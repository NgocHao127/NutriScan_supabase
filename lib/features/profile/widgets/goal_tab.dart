import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriscan/models/users_model.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/today_record_provider.dart';

class GoalTab extends ConsumerWidget {
  const GoalTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 14),
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

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(label: 'Mục tiêu hiện tại'),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              onPressed: () => context.push('/edit-profile'),
            ),
          ],
        ),
        const CurrentGoalCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(label: 'Mục tiêu hiện tại'),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              onPressed: () => context.push('/edit-profile'),
            ),
          ],
        ),
        const CurrentGoalCard(),
      ],
    );
  }
}

class CurrentGoalCard extends ConsumerWidget {
  const CurrentGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).valueOrNull;
    final todayRecord = ref.watch(todayRecordProvider).valueOrNull;

    final calorieGoal = user.safeCaloriesGoal;
    final proteinGoal = user.safeProteinGoal;
    final carbsGoal = user.safeCarbsGoal;
    final fatGoal = user.safeFatGoal;

    // Dữ liệu thực hôm nay
    final caloriesConsumed = todayRecord?.caloriesConsumed ?? 0;
    final proteinConsumed = todayRecord?.protein ?? 0;
    final carbConsumed = todayRecord?.carbs ?? 0;
    final fatConsumed = todayRecord?.fat ?? 0;

    final iconSize = context.iconSize(32, tablet: 36, desktop: 40);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(iconSize * 0.28),
                ),
                child: Icon(
                  Icons.track_changes,
                  size: iconSize * 0.52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.safeGoal,
                      style: TextStyle(
                        fontSize: context.fs(13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${user.safeActivityLevel} · $calorieGoal kcal',
                      style: TextStyle(
                        fontSize: context.fs(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Đang chạy',
                  style: TextStyle(
                    fontSize: context.fs(10),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MacroCard(
                  label: 'Calo / ngày',
                  value: '$calorieGoal',
                  color: AppColors.primaryMid,
                  progress: calorieGoal > 0
                      ? (caloriesConsumed / calorieGoal).clamp(0.0, 1.0)
                      : 0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Protein',
                  value: '${proteinGoal}g',
                  color: AppColors.protein,
                  progress: (proteinConsumed / proteinGoal).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Carb',
                  value: '${carbsGoal}g',
                  color: AppColors.carb,
                  progress: (carbConsumed / carbsGoal).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Fat',
                  value: '${fatGoal}g',
                  color: AppColors.fat,
                  progress: (fatConsumed / fatGoal).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Calo dự kiến được tính tự động từ thông số cơ thể của bạn',
                    style: TextStyle(
                      fontSize: context.fs(10),
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
