import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

class LastActivityState {
  ActivityPreview activityPreview;

  LastActivityState({required this.activityPreview});

  factory LastActivityState.initial() {
    return LastActivityState(
        activityPreview: ActivityPreview(
            activityType: HealthWorkoutActivityType.OTHER,
            caloriesBurnt: 0,
            distance: 0,
            start: DateTime.now(),
            end: DateTime.now(),
            sourceId: ""));
  }

  LastActivityState copyWith({ActivityPreview? newActivityPreview}) {
    return LastActivityState(
        activityPreview: newActivityPreview ?? activityPreview);
  }
}
