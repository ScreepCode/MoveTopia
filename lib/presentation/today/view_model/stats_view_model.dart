import 'package:hackathon/data/repositories/local_health_impl.dart';
import 'package:hackathon/presentation/today/view_model/stats_state.dart';
import 'package:health/health.dart';
import 'package:riverpod/riverpod.dart';

final statsViewModelProvider =
    StateNotifierProvider.autoDispose<StatsViewModel, StatsState>((ref) {
  return StatsViewModel(ref);
});

class StatsViewModel extends StateNotifier<StatsState> {
  late final Ref ref;
  StatsViewModel(this.ref) : super(StatsState.initial()) {
    // HealthAuthViewModelState state = ref.watch(healthViewModelProvider);
    // if (state == HealthAuthViewModelState.authorized) {
    //   fetchStats();
    // }
  }

  Future<void> fetchStats() async {
    // This should fetch the last training. Currently thats only mock data
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(hours: 48));
    int steps = await ref
        .read(localHealthRepositoryProvider)
        .getStepsInInterval(start, now);
    double distance = await ref
        .read(localHealthRepositoryProvider)
        .getDistanceInInterval(start, now, [HealthDataType.DISTANCE_DELTA]);
    int sleep = await ref
        .read(localHealthRepositoryProvider)
        .getSleepFromDate(now.subtract(const Duration(days: 3)));
    state = state.copyWith(steps: steps, distance: distance, sleep: sleep);
  }
}
