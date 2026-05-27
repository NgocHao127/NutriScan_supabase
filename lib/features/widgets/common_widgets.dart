import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_responsive.dart';

// Macro Badge
class MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double progress; // 0.0 → 1.0

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(context.cardRadius),
      ),

      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: context.fs(13),
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: context.fs(9), color: AppColors.primary),
          ),

          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class CalorieProgressBar extends StatelessWidget {
  final int consumed;
  final int goal;

  const CalorieProgressBar({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calo hôm nay',
              style: TextStyle(
                fontSize: context.fs(12),
                color: AppColors.textSecondary,
              ),
            ),

            Text(
              '$consumed / $goal kcal',
              style: TextStyle(
                fontSize: context.fs(12),
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryMid,
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: context.fs(14),
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),

        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: context.fs(12),
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final String? sub;
  final Color? subColor;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    this.sub,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: context.fs(16),
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: context.fs(11),
              color: AppColors.textSecondary,
            ),
          ),

          if (sub != null) ...[
            const SizedBox(height: 1),
            Text(
              sub!,
              style: TextStyle(
                fontSize: context.fs(10),
                color: subColor ?? AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'AI Scan',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Nhật ký',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity, // Giúp thẻ tràn đều ra kín ô Grid
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(context.cardRadius),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.12),
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: context.fs(20),
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),

                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.fs(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.fs(11),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(6),
                  ),
                ),
                child: Text(
                  'Đang chọn',
                  style: TextStyle(
                    fontSize: context.fs(9),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: context.fs(11),
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
