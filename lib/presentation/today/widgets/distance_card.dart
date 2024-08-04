import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hackathon/presentation/today/widgets/generic_card.dart';

class DistanceCard extends StatelessWidget {
  const DistanceCard(
      {super.key, required this.value, required this.percentage});

  final String value;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    const color = Colors.cyan;

    return GenericCard(
        title: AppLocalizations.of(context)!.distance,
        color: color,
        iconData: Icons.map,
        contentHeight: 50.0,
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Spacer(),
          LinearProgressIndicator(
            value: percentage,
            color: color,
          )
        ]));
  }
}
