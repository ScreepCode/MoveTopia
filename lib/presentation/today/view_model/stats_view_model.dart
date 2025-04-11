import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/service/health_service_impl.dart';
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
    try {
      final log = Logger('StatsViewModel');
      log.info('Fetching today stats...');

      DateTime now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay =
          startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      log.info('Fetching steps for time range: $startOfDay to $endOfDay');
      int steps = (await ref
              .read(healthService)
              .getStepsInInterval(startOfDay, endOfDay))
          .sum;
      log.info('Got steps: $steps');

      log.info('Fetching distance for time range: $startOfDay to $endOfDay');
      double distance = await ref
              .read(healthService)
              .getDistanceInInterval(startOfDay, endOfDay) /
          1000;
      log.info('Got distance: $distance km');

      final yesterday = now.subtract(const Duration(days: 1));
      log.info('Fetching sleep data for: $yesterday');
      int sleep = await ref.read(healthService).getSleepFromDate(yesterday);
      log.info('Got sleep duration: $sleep seconds');

      state = state.copyWith(steps: steps, distance: distance, sleep: sleep);
      log.info('Stats updated successfully');

      final stepGoal = ref.read(profileProvider).stepGoal;

      if (steps >= stepGoal) {
        log.info('Step goal reached ($steps/$stepGoal). Updating streak...');
        final params = UpdateStreakParams(steps: steps, goal: stepGoal);
        await ref.read(updateStreakProvider)(params);
      }
    } catch (e, stackTrace) {
      final log = Logger('StatsViewModel');
      log.severe('Error fetching stats: $e', e, stackTrace);
      // Keep previous state in case of error
    }
  }
}
