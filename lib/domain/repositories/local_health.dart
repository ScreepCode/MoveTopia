import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

abstract class LocalHealthRepository {
  Future<int> getStepsInInterval(DateTime start, DateTime end);

  Future<double> getDistanceInInterval(
      DateTime start, DateTime end, List<HealthDataType> distanceTypes);

  Future<int> getSleepFromDate(DateTime date);

  Future<List<ActivityPreview>?> getActivities(DateTime start, DateTime end);

  // Future<Activities?> getActivitieById(String id);
  Future<Activity?> getActivityDetailed(ActivityPreview preview);

  Future<ActivityPreview?> getLastActivity();

  Future<int> getCaloriesBurnedInInterval(DateTime start, DateTime end);
}
