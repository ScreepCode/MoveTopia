import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/presentation/challenges/provider/streak_provider.dart';
import 'package:movetopia/presentation/profile/view_model/profile_view_model.dart';
import 'package:riverpod/riverpod.dart';

import 'stats_state.dart';

final statsViewModelProvider =
    StateNotifierProvider.autoDispose<StatsViewModel, StatsState>((ref) {
  return StatsViewModel(ref);
});

class StatsViewModel extends StateNotifier<StatsState> {
  late final Ref ref;

  StatsViewModel(this.ref) : super(StatsState.initial());

  Future<void> fetchStats() async {
    DateTime now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay =
    startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    int steps = await ref
        .read(localHealthRepositoryProvider)
        .getStepsInInterval(startOfDay, endOfDay);
    double distance = await ref
        .read(localHealthRepositoryProvider)
        .getDistanceInInterval(
            startOfDay, endOfDay) / 1000;
    int sleep = await ref
        .read(localHealthRepositoryProvider)
        .getSleepFromDate(now.subtract(const Duration(days: 1)));
    state = state.copyWith(steps: steps, distance: distance, sleep: sleep);

    final stepGoal = ref.read(profileProvider).stepGoal;

    if (steps >= stepGoal) {
      final params = UpdateStreakParams(steps: steps, goal: stepGoal);
      await ref.read(updateStreakProvider)(params);
    }
  }
}
