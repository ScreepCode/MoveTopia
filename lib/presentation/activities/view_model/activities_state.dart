import 'package:movetopia/data/model/activity.dart';

class ActivitiesState {
  List<ActivityPreview> activities;

  ActivitiesState({required this.activities});

  factory ActivitiesState.initial() {
    return ActivitiesState(activities: List.empty(growable: true));
  }

  ActivitiesState copyWith({List<ActivityPreview>? activities}) {
    return ActivitiesState(activities: activities ?? this.activities);
  }
}
