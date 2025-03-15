import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/data/model/badge.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final int currentValue;
  final List<AchivementBadge> badges;
  final Widget countDisplay;
  final bool showProgress;

  const ProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.badges,
    required this.countDisplay,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _getNextBadgeInfo(badges, currentValue);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            countDisplay,
            if (showProgress && badgeInfo.badge != null) ...[
              const SizedBox(height: 16),
              ProgressIndicator(
                currentValue: currentValue,
                nextBadge: badgeInfo.badge!,
                nextThreshold: badgeInfo.threshold,
              ),
            ]
          ],
        ),
      ),
    );
  }

  _BadgeInfo _getNextBadgeInfo(List<AchivementBadge> badges, int currentValue) {
    // First sort badges by threshold
    final sortedBadges = [...badges]
      ..sort((a, b) => a.threshold.compareTo(b.threshold));

    AchivementBadge? nextBadge;
    int nextThreshold = 0;

    for (final badge in sortedBadges) {
      if (badge.threshold > currentValue) {
        nextBadge = badge;
        nextThreshold = badge.threshold;
        break;
      }
    }

    // If all badges are achieved, use the highest one
    if (nextBadge == null && sortedBadges.isNotEmpty) {
      nextBadge = sortedBadges.last;
      nextThreshold = nextBadge.threshold;
    }

    return _BadgeInfo(nextBadge, nextThreshold);
  }
}

class _BadgeInfo {
  final AchivementBadge? badge;
  final int threshold;

  _BadgeInfo(this.badge, this.threshold);
}

class ProgressIndicator extends StatelessWidget {
  final int currentValue;
  final AchivementBadge nextBadge;
  final int nextThreshold;

  const ProgressIndicator({
    super.key,
    required this.currentValue,
    required this.nextBadge,
    required this.nextThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 16,
            value: currentValue / nextThreshold,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.badge_progress(
              nextBadge.name,
              currentValue / nextThreshold * 100,
              currentValue.toInt(),
              nextThreshold.toInt()),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class CountDisplay extends StatelessWidget {
  final int value;
  final String label;

  const CountDisplay({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }
}
