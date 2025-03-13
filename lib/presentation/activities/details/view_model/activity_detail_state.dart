import 'dart:typed_data';

import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';

class ActivityDetailState {
  Activity activity;
  Uint8List icon;
  bool isLoading;
  final log = Logger('activityDetailedState');

  ActivityDetailState(
      {required this.activity, required this.isLoading, required this.icon});

  factory ActivityDetailState.initial() {
    return ActivityDetailState(
        activity: Activity(
            distance: 0,
            activityType: HealthWorkoutActivityType.OTHER,
            caloriesBurnt: 0,
            start: DateTime.now(),
            end: DateTime.now(),
            heartRates: [],
            speed: [],
            sourceId: ""),
        isLoading: true,
        icon: Uint8List(0));
  }

  ActivityDetailState copyWith(
      {Activity? newActivity, bool? loading, Uint8List? newIcon}) {
    //if (newIcon == null && icon != null) newIcon = icon;
    return ActivityDetailState(
        activity: newActivity ?? activity,
        isLoading: loading ?? isLoading,
        icon: newIcon ?? icon);
  }

  int getAverageHeartBeat() {
    final heartRates = activity.heartRates;
    if (heartRates != null) {
      double sum = 0;
      heartRates.forEach((e) {
        sum += e.value;
      });
      return (sum / heartRates.length).round();
    }
    return 0;
  }
}
