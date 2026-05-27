import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_responsive.dart';

class AiTipCard extends StatelessWidget {
  const AiTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = context.iconSize(28, tablet: 32, desktop: 36);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: iconSize * 0.52,
              color: AppColors.onPrimary,
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gợi ý từ AI',
                  style: TextStyle(
                    fontSize: context.fs(10),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  'Bữa tối nên bổ sung rau xanh - bạn mới đạt 18% chất xơ hôm nay.',
                  style: TextStyle(
                    fontSize: context.fs(12),
                    color: AppColors.primaryDark,
                    height: 1.5,
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
