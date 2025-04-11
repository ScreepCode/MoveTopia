import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/challenges/provider/streak_provider.dart';
import 'package:movetopia/presentation/challenges/routes.dart';

/// A combined card that shows both the daily step count and the streak.
/// This combines functionality from StepsCard and StreakCard into a single widget.
class StepsStreakCard extends ConsumerWidget {
  final int steps;
  final int stepGoal;

  const StepsStreakCard({
    super.key,
    required this.steps,
    required this.stepGoal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streakCount = ref.watch(streakCountProvider);

    // Calculate step progress
    var percentage = steps / stepGoal;
    final isGoalReached = steps >= stepGoal;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Steps Section
            StepsSection(
              steps: steps,
              stepGoal: stepGoal,
              percentage: percentage,
              isGoalReached: isGoalReached,
            ),

            const SizedBox(height: 24),

            // Divider
            Divider(color: theme.colorScheme.outline.withOpacity(0.1)),
            const SizedBox(height: 16),

            // Streak Section
            StreakSection(streakCount: streakCount),
          ],
        ),
      ),
    );
  }
}

/// Displays the steps information including progress bar and count
class StepsSection extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final double percentage;
  final bool isGoalReached;

  const StepsSection({
    super.key,
    required this.steps,
    required this.stepGoal,
    required this.percentage,
    required this.isGoalReached,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final percentInt = (percentage * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Progress
        Row(
          children: [
            _buildIconContainer(
              context,
              Icons.directions_walk_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.common_health_data_steps,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "$percentInt%",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Steps progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage > 1.0 ? 1.0 : percentage,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isGoalReached ? Colors.green : theme.colorScheme.primary,
            ),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 12),

        // Steps count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  steps.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "/ $stepGoal",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (isGoalReached) _buildGoalReachedBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalReachedBadge(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.steps_card_goal_reached,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the streak information
class StreakSection extends StatelessWidget {
  final AsyncValue<int> streakCount;

  const StreakSection({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
        onTap: () {
          context.go(fullStreakDetailsPath);
        },
        child: Row(
          children: [
            _buildIconContainer(
              context,
              Icons.local_fire_department_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.streakTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  streakCount.when(
                    data: (count) => Text(
                      l10n.streakCount(count),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => Text(
                      'Error',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
            _buildStreakBadge(context, streakCount),
          ],
        ));
  }

  Widget _buildStreakBadge(BuildContext context, AsyncValue<int> streakCount) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: streakCount.maybeWhen(
        data: (count) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count > 0 ? '🔥' : '❄️',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        orElse: () => const SizedBox(width: 20),
      ),
    );
  }
}

/// Builds a container with an icon and background
Widget _buildIconContainer(BuildContext context, IconData icon) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      color: theme.colorScheme.primary,
      size: 24,
    ),
  );
}
