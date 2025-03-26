
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Icon getIcon (ActivityType activityType, {double? size = 24}) {
  switch (activityType) {
    case ActivityType.running:
      return Icon(Icons.directions_run, size: size);
    case ActivityType.cycling:
      return Icon(Icons.directions_bike,size: size);
    case ActivityType.walking:
      return Icon(Icons.directions_walk,size: size,);
    default:
      return Icon(Icons.error, size: size);
  }
}