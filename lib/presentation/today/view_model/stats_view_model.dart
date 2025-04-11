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
  final log = Logger('StatsViewModel');

  StatsViewModel(this.ref) : super(StatsState.initial());

  Future<void> fetchStats() async {
    try {
      log.info('Fetching stats data...');
      final now = DateTime.now();

      // Fetch weekly data (last 7 days) in one go
      await _fetchWeeklyData(now);

      // Update step goal and streak if today's steps meet the goal
      final steps =
          state.weeklySteps.last; // Today's steps are the last in the list
      final stepGoal = ref.read(profileProvider).stepGoal;

      if (steps >= stepGoal) {
        log.info('Step goal reached ($steps/$stepGoal). Updating streak...');
        final params = UpdateStreakParams(steps: steps, goal: stepGoal);
        await ref.read(updateStreakProvider)(params);
      }
    } catch (e, stackTrace) {
      log.severe('Error fetching stats', e, stackTrace);
      // Keep previous state in case of error
    }
  }

  /// Efficiently fetch data for the last 7 days in batches
  Future<void> _fetchWeeklyData(DateTime now) async {
    // Calculate date range for the weekly data
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfWeek =
        DateTime(now.year, now.month, now.day - 6); // 7 days including today

    log.info('Fetching weekly data from $startOfWeek to $endOfToday');

    // Get steps for each day in the week
    List<int> weeklySteps = [];
    List<int> weeklySleep = [];

    // Fetch steps day by day (more efficient than querying per datapoint)
    for (int i = 6; i >= 0; i--) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd =
          dayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      // Log only for context, not for each day to reduce log spam
      if (i == 6 || i == 0) {
        log.info(
            'Fetching data for ${i == 6 ? "earliest" : "latest"} day: ${dayStart.toString()}');
      }

      // Fetch steps
      final daySteps = (await ref
          .read(healthService)
          .getStepsInInterval(dayStart, dayEnd)).sum;
      weeklySteps.add(daySteps);

      // Fetch sleep (for previous night)
      final sleepDuration = await ref.read(healthService).getSleepFromDate(day);
      weeklySleep.add(sleepDuration);
    }

    // Calculate today's distance (only needed for today)
    final todayStart = DateTime(now.year, now.month, now.day);
    final distance = await ref
            .read(healthService)
            .getDistanceInInterval(todayStart, endOfToday) /
        1000;

    // Calculate exercise minutes for today and this week
    final exerciseMinutesToday =
        await _calculateExerciseMinutes(todayStart, endOfToday);
    final startOfCalendarWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final exerciseMinutesWeek =
        await _calculateExerciseMinutes(startOfCalendarWeek, endOfToday);

    // Update the state with all fetched data
    state = state.copyWith(
        steps: weeklySteps.last, // Today's steps
        distance: distance,
        sleep: weeklySleep.last, // Most recent sleep data
        weeklySteps: weeklySteps,
        weeklySleep: weeklySleep,
        exerciseMinutesToday: exerciseMinutesToday,
        exerciseMinutesWeek: exerciseMinutesWeek);

    log.info('Weekly stats fetched successfully');
  }

  Future<int> _calculateExerciseMinutes(DateTime start, DateTime end) async {
    try {
      var activities = await ref.read(healthService).getActivities(start, end);
      if (activities == null || activities.isEmpty) {
        return 0;
      }

      int totalMinutes = 0;
      for (var activity in activities) {
        // Calculate duration in minutes
        int durationMinutes = activity.getDuration() ~/ 60;
        totalMinutes += durationMinutes;
      }

      return totalMinutes;
    } catch (e) {
      log.warning('Error calculating exercise minutes: $e');
      return 0;
    }
  }
}
