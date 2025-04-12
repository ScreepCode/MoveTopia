import 'package:activity_tracking/model/activity.dart' as tracking_activity;
import 'package:activity_tracking/model/activity_type.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/domain/repositories/local_health.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

final localHealthRepositoryProvider =
    Provider<BaseLocalHealthRepository>((ref) => BaseLocalHealthRepoImpl());

interface class BaseLocalHealthRepoImpl extends BaseLocalHealthRepository {
  final log = Logger('LocalHealthRepoImpl');

  @override
  Future<List<HealthDataPoint>?> getHealthDataInInterval(
      DateTime start, DateTime end, List<HealthDataType> types) async {
    try {
      _compareDate(start, end);

      start = start.subtract(start.timeZoneOffset);
      end = end.subtract(end.timeZoneOffset);
      List<HealthDataPoint> dataPoints = await Health()
          .getHealthDataFromTypes(types: types, startTime: start, endTime: end);

      // Remove duplicates from the data points - with proper overlap handling
      List<HealthDataPoint> uniqueDataPoints = [];
      Map<String, List<HealthDataPoint>> dataByType = {};

      // Group data points by type only (not by time)
      for (var point in dataPoints) {
        final key = point.typeString;

        // Convert to UTC
        if (!point.dateFrom.isUtc) {
          point.dateFrom = point.dateFrom.toUtc();
        }
        if (!point.dateTo.isUtc) {
          point.dateTo = point.dateTo.toUtc();
        }
        if (!dataByType.containsKey(key)) {
          dataByType[key] = [];
        }
        dataByType[key]!.add(point);
      }

      // Process each type group to handle overlaps
      for (var typePoints in dataByType.values) {
        // Sort by start time to make overlap detection easier
        typePoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        List<HealthDataPoint> nonOverlapping = [];

        for (var point in typePoints) {
          // Check if this point overlaps with any already accepted point
          bool hasOverlap = false;
          int overlapIndex = -1;

          for (int i = 0; i < nonOverlapping.length; i++) {
            var existing = nonOverlapping[i];

            // We use isBefore and isAfter to check for overlap
            // We also need to check that the sources are different
            bool isSameSource = point.sourceName == existing.sourceName;
            if (isSameSource) {
              continue;
            }

            // Check for time overlap
            if (point.dateFrom.isBefore(existing.dateTo) &&
                point.dateTo.isAfter(existing.dateFrom)) {
              hasOverlap = true;
              overlapIndex = i;

              // If this is from movetopia, prioritize it
              if (point.sourceName.startsWith('de.buseslaar.movetopia') &&
                  (point.type == HealthDataType.WORKOUT ||
                      point.type == HealthDataType.DISTANCE_DELTA)) {
                nonOverlapping[i] = point;
                break;
              }

              // Otherwise, take the one with longer duration
              if (point.dateTo.difference(point.dateFrom) >
                  existing.dateTo.difference(existing.dateFrom)) {
                nonOverlapping[i] = point;
              }

              break;
            }
          }

          if (!hasOverlap) {
            nonOverlapping.add(point);
          }
        }

        uniqueDataPoints.addAll(nonOverlapping);
      }

      dataPoints = uniqueDataPoints;

      return dataPoints;
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
    return null;
  }
}
