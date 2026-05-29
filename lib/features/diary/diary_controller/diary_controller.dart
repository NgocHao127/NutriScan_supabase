import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'diary_state.dart';
import '../../../providers/api_provider.dart';
import '../../../models/daily_record_model.dart';

class DiaryController extends AutoDisposeNotifier<DiaryState> {
  @override
  DiaryState build() {
    final weekDates = _buildWeekDates();
    final todayIndex = DateTime.now().weekday - 1;
    // Fetch sau frame đầu
    Future.microtask(() => _fetchForIndex(weekDates, todayIndex));
    return DiaryState(
      weekDates: weekDates,
      selectedIndex: todayIndex,
      status: DiaryStatus.loading,
    );
  }

  // ── Tính 7 ngày trong tuần ────────────────────────────────
  List<DateTime> _buildWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // ── Chọn ngày ────────────────────────────────────────────
  void selectDay(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(
      selectedIndex: index,
      status: DiaryStatus.loading,
    );
    _fetchForIndex(state.weekDates, index);
  }

  // ── Fetch data cho ngày được chọn ────────────────────────
  Future<void> _fetchForIndex(List<DateTime> dates, int index) async {
    state = state.copyWith(status: DiaryStatus.loading);
    try {
      final mealService = ref.read(mealServiceProvider);
      final selectedDate = dates[index];
      final data = await mealService.getDailyRecord(
        date: selectedDate.toIso8601String().substring(0, 10),
      );
      if (data.isNotEmpty) {
        final record = DailyRecordModel.fromJson(data);
        state = state.copyWith(
          status: DiaryStatus.loaded,
          currentRecord: record,
          currentMeals: record.meals,
        );
      } else {
        state = state.copyWith(
          status: DiaryStatus.loaded,
          clearRecord: true,
          currentMeals: [],
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: DiaryStatus.loaded,
        clearRecord: true,
        currentMeals: [],
      );
    }
  }

  // ── Refresh sau khi thêm bữa ─────────────────────────────
  Future<void> refresh() async {
    await _fetchForIndex(state.weekDates, state.selectedIndex);
  }
}

final diaryControllerProvider =
    AutoDisposeNotifierProvider<DiaryController, DiaryState>(
  DiaryController.new,
);
