import 'dart:typed_data';

import 'package:movetopia/data/model/activity.dart';

class ActivitiesState {
  List<ActivityPreview> activities;
  Map<DateTime, List<ActivityPreview>>? groupedActivities;
  Map<String, Uint8List?>? icons;
  bool isLoading;

  ActivitiesState(
      {required this.activities,
      required this.isLoading,
      required this.groupedActivities,
      required this.icons});

  factory ActivitiesState.initial() {
    return ActivitiesState(
        activities: List.empty(growable: true),
        isLoading: false,
        groupedActivities: <DateTime, List<ActivityPreview>>{},
        icons: <String, Uint8List?>{});

  }

  ActivitiesState copyWith(
      {List<ActivityPreview>? activities,
      bool? isLoading,
      Map<DateTime, List<ActivityPreview>>? newGroupedActivities, Map<String, Uint8List?>? newIcons}) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      groupedActivities: newGroupedActivities ?? this.groupedActivities,
      icons: newIcons ?? this.icons,
    );
  }
}
