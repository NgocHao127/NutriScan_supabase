import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  bool _notifyMeal = true;
  bool _notifyWeekly = true;
  bool _notifyAlert = false;

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
        // Cột trái: thông báo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label: 'Thông báo'),
              _toggleRows(),
            ],
          ),
        ),

        const SizedBox(width: 32),
        // Cột phải: dữ liệu & tài khoản
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label: 'Dữ liệu & bảo mật'),
              _dataRows(),

              const SizedBox(height: 14),
              SectionLabel(label: 'Tài khoản'),
              _accountRows(context), // Truyền context vào đây
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
        SectionLabel(label: 'Thông báo'),
        _toggleRows(),

        const SizedBox(height: 14),
        SectionLabel(label: 'Dữ liệu & bảo mật'),
        _dataRows(),

        const SizedBox(height: 14),
        SectionLabel(label: 'Tài khoản'),
        _accountRows(context), // Truyền context vào đây

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _toggleRows() => Column(
    children: [
      ToggleRow(
        icon: Icons.notifications_outlined,
        iconbg: AppColors.primaryLight,
        iconcolor: AppColors.primary,
        title: 'Nhắc ghi bữa ăn',
        sub: 'Sáng 7h · Trưa 12h · Tối 18h',
        value: _notifyMeal,
        onChanged: (v) => setState(() => _notifyMeal = v),
      ),
      ToggleRow(
        icon: Icons.auto_awesome_outlined,
        iconbg: AppColors.primaryLight,
        iconcolor: AppColors.primary,
        title: 'Tổng kết tuần AI',
        sub: 'Mỗi Chủ nhật lúc 20h',
        value: _notifyWeekly,
        onChanged: (v) => setState(() => _notifyWeekly = v),
      ),
      ToggleRow(
        icon: Icons.warning_amber_outlined,
        iconbg: const Color(0xFFFAEEDA),
        iconcolor: AppColors.warning,
        title: 'Cảnh báo vượt calo',
        sub: 'Khi đạt 90% mục tiêu',
        value: _notifyAlert,
        onChanged: (v) => setState(() => _notifyAlert = v),
      ),
    ],
  );

  Widget _dataRows() => Column(
    children: [
      ArrowRow(
        icon: Icons.download_outlined,
        iconbg: const Color(0xFFE6F1FB),
        iconcolor: const Color(0xFF185FA5),
        title: 'Xuất dữ liệu',
        sub: 'Tải về file Excel',
      ),
      ArrowRow(
        icon: Icons.info_outline,
        iconbg: AppColors.primaryLight,
        iconcolor: AppColors.primary,
        title: 'Về ứng dụng',
        sub: 'NutriScan v1.0.0',
      ),
    ],
  );

  Widget _accountRows(BuildContext context) => Column(
    children: [
      ArrowRow(
        icon: Icons.logout,
        iconbg: const Color(0xFFFCEBEB),
        iconcolor: AppColors.danger,
        title: 'Đăng xuất',
        titleColor: AppColors.danger,
        borderColor: AppColors.danger.withValues(alpha: 0.2),
        onTap: () async {
          // Sử dụng authNotifier để đăng xuất
          await ref.read(authNotifierProvider.notifier).signOut();
          // GoRouter sẽ tự động redirect về /login nhờ redirect guard
        },
      ),
    ],
  );
}

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
      onTap:
          onTap ??
          () {}, // Nếu onTap không được cung cấp, sử dụng hàm rỗng để tránh lỗi
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
