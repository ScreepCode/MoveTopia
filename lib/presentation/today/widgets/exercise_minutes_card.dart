import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movetopia/presentation/profile/view_model/profile_view_model.dart';

class ExerciseMinutesCard extends ConsumerWidget {
  final int minutesToday;
  final int minutesWeek;

  const ExerciseMinutesCard({
    super.key,
    required this.minutesToday,
    required this.minutesWeek,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);

    final dailyGoal = profileState.dailyExerciseMinutesGoal;
    final weeklyGoal = profileState.weeklyExerciseMinutesGoal;

    // Format minutes as hours:minutes
    String formatMinutes(int minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return hours > 0
          ? '$hours h ${mins > 0 ? '$mins min' : ''}'
          : '$mins min';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.exercise_minutes_title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePeriodStat(
                    context,
                    l10n.today,
                    formatMinutes(minutesToday),
                    theme.colorScheme.primary,
                    minutesToday,
                    dailyGoal,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTimePeriodStat(
                    context,
                    l10n.this_week,
                    formatMinutes(minutesWeek),
                    theme.colorScheme.secondary,
                    minutesWeek,
                    weeklyGoal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodStat(
    BuildContext context,
    String period,
    String value,
    Color accentColor,
    int minutes,
    int goal,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (minutes / goal).clamp(0.0, 1.0),
          backgroundColor: accentColor.withValues(alpha: 0.2),
          color: accentColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
