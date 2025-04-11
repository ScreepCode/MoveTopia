class StatsState {
  int steps;
  double distance;
  int sleep;
  List<int> weeklySteps;
  List<int> weeklySleep;
  int exerciseMinutesToday;
  int exerciseMinutesWeek;

  StatsState({
    required this.steps,
    required this.distance,
    required this.sleep,
    required this.weeklySteps,
    required this.weeklySleep,
    required this.exerciseMinutesToday,
    required this.exerciseMinutesWeek,
  });

  factory StatsState.initial() {
    return StatsState(
      steps: 0,
      distance: 0.0,
      sleep: 0,
      weeklySteps: List.filled(7, 0),
      weeklySleep: List.filled(7, 0),
      exerciseMinutesToday: 0,
      exerciseMinutesWeek: 0,
    );
  }

  StatsState copyWith({
    int? steps,
    double? distance,
    int? sleep,
    List<int>? weeklySteps,
    List<int>? weeklySleep,
    int? exerciseMinutesToday,
    int? exerciseMinutesWeek,
  }) {
    return StatsState(
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      sleep: sleep ?? this.sleep,
      weeklySteps: weeklySteps ?? this.weeklySteps,
      weeklySleep: weeklySleep ?? this.weeklySleep,
      exerciseMinutesToday: exerciseMinutesToday ?? this.exerciseMinutesToday,
      exerciseMinutesWeek: exerciseMinutesWeek ?? this.exerciseMinutesWeek,
    );
  }
}
