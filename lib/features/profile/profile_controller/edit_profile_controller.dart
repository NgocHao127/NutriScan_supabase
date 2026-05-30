import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_state.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/api_provider.dart';

class EditProfileController extends AutoDisposeNotifier<EditProfileState> {
  @override
  EditProfileState build() {
    Future.microtask(() => loadProfile());
    return const EditProfileState();
  }

  // ── Load profile ─────────────────────────────────────────
  Future<void> loadProfile() async {
    state = state.copyWith(status: EditProfileStatus.loading);
    try {
      final userAsync = ref.read(userProfileProvider);
      final user = userAsync is AsyncData
          ? userAsync.value
          : await ref.read(userProfileProvider.future);

      if (user != null) {
        state = EditProfileState(
          status: EditProfileStatus.idle,
          selectedGender: user.gender,
          selectedGoal: user.goal,
          selectedActivity: user.activityLevel,
          selectedBodyShape: user.bodyShape,
        );
      } else {
        state = state.copyWith(status: EditProfileStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(status: EditProfileStatus.idle);
    }
  }

  // ── Cập nhật selections ──────────────────────────────────
  void selectGender(String? v) => state = state.copyWith(selectedGender: v);
  void selectGoal(String? v) => state = state.copyWith(selectedGoal: v);
  void selectActivity(String? v) => state = state.copyWith(selectedActivity: v);
  void selectBodyShape(String? v) =>
      state = state.copyWith(selectedBodyShape: v);

  // ── Validate ─────────────────────────────────────────────
  bool validate(String name, String age, String height, String weight) {
    if (name.trim().isEmpty) {
      state = state.copyWith(nameError: 'Vui lòng nhập họ tên');
      return false;
    }
    if (age.trim().isEmpty || height.trim().isEmpty || weight.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'Vui lòng nhập đầy đủ tuổi, chiều cao và cân nặng',
      );
      return false;
    }
    if (state.selectedGender == null ||
        state.selectedGoal == null ||
        state.selectedActivity == null) {
      state = state.copyWith(
        errorMessage: 'Vui lòng chọn giới tính, mục tiêu và mức độ hoạt động',
      );
      return false;
    }
    state = state.copyWith(
      clearNameError: true,
      errorMessage: null,
    );
    return true;
  }

  // ── Save ─────────────────────────────────────────────────
  Future<bool> save({
    required String name,
    required String age,
    required String height,
    required String weight,
  }) async {
    if (!validate(name, age, height, weight)) return false;

    state = state.copyWith(status: EditProfileStatus.saving);
    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateProfile({
        'name': name.trim(),
        'age': int.tryParse(age) ?? 0,
        'height': double.tryParse(height) ?? 0.0,
        'weight': double.tryParse(weight) ?? 0.0,
        'gender': state.selectedGender,
        'goal': state.selectedGoal,
        'activity_level': state.selectedActivity,
        'body_shape': state.selectedBodyShape,
      });

      ref.invalidate(userProfileProvider);
      state = state.copyWith(status: EditProfileStatus.saved);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Lỗi kết nối. Không thể lưu!',
      );
      return false;
    }
  }
}

final editProfileControllerProvider =
    AutoDisposeNotifierProvider<EditProfileController, EditProfileState>(
  EditProfileController.new,
);
