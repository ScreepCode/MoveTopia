import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

class ActivityDetailState {
  Activity activity;
  bool isLoading;

  ActivityDetailState({required this.activity, required this.isLoading});

  factory ActivityDetailState.initial() {
    return ActivityDetailState(
        activity: Activity(
            distance: 0,
            activityType: HealthWorkoutActivityType.OTHER,
            caloriesBurnt: 0,
            start: DateTime.now(),
            end: DateTime.now(),
            heartRates: [],
            speed: []),
        isLoading: true);
  }

  ActivityDetailState copyWith({Activity? newActivity, bool? loading}) {
    return ActivityDetailState(
        activity: newActivity ?? this.activity,
        isLoading: loading ?? this.isLoading);
  }

  int getAverageHeartBeat() {
    if (activity.heartRates != null && activity.heartRates!.isNotEmpty) {
      double sum = 0;
      activity.heartRates?.forEach((e) {
        sum += e.value;
      });
      return (sum / activity.heartRates!.length).round();
    }
    return 0;
  }
}
