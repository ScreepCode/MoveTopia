import 'package:flutter/material.dart';

class GenericCard extends StatelessWidget {
  const GenericCard({
    super.key,
    required this.title,
    required this.iconData,
    this.color,
    this.contentHeight = 50.0,
    required this.content,
  });

  final String title;
  final IconData iconData;
  final Color? color;
  final double contentHeight;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: color ?? Theme.of(context).primaryColor,
                child: Icon(iconData, color: Colors.white),
              ),
            ]),
            // Spacer(),
            SizedBox(height: contentHeight, child: content),
          ],
        ),
      ),
    );
  }
}
