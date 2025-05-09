import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';

class ActivityDetailState {
  Activity activity;
  bool isLoading;
  final log = Logger('activityDetailedState');

  ActivityDetailState({required this.activity, required this.isLoading});

  factory ActivityDetailState.initial() {
    return ActivityDetailState(
      activity: Activity(
        distance: 0,
        activityType: HealthWorkoutActivityType.OTHER,
        caloriesBurnt: 0,
        steps: 0,
        start: DateTime.now(),
        end: DateTime.now(),
        heartRates: [],
        speed: [],
        sourceId: "",
      ),
      isLoading: true,
    );
  }

  ActivityDetailState copyWith({Activity? newActivity, bool? loading}) {
    //if (newIcon == null && icon != null) newIcon = icon;
    return ActivityDetailState(
        activity: newActivity ?? activity, isLoading: loading ?? isLoading);
  }

  int getAverageHeartBeat() {
    final heartRates = activity.heartRates;
    if (heartRates != null && heartRates.isNotEmpty) {
      double sum = 0;
      for (var heartRate in heartRates) {
        sum += heartRate.value;
      }
      return (sum / heartRates.length).round();
    }
    return 0;
  }
}
