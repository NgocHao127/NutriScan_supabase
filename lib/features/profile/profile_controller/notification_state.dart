class NotificationState {
  final bool notifyMeal;
  final bool notifyWeekly;
  final bool notifyAlert;
  final bool isSaving;

  const NotificationState({
    this.notifyMeal = true,
    this.notifyWeekly = true,
    this.notifyAlert = true,
    this.isSaving = false,
  });

  NotificationState copyWith({
    bool? notifyMeal,
    bool? notifyWeekly,
    bool? notifyAlert,
    bool? isSaving,
  }) {
    return NotificationState(
      notifyMeal: notifyMeal ?? this.notifyMeal,
      notifyWeekly: notifyWeekly ?? this.notifyWeekly,
      notifyAlert: notifyAlert ?? this.notifyAlert,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
