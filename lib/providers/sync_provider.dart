import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_entry_model.dart';
import '../core/api_exception.dart';
import 'isar_provider.dart';
import 'api_provider.dart';
import 'connectivity_provider.dart';
import 'today_record_provider.dart';
import 'navigation_provider.dart';

final syncServiceProvider = Provider.autoDispose<SyncService>((ref) {
  final service = SyncService(ref);
  // Đăng ký lắng nghe connectivity ngay khi provider được tạo
  ref.listen(connectivityProvider, (_, connected) {
    if (connected == true) {
      service.syncPending();
    }
  });
  ref.onDispose(() {
    // không cần làm gì, listen tự hủy
  });
  return service;
});

class SyncService {
  final Ref _ref;

  SyncService(this._ref);

  Future<void> syncPending() async {
    final isar = _ref.read(isarProvider);
    final apiService = _ref.read(apiServiceProvider);
    final pending = await isar.getPendingMeals();
    if (pending.isEmpty) return;

    for (var meal in pending) {
      try {
        final response = await apiService.logMeal(
          meal.toJson(),
          meal.updatedAt,
        );
        meal.pendingSync = false;
        meal.updatedAt = response['updated_at']?.toString();
        await isar.saveMeal(meal);
      } on ApiException catch (e) {
        if (e.isConflict && e.payload != null) {
          final serverMeal = MealEntryModel.fromJson(
            Map<String, dynamic>.from(e.payload as Map),
          );
          serverMeal.pendingSync = false;
          await isar.saveMeal(serverMeal);

          // Hiển thị toast
          final navigatorKey = _ref.read(navigatorKeyProvider);
          final context = navigatorKey.currentContext;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dữ liệu đã được cập nhật từ máy chủ'),
              ),
            );
          }
        }
      } catch (_) {
        // Lỗi mạng: giữ pending
      }
    }

    _ref.invalidate(todayRecordProvider);
  }
}
