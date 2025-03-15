import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/service/badge_service.dart';

class ResetBadgesButton extends HookConsumerWidget {
  const ResetBadgesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeService = ref.read(badgeServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.restore),
      tooltip: l10n.badge_reset_button_tooltip,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.badge_reset_dialog_title),
            content: Text(l10n.badge_reset_dialog_message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.badge_reset_dialog_cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.badge_reset_dialog_confirm),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await _resetAllBadges(badgeService);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.badge_reset_success)),
          );
        }
      },
    );
  }

  Future<void> _resetAllBadges(BadgeService badgeService) async {
    final allBadges = await badgeService.getAllBadges();

    for (final badge in allBadges) {
      await badgeService.badgeRepository.saveBadge(badge.copyWith(
        isAchieved: false,
        achievedCount: 0,
        lastAchievedDate: null,
      ));
    }
  }
}
