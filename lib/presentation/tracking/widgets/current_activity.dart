import 'package:activity_tracking/model/activity.dart';
import 'package:flutter/material.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_active.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_finished.dart';

class CurrentActivity extends StatelessWidget {
  final Activity? activity;

  final Function onStop;

  final Function onPause;

  final bool isRecording;

  final bool isPaused;

  final int durationMillis;

  final Function startTimer;

  const CurrentActivity(
      {super.key,
      required this.activity,
      required this.onStop,
      required this.onPause,
      required this.isRecording,
      required this.startTimer,
      required this.durationMillis,
      required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return isRecording
        ? TrackingRecording(
            activity: activity,
            onStop: onStop,
            durationMillis: durationMillis,
            isPaused: isPaused,
            onPause: onPause,
          )
        : TrackingFinished(activity: activity, durationMillis: durationMillis);
  }
}
