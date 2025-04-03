import 'package:movetopia/data/model/activity.dart';

class ActivitiesState {
  List<ActivityPreview> activities;
  Map<DateTime, List<ActivityPreview>>? groupedActivities;
  bool isLoading;

  ActivitiesState(
      {required this.activities,
      required this.isLoading,
      required this.groupedActivities});

  factory ActivitiesState.initial() {
    return ActivitiesState(
        activities: List.empty(growable: true),
        isLoading: false,
        groupedActivities: <DateTime, List<ActivityPreview>>{});
  }

  ActivitiesState copyWith(
      {List<ActivityPreview>? activities,
      bool? isLoading,
      Map<DateTime, List<ActivityPreview>>? newGroupedActivities}) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      groupedActivities: newGroupedActivities ?? this.groupedActivities,
    );
  }
}
