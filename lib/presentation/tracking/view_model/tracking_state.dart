import 'dart:typed_data';

import 'package:activity_tracking/model/Location.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:logging/logging.dart';
import 'package:activity_tracking/model/activity.dart';


class TrackingState {
  Activity? activity;
  bool isRecording = false;

  final log = Logger('trackingState');

  TrackingState(
      {required this.activity, required this.isRecording});

  factory TrackingState.initial() {
    return TrackingState(
        isRecording: false,
        activity: Activity(activityType: ActivityType.unknown, distance: 0.0, steps: 0, locations: <DateTime, Location>{}));
  }

  TrackingState copyWith(
      {Activity? newActivity, bool newIsRecording = false}) {
    return TrackingState(
        isRecording: newIsRecording,
        activity: newActivity ?? activity);
  }
  
}
