import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  Map<Permission, PermissionStatus> perms = await [
    Permission.location,
    Permission.activityRecognition,
    Permission.locationWhenInUse,
    Permission.notification,
  ].request();
  var success = true;
  for (var val in perms.entries) {
    if (val.value.isDenied) {
      print("Permission denied for ${val.key}");
      success = false;
    }
  }
  return success;
}

Icon getIcon(ActivityType activityType,
    {double? size = 36, Color? color = Colors.black}) {
  switch (activityType) {
    case ActivityType.running:
      return Icon(
        Icons.directions_run,
        size: size,
        color: color,
      );
    case ActivityType.biking:
      return Icon(
        Icons.directions_bike,
        size: size,
        color: color,
      );
    case ActivityType.walking:
      return Icon(
        Icons.directions_walk,
        size: size,
        color: color,
      );
    default:
      return Icon(Icons.error, size: size, color: Colors.red);
  }
}

String getDuration(int startMillis, int endMillis) {
  DateTime startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
  DateTime endTime = DateTime.fromMillisecondsSinceEpoch(endMillis);

  int hours = endTime.difference(startTime).inHours;
  int minutes = endTime.difference(startTime).inMinutes.remainder(60);
  int seconds = endTime.difference(startTime).inSeconds.remainder(60);

  String duration = "";
  if (hours > 0) {
    duration += "$hours h ";
  }
  if (minutes > 0) {
    duration += "$minutes min ";
  }
  duration += "$seconds s";

  return duration;
}

String getPace(double pace) {
  if (pace == 0) return "0:00 min/km";
  var minutes = pace ~/ 60;
  var seconds = (pace % 60).toInt();
  return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km";
}
