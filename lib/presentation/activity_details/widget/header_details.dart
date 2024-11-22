import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Card(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: Colors.grey,
                          ),
                          Text(
                              "${DateFormat("d MMM y HH:mm").format(start)} - ${DateFormat("HH:mm").format(end)}",
                              style: const TextStyle(
                                color: Colors.grey,
                              )),
                        ],
                      )
                    ]),
                Column(
                  children: [
                    if (platformIcon != null && platformIcon.isNotEmpty)
                      CircleAvatar(
                        backgroundColor: Colors.cyan,
                        child: Image.memory(platformIcon),
                      )
                  ],
                )
              ],
            )));
  }
}
