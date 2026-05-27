import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_responsive.dart';

import '../../../models/daily_record_model.dart';

// Đổi tên thành HomeSliverAppBar để phân biệt
class HomeSliverAppBar extends StatelessWidget {
  final String userName;
  final DailyRecordModel? record;

  const HomeSliverAppBar({
    super.key,
    required this.userName,
    this.record,
  });

  @override
  Widget build(BuildContext context) {
    // Chiều cao khi mở rộng toàn bộ (chứa cả lời chào + Vòng Calo)
    final expandedHeight = context.isTablet || context.isDesktop
        ? 220.0
        : 250.0;

    return SliverAppBar(
      automaticallyImplyLeading: false, // THÊM DÒNG NÀY ĐỂ TẮT MŨI TÊN TỰ ĐỘNG
      expandedHeight: expandedHeight,
      pinned: true, // Ghim thanh màu xanh lại ở trên cùng khi cuộn xuống
      backgroundColor: AppColors.primary,
      elevation: 0,

      // FlexibleSpaceBar tạo hiệu ứng thu nhỏ và mờ dần (parallax) cực mượt
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.hPad, 12, context.hPad, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào buổi sáng',
                  style: TextStyle(
                    fontSize: context.fs(12),
                    color: AppColors.onPrimary,
                  ),
                ),

                const SizedBox(height: 2),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: context.fs(18),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),
                // Vòng CaloRingBow sẽ cuộn đi và mờ dần khi vuốt danh sách lên
                CaloRingBow(record: record),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CaloRingBow extends StatelessWidget {
  final DailyRecordModel? record;

  const CaloRingBow({
    super.key,
    this.record,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = context.caloRingSize;

    // Tính toán số liệu an toàn
    final consumed = record?.caloriesConsumed ?? 0.0;
    final goal = record?.caloriesGoal ?? 2000.0;
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(context.cardRadius + 2),
      ),

      child: Row(
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${consumed.toInt()}',
                style: TextStyle(
                  fontSize: context.fs(11),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                '${goal.toInt()}',
                style: TextStyle(
                  fontSize: context.fs(8),
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dinh dưỡng hôm nay',
                  style: TextStyle(
                    fontSize: context.fs(11),
                    color: AppColors.onPrimary,
                  ),
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    // Tạm thời để 0g vì bảng meal_entries của ta tập trung vào Calo trước
                    MiniMacro(
                      value: '${(record?.protein ?? 0).toStringAsFixed(0)}g',
                      label: 'Protein',
                    ),

                    SizedBox(width: 6),
                    MiniMacro(
                      value: '${(record?.carbs ?? 0).toStringAsFixed(0)}g',
                      label: 'Carb',
                    ),

                    SizedBox(width: 6),
                    MiniMacro(
                      value: '${(record?.fat ?? 0).toStringAsFixed(0)}g',
                      label: 'Fat',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniMacro extends StatelessWidget {
  final String value;
  final String label;
  
  const MiniMacro({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: context.fs(12),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
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
