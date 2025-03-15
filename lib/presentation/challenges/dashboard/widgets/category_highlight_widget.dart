import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/service/badge_service.dart';
import 'package:movetopia/presentation/challenges/widgets/badge_item.dart';

class CategoryHighlightWidget extends ConsumerWidget {
  final AchievementBadgeCategory category;
  final String categoryName;
  final FutureProvider<double> categoryProgress;
  final VoidCallback onSeeAll;

  const CategoryHighlightWidget({
    super.key,
    required this.category,
    required this.categoryName,
    required this.categoryProgress,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final badgeService = ref.watch(badgeServiceProvider);
    final progressValue = ref.watch(categoryProgress);

    return FutureBuilder<List<AchievementBadge>>(
      future: badgeService.getBadgesByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(l10n.common_error(snapshot.error.toString())));
        }

        final badges = snapshot.data!;
        // Sort badges by tier in descending order
        badges.sort((a, b) => b.tier.compareTo(a.tier));

        // Get the highest tier achieved badge, if any is achieved
        final highestAchievedBadge = badges
            .where((b) => b.isAchieved)
            .fold<AchievementBadge?>(
                null,
                (highest, badge) => highest == null || badge.tier > highest.tier
                    ? badge
                    : highest);

        // Get the next badge to achieve
        final nextToAchieve = badges
            .where((b) => !b.isAchieved)
            .fold<AchievementBadge?>(
                null,
                (lowest, badge) => lowest == null || badge.tier < lowest.tier
                    ? badge
                    : lowest);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: onSeeAll,
                      child: Text(l10n.challenges_see_all),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (highestAchievedBadge != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(l10n.challenges_highest_achieved),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BadgeItem(badge: highestAchievedBadge),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(l10n.challenges_no_achieved_badges),
                    ),
                  ),
                ],
                if (nextToAchieve != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.next_plan,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.challenges_next_goal),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BadgeItem(
                    badge: nextToAchieve,
                    currentValue: progressValue.when(
                      data: (value) => value,
                      loading: () => 0.0,
                      error: (_, __) => 0.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
