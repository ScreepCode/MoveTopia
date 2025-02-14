import 'package:flutter/material.dart';

import '../../common/widgets/generic_card.dart';
import 'detail_stats_card.dart';

class WorkoutDetails extends StatelessWidget {
  final int averageHeartBeat;
  final int duration;
  final int caloriesBurnt;

  const WorkoutDetails({
    super.key,
    required this.averageHeartBeat,
    required this.duration,
    required this.caloriesBurnt,
  });

  @override
  Widget build(BuildContext context) {
    return GenericCard(
      title: "Workout Details",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailStatsCardEntry(
            displayName: "Active Time",
            value:
                "${(duration / 60).toStringAsFixed(0)} min ${((duration / 60 % 1) * 60).toStringAsFixed(0)} sec",
          ),
          DetailStatsCardEntry(
            displayName: "Hearth Rate",
            value: '${averageHeartBeat} bpm',
          ),
          DetailStatsCardEntry(
            displayName: "Total burnt calories",
            value: '${caloriesBurnt} kcal',
          )
        ],
      ),
    );
  }
}
