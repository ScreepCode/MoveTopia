import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/presentation/activities/view_model/activities_state.dart';
import 'package:riverpod/riverpod.dart';

final activitiesViewModelProvider =
    StateNotifierProvider.autoDispose<ActivitiesViewModel, ActivitiesState>(
        (ref) {
  return ActivitiesViewModel(ref);
});

class ActivitiesViewModel extends StateNotifier<ActivitiesState> {
  late final Ref ref;
  final log = Logger('ActivitiesState');

  ActivitiesViewModel(this.ref) : super(ActivitiesState.initial());

  Future<void> fetchActivities() async {
    state = state.copyWith(isLoading: true);
    DateTime now = DateTime.now();
    List<ActivityPreview>? workouts = await ref
        .read(localHealthRepositoryProvider)
        .getActivities(now.subtract(const Duration(days: 7)), now);

    state = state.copyWith(activities: workouts, isLoading: false);
  }
}
