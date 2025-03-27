class ProfileState {
  final int stepGoal;
  final bool isDarkMode;
  final DateTime installationDate;
  final DateTime lastUpdated;

  ProfileState({
    this.stepGoal = 5000,
    this.isDarkMode = false,
    DateTime? installationDate,
    DateTime? lastUpdated,
  })  : installationDate = installationDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  ProfileState copyWith({
    int? stepGoal,
    bool? isDarkMode,
    DateTime? installationDate,
    DateTime? lastUpdated,
  }) {
    return ProfileState(
      stepGoal: stepGoal ?? this.stepGoal,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      installationDate: installationDate ?? this.installationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
