import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasCompletedOnboarding') ?? false;
});

class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;

  OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState()) {
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    state = state.copyWith(
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    state = state.copyWith(
      hasCompletedOnboarding: true,
    );
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', false);

    state = state.copyWith(
      hasCompletedOnboarding: false,
      currentPage: 2,
    );
  }
}
