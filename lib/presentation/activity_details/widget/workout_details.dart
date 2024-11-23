import 'package:flutter/material.dart';

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
    return Card(
        child: Container(
            padding: EdgeInsets.all(16),
            child: (Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Workout Details",
                    textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
                DetailStatsCard(
                  displayName: "Active Time",
                  value:
                      "${(duration / 60).toStringAsFixed(0)} min ${((duration / 60 % 1) * 60).toStringAsFixed(0)} sec",
                ),
                DetailStatsCard(
                  displayName: "Hearth Rate",
                  value: '${averageHeartBeat} bpm',
                ),
                DetailStatsCard(
                  displayName: "Total burnt calories",
                  value: '${caloriesBurnt} kcal',
                )
              ],
            ))));
  }
}
