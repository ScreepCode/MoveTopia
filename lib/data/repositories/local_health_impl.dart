import 'dart:io';

import 'package:activity_tracking/model/activity.dart' as tracking_activity;
import 'package:activity_tracking/model/activity_type.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/domain/repositories/local_health.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  Future<double> getDistanceInInterval(DateTime start, DateTime end) async {
    var distanceTypes;
    if (Platform.isAndroid) {
      distanceTypes = [HealthDataType.DISTANCE_DELTA];
    } else if (Platform.isIOS) {
      distanceTypes = [HealthDataType.DISTANCE_WALKING_RUNNING];
    } else {
      throw Exception("Unsupported platform");
    }

    try {
      var distances = await getHealthDataInInterval(start, end, distanceTypes);
      double combinedDistance = 0;
      for (var data in distances!) {
        combinedDistance +=
            NumericHealthValue.fromJson(data.value.toJson()).numericValue;
      }
      return combinedDistance;
    } catch (e) {
      //log.info(e);
      return -1;
    }
  }

  /// Get the sleep data
  /// This method returns the actual sleep time, without time spent awake
  @override
  Future<int> getSleepFromDate(DateTime date) async {
    try {
      var sleepHealthValues = await getHealthDataInInterval(date,
          date.add(const Duration(days: 1)), [HealthDataType.SLEEP_SESSION]);
      if (sleepHealthValues!.isEmpty) return 0;

      // Get the times being awake in the period of one sleep cyclus
      var awakeTimeHealthValues = await getHealthDataInInterval(
          sleepHealthValues[0].dateFrom,
          sleepHealthValues[0].dateTo,
          [HealthDataType.SLEEP_AWAKE]);

      var sleepTime =
          NumericHealthValue.fromJson(sleepHealthValues[0].value.toJson())
              .numericValue
              .toInt();
      var awakeTime = 0.0;

      if (awakeTimeHealthValues!.isNotEmpty) {
        for (var value in awakeTimeHealthValues) {
          var time = NumericHealthValue.fromJson(value.value.toJson())
              .numericValue
              .toDouble();
          awakeTime += time;
        }
      }
      return sleepTime - awakeTime.toInt();
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
        ActivityPreview preview = ActivityPreview(
            activityType: healthValue.workoutActivityType,
            caloriesBurnt: 0,
            start: current.dateFrom,
            end: current.dateTo,
            distance: healthValue.totalDistance != null
                ? (healthValue.totalDistance! / 1000).toDouble()
                : 0.0,
            sourceId: current.sourceName);
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
      if (heartFrequency == null) {
        return null;
      }
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
        heartRates: heartRates,
        sourceId: preview.sourceId,
      );
    } catch (e) {
      log.info(e);
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
            distance: (healthValue.totalDistance ?? 0).toDouble(),
            sourceId: lastWorkout.sourceName);
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

  @override
  Future<double> getDistanceOfWorkoutsInInterval(DateTime start, DateTime end,
      List<HealthWorkoutActivityType> workoutTypes) async {
    try {
      var workouts = await getHealthDataInInterval(start, end, [
        HealthDataType.WORKOUT,
      ]);
      if (workouts == null || workouts.isEmpty) {
        return 0;
      } else {
        workouts = workouts
            .where((element) => workoutTypes.contains(
                (element.value as WorkoutHealthValue).workoutActivityType))
            .toList();
        double distance = 0;
        for (var workout in workouts) {
          distance += (workout.value as WorkoutHealthValue).totalDistance ?? 0;
        }
        return distance;
      }
    } catch (e) {
      log.info(e);
    }
    return 0;
  }

  @override
  Future<ActivityPreview?> writeTrackingToHealth(
      tracking_activity.Activity preview) async {
    final startTime =
        DateTime.fromMillisecondsSinceEpoch(preview.startDateTime ?? 0);
    final endTime =
        DateTime.fromMillisecondsSinceEpoch(preview.endDateTime ?? 0);
    var success = true;
    try {
      if (preview.steps! > 0) {
        success = await Health().writeHealthData(
            value: (preview.steps ?? 0).toDouble(),
            type: HealthDataType.STEPS,
            startTime: startTime,
            endTime: endTime);
      } else if (preview.activityType == ActivityType.walking ||
          preview.activityType == ActivityType.running) {
        return null;
      }
      success = await Health().writeWorkoutData(
          activityType: HealthWorkoutActivityType.values.firstWhere(
              (element) => element.name == preview.activityType?.name),
          start: startTime,
          end: endTime,
          totalDistance: (preview.distance ?? 0).toInt() * 1000,
          totalDistanceUnit: HealthDataUnit.METER);
    } catch (e) {
      log.info(e);
    }
    if (success) {
      var appPackage = await PackageInfo.fromPlatform();
      return ActivityPreview(
          activityType: HealthWorkoutActivityType.values.firstWhere(
              (element) => element.name == preview.activityType?.name),
          start: startTime,
          end: endTime,
          distance: preview.distance ?? 0,
          sourceId: appPackage.packageName,
          caloriesBurnt: 0);
    }
    return await getLastActivity();
  }
}
