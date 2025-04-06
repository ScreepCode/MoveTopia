import 'dart:developer';
import 'dart:io';

import 'package:activity_tracking/model/activity.dart' as tracking_activity;
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/repositories/base_local_health_impl.dart';
import 'package:movetopia/domain/repositories/local_health.dart';
import 'package:movetopia/domain/service/health_service.dart';
import 'package:movetopia/utils/time_range.dart';

final healthService = Provider<HealthServiceImpl>((ref) {
// Get the base implementation
  final baseRepo = ref.watch(localHealthRepositoryProvider);

// Wrap it with the cache implementation
  return HealthServiceImpl(
    baseRepo,
    cacheDuration: const Duration(minutes: 15),
  );
});

class HealthServiceImpl implements HealthService {
  final BaseLocalHealthRepository _delegate;

  // Cache storage with time interval information
  final Map<String, dynamic> _cache = {};
  final Map<String, TimeRange> _cacheTimeRanges = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration;
  final Logger _logger = Logger('CachedHealthRepository');

  HealthServiceImpl(this._delegate, {Duration? cacheDuration})
      : _cacheDuration = cacheDuration ?? const Duration(minutes: 15);

  // Helper method to check if cache is valid
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  // Helper to create method-specific cache keys (without time ranges)
  String _createMethodKey(String method, [List<dynamic>? params]) {
    if (params == null || params.isEmpty) {
      return method;
    }
    return '$method:${params.map((p) => p.toString()).join(":")}';
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataInInterval(
      DateTime start, DateTime end, List<HealthDataType> types) async {
    final methodKey = _createMethodKey(
        'getHealthDataInInterval', [types.map((e) => e.toString()).join(',')]);

    // Look for a cached result that fully contains our requested range
    String? fullMatchKey;
    for (var entry in _cacheTimeRanges.entries) {
      if (entry.key.startsWith(methodKey) &&
          entry.value.containsRange(start, end) &&
          _isCacheValid(entry.key)) {
        fullMatchKey = entry.key;
        _logger.info('Found full cache match for $methodKey');
        break;
      }
    }
    if (fullMatchKey != null) {
      final cachedData = _cache[fullMatchKey] as List<HealthDataPoint>;
      // Filter for the exact time range requested
      log("Cache hit for $types");
      return cachedData.where((point) {
        return (point.dateFrom
                    .isAfter(start.subtract(const Duration(seconds: 1))) ||
                point.dateFrom.isAtSameMomentAs(start)) &&
            (point.dateTo.isBefore(end.add(const Duration(seconds: 1))) ||
                point.dateTo.isAtSameMomentAs(end));
      }).toList();
    }

    // If no full match, fetch from delegate
    final data = await _delegate.getHealthDataInInterval(start, end, types);

    // Cache the result
    if (data == null || data.isEmpty) {
      return [];
    }
    final cacheKey =
        '$methodKey:${start.toIso8601String()}:${end.toIso8601String()}';
    _cache[cacheKey] = data;
    _cacheTimeRanges[cacheKey] = TimeRange(start, end);
    _cacheTimestamps[cacheKey] = DateTime.now();

    return data;
  }

  @override
  Future<List<int>> getStepsInInterval(DateTime start, DateTime end) async {
    try {
      var healthDataPoints =
          await getHealthDataInInterval(start, end, [HealthDataType.STEPS]);
      if (healthDataPoints.isEmpty) {
        return [0];
      }
      List<int> steps = List.empty(growable: true);
      for (var i = 0; i < healthDataPoints!.length; i++) {
        steps.add((healthDataPoints[i].value as NumericHealthValue)
            .numericValue
            .toInt());
      }

      return steps;
    } catch (e) {
      return [0];
    }
  }

  @override
  Future<double> getDistanceInInterval(DateTime start, DateTime end) async {
    List<HealthDataType> distanceTypes;
    if (Platform.isAndroid) {
      distanceTypes = [HealthDataType.DISTANCE_DELTA];
    } else if (Platform.isIOS) {
      distanceTypes = [HealthDataType.DISTANCE_WALKING_RUNNING];
    } else {
      throw Exception("Unsupported platform");
    }

    var distances = await getHealthDataInInterval(start, end, distanceTypes);
    double combinedDistance = 0;
    for (var data in distances!) {
      combinedDistance +=
          NumericHealthValue.fromJson(data.value.toJson()).numericValue;
    }
    return combinedDistance;
  }

  @override
  Future<double> getDistanceOfWorkoutsInInterval(DateTime start, DateTime end,
      List<HealthWorkoutActivityType> workoutTypes) async {
    try {
      var workouts = await getHealthDataInInterval(start, end, [
        HealthDataType.WORKOUT,
      ]);
      if (workouts.isEmpty) {
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
      //log.info(e);
    }
    return 0;
  }

  @override
  Future<int> getSleepFromDate(DateTime date) async {
    try {
      var sleepHealthValues = await getHealthDataInInterval(date,
          date.add(const Duration(days: 1)), [HealthDataType.SLEEP_SESSION]);
      if (sleepHealthValues.isEmpty) return 0;

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

      if (awakeTimeHealthValues.isNotEmpty) {
        for (var value in awakeTimeHealthValues) {
          var time = NumericHealthValue.fromJson(value.value.toJson())
              .numericValue
              .toDouble();
          awakeTime += time;
        }
      }
      return sleepTime - awakeTime.toInt();
    } catch (e) {
      log(e.toString());
      return -1;
    }
  }

  @override
  Future<List<ActivityPreview>?> getActivities(
      DateTime start, DateTime end) async {
    var rawWorkouts =
        await getHealthDataInInterval(start, end, [HealthDataType.WORKOUT]);
    List<ActivityPreview> parsedWorkouts = List.empty(growable: true);
    for (var i = 0; i < rawWorkouts.length; i++) {
      var current = rawWorkouts[i];
      WorkoutHealthValue healthValue = current.value as WorkoutHealthValue;

      var kilometres = healthValue.totalDistance != null
          ? (healthValue.totalDistance! / 1000)
          : 0.0;
      // Round kilometres to 2 decimal places
      kilometres = (((kilometres * 100).toInt()) / 100).toDouble();

      ActivityPreview preview = ActivityPreview(
          activityType: healthValue.workoutActivityType,
          caloriesBurnt: healthValue.totalEnergyBurned ?? 0,
          start: current.dateFrom,
          end: current.dateTo,
          distance: kilometres,
          sourceId: current.sourceName);
      parsedWorkouts.add(preview);
    }
    return parsedWorkouts;
  }

  @override
  Future<Activity?> getActivityDetailed(ActivityPreview preview) async {
    try {
      List<HealthDataPoint>? heartFrequency = await getHealthDataInInterval(
          preview.start, preview.end, [HealthDataType.HEART_RATE]);
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
        steps: (await getStepsInInterval(preview.start, preview.end))[0],
        end: preview.end,
        start: preview.start,
        activityType: preview.activityType,
        heartRates: heartRates,
        sourceId: preview.sourceId,
      );
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<ActivityPreview?> getLastActivity() async {
    try {
      var now = DateTime.now();
      var endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      var workouts = await getHealthDataInInterval(
          endOfDay.subtract(const Duration(days: 7)), endOfDay, [
        HealthDataType.WORKOUT,
      ]);
      if (workouts.isEmpty) {
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
      log(e.toString());
    }
    return null;
  }

  @override
  Future<int> getCaloriesBurnedInInterval(DateTime start, DateTime end) async {
    try {
      var calories = await getHealthDataInInterval(
          start, end, [HealthDataType.TOTAL_CALORIES_BURNED]);
      if (calories.isEmpty) return 0;
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
  Future<ActivityPreview?> writeTrackingToHealth(
      tracking_activity.Activity activity) async {
    // Don't cache write operations, just delegate
    final result = await _delegate.writeTrackingToHealth(activity);

    // Invalidate relevant caches that might be affected by this write
    _invalidateRelatedCaches(
        DateTime.fromMicrosecondsSinceEpoch(activity.startDateTime ?? 0),
        DateTime.fromMicrosecondsSinceEpoch(activity.endDateTime ?? 0));

    return result;
  }

  void _invalidateRelatedCaches(DateTime start, DateTime end) {
    final keysToInvalidate = _cacheTimestamps.keys.where((key) {
      return key.contains('getActivities') ||
          key.contains('getLastActivity') ||
          key.contains('getStepsInInterval') ||
          key.contains('getDistanceInInterval') ||
          key.contains('getCaloriesBurnedInInterval');
    }).toList();

    for (final key in keysToInvalidate) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // Method to clear all caches
  void clearCache() {
    _logger.info('Clearing health service cache...');
    _cache.clear();
    _cacheTimeRanges.clear();
    _cacheTimestamps.clear();
    _logger.info('Health service cache cleared');
  }
}
