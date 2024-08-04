import 'package:health/health.dart';

interface class Data<T> {
  final T value;
  final DateTime startTime;
  final DateTime endTime;

  Data({required this.value, required this.startTime, required this.endTime});
}

interface class Activity extends ActivityPreview {
  final List<Data<int>>? heartRates;
  final List<Data<double>>? speed;

  const Activity({
    required super.distance,
    required super.activityType,
    required super.caloriesBurnt,
    required super.start,
    required super.end,
    this.heartRates,
    this.speed,
  });
}

interface class ActivityPreview {
  final HealthWorkoutActivityType activityType;
  final int caloriesBurnt;
  final double distance;
  final DateTime start;
  final DateTime end;

  const ActivityPreview(
      {required this.activityType,
      required this.caloriesBurnt,
      required this.distance,
      required this.start,
      required this.end});

  int getDuration() {
    return start.difference(end).inMinutes.abs();
  }

  // Factory constructor to create an instance from a JSON map
  factory ActivityPreview.fromJson(Map<String, dynamic> json) {
    return ActivityPreview(
      activityType: HealthWorkoutActivityType.WALKING,
      caloriesBurnt: json['caloriesBurnt'],
      distance: json['distance'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityType': "",
      'caloriesBurnt': caloriesBurnt,
      'distance': distance,
      'start': start.toIso8601String(), // Convert DateTime to ISO8601 string
      'end': end.toIso8601String(), // Convert DateTime to ISO8601 string
    };
  }
}
