import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriscan/core/services/notification_service.dart';
import 'package:nutriscan/providers/api_provider.dart';
import 'package:nutriscan/providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import 'settings_components.dart';

class NotificationSection extends ConsumerStatefulWidget {
  const NotificationSection({super.key});

  @override
  ConsumerState<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends ConsumerState<NotificationSection> {
  bool _notifyMeal = true;
  bool _notifyWeekly = true;
  bool _notifyAlert = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).valueOrNull;
      if (user != null) {
        setState(() {
          _notifyMeal = user.notifyMeal ?? true;
          _notifyWeekly = user.notifyWeekly ?? true;
          _notifyAlert = user.notifyAlert ?? true;
        });
      }
    });
  }

  Future<void> _showMealReminderSheet() async {
    final service = NotificationService();
    final saved = await service.loadSavedMealTimes();

    var breakfast = saved['breakfast']!;
    var lunch = saved['lunch']!;
    var dinner = saved['dinner']!;
    var snack = saved['snack']!;

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<TimeOfDay?> pickTime(TimeOfDay initial) =>
              showTimePicker(context: ctx, initialTime: initial);

          Widget mealRow(
            String label,
            TimeOfDay time,
            Future<void> Function(TimeOfDay) onPicked,
          ) {
            return ListTile(
              title: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
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
                      color: AppColors.primary,
                    ),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                const Text('Giờ nhắc nhở',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                mealRow('🌅 Bữa sáng', breakfast, (t) async {
                  setSheetState(() => breakfast = t);
                }),
                mealRow('☀️ Bữa trưa', lunch, (t) async {
                  setSheetState(() => lunch = t);
                }),
                mealRow('🌙 Bữa tối', dinner, (t) async {
                  setSheetState(() => dinner = t);
                }),
                mealRow('🍎 Ăn vặt', snack, (t) async {
                  setSheetState(() => snack = t);
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await service.scheduleDailyMealReminders(
                        breakfast: breakfast,
                        lunch: lunch,
                        dinner: dinner,
                        snack: snack,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu giờ nhắc nhở!'),
                            backgroundColor: AppColors.primaryMid,
                          ),
                        );
                      }
                    },
                    child: const Text('Lưu cài đặt'),
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleRow(
          icon: Icons.notifications_outlined,
          iconbg: AppColors.primaryLight,
          iconcolor: AppColors.primary,
          title: 'Nhắc ghi bữa ăn',
          sub: 'Sáng 7h · Trưa 12h · Tối 18h',
          value: _notifyMeal,
          onChanged: (v) async {
            setState(() => _notifyMeal = v);
            final userService = ref.read(userServiceProvider);
            await userService.updateProfile({'notify_meal': v});
            ref.invalidate(userProfileProvider);
            if (v) {
              await _showMealReminderSheet();
            } else {
              await NotificationService().cancelMealReminders();
            }
          },
        ),
        ToggleRow(
          icon: Icons.auto_awesome_outlined,
          iconbg: AppColors.primaryLight,
          iconcolor: AppColors.primary,
          title: 'Tổng kết tuần AI',
          sub: 'Mỗi Chủ nhật lúc 20h',
          value: _notifyWeekly,
          onChanged: (v) async {
            setState(() => _notifyWeekly = v);
            final userService = ref.read(userServiceProvider);
            await userService.updateProfile({'notify_weekly': v});
            if (v) {
              await NotificationService().scheduleWeeklySummaryBait();
            } else {
              await NotificationService().cancelWeeklySummary();
            }
          },
        ),
        ToggleRow(
          icon: Icons.warning_amber_outlined,
          iconbg: const Color(0xFFFAEEDA),
          iconcolor: AppColors.warning,
          title: 'Cảnh báo vượt calo',
          sub: 'Khi đạt 90% mục tiêu',
          value: _notifyAlert,
          onChanged: (v) async {
            setState(() => _notifyAlert = v);
            final userService = ref.read(userServiceProvider);
            await userService.updateProfile({'notify_alert': v});
            ref.invalidate(userProfileProvider);
          },
        ),
      ],
    );
  }
}