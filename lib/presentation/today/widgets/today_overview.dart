import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:movetopia/presentation/today/widgets/distance_card.dart';
import 'package:movetopia/presentation/today/widgets/sleep_card.dart';
import 'package:movetopia/presentation/today/widgets/steps_card.dart';

// ignore: must_be_immutable
class TodayOverview extends StatelessWidget {
  TodayOverview(
      {super.key,
      required this.steps,
      required this.distance,
      required this.sleep,
      required this.stepGoal});

  int steps;
  String distance;
  int sleep;
  int stepGoal;

  String formatDuration(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Text(AppLocalizations.of(context)!.your_stats,
              style: const TextStyle(fontSize: 20)),
          const Spacer(),
          const Icon(Icons.navigate_next)
        ],
      ),
      StaggeredGrid.count(
          crossAxisCount: 2,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
          children: [
            StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: StepsCard(
                  steps: steps,
                  stepGoal: stepGoal,
                )),
            StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: DistanceCard(
                  value: '$distance km',
                  percentage: 0.6,
                )),
            StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: SleepCard(
                  value: formatDuration(sleep),
                )),
          ])
    ]);
  }
}
