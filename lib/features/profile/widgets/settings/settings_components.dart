import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_responsive.dart';

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconbg;
  final Color iconcolor;
  final String title;
  final String sub;
  final bool value;
  final Function(bool) onChanged;

  const ToggleRow({
    required this.icon,
    required this.iconbg,
    required this.iconcolor,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
          RowIcon(icon: icon, bg: iconbg, color: iconcolor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.fs(13),
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: context.fs(11),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class ArrowRow extends StatelessWidget {
  final IconData icon;
  final Color iconbg;
  final Color iconcolor;
  final String title;
  final String? sub;
  final Color? titleColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const ArrowRow({
    required this.icon,
    required this.iconbg,
    required this.iconcolor,
    required this.title,
    this.sub,
    this.titleColor,
    this.borderColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(context.cardRadius),
          border: Border.all(
            color: borderColor ?? AppColors.primary.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            RowIcon(icon: icon, bg: iconbg, color: iconcolor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.fs(13),
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub!,
                      style: TextStyle(
                        fontSize: context.fs(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: context.fs(18),
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class RowIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const RowIcon({
    required this.icon,
    required this.bg,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.iconSize(30, tablet: 34, desktop: 38);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
