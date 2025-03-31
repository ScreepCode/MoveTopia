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
      final installationDate = await _repository.getInstallationDate();
      final lastUpdated = await _repository.getLastUpdated();

      state = state.copyWith(
        stepGoal: stepGoal,
        isDarkMode: isDarkMode,
        installationDate: installationDate,
        lastUpdated: lastUpdated,
      );

      logger.info('Profile settings loaded');
    } catch (e, s) {
      logger.severe('Error loading profile settings', e, s);
    }
  }

  int get stepGoal => state.stepGoal;

  bool get isDarkMode => state.isDarkMode;

  DateTime get installationDate => state.installationDate;

  DateTime get lastUpdated => state.lastUpdated;

  void setStepGoal(int stepGoal) async {
    await _repository.saveStepGoal(stepGoal);
    state = state.copyWith(stepGoal: stepGoal);
  }

  void setIsDarkMode(bool isDarkMode) async {
    await _repository.saveIsDarkMode(isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  void setInstallationDate(DateTime date) async {
    await _repository.saveInstallationDate(date);
    state = state.copyWith(installationDate: date);
  }

  void setLastUpdated(DateTime date) async {
    await _repository.saveLastUpdated(date);
    state = state.copyWith(lastUpdated: date);
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
