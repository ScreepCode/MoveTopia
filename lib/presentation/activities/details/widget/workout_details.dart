import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';

import 'detail_stats_card.dart';

class WorkoutDetails extends StatelessWidget {
  final int averageHeartBeat;
  final int duration;
  final int caloriesBurnt;
  final int steps;
  final double distance;

  const WorkoutDetails({
    super.key,
    required this.averageHeartBeat,
    required this.duration,
    required this.caloriesBurnt,
    required this.steps,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String getDurationText(int duration) {
      final hours = (duration / 3600).toInt();
      final minutes = ((duration % 3600) / 60).toInt();
      final seconds = (duration % 60).toInt();
      if (hours > 0) {
        return l10n.activity_duration_text_with_hours(hours, minutes, seconds);
      } else {
        return l10n.activity_duration_text(minutes, seconds);
      }
    }

    return GenericCard(
      title: l10n.activity_details_title,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailStatsCardEntry(
              displayName: l10n.activity_duration,
              value: getDurationText(duration)),
          if (steps != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_steps,
              value: '$steps',
            ),
          if (averageHeartBeat != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_avg_heart_rate,
              value: '$averageHeartBeat bpm',
            ),
          if (caloriesBurnt != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_burnt_calories,
              value: '$caloriesBurnt kcal',
            ),
          if (distance != 0)
            DetailStatsCardEntry(
              displayName: l10n.activity_distance,
              value: '$distance km',
            )
        ],
      ),
    );
  }
}
