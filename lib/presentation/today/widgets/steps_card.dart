import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hackathon/presentation/today/widgets/generic_card.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StepsCard extends StatelessWidget {
  const StepsCard({super.key, required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    const color = Color.fromARGB(255, 153, 39, 173);
    const colorBackground = Color.fromARGB(50, 153, 39, 173);
    const necessarySteps = 8000;
    var percentage = steps / necessarySteps;

    return GenericCard(
        title: AppLocalizations.of(context)!.steps,
        color: color,
        iconData: Icons.directions_walk_outlined,
        contentHeight: 150.0,
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(),
          // LinearProgressIndicator(value: percentage, color: color),
          CircularPercentIndicator(
            backgroundColor:
                percentage > 1 ? colorBackground : const Color(0xFFB8C7CB),
            radius: 60.0,
            lineWidth: 15.0,
            percent: percentage % 1.0,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(steps.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text("${(percentage * 100).round()}%",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal)),
              ],
            ),
            progressColor: color,
          )
        ]));
  }
}
