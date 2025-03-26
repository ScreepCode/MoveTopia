import 'package:activity_tracking/activity_tracking.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracking/model/activity.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_active.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_finished.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class CurrentActivity extends StatelessWidget {
  final Activity? activity;

  final Function onStop;

  final bool isRecording;


  const CurrentActivity({Key? key, required this.activity, required this.onStop, required this.isRecording}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      return isRecording ? TrackingRecording(activity: activity, onStop: onStop) :  TrackingFinished(activity: activity);
  }
}