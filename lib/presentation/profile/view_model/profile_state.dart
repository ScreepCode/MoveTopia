import 'package:movetopia/domain/repositories/profile_repository.dart';

class ProfileState {
  final int stepGoal;
  final AppThemeMode themeMode;
  final DateTime installationDate;
  final DateTime lastUpdated;

  ProfileState({
    this.stepGoal = 5000,
    this.themeMode = AppThemeMode.system,
    DateTime? installationDate,
    DateTime? lastUpdated,
  })  : installationDate = installationDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  ProfileState copyWith({
    int? stepGoal,
    AppThemeMode? themeMode,
    DateTime? installationDate,
    DateTime? lastUpdated,
  }) {
    return ProfileState(
      stepGoal: stepGoal ?? this.stepGoal,
      themeMode: themeMode ?? this.themeMode,
      installationDate: installationDate ?? this.installationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
