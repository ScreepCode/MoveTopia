import 'package:activity_tracking/model/Location.dart';
import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:logging/logging.dart';

class TrackingState {
  Activity activity;
  bool isRecording = false;
  String duration = "--";
  final log = Logger('trackingState');

  TrackingState(
      {required this.activity,
      required this.isRecording,
      required this.duration});

  factory TrackingState.initial() {
    return TrackingState(
        isRecording: false,
        duration: "--",
        activity: Activity(
            activityType: ActivityType.unknown,
            distance: 0.0,
            steps: 0,
            locations: <DateTime, Location>{}));
  }

  TrackingState copyWith(
      {Activity? newActivity, bool? newIsRecording, String? newDuration}) {
    return TrackingState(
        isRecording: newIsRecording ?? isRecording,
        duration: newDuration ?? duration,
        activity: newActivity ?? activity);
  }
}
