enum WeeklyStatus { loading, loaded }

class WeeklyState {
  final WeeklyStatus status;
  final List<int> cals; // 7 phần tử, index = weekday-1
  final int avgCals;
  final int avgProtein;
  final int daysOverGoal;
  final int goal;
  final int proteinGoal;

  const WeeklyState({
    this.status = WeeklyStatus.loading,
    this.cals = const [0, 0, 0, 0, 0, 0, 0],
    this.avgCals = 0,
    this.avgProtein = 0,
    this.daysOverGoal = 0,
    this.goal = 2000,
    this.proteinGoal = 70,
  });

  bool get isLoading => status == WeeklyStatus.loading;

  WeeklyState copyWith({
    WeeklyStatus? status,
    List<int>? cals,
    int? avgCals,
    int? avgProtein,
    int? daysOverGoal,
    int? goal,
    int? proteinGoal,
  }) {
    return WeeklyState(
      status: status ?? this.status,
      cals: cals ?? this.cals,
      avgCals: avgCals ?? this.avgCals,
      avgProtein: avgProtein ?? this.avgProtein,
      daysOverGoal: daysOverGoal ?? this.daysOverGoal,
      goal: goal ?? this.goal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
    );
  }
}
