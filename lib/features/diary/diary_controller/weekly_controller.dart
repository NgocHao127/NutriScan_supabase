import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weekly_state.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/daily_record_model.dart';

class WeeklyController extends AutoDisposeNotifier<WeeklyState> {
  List<DateTime> _weekDates = [];

  void init(List<DateTime> weekDates) {
    _weekDates = weekDates;
    _fetchWeeklyData(_weekDates);
  }

  @override
  WeeklyState build() => const WeeklyState();

  Future<void> _fetchWeeklyData(List<DateTime> weekDates) async {
    state = state.copyWith(status: WeeklyStatus.loading);

    final mealService = ref.read(mealServiceProvider);
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final proteinGoal = userProfile?.proteinGoal ?? 70;

    final List<DailyRecordModel?> records = [];
    for (final date in weekDates) {
      try {
        final data = await mealService.getDailyRecord(
          date: date.toIso8601String().substring(0, 10),
        );
        records.add(data.isNotEmpty ? DailyRecordModel.fromJson(data) : null);
      } catch (_) {
        records.add(null);
      }
    }

    // ── Tính toán ────────────────────────────────────────
    final cals = List.filled(7, 0);
    int totalWeeklyCals = 0;
    int activeDays = 0;
    double totalProtein = 0;

    // Lấy goal từ record đầu tiên có data, fallback user profile
    int goal = userProfile?.calorieGoal ?? 2000;

    for (final record in records) {
      if (record == null) continue;
      final caloriesGoal = record.caloriesGoal?.toInt();
      if (caloriesGoal != null) goal = caloriesGoal;

      final dayIndex = record.recordDate.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) {
        final consumed = record.caloriesConsumed.toInt();
        cals[dayIndex] = consumed;
        if (consumed > 0) {
          totalWeeklyCals += consumed;
          activeDays++;
          totalProtein += record.protein;
        }
      }
    }

    final avgCals = activeDays > 0 ? (totalWeeklyCals / activeDays).round() : 0;
    final avgProtein = activeDays > 0 ? (totalProtein / activeDays).round() : 0;
    final daysOverGoal = cals.where((c) => c > goal).length;

    state = state.copyWith(
      status: WeeklyStatus.loaded,
      cals: cals,
      avgCals: avgCals,
      avgProtein: avgProtein,
      daysOverGoal: daysOverGoal,
      goal: goal,
      proteinGoal: proteinGoal,
    );
  }
}

final weeklyControllerProvider =
    AutoDisposeNotifierProvider<WeeklyController, WeeklyState>(
  WeeklyController.new,
);
