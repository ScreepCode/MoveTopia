import 'package:movetopia/domain/repositories/profile_repository.dart';

class ProfileState {
  final int stepGoal;
  final AppThemeMode themeMode;
  final DateTime installationDate;
  final DateTime lastUpdated;
  final int dailyExerciseMinutesGoal;
  final int weeklyExerciseMinutesGoal;

  // User statistics
  final int lifetimeSteps;
  final double lifetimeDistance;
  final int currentStreak;
  final int badgesEarned;

  ProfileState({
    this.stepGoal = 5000,
    this.themeMode = AppThemeMode.system,
    DateTime? installationDate,
    DateTime? lastUpdated,
    this.dailyExerciseMinutesGoal = 30,
    this.weeklyExerciseMinutesGoal = 150,
    this.lifetimeSteps = 0,
    this.lifetimeDistance = 0.0,
    this.currentStreak = 0,
    this.badgesEarned = 0,
  })  : installationDate = installationDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  ProfileState copyWith({
    int? stepGoal,
    AppThemeMode? themeMode,
    DateTime? installationDate,
    DateTime? lastUpdated,
    int? dailyExerciseMinutesGoal,
    int? weeklyExerciseMinutesGoal,
    int? lifetimeSteps,
    double? lifetimeDistance,
    int? currentStreak,
    int? badgesEarned,
  }) {
    return ProfileState(
      stepGoal: stepGoal ?? this.stepGoal,
      themeMode: themeMode ?? this.themeMode,
      installationDate: installationDate ?? this.installationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      dailyExerciseMinutesGoal:
          dailyExerciseMinutesGoal ?? this.dailyExerciseMinutesGoal,
      weeklyExerciseMinutesGoal:
          weeklyExerciseMinutesGoal ?? this.weeklyExerciseMinutesGoal,
      lifetimeSteps: lifetimeSteps ?? this.lifetimeSteps,
      lifetimeDistance: lifetimeDistance ?? this.lifetimeDistance,
      currentStreak: currentStreak ?? this.currentStreak,
      badgesEarned: badgesEarned ?? this.badgesEarned,
    );
  }
}
