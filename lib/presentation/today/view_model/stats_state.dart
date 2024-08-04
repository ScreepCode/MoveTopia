class StatsState {
  int steps;
  double distance;
  int sleep;

  StatsState(
      {required this.steps, required this.distance, required this.sleep});

  factory StatsState.initial() {
    return StatsState(steps: 0, distance: 0.0, sleep: 0);
  }

  StatsState copyWith({int? steps, double? distance, int? sleep}) {
    return StatsState(
        steps: steps ?? this.steps,
        distance: distance ?? this.distance,
        sleep: sleep ?? this.sleep);
  }
}
