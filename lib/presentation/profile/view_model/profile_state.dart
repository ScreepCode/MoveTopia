class ProfileState {
  final int stepGoal;
  final bool isDarkMode;

  ProfileState({
    this.stepGoal = 5000,
    this.isDarkMode = false,
  });

  ProfileState copyWith({
    int? stepGoal,
    bool? isDarkMode,
  }) {
    return ProfileState(
      stepGoal: stepGoal ?? this.stepGoal,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
