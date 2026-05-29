import '../../../models/daily_record_model.dart';
import '../../../models/meal_entry_model.dart';

enum DiaryStatus { loading, loaded, error }

class DiaryState {
  final List<DateTime> weekDates;
  final int selectedIndex;
  final DiaryStatus status;
  final DailyRecordModel? currentRecord;
  final List<MealEntryModel> currentMeals;

  const DiaryState({
    this.weekDates = const [],
    this.selectedIndex = 0,
    this.status = DiaryStatus.loading,
    this.currentRecord,
    this.currentMeals = const [],
  });

  bool get isLoading => status == DiaryStatus.loading;

  DiaryState copyWith({
    List<DateTime>? weekDates,
    int? selectedIndex,
    DiaryStatus? status,
    DailyRecordModel? currentRecord,
    List<MealEntryModel>? currentMeals,
    bool clearRecord = false,
  }) {
    return DiaryState(
      weekDates: weekDates ?? this.weekDates,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      status: status ?? this.status,
      currentRecord: clearRecord ? null : currentRecord ?? this.currentRecord,
      currentMeals: currentMeals ?? this.currentMeals,
    );
  }
}
