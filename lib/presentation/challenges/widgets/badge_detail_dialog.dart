import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:movetopia/data/model/badge.dart';

class BadgeDetailDialog extends StatelessWidget {
  final AchievementBadge badge;
  final double? currentValue;

  const BadgeDetailDialog({
    super.key,
    required this.badge,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, badge),
          _buildContent(context, badge, currentValue),
          _buildFooter(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AchievementBadge badge) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _buildBadgeIcon(context, badge),
          const SizedBox(width: 16),
          _buildBadgeTitle(context, badge),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(BuildContext context, AchievementBadge badge) {
    final theme = Theme.of(context);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events,
        size: 40,
        color: badge.isAchieved
            ? Colors.amber
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildBadgeTitle(BuildContext context, AchievementBadge badge) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            badge.name,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            "Tier ${badge.tier}",
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AchievementBadge badge, double? currentValue) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final achievedDate = badge.lastAchievedDate != null
        ? DateFormat.yMMMd().format(badge.lastAchievedDate!)
        : null;

    final progressPercentage = !badge.isAchieved && currentValue != null
        ? (currentValue / badge.threshold * 100).toInt()
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            badge.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (badge.isAchieved && achievedDate != null)
            _buildAchievedDateRow(context, l10n, achievedDate)
          else if (currentValue != null)
            _buildProgressColumn(
                context, currentValue, badge, progressPercentage),
          if (badge.achievedCount > 1)
            _buildCompletedTimesRow(context, l10n, badge.achievedCount),
        ],
      ),
    );
  }

  Widget _buildAchievedDateRow(
      BuildContext context, AppLocalizations l10n, String achievedDate) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.event_available,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.badge_achieved_on(achievedDate),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProgressColumn(BuildContext context, double currentValue,
      AchievementBadge badge, int? progressPercentage) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Progress: ${currentValue.toInt()}/${badge.threshold}",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentValue / badge.threshold).clamp(0.0, 1.0),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 4),
        Text(
          "$progressPercentage% complete",
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletedTimesRow(
      BuildContext context, AppLocalizations l10n, int achievedCount) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.badge_completed_x_times(achievedCount),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.badge_reset_dialog_cancel),
          ),
        ],
      ),
    );
  }
}
