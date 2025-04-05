import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';

import 'detail_stats_card.dart';

class WorkoutDetails extends StatelessWidget {
  final int averageHeartBeat;
  final int duration;
  final int caloriesBurnt;
  final int steps;

  const WorkoutDetails({
    super.key,
    required this.averageHeartBeat,
    required this.duration,
    required this.caloriesBurnt,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GenericCard(
      title: l10n.activity_details_title,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailStatsCardEntry(
              displayName: l10n.activity_duration,
              value: AppLocalizations.of(context)!.activity_duration_text(
                  (duration / 60).toStringAsFixed(0),
                  ((duration / 60 % 1) * 60).toStringAsFixed(0))),
          if (averageHeartBeat != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_avg_heart_rate,
              value: '$averageHeartBeat bpm',
            ),
          if (steps != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_steps,
              value: '$steps',
            ),
          if (caloriesBurnt != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_burnt_calories,
              value: '$caloriesBurnt kcal',
            )
        ],
      ),
    );
  }
}
