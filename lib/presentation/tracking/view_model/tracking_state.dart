import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:activity_tracking/model/location.dart';
import 'package:logging/logging.dart';

class TrackingState {
  Activity activity;
  bool isRecording = false;
  bool isPaused = false;
  int durationMillis = 0;
  final log = Logger('trackingState');

  TrackingState(
      {required this.activity,
      required this.isRecording,
      required this.isPaused,
      required this.durationMillis});

  factory TrackingState.initial() {
    return TrackingState(
        isRecording: false,
        isPaused: false,
        durationMillis: 0,
        activity: Activity(
            activityType: ActivityType.unknown,
            distance: 0.0,
            steps: 0,
            locations: <DateTime, Location>{}));
  }

  TrackingState copyWith(
      {Activity? newActivity,
      bool? newIsRecording,
      bool? newIsPaused,
      int? newDurationMillis}) {
    return TrackingState(
      isRecording: newIsRecording ?? isRecording,
      activity: newActivity ?? activity,
      isPaused: newIsPaused ?? isPaused,
      durationMillis: newDurationMillis ?? durationMillis,
    );
  }
}
