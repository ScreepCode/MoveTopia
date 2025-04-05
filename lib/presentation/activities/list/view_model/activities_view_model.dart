import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/utils/system_utils.dart';
import 'package:riverpod/riverpod.dart';

import 'activities_state.dart';

final activitiesViewModelProvider =
    StateNotifierProvider.autoDispose<ActivitiesViewModel, ActivitiesState>(
        (ref) {
  return ActivitiesViewModel(ref);
});

class ActivitiesViewModel extends StateNotifier<ActivitiesState> {
  late final Ref ref;
  final log = Logger('ActivitiesState');

  ActivitiesViewModel(this.ref) : super(ActivitiesState.initial());

  Future<void> fetchActivities({DateTime? endOfData}) async {
    endOfData ??= DateTime.now();
    state = state.copyWith(isLoading: true);
    List<ActivityPreview>? workouts = await ref
        .read(localHealthRepositoryProvider)
        .getActivities(endOfData.subtract(const Duration(days: 7)), endOfData);

    if (workouts == null || workouts.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    Map<DateTime, List<ActivityPreview>> workoutsByDay = {};
    // Sort the workouts by start date, starting with the highest date
    workouts.sort((a, b) => b.start.compareTo(a.start));

    for (int i = 0; i < workouts.length; i++) {
      ActivityPreview workout = workouts[i];
      state.icons ??= {};
      if (state.icons!.containsKey(workout.sourceId)) {
        workouts[i].icon = state.icons?[workout.sourceId];
      } else {
        workouts[i].icon = await getInstalledAppIcon(
          workout.sourceId ?? "",
        );
        state.icons![workout.sourceId!] = workouts[i].icon;
        state = state.copyWith(newIcons: state.icons);
      }
      DateTime day =
          DateTime(workout.start.year, workout.start.month, workout.start.day);
      if (workoutsByDay[day] == null) {
        workoutsByDay[day] = [];
      }
      workoutsByDay[day]!.add(workout);
    }

    workouts.sort((a, b) => b.start.compareTo(a.start));
    // We need to filter the workouts by the day they were started and put these sublists into the map
    state.groupedActivities ??= {};
    state.groupedActivities?.addAll(workoutsByDay);

    state = state.copyWith(
        activities: workouts,
        isLoading: false,
        newGroupedActivities: state.groupedActivities);
  }
}
