import 'package:hackathon/data/model/activity.dart';
import 'package:hackathon/domain/repositories/local_health.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';

final localHealthRepositoryProvider =
    Provider<LocalHealthRepository>((ref) => LocalHealthRepoImpl());

interface class LocalHealthRepoImpl extends LocalHealthRepository {
  final log = Logger('LocalHealthRepoImpl');

  Future<List<HealthDataPoint>?> getHealthDataInInterval(
      DateTime start, DateTime end, List<HealthDataType> types) async {
    try {
      _compareDate(start, end);

      List<HealthDataPoint> dataPoint = await Health()
          .getHealthDataFromTypes(types: types, startTime: start, endTime: end);
      return dataPoint;
    } catch (e) {
      log.info(e);
    }
    return null;
  }

  /// Get the total steps taken in the given interval
  @override
  Future<int> getStepsInInterval(DateTime start, DateTime end) async {
    log.info('Started fetching steps!');

    try {
      _compareDate(start, end);

      int? steps = await Health().getTotalStepsInInterval(start, end);
      log.info("Steps taken in interval: $steps");

      return steps ?? -1;
    } catch (e) {
      log.info(e);
      return -1;
    }
  }

  /// Get the total distance covered in the given interval
  @override
  Future<double> getDistanceInInterval(
      DateTime start, DateTime end, List<HealthDataType> distanceTypes) async {
    try {
      var distances = await getHealthDataInInterval(
          start, end, [HealthDataType.DISTANCE_DELTA]);
      double combinedDistance = 0;
      for (var data in distances!) {
        combinedDistance +=
            NumericHealthValue.fromJson(data.value.toJson()).numericValue;
      }
      return combinedDistance / 1000;
    } catch (e) {
      //log.info(e);
      return -1;
    }
  }

  /// Get the sleep data
  @override
  Future<int> getSleepFromDate(DateTime date) async {
    try {
      var sleep = await getHealthDataInInterval(date,
          date.add(const Duration(days: 3)), [HealthDataType.SLEEP_SESSION]);

      if (sleep!.isEmpty) return 0;
      return NumericHealthValue.fromJson(sleep[0].value.toJson())
          .numericValue
          .toInt();
    } catch (e) {
      log.info(e);
      return -1;
    }
  }

  @override
  Future<int> getCaloriesBurnedInInterval(DateTime start, DateTime end) async {
    try {
      var calories = await getHealthDataInInterval(
          start, end, [HealthDataType.TOTAL_CALORIES_BURNED]);
      if (calories == null || calories.isEmpty) return 0;
      int totalCalories = 0;
      for (var i = 0; i < calories.length; i++) {
        totalCalories +=
            (calories[i].value as NumericHealthValue).numericValue.toInt();
      }
      return totalCalories;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<List<ActivityPreview>?> getActivities(
      DateTime start, DateTime end) async {
    try {
      var rawWorkouts =
          await getHealthDataInInterval(start, end, [HealthDataType.WORKOUT]);
      List<ActivityPreview> parsedWorkouts = List.empty(growable: true);
      for (var i = 0; i < rawWorkouts!.length; i++) {
        var current = rawWorkouts[i];
        WorkoutHealthValue healthValue = current.value as WorkoutHealthValue;
        var calories =
            await getCaloriesBurnedInInterval(current.dateFrom, current.dateTo);
        ActivityPreview preview = ActivityPreview(
            activityType: healthValue.workoutActivityType,
            caloriesBurnt: calories,
            start: current.dateFrom,
            end: current.dateTo,
            distance: healthValue.totalDistance != null
                ? (healthValue.totalDistance! / 1000).toDouble()
                : 0.0);
        parsedWorkouts.add(preview);
      }
      return parsedWorkouts;
    } catch (e) {
      log.info(e);
    }
    return null;
  }

  @override
  Future<Activity?> getActivityDetailed(ActivityPreview preview) async {
    try {
      List<HealthDataPoint>? data = await getHealthDataInInterval(
          preview.start, preview.end, [HealthDataType.WORKOUT]);

      List<HealthDataPoint>? heartFrequency = await getHealthDataInInterval(
          preview.start, preview.end, [HealthDataType.HEART_RATE]);
      if (data!.isEmpty || heartFrequency!.isEmpty) return null;
      log.info(heartFrequency.length);
      List<Data<int>> heartRates = List.empty(growable: true);
      for (var value in heartFrequency) {
        heartRates.add(Data(
            value: (value.value as NumericHealthValue).numericValue.toInt(),
            startTime: value.dateFrom,
            endTime: value.dateTo));
      }

      return Activity(
          caloriesBurnt: preview.caloriesBurnt,
          distance: preview.distance,
          end: preview.end,
          start: preview.start,
          activityType: preview.activityType,
          heartRates: heartRates);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ActivityPreview?> getLastActivity() async {
    try {
      var workouts = await getHealthDataInInterval(
          DateTime.now().subtract(const Duration(days: 3)), DateTime.now(), [
        HealthDataType.WORKOUT,
      ]);
      if (workouts == null || workouts.isEmpty) {
        return null;
      } else {
        var lastWorkout = workouts.last;
        WorkoutHealthValue healthValue =
            lastWorkout.value as WorkoutHealthValue;
        int calories = await getCaloriesBurnedInInterval(
            lastWorkout.dateFrom, lastWorkout.dateTo);
        return ActivityPreview(
            activityType: healthValue.workoutActivityType,
            caloriesBurnt: calories,
            start: lastWorkout.dateFrom,
            end: lastWorkout.dateTo,
            distance: (healthValue.totalDistance ?? 0).toDouble());
      }
    } catch (e) {
      log.info(e);
    }
    return null;
  }

  bool _compareDate(DateTime start, DateTime end) {
    if (start.compareTo(end) < 0) {
      return true;
    } else {
      throw Exception("Start date is greater than end date");
    }
  }
}
