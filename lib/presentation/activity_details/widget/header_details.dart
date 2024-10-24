import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderDetails extends StatelessWidget {
  final String title;
  final DateTime start;
  final DateTime end;
  final IconData icon;

  const HeaderDetails(
      {this.icon = Icons.directions_walk,
      super.key,
      required this.title,
      required this.start,
      required this.end});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    children: [
                      Text(
                          "${DateFormat("d MMM y HH:mm").format(start)} - ${DateFormat("HH:mm").format(end)}")
                    ],
                  )
                ]),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.cyan,
                      child: Icon(icon ?? Icons.directions_walk),
                    )
                  ],
                )
              ],
            )));
  }
}
