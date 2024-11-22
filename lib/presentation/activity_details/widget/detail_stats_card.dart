import 'package:flutter/material.dart';

class DetailStatsCard extends StatelessWidget {
  final String displayName;
  final String value;
  final Widget? child;

  const DetailStatsCard(
      {super.key,
      required this.displayName,
      required this.value,
      this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(displayName, style: const TextStyle(fontSize: 12),),
              ]),
              Text(
                value,
                textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ],
          ),
          if (child != null) child!
        ]));
  }
}
