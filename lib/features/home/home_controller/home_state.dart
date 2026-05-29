import '../../../models/daily_record_model.dart';
import '../../../models/meal_entry_model.dart';

class HomeState {
  final String userName;
  final DailyRecordModel? record;

  const HomeState({
    this.userName = 'Người dùng',
    this.record,
  });

  int get consumed => record.safeConsumed;
  int get goal => record.safeGoal;
  List<MealEntryModel> get meals => record?.meals ?? [];

  HomeState copyWith({
    String? userName,
    DailyRecordModel? record,
    bool? isRefreshing,
    bool clearRecord = false,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      record: clearRecord ? null : record ?? this.record,
    );
  }
}
