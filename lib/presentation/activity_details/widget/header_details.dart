import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/generic_card.dart';

class HeaderDetails extends StatelessWidget {
  final String title;
  final DateTime start;
  final DateTime end;
  final IconData icon;
  final dynamic platformIcon;

  const HeaderDetails(
      {this.icon = Icons.directions_walk,
      super.key,
      required this.title,
      required this.start,
      required this.end,
      this.platformIcon});

  @override
  Widget build(BuildContext context) {
    return GenericCard(
      title: title,
      imageData: platformIcon != null && platformIcon.isNotEmpty
          ? Image.memory(platformIcon)
          : null,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                        "${DateFormat("d MMM y HH:mm").format(start)} - ${DateFormat("HH:mm").format(end)}",
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  ],
                )
              ])
        ],
      ),
    );
  }
}
