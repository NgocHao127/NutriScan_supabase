import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';
import '../../../providers/onboarding_provider.dart';

class OnboardingController extends AutoDisposeNotifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage() {
    if (state.isLastPage) {
      finish();
    } else {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  Future<void> finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    ref.read(onboardingDoneProvider.notifier).state = true;
    state = state.copyWith(isDone: true);
  }
}

final onboardingControllerProvider =
    AutoDisposeNotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
