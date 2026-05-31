import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriscan/core/services/notification_service.dart';
import '../../../theme/app_theme.dart';
import 'settings_components.dart';
import '../../profile_controller/notification_controller.dart';

class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  Future<void> _showMealReminderSheet(BuildContext context) async {
    final service = NotificationService();
    final saved = await service.loadSavedMealTimes();

    var breakfast = saved['breakfast']!;
    var lunch = saved['lunch']!;
    var dinner = saved['dinner']!;
    var snack = saved['snack']!;

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<TimeOfDay?> pickTime(TimeOfDay initial) =>
              showTimePicker(context: ctx, initialTime: initial);

          Widget mealRow(String label, TimeOfDay time,
              Future<void> Function(TimeOfDay) onPicked) {
            return ListTile(
              title: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  final picked = await pickTime(time);
                  if (picked != null) await onPicked(picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Giờ nhắc nhở',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                mealRow(
                  '🌅 Bữa sáng',
                  breakfast,
                  (t) async => setSheetState(() => breakfast = t),
                ),
                mealRow(
                  '☀️ Bữa trưa',
                  lunch,
                  (t) async => setSheetState(() => lunch = t),
                ),
                mealRow(
                  '🌙 Bữa tối',
                  dinner,
                  (t) async => setSheetState(() => dinner = t),
                ),
                mealRow(
                  '🍎 Ăn vặt',
                  snack,
                  (t) async => setSheetState(() => snack = t),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Consumer(
                    builder: (context, ref, child) {
                      // Lắng nghe trạng thái từ Controller
                      final isSaving =
                          ref.watch(notificationControllerProvider).isSaving;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: isSaving ? null : () async {
                          await ref.read(notificationControllerProvider.notifier).saveMealReminders(
                            breakfast: breakfast,
                            lunch: lunch,
                            dinner: dinner,
                            snack: snack,
                          );
                          // Đóng BottomSheet và hiện thông báo
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã lưu giờ nhắc nhở!'),
                                  backgroundColor: AppColors.primaryMid),
                            );
                          }
                        },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Lưu cài đặt'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ lắng nghe và đọc trạng thái từ Controller duy nhất
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    return Column(
      children: [
        ToggleRow(
          icon: Icons.notifications_outlined,
          iconbg: AppColors.primaryLight,
          iconcolor: AppColors.primary,
          title: 'Nhắc ghi bữa ăn',
          sub: 'Sáng 7h · Trưa 12h · Tối 18h',
          value: state.notifyMeal,
          onChanged: (v) async {
            await controller.toggleNotifyMeal(v);
            if (v && context.mounted) {
              // Nếu bật thì kích hoạt hiện Sheet chọn giờ từ UI
              await _showMealReminderSheet(context);
            }
          },
        ),
        ToggleRow(
          icon: Icons.auto_awesome_outlined,
          iconbg: AppColors.primaryLight,
          iconcolor: AppColors.primary,
          title: 'Tổng kết tuần AI',
          sub: 'Mỗi Chủ nhật lúc 20h',
          value: state.notifyWeekly,
          onChanged: controller.toggleNotifyWeekly,
        ),
        ToggleRow(
          icon: Icons.warning_amber_outlined,
          iconbg: const Color(0xFFFAEEDA),
          iconcolor: AppColors.warning,
          title: 'Cảnh báo vượt calo',
          sub: 'Khi đạt 90% mục tiêu',
          value: state.notifyAlert,
          onChanged: controller.toggleNotifyAlert,
        ),
      ],
    );
  }
}
