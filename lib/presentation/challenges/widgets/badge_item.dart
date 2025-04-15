import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:movetopia/data/model/badge.dart';

import 'badge_detail_dialog.dart';

class BadgeItem extends StatelessWidget {
  final AchievementBadge badge;
  final double currentValue;
  final bool showProgress;

  const BadgeItem({
    super.key,
    required this.badge,
    this.currentValue = 0,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => _showBadgeDetails(context),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BadgeIcon(badge: badge),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeDetailsSection(badge: badge),
                      if (badge.isAchieved)
                        BadgeAchievementDate(badge: badge)
                      else
                        BadgeProgressSection(
                          badge: badge,
                          currentValue: currentValue,
                          showProgress: showProgress,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailDialog(
        badge: badge,
        currentValue: currentValue,
      ),
    );
  }
}

class BadgeIcon extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeIcon({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.emoji_events,
          size: 60,
          color: badge.isAchieved ? Colors.amber : colorScheme.outline,
        ),
        if (!badge.isAchieved)
          Icon(
            Icons.lock,
            size: 30,
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class BadgeDetailsSection extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeDetailsSection({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          badge.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: badge.isAchieved
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          badge.description,
          style: TextStyle(
            fontSize: 12,
            color: badge.isAchieved
                ? colorScheme.onSurfaceVariant
                : colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class BadgeProgressSection extends StatelessWidget {
  final AchievementBadge badge;
  final double currentValue;
  final bool showProgress;

  const BadgeProgressSection({
    super.key,
    required this.badge,
    required this.currentValue,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    final bool showProgressBar = showProgress && currentValue < badge.threshold;

    if (!showProgressBar) {
      return const SizedBox(height: 4);
    }

    final progressPercentage = currentValue / badge.threshold;
    final percentText = '${(progressPercentage * 100).toInt()}%';
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progressPercentage,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentText (${currentValue.toInt()}/${badge.threshold.toInt()})',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class BadgeAchievementDate extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeAchievementDate({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    if (badge.lastAchievedDate == null) {
      return const SizedBox(height: 4);
    }

    final l10n = AppLocalizations.of(context)!;
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    final String formattedDate = formatter.format(badge.lastAchievedDate!);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.badge_achieved_on(formattedDate),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (badge.achievedCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              l10n.badge_completed_x_times(badge.achievedCount),
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
