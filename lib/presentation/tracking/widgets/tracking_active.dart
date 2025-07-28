import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/tracking/widgets/tracking_map.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class TrackingRecording extends StatelessWidget {
  final Activity? activity;
  final bool isPaused;
  final Function onStop;
  final Function onPause;
  final int durationMillis;

  const TrackingRecording(
      {super.key,
      required this.activity,
      required this.onStop,
      required this.onPause,
      required this.durationMillis,
      required this.isPaused});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMap(context, activity),
        _buildDetailsGrid(context, l10n),
        _buildActionButtons(context, onStop, onPause, isPaused),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context, AppLocalizations l10n) {
    final List<Widget> detailEntries = [
      _buildDetailEntry(context, Icons.streetview, l10n.activity_distance,
          "${activity?.distance ?? "--"} km"),
      _buildDetailEntry(context, Icons.timelapse, l10n.activity_duration,
          getDuration(durationMillis)),
      if (activity?.locations != null)
        _buildDetailEntry(context, Icons.speed, l10n.activity_current_speed,
            "${activity!.locations!.isEmpty || isPaused ? "--" : ((activity?.locations?.entries.last.value.speed ?? 0) * 10).roundToDouble() / 10} km/h"),
      if (activity?.locations != null)
        _buildDetailEntry(
            context,
            Icons.directions_run,
            l10n.activity_current_pace,
            activity!.locations!.isEmpty || isPaused
                ? "-- min/km"
                : getPace(activity?.locations?.entries.last.value.pace ?? 0)),
      if (activity?.steps != null &&
          activity?.activityType != ActivityType.biking)
        _buildDetailEntry(context, Icons.nordic_walking, l10n.activity_steps,
            "${activity?.steps ?? "--"}"),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 8.0,
      padding: const EdgeInsets.all(8.0),
      children: detailEntries,
    );
  }

  Widget _buildDetailEntry(
    BuildContext context,
    IconData iconData,
    String title,
    String value,
  ) {
    return Container(
        // color: Theme.of(context).colorScheme.surface,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(iconData),
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ]),
            const SizedBox(height: 4), // Reduced from width: 10 to height: 4
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value, style: const TextStyle(fontSize: 24)),
            ]),
          ],
        ));
  }

  Widget _buildMap(BuildContext context, Activity? activity) {
    // Placeholder for map widget
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [if (activity != null) TrackingMap(activity: activity)],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Function onStop, Function onPause, bool isPaused) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => onPause(),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24)),
          child: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            size: 24,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        ElevatedButton(
          onPressed: () => onStop(),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24)),
          child: Icon(
            Icons.stop,
            size: 24,
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }
}
