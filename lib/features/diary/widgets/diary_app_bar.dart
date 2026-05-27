import 'package:flutter/material.dart';
import '../../theme/app_responsive.dart';
import '../../theme/app_theme.dart';

class DiaryAppBar extends StatelessWidget {
  final List<DateTime> weekDates;
  final int selectedIndex;
  final Function(int) onDaySelected;

  const DiaryAppBar({
    super.key,
    required this.weekDates,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final selectedDates = weekDates[selectedIndex];

    // Check xem ngày đang chọn có phải hôm nay không
    final now = DateTime.now();
    final isToday = selectedDates.year == now.year &&
      selectedDates.month == now.month &&
      selectedDates.day == now.day;

    final dateString = '${selectedDates.day}/${selectedDates.month}';
    final headerText = isToday ? 'Hôm nay, $dateString' : '${days[selectedIndex]}, $dateString';

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        context.hPad,
        MediaQuery.of(context).padding.top + 12,
        context.hPad,
        12,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhật ký',
                style: TextStyle(
                  fontSize: context.fs(16),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              Row(
                children: [
                  NavBtn(icon: Icons.chevron_left),

                  const SizedBox(width: 8),
                  Text(
                    headerText,
                    style: TextStyle(
                      fontSize: context.fs(12),
                      color: AppColors.onPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),
                  NavBtn(icon: Icons.chevron_right),
                ],
              ),
            ],
          ),

          // Week picker: giới hạn chiều rộng trên tablet/desktop
          // tránh bị dãn ra quá rộng và trông lạ
          const SizedBox(height: 10),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isMobile ? double.infinity : 480,
              ),
              child: Row(
                children: List.generate(7, (i) {
                  final isSelected = i == selectedIndex;
                  final currentDateStr = weekDates[i].day.toString();

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDaySelected(i),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              days[i],
                              style: TextStyle(
                                fontSize: context.fs(9),
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),

                            const SizedBox(height: 3),
                            Text(
                              currentDateStr,
                              style: TextStyle(
                                fontSize: context.fs(12),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: i < 5
                                    ? AppColors.primaryAccent
                                    : Colors.transparent, // Chỉ hiện chấm cho ngày đang chọn
                                    // : Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBtn extends StatelessWidget {
  final IconData icon;

  const NavBtn({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final size = context.iconSize(24, tablet: 28, desktop: 32);
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size * 0.6, color: Colors.white),
      ),
    );
  }
}
