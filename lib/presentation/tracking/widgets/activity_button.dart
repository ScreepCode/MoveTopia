import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class ActivityButton extends StatelessWidget {
  final ActivityType activityType;

  final Function onPressed;

  const ActivityButton(
      {Key? key, required this.activityType, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
          shape: const CircleBorder(), padding: const EdgeInsets.all(24)),
      onPressed: onPressed(activityType),
      child: Column(
        children: [
          getIcon(activityType, color: Theme.of(context).colorScheme.onPrimary),
        ],
      ),
    );
  }
}
