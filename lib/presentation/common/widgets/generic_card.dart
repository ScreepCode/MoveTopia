import 'package:flutter/material.dart';

class GenericCard extends StatelessWidget {
  const GenericCard({
    super.key,
    required this.title,
    this.subtitles,
    this.iconData,
    this.imageData,
    this.color,
    this.content,
    this.contentAlignment = CrossAxisAlignment.start,
  });

  final String title;
  final List<String>? subtitles;
  final IconData? iconData;
  final Image? imageData;
  final Color? color;
  final Widget? content;
  final CrossAxisAlignment contentAlignment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: contentAlignment,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitles != null)
                      ...subtitles!.map((subtitle) => Text(
                            subtitle,
                            style: const TextStyle(fontSize: 12),
                          )),
                  ],
                ),
                const Spacer(),
                if (iconData != null)
                  CircleAvatar(
                    backgroundColor: color ?? Theme.of(context).primaryColor,
                    child: Icon(iconData!, color: Colors.white),
                  ),
                if (imageData != null)
                  CircleAvatar(
                    backgroundColor: color ?? Theme.of(context).primaryColor,
                    child: imageData,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (content != null) content!,
          ],
        ),
      ),
    );
  }
}
