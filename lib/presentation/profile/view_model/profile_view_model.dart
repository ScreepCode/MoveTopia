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
      final themeMode = await _repository.getThemeMode();
      final installationDate = await _repository.getInstallationDate();
      final lastUpdated = await _repository.getLastUpdated();
      final dailyExerciseMinutesGoal =
          await _repository.getDailyExerciseMinutesGoal();
      final weeklyExerciseMinutesGoal =
          await _repository.getWeeklyExerciseMinutesGoal();

      state = state.copyWith(
        stepGoal: stepGoal,
        themeMode: themeMode,
        installationDate: installationDate,
        lastUpdated: lastUpdated,
        dailyExerciseMinutesGoal: dailyExerciseMinutesGoal,
        weeklyExerciseMinutesGoal: weeklyExerciseMinutesGoal,
      );

      logger.info('Profile settings loaded');
    } catch (e, s) {
      logger.severe('Error loading profile settings', e, s);
    }
  }

  int get stepGoal => state.stepGoal;

  AppThemeMode get themeMode => state.themeMode;

  DateTime get installationDate => state.installationDate;

  DateTime get lastUpdated => state.lastUpdated;

  int get dailyExerciseMinutesGoal => state.dailyExerciseMinutesGoal;

  int get weeklyExerciseMinutesGoal => state.weeklyExerciseMinutesGoal;

  void setStepGoal(int stepGoal) async {
    await _repository.saveStepGoal(stepGoal);
    state = state.copyWith(stepGoal: stepGoal);
  }

  void setThemeMode(AppThemeMode themeMode) async {
    await _repository.saveThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  void setInstallationDate(DateTime date) async {
    await _repository.saveInstallationDate(date);
    state = state.copyWith(installationDate: date);
  }

  void setLastUpdated(DateTime date) async {
    await _repository.saveLastUpdated(date);
    state = state.copyWith(lastUpdated: date);
  }

  void setDailyExerciseMinutesGoal(int minutes) async {
    await _repository.saveDailyExerciseMinutesGoal(minutes);
    state = state.copyWith(dailyExerciseMinutesGoal: minutes);
  }

  void setWeeklyExerciseMinutesGoal(int minutes) async {
    await _repository.saveWeeklyExerciseMinutesGoal(minutes);
    state = state.copyWith(weeklyExerciseMinutesGoal: minutes);
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
