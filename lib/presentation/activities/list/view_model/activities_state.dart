import 'package:movetopia/data/model/activity.dart';

class ActivitiesState {
  List<ActivityPreview> activities;
  bool isLoading;

  ActivitiesState({required this.activities, required this.isLoading});

  factory ActivitiesState.initial() {
    return ActivitiesState(
        activities: List.empty(growable: true), isLoading: false);
  }

  ActivitiesState copyWith(
      {List<ActivityPreview>? activities, bool? isLoading}) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
