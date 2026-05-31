import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriscan/core/services/notification_service.dart';
import 'package:nutriscan/providers/api_provider.dart';
import 'package:nutriscan/providers/user_provider.dart';
import 'notification_state.dart';

class NotificationController extends AutoDisposeNotifier<NotificationState> {
  @override
  NotificationState build() {
    // Tự động đồng bộ trạng thái ban đầu dựa vào User Profile từ Server
    final user = ref.watch(userProfileProvider).valueOrNull;
    return NotificationState(
      notifyMeal: user?.notifyMeal ?? true,
      notifyWeekly: user?.notifyWeekly ?? true,
      notifyAlert: user?.notifyAlert ?? true,
    );
  }

  Future<void> toggleNotifyMeal(bool value) async {
    state = state.copyWith(notifyMeal: value);
    final userService = ref.read(userServiceProvider);
    await userService.updateProfile({'notify_meal': value});
    ref.invalidate(userProfileProvider);

    if (!value) {
      await NotificationService().cancelMealReminders();
    }
  }

  Future<void> toggleNotifyWeekly(bool value) async {
    state = state.copyWith(notifyWeekly: value);
    final userService = ref.read(userServiceProvider);
    await userService.updateProfile({'notify_weekly': value});
    ref.invalidate(userProfileProvider);

    if (value) {
      await NotificationService().scheduleWeeklySummaryBait();
    } else {
      await NotificationService().cancelWeeklySummary();
    }
  }

  Future<void> toggleNotifyAlert(bool value) async {
    state = state.copyWith(notifyAlert: value);
    final userService = ref.read(userServiceProvider);
    await userService.updateProfile({'notify_alert': value});
    ref.invalidate(userProfileProvider);
  }

  Future<void> saveMealReminders({
    required TimeOfDay breakfast,
    required TimeOfDay lunch,
    required TimeOfDay dinner,
    required TimeOfDay snack,
  }) async {
    // Bật trạng thái quay mòng mòng
    state = state.copyWith(isSaving: true);

    try {
      // Controller gọi Service, không cho UI gọi nữa
      await NotificationService().scheduleDailyMealReminders(
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snack: snack,
      );
    } finally {
      // Xong việc thì tắt quay mòng mòng
      state = state.copyWith(isSaving: false);
    }
  }
}

final notificationControllerProvider =
    AutoDisposeNotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);
