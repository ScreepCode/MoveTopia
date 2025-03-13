import 'package:logging/logging.dart';
import 'package:movetopia/data/repositories/profile_repository_impl.dart';
import 'package:movetopia/domain/repositories/profile_repository.dart';
import 'package:riverpod/riverpod.dart';

import 'profile_state.dart';

final logger = Logger('ProfileViewModel');

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final profileProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileViewModel(repository);
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) : super(ProfileState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final stepGoal = await _repository.loadSetting('stepGoal');
      final count = await _repository.loadSetting('count');
      final isDarkMode = await _repository.loadSetting('isDarkMode');

      state = state.copyWith(
        stepGoal: stepGoal ?? state.stepGoal,
        count: count ?? state.count,
        isDarkMode: isDarkMode ?? state.isDarkMode,
      );

      logger.info('Profile settings loaded');
    } catch (e, s) {
      logger.severe('Error loading profile settings', e, s);
    }
  }

  int get stepGoal => state.stepGoal;

  int get count => state.count;

  bool get isDarkMode => state.isDarkMode;

  void setStepGoal(int stepGoal) async {
    await _repository.saveSetting('stepGoal', stepGoal);
    state = state.copyWith(stepGoal: stepGoal);
  }

  void incrementCount() async {
    final newCount = state.count + 1;
    await _repository.saveSetting('count', newCount);
    state = state.copyWith(count: newCount);
  }

  void setIsDarkMode(bool isDarkMode) async {
    await _repository.saveSetting('isDarkMode', isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }
}
