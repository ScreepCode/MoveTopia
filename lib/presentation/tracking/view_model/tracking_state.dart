import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:activity_tracking/model/Activity.dart';


class TrackingState {
  Activity? activity;

  final log = Logger('trackingState');

  TrackingState(
      {required this.activity});

  factory TrackingState.initial() {
    return TrackingState(
        activity: null);
  }

  TrackingState copyWith(
      {Activity? newActivity}) {
    return TrackingState(
        activity: newActivity ?? activity);
  }
  
}
