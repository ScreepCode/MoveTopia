import 'package:health/health.dart';
import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/presentation/today/view_model/stats_state.dart';
import 'package:riverpod/riverpod.dart';

final statsViewModelProvider =
    StateNotifierProvider.autoDispose<StatsViewModel, StatsState>((ref) {
  return StatsViewModel(ref);
});

class StatsViewModel extends StateNotifier<StatsState> {
  late final Ref ref;
  StatsViewModel(this.ref) : super(StatsState.initial());

  Future<void> fetchStats() async {
    DateTime now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    int steps = await ref
        .read(localHealthRepositoryProvider)
        .getStepsInInterval(lastMidnight, now);
    double distance = await ref
        .read(localHealthRepositoryProvider)
        .getDistanceInInterval(
            lastMidnight, now, [HealthDataType.DISTANCE_DELTA]);
    int sleep = await ref
        .read(localHealthRepositoryProvider)
        .getSleepFromDate(now.subtract(const Duration(days: 1)));
    state = state.copyWith(steps: steps, distance: distance, sleep: sleep);
  }
}
