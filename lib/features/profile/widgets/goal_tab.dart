import 'package:flutter/material.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class GoalTab extends StatefulWidget {
  const GoalTab({super.key});

  @override
  State<GoalTab> createState() => _GoalTabState();
}

class _GoalTabState extends State<GoalTab> with AutomaticKeepAliveClientMixin {
  int selectedGoal = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột trái: mục tiêu hiện tại
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label: 'Mục tiêu hiện tại'),
              const CurrentGoalCard(),
            ],
          ),
        ),

        const SizedBox(width: 32),
        // Cột phải: đổi mục tiêu
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label: 'Đổi mục tiêu'),
              GoalGrid(
                selectedGoal: selectedGoal,
                onGoalSelected: (i) => setState(() => selectedGoal = i),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: 'Mục tiêu hiện tại'),
        const CurrentGoalCard(),

        const SizedBox(height: 14),
        SectionLabel(label: 'Đổi mục tiêu'),
        GoalGrid(
          selectedGoal: selectedGoal,
          onGoalSelected: (i) => setState(() => selectedGoal = i),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class CurrentGoalCard extends StatelessWidget {
  const CurrentGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Duy trì cân nặng',
                      style: TextStyle(
                        fontSize: context.fs(13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hoạt động vừa phải · TDEE 2.100 kcal',
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
                  value: '1.800',
                  color: AppColors.primaryMid,
                  progress: 1240 / 1800,
                ),
              ),

              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Protein',
                  value: '70g',
                  color: AppColors.protein,
                  progress: 62 / 70,
                ),
              ),

              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Carb',
                  value: '220g',
                  color: AppColors.carb,
                  progress: 148 / 220,
                ),
              ),

              const SizedBox(width: 6),
              Expanded(
                child: MacroCard(
                  label: 'Fat',
                  value: '60g',
                  color: AppColors.fat,
                  progress: 38 / 60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalGrid extends StatelessWidget {
  final int selectedGoal;
  final Function(int) onGoalSelected;

  const GoalGrid({
    required this.selectedGoal,
    required this.onGoalSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goals = [
      (Icons.trending_down_rounded, 'Giảm cân', '-0.5kg / tuần'),
      (Icons.balance_rounded, 'Duy trì', 'Cân bằng calo'),
      (Icons.fitness_center_rounded, 'Tăng cơ', '+200 kcal surplus'),
      (Icons.favorite_border_rounded, 'Ăn lành mạnh', 'Cải thiện chất xơ'),
    ];

    if (context.isTablet) {
      final cardWidth = (context.sw - context.hPad * 2 - 20) / 3;

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: goals.asMap().entries.map((e) {
          final g = e.value;
          final isSelected = e.key == selectedGoal;

          return SizedBox(
            width: cardWidth,
            child: GoalCard(
              icon: g.$1,
              title: g.$2,
              subtitle: g.$3,
              isSelected: isSelected,
              onTap: () => onGoalSelected(e.key),
            ),
          );
        }).toList(),
      );
    }

    final cols = context.isDesktop ? 4 : 2;
    final ratio = context.isDesktop
        ? 1.0
        : context.isTablet
        ? 1.0
        : 1.3;

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: ratio,
      children: goals.asMap().entries.map((e) {
        final g = e.value;
        final isSelected = e.key == selectedGoal;

        return GoalCard(
          icon: g.$1,
          title: g.$2,
          subtitle: g.$3,
          isSelected: isSelected,
          onTap: () => onGoalSelected(e.key),
        );
      }).toList(),
    );
  }
}
