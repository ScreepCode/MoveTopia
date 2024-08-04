import 'package:flutter/material.dart';

class DetailStatsCard extends StatelessWidget {
  final String displayName;
  final String value;
  final IconData iconData;
  final Widget? child;

  const DetailStatsCard(
      {super.key,
      required this.displayName,
      required this.value,
      required this.iconData,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        // decoration: const BoxDecoration(color: Colors.red),
        child: SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(iconData),
                    // const Spacer(),
                    const SizedBox(width: 50),
                    Text(displayName),
                  ]),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              if (child != null) child!
            ])));
  }
}
