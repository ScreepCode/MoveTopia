import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/presentation/activity_details/view_model/activity_detail_state.dart';
import 'package:riverpod/riverpod.dart';

final activityDetailedViewModelProvider = StateNotifierProvider.autoDispose<
    ActivityDetailedViewModel, ActivityDetailState>((ref) {
  return ActivityDetailedViewModel(ref);
});

class ActivityDetailedViewModel extends StateNotifier<ActivityDetailState> {
  late final Ref ref;
  final log = Logger('activityDetailedState');

  ActivityDetailedViewModel(this.ref) : super(ActivityDetailState.initial());

  Future<void> fetchActivityDetailed(ActivityPreview preview) async {
    // This should fetch the detailed
    Activity? activityDetailed = await ref
        .read(localHealthRepositoryProvider)
        .getActivityDetailed(preview);
    if (activityDetailed != null) {
      state = state.copyWith(
          newActivity: Activity(
              distance: activityDetailed.distance,
              activityType: activityDetailed.activityType,
              caloriesBurnt: activityDetailed.caloriesBurnt,
              start: activityDetailed.start,
              end: activityDetailed.end,
              heartRates: activityDetailed.heartRates,
              speed: activityDetailed.speed));
    }
  }

  void setLoading(bool loading) {
    state.isLoading = loading;
  }
}
