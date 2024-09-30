import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

class LastActivityState {
  String date;
  int duration;
  String comment;
  HealthWorkoutActivityType activityType;
  int calories;

  LastActivityState(
      {required this.date,
      required this.duration,
      required this.comment,
      required this.activityType,
      required this.calories});

  factory LastActivityState.initial() {
    return LastActivityState(
        date: "1970-01-01",
        duration: 0,
        comment: "",
        activityType: HealthWorkoutActivityType.OTHER,
        calories: 0);
  }

  LastActivityState copyWith(
      {String? date,
      int? duration,
      String? comment,
      HealthWorkoutActivityType? activityType,
      int? calories}) {
    return LastActivityState(
        date: date ?? this.date,
        duration: duration ?? this.duration,
        comment: comment ?? this.comment,
        activityType: activityType ?? this.activityType,
        calories: calories ?? this.calories);
  }

  // Add a getter to return the ActivityPreview
  ActivityPreview get activityPreview => ActivityPreview(
        activityType: activityType,
        caloriesBurnt: calories,
        distance: 0.0, // You might need to add distance to LastActivityState
        start: DateTime.now().subtract(Duration(minutes: duration)),
        end: DateTime.now(),
      );
}
