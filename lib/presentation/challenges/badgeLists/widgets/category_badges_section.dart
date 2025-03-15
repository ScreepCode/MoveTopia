import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/service/badge_service.dart';
import 'package:movetopia/presentation/challenges/badgeLists/widgets/badge_item.dart';

import 'progress_card.dart';

class CategoryBadgesSection extends StatefulHookConsumerWidget {
  final AchivementBadgeCategory category;
  final double currentValue;

  const CategoryBadgesSection({
    super.key,
    required this.category,
    required this.currentValue,
  });

  @override
  ConsumerState<CategoryBadgesSection> createState() =>
      _CategoryBadgesSectionState();
}

class _CategoryBadgesSectionState extends ConsumerState<CategoryBadgesSection> {
  bool _showRemainingBadges = false;
  bool _showAchievedBadges = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final badgesFuture =
        ref.watch(badgeServiceProvider).getBadgesByCategory(widget.category);

    return FutureBuilder<List<AchivementBadge>>(
      future: badgesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final badges = snapshot.data!;
        if (badges.isEmpty) {
          return const Center(child: Text('No badges found'));
        }

        badges.sort((a, b) => a.threshold.compareTo(b.threshold));

        final achievedBadges = badges.where((b) => b.isAchieved).toList();
        achievedBadges.sort((a, b) => b.threshold.compareTo(a.threshold));

        final remainingBadges = badges.where((b) => !b.isAchieved).toList();

        if (remainingBadges.isEmpty) {
          return _buildAllAchievedLayout(achievedBadges);
        }

        // Get next badge (with lowest threshold)
        final nextBadge = remainingBadges.first;

        return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressCard(),

                // Next badge
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    l10n.badge_next_goal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                BadgeItem(
                  badge: nextBadge,
                  currentValue: widget.currentValue,
                  showProgress: true,
                ),

                // Other remaining badges (expandable)
                if (remainingBadges.length > 1)
                  _buildExpandableSection(
                    title:
                        "${l10n.badge_upcoming_badges} (${remainingBadges.length - 1})",
                    isExpanded: _showRemainingBadges,
                    onTap: () => setState(
                        () => _showRemainingBadges = !_showRemainingBadges),
                    badgeWidgets: remainingBadges
                        .skip(1)
                        .map((badge) => BadgeItem(
                              badge: badge,
                              currentValue: widget.currentValue,
                              showProgress: true,
                            ))
                        .toList(),
                  ),

                // Achieved badges (expandable)
                if (achievedBadges.isNotEmpty)
                  _buildExpandableSection(
                    title:
                        "${l10n.badge_achieved_badges} (${achievedBadges.length})",
                    isExpanded: _showAchievedBadges,
                    onTap: () => setState(
                        () => _showAchievedBadges = !_showAchievedBadges),
                    badgeWidgets: achievedBadges
                        .map((badge) => BadgeItem(badge: badge))
                        .toList(),
                  ),
              ],
            )));
      },
    );
  }

  Widget _buildAllAchievedLayout(List<AchivementBadge> achievedBadges) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressCard(),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            l10n.badge_all_achieved,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
        ),
        _buildExpandableSection(
          title: "${l10n.badge_achieved_badges} (${achievedBadges.length})",
          isExpanded: _showAchievedBadges,
          onTap: () =>
              setState(() => _showAchievedBadges = !_showAchievedBadges),
          badgeWidgets:
              achievedBadges.map((badge) => BadgeItem(badge: badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final l10n = AppLocalizations.of(context)!;
    String title;
    String label;

    switch (widget.category) {
      case AchivementBadgeCategory.dailySteps:
        title = l10n.badge_daily_steps_title;
        label = l10n.common_health_data_steps;
        break;
      case AchivementBadgeCategory.totalSteps:
        title = l10n.badge_total_steps_title;
        label = l10n.common_health_data_steps;
        break;
      case AchivementBadgeCategory.totalCyclingDistance:
        title = l10n.badge_cycling_title;
        label = l10n.common_health_data_distance_type;
        break;
      default:
        title = l10n.common_unknown;
        label = '';
    }

    return FutureBuilder<List<AchivementBadge>>(
        future: ref
            .watch(badgeServiceProvider)
            .getBadgesByCategory(widget.category),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ProgressCard(
            title: title,
            currentValue: widget.currentValue.toInt(),
            badges: snapshot.data!,
            countDisplay: CountDisplay(
              value: widget.currentValue.toInt(),
              label: label,
            ),
            showProgress: false,
          );
        });
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> badgeWidgets,
  }) {
    if (badgeWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(children: badgeWidgets),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
