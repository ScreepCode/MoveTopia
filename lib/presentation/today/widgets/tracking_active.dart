import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:movetopia/utils/health_utils.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class ActiveTracking extends StatelessWidget {
  const ActiveTracking(
      {super.key,
      required this.activity,
      required this.duration,
      required this.onStop,
      required this.onPause,
      required this.onCardClick});

  final Activity activity;
  final String duration;
  final Future<void> Function() onStop;
  final Future<void> Function() onPause;
  final Function onCardClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onCardClick(),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: (Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side with activity info
                    Row(
                      children: [
                        getIcon(activity.activityType ?? ActivityType.unknown,
                            color: Theme.of(context).colorScheme.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          getTranslatedActivityType(
                              context,
                              HealthWorkoutActivityType.values.firstWhere(
                                  (element) =>
                                      element.name ==
                                      activity.activityType?.name)),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Center with distance
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),

                    // Right side with buttons
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _buildActionButton(context, onPause,
                          Theme.of(context).colorScheme.outline, Icons.pause),
                      _buildActionButton(context, onStop,
                          Theme.of(context).colorScheme.error, Icons.stop)
                    ]),
                  ],
                ))),
          ),
        ]));
  }

  Widget _buildActionButton(BuildContext context,
      Future<void> Function() onButtonPressed, Color color, IconData icon) {
    return IconButton(
      onPressed: onButtonPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
      ),
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }
}
