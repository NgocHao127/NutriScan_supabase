import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';
import '../../../providers/user_provider.dart';

class ProfileAppBar extends ConsumerWidget {
  const ProfileAppBar({super.key});

  // Hàm lấy chữ cái đầu để làm Avatar
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final words = name.trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words.last[0]}'.toUpperCase();
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'tháng 1',
      'tháng 2',
      'tháng 3',
      'tháng 4',
      'tháng 5',
      'tháng 6',
      'tháng 7',
      'tháng 8',
      'tháng 9',
      'tháng 10',
      'tháng 11',
      'tháng 12',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarSize = context.iconSize(52, tablet: 58, desktop: 64);
    final userAsync = ref.watch(userProfileProvider);

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        context.hPad,
        MediaQuery.of(context).padding.top + 12,
        context.hPad,
        14,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: userAsync.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            error: (error, stack) => const Text('Lỗi tải dữ liệu'),
            data: (user) {
              // Lấy dữ liệu an toàn
              final name = user?.name ?? 'Người dùng';
              final age = user?.age ?? 0;
              final initials = _getInitials(name);
              final bmiStr =
                  user?.bmi != null ? user!.bmi!.toStringAsFixed(1) : '-';

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.maxContentWidth,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: context.fs(16),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: context.fs(16),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.createdAt != null
                                      ? 'Thành viên từ ${_formatJoinDate(user!.createdAt!)}'
                                      : 'Thành viên NutriScan',
                                  style: TextStyle(
                                    fontSize: context.fs(11),
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.hPad * 0.75,
                                vertical: 5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: TextStyle(fontSize: context.fs(11)),
                            ),
                            onPressed: () => context.push('/edit-profile'),
                            child: const Text('Sửa'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                context.isDesktop ? 1000 : double.infinity,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _buildInfoItem(
                                  context,
                                  age == 0 ? '-' : '$age',
                                  'Tuổi',
                                ),
                                _buildInfoItem(
                                  context,
                                  user?.weight == null
                                      ? '-'
                                      : '${user!.weight}kg',
                                  'Cân nặng',
                                ),
                                _buildInfoItem(
                                  context,
                                  user?.height == null
                                      ? '-'
                                      : '${user!.height}cm',
                                  'Chiều cao',
                                ),
                                _buildInfoItem(context, bmiStr, 'BMI'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: label != 'Tuổi'
              ? Border(
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: context.fs(14),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: context.fs(9),
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
