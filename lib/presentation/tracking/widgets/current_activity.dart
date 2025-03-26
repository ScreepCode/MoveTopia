import 'package:activity_tracking/model/activity.dart';
import 'package:flutter/material.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_active.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_finished.dart';

class CurrentActivity extends StatelessWidget {
  final Activity? activity;

  final Function onStop;

  final bool isRecording;

  final String duration;

  final Function startTimer;

  const CurrentActivity(
      {super.key,
      required this.activity,
      required this.onStop,
      required this.isRecording,
      required this.startTimer,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    return isRecording
        ? TrackingRecording(
            activity: activity,
            onStop: onStop,
            duration: duration,
          )
        : TrackingFinished(activity: activity);
  }
}
