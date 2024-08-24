class ProfileState {
  final int stepGoal;
  final int count;
  final bool isDarkMode;

  ProfileState({
    this.stepGoal = 5000,
    this.count = 0,
    this.isDarkMode = false,
  });

  ProfileState copyWith({
    int? stepGoal,
    int? count,
    bool? isDarkMode,
  }) {
    return ProfileState(
      stepGoal: stepGoal ?? this.stepGoal,
      count: count ?? this.count,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
