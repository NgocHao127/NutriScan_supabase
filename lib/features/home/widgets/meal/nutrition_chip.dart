import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_responsive.dart';

class NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const NutritionChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            '$unit\n$label',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.fs(9),
              color: AppColors.onPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
