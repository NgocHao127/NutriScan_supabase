enum EditProfileStatus { loading, idle, saving, saved, error }

class EditProfileState {
  final EditProfileStatus status;
  final String? selectedGender;
  final String? selectedGoal;
  final String? selectedActivity;
  final String? selectedBodyShape;
  final String? nameError;
  final String? errorMessage;

  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.selectedGender,
    this.selectedGoal,
    this.selectedActivity,
    this.selectedBodyShape,
    this.nameError,
    this.errorMessage,
  });

  bool get isLoading => status == EditProfileStatus.loading;
  bool get isSaving => status == EditProfileStatus.saving;
  bool get isSaved => status == EditProfileStatus.saved;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? selectedGender,
    String? selectedGoal,
    String? selectedActivity,
    String? selectedBodyShape,
    String? nameError,
    String? errorMessage,
    bool clearNameError = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedActivity: selectedActivity ?? this.selectedActivity,
      selectedBodyShape: selectedBodyShape ?? this.selectedBodyShape,
      nameError: clearNameError ? null : nameError ?? this.nameError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
