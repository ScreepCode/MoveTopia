import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/service/badge_service.dart';

class ResetBadgesButton extends HookConsumerWidget {
  const ResetBadgesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeService = ref.read(badgeServiceProvider);

    return IconButton(
      icon: const Icon(Icons.restore),
      tooltip: 'Reset all badges',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Badges'),
            content: const Text('Are you sure you want to reset all badges?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await _resetAllBadges(badgeService);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All badges have been reset')),
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
