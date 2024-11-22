import 'package:health/health.dart';

interface class HearthRate {
  final int bpm;
  final DateTime startTime;
  final DateTime endTime;

  HearthRate(
      {required this.bpm, required this.startTime, required this.endTime});
}

interface class Activity extends ActivityPreview {
  final List<HearthRate> heartRates;

  const Activity(this.heartRates,
      {required super.distance,
      required super.activityType,
      required super.caloriesBurnt,
      required super.start,
      required super.end,
      required super.sourceId});
}

interface class ActivityPreview {
  final HealthWorkoutActivityType activityType;
  final int caloriesBurnt;
  final double distance;
  final DateTime start;
  final DateTime end;
  final String sourceId;

  const ActivityPreview(
      {required this.activityType,
      required this.caloriesBurnt,
      required this.distance,
      required this.start,
      required this.end,
      required this.sourceId});

  int getDuration() {
    return start.difference(end).inMinutes;
  }
}
