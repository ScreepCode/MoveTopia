import 'package:activity_tracking/model/activity.dart' as tracking_activity;
import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

abstract class HealthService {
  Future<List<HealthDataPoint>?> getHealthDataInInterval(
      DateTime start, DateTime end, List<HealthDataType> types);

  Future<ActivityPreview?> writeTrackingToHealth(
      tracking_activity.Activity preview);

  Future<List<int>> getStepsInInterval(DateTime start, DateTime end);

  Future<double> getDistanceInInterval(DateTime start, DateTime end);

  Future<double> getDistanceOfWorkoutsInInterval(DateTime start, DateTime end,
      List<HealthWorkoutActivityType> workoutTypes);

  Future<int> getSleepFromDate(DateTime date);

  Future<List<ActivityPreview>?> getActivities(DateTime start, DateTime end);

  Future<Activity?> getActivityDetailed(ActivityPreview preview);

  Future<ActivityPreview?> getLastActivity();

  Future<int> getCaloriesBurnedInInterval(DateTime start, DateTime end);
}
