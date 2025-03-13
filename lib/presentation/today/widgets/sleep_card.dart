import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';

class SleepCard extends StatelessWidget {
  const SleepCard({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    const color = Colors.amber;

    return GenericCard(
        title: AppLocalizations.of(context)!.common_health_data_sleep,
        iconData: Icons.bedtime,
        color: color,
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
            AppLocalizations.of(context)!.common_health_data_hours,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ]));
  }
}
