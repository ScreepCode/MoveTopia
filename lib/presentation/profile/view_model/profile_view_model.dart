import 'package:logging/logging.dart';
import 'package:movetopia/data/repositories/profile_repository_impl.dart';
import 'package:movetopia/domain/repositories/profile_repository.dart';
import 'package:riverpod/riverpod.dart';

import 'profile_state.dart';

final logger = Logger('ProfileViewModel');

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) : super(ProfileState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final stepGoal = await _repository.getStepGoal();
      final isDarkMode = await _repository.getIsDarkMode();

      state = state.copyWith(
        stepGoal: stepGoal,
        isDarkMode: isDarkMode,
      );

      logger.info('Profile settings loaded');
    } catch (e, s) {
      logger.severe('Error loading profile settings', e, s);
    }
  }

  int get stepGoal => state.stepGoal;

  bool get isDarkMode => state.isDarkMode;

  void setStepGoal(int stepGoal) async {
    await _repository.saveStepGoal(stepGoal);
    state = state.copyWith(stepGoal: stepGoal);
  }

  void setIsDarkMode(bool isDarkMode) async {
    await _repository.saveIsDarkMode(isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final profileProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileViewModel(repository);
});
