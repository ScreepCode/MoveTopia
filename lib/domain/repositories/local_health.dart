import 'package:activity_tracking/model/activity.dart' as tracking_activity;
import 'package:health/health.dart';
import 'package:movetopia/data/model/activity.dart';

abstract class BaseLocalHealthRepository {
  Future<List<HealthDataPoint>?> getHealthDataInInterval(
      DateTime start, DateTime end, List<HealthDataType> types);

  Future<ActivityPreview?> writeTrackingToHealth(
      tracking_activity.Activity preview);
}
