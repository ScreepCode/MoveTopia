import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/streak_repository_impl.dart';
import '../../../../domain/service/badge_service.dart';
import '../../../challenges/provider/badge_lists_provider.dart';
import '../../../challenges/provider/streak_provider.dart';
import '../../view_model/profile_view_model.dart';

/// Section for displaying user profile statistics
class ProfileStatsSection extends ConsumerWidget {
  const ProfileStatsSection({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);

    // Calculate number of days since installation
    final daysSinceInstallation =
        DateTime.now().difference(profile.installationDate).inDays;

    // Get days with step goal reached this month from the StreakRepository
    final daysWithStepGoalThisMonthAsync =
        ref.watch(daysWithStepGoalThisMonthProvider);

    // Get total steps from health data
    final totalStepsAsync = ref.watch(totalStepsProvider);

    // Get cycling distance
    final totalCyclingAsync = ref.watch(totalCyclingProvider);

    // Get achieved badges count
    final achievedBadgesAsync = ref.watch(achievedBadgesCountProvider);

    // Get current streak count
    final currentStreakAsync = ref.watch(streakCountProvider);

    // Format large numbers with commas
    final NumberFormat numberFormat = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.user_level_title,
                style: theme.textTheme.titleMedium,
              ),
              const Divider()
            ],
          ),
        ),

        // User Profile Stats Cards
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          childAspectRatio: 1.0,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Total Steps Card
            totalStepsAsync.when(
              data: (totalSteps) => _buildStatCard(
                context,
                icon: Icons.directions_walk,
                title: l10n.badge_total_steps_title,
                value: numberFormat.format(totalSteps.toInt()),
                color: theme.colorScheme.primary,
              ),
              loading: () => _buildStatCard(
                context,
                icon: Icons.directions_walk,
                title: l10n.badge_total_steps_title,
                value: "...",
                color: theme.colorScheme.primary,
              ),
              error: (_, __) => _buildStatCard(
                context,
                icon: Icons.directions_walk,
                title: l10n.badge_total_steps_title,
                value: numberFormat.format(profile.lifetimeSteps),
                color: theme.colorScheme.primary,
              ),
            ),

            // Total Cycling Distance Card
            totalCyclingAsync.when(
              data: (cyclingDistance) => _buildStatCard(
                context,
                icon: Icons.directions_bike,
                title: l10n.badge_cycling_title,
                value: "${cyclingDistance.toStringAsFixed(1)} km",
                color: theme.colorScheme.secondary,
              ),
              loading: () => _buildStatCard(
                context,
                icon: Icons.directions_bike,
                title: l10n.badge_cycling_title,
                value: "...",
                color: theme.colorScheme.secondary,
              ),
              error: (_, __) => _buildStatCard(
                context,
                icon: Icons.directions_bike,
                title: l10n.badge_cycling_title,
                value: "0.0 km",
                color: theme.colorScheme.secondary,
              ),
            ),

            // Current Streak Card
            currentStreakAsync.when(
              data: (streakCount) => _buildStatCard(
                context,
                icon: Icons.local_fire_department,
                title: l10n.streakActive,
                value: "$streakCount ${l10n.common_days}",
                color: theme.colorScheme.tertiary,
              ),
              loading: () => _buildStatCard(
                context,
                icon: Icons.local_fire_department,
                title: l10n.streakActive,
                value: "...",
                color: theme.colorScheme.tertiary,
              ),
              error: (_, __) => _buildStatCard(
                context,
                icon: Icons.local_fire_department,
                title: l10n.streakActive,
                value: "${profile.currentStreak} ${l10n.common_days}",
                color: theme.colorScheme.tertiary,
              ),
            ),

            // Badges Earned Card
            achievedBadgesAsync.when(
              data: (badgesCount) => _buildStatCard(
                context,
                icon: Icons.emoji_events,
                title: l10n.badge_achieved_badges,
                value: "$badgesCount",
                color: Colors.amber,
              ),
              loading: () => _buildStatCard(
                context,
                icon: Icons.emoji_events,
                title: l10n.badge_achieved_badges,
                value: "...",
                color: Colors.amber,
              ),
              error: (_, __) => _buildStatCard(
                context,
                icon: Icons.emoji_events,
                title: l10n.badge_achieved_badges,
                value: "${profile.badgesEarned}",
                color: Colors.amber,
              ),
            ),

            // Days Since Installation Card
            _buildStatCard(
              context,
              icon: Icons.calendar_today,
              title: l10n.date_installation,
              value: "$daysSinceInstallation ${l10n.common_days}",
              color: theme.colorScheme.primaryContainer,
            ),

            // Days with Goal This Month Card
            daysWithStepGoalThisMonthAsync.when(
              data: (daysThisMonth) => _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                title: l10n.common_this_month,
                value: "$daysThisMonth ${l10n.common_days}",
                color: Colors.green,
              ),
              loading: () => _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                title: l10n.common_this_month,
                value: "...",
                color: Colors.green.withValues(alpha: 0.7),
              ),
              error: (error, _) => _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                title: l10n.common_this_month,
                value: "!",
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider that calculates the number of days in the current month where step goal was reached
final daysWithStepGoalThisMonthProvider = FutureProvider<int>((ref) async {
  final streakRepository = ref.watch(streakRepositoryProvider);
  final completedDays = await streakRepository.getCompletedDays();

  // Get current month and year
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  // Count days in current month where step goal was reached
  final daysThisMonth = completedDays
      .where((day) => day.month == currentMonth && day.year == currentYear)
      .length;

  return daysThisMonth;
});

/// Provider that counts the number of achieved badges
final achievedBadgesCountProvider = FutureProvider<int>((ref) async {
  final badgeService = ref.watch(badgeServiceProvider);
  final allBadges = await badgeService.getAllBadges();

  return allBadges.where((badge) => badge.isAchieved).length;
});
