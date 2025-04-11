import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/presentation/challenges/provider/badge_repository_provider.dart';
import 'package:movetopia/presentation/challenges/widgets/badge_detail_dialog.dart';

/// A card that displays a preview of achievements/badges
class AchievementPreviewCard extends ConsumerWidget {
  final void Function() onTapViewAll;

  const AchievementPreviewCard({
    super.key,
    required this.onTapViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.challenges_achievements_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _BadgeGrid(ref: ref),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: onTapViewAll,
                icon: Icon(
                  Icons.collections_bookmark,
                  color: theme.colorScheme.primary,
                ),
                label: Text(l10n.challenges_achievements_title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeGrid extends ConsumerWidget {
  final WidgetRef ref;

  const _BadgeGrid({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final badgeRepository = ref.watch(badgeRepositoryProvider);

    return FutureBuilder<List<AchievementBadge>>(
      future: _getBadgesForTodayScreen(badgeRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 80,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading badges',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final badges = snapshot.data ?? [];

        if (badges.isEmpty) {
          return _buildDefaultBadges(context, theme);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: badges
              .map((badge) => GestureDetector(
                    onTap: () => _showBadgeDetail(context, badge),
                    child: _buildBadgeItem(badge, theme),
                  ))
              .toList(),
        );
      },
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailDialog(
        badge: badge,
      ),
    );
  }

  // Fallback in case no badges are available
  Widget _buildDefaultBadges(BuildContext context, ThemeData theme) {
    // Sample badges with different categories
    final badges = [
      _BadgePreview(
          icon: Icons.directions_walk,
          color: theme.colorScheme.primary,
          name: "10K Steps"),
      _BadgePreview(
          icon: Icons.local_fire_department,
          color: theme.colorScheme.secondary,
          name: "Active Days"),
      _BadgePreview(
          icon: Icons.emoji_events,
          color: theme.colorScheme.tertiary,
          name: "Weekly Goals"),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          badges.map((badge) => _buildDefaultBadgeIcon(badge, theme)).toList(),
    );
  }

  Widget _buildDefaultBadgeIcon(_BadgePreview badge, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Badge background container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.color,
                  width: 2,
                ),
              ),
            ),

            // Main icon
            Icon(
              badge.icon,
              color: badge.color,
              size: 30,
            ),

            // Sample indicator (grayed out)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            badge.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Helper class for badge preview
class _BadgePreview {
  final IconData icon;
  final Color color;
  final String name;

  _BadgePreview({
    required this.icon,
    required this.color,
    required this.name,
  });
}

// Get the most relevant badges to show on the Today screen
Future<List<AchievementBadge>> _getBadgesForTodayScreen(
    BadgeRepository repository) async {
  // Get badges from the three key categories
  final totalStepsBadges =
      await repository.getBadgesByCategory(AchievementBadgeCategory.totalSteps);
  final dailyStepsBadges =
      await repository.getBadgesByCategory(AchievementBadgeCategory.dailySteps);
  final cyclingBadges = await repository
      .getBadgesByCategory(AchievementBadgeCategory.totalCyclingDistance);

  // Create a list to store our selected badges
  final selectedBadges = <AchievementBadge>[];

  // First, try to find the highest achieved badge from each category
  final achievedTotalSteps = _getHighestAchievedBadge(totalStepsBadges);
  final achievedDailySteps = _getHighestAchievedBadge(dailyStepsBadges);
  final achievedCycling = _getHighestAchievedBadge(cyclingBadges);

  // Add the achieved badges we found
  if (achievedTotalSteps != null) selectedBadges.add(achievedTotalSteps);
  if (achievedDailySteps != null) selectedBadges.add(achievedDailySteps);
  if (achievedCycling != null) selectedBadges.add(achievedCycling);

  // If we don't have 3 achieved badges, add the next ones to achieve
  if (selectedBadges.length < 3) {
    // Find the next badges to achieve (lowest tier unachieved)
    final nextTotalSteps = _getNextBadgeToAchieve(totalStepsBadges);
    final nextDailySteps = _getNextBadgeToAchieve(dailyStepsBadges);
    final nextCycling = _getNextBadgeToAchieve(cyclingBadges);

    // Add them in order (if not already showing an achieved badge from that category)
    if (selectedBadges.length < 3 &&
        nextTotalSteps != null &&
        !selectedBadges
            .any((b) => b.category == AchievementBadgeCategory.totalSteps)) {
      selectedBadges.add(nextTotalSteps);
    }

    if (selectedBadges.length < 3 &&
        nextDailySteps != null &&
        !selectedBadges
            .any((b) => b.category == AchievementBadgeCategory.dailySteps)) {
      selectedBadges.add(nextDailySteps);
    }

    if (selectedBadges.length < 3 &&
        nextCycling != null &&
        !selectedBadges.any((b) =>
            b.category == AchievementBadgeCategory.totalCyclingDistance)) {
      selectedBadges.add(nextCycling);
    }
  }

  // If we still don't have 3 badges, add any remaining badges
  if (selectedBadges.length < 3) {
    final allRemainingBadges = [
      ...totalStepsBadges,
      ...dailyStepsBadges,
      ...cyclingBadges
    ].where((badge) => !selectedBadges.contains(badge)).toList();

    // Sort by tier (ascending)
    allRemainingBadges.sort((a, b) => a.tier.compareTo(b.tier));

    // Add badges until we have 3 or run out
    for (final badge in allRemainingBadges) {
      if (selectedBadges.length >= 3) break;
      selectedBadges.add(badge);
    }
  }

  return selectedBadges;
}

// Get the highest tier badge that has been achieved
AchievementBadge? _getHighestAchievedBadge(List<AchievementBadge> badges) {
  final achievedBadges = badges.where((badge) => badge.isAchieved).toList();
  if (achievedBadges.isEmpty) return null;

  // Sort by tier (descending)
  achievedBadges.sort((a, b) => b.tier.compareTo(a.tier));
  return achievedBadges.first;
}

// Get the next badge to achieve (lowest tier unachieved)
AchievementBadge? _getNextBadgeToAchieve(List<AchievementBadge> badges) {
  final unachievedBadges = badges.where((badge) => !badge.isAchieved).toList();
  if (unachievedBadges.isEmpty) return null;

  // Sort by tier (ascending)
  unachievedBadges.sort((a, b) => a.tier.compareTo(b.tier));
  return unachievedBadges.first;
}

Widget _buildBadgeItem(AchievementBadge badge, ThemeData theme) {
  final bool isAchieved = badge.isAchieved;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          // Badge background container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isAchieved
                  ? _getBadgeColor(badge, theme).withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAchieved
                    ? _getBadgeColor(badge, theme)
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),

          // Main icon
          Icon(
            _getBadgeIcon(badge),
            color: isAchieved
                ? _getBadgeColor(badge, theme)
                : theme.colorScheme.outline,
            size: 30,
          ),

          // Lock icon for unachieved badges
          if (!isAchieved)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.lock,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),

          // Checkmark for achieved badges
          if (isAchieved)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 80,
        child: Text(
          badge.name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isAchieved
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

IconData _getBadgeIcon(AchievementBadge badge) {
  switch (badge.category) {
    case AchievementBadgeCategory.totalSteps:
    case AchievementBadgeCategory.dailySteps:
      return Icons.directions_walk;
    case AchievementBadgeCategory.totalCyclingDistance:
      return Icons.directions_bike;
    default:
      return Icons.emoji_events;
  }
}

Color _getBadgeColor(AchievementBadge badge, ThemeData theme) {
  if (!badge.isAchieved) {
    return theme.colorScheme.outline;
  }

  switch (badge.category) {
    case AchievementBadgeCategory.totalSteps:
      return theme.colorScheme.primary;
    case AchievementBadgeCategory.dailySteps:
      return theme.colorScheme.secondary;
    case AchievementBadgeCategory.totalCyclingDistance:
      return theme.colorScheme.tertiary;
    default:
      return Colors.amber; // Trophy color for other badges
  }
}
