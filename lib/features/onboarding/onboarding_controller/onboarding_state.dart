class OnboardingState {
  final int currentPage;
  final bool isDone;

  const OnboardingState({
    this.currentPage = 0,
    this.isDone = false,
  });

  bool get isLastPage => currentPage == 2;

  OnboardingState copyWith({int? currentPage, bool? isDone}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isDone: isDone ?? this.isDone,
    );
  }
}
