import 'package:flutter/material.dart';

class DetailStatsCardEntry extends StatelessWidget {
  final String displayName;
  final String value;
  final Widget? child;

  const DetailStatsCardEntry(
      {super.key, required this.displayName, required this.value, this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(
                  displayName,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ]),
              Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface))
            ],
          ),
          if (child != null) child!
        ]));
  }
}
