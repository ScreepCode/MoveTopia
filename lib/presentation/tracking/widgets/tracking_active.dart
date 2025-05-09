import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
          _buildDetailEntry(
              context,
              Icons.nordic_walking,
              AppLocalizations.of(context)!.activity_steps,
              "${activity?.steps ?? "--"}"),
        _buildActionButtons(context, onStop, onPause, isPaused),
      ],
    );
  }

  Widget _buildDetailEntry(
    BuildContext context,
    IconData iconData,
    String title,
    String value,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(iconData),
          const SizedBox(
            width: 20,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 28),
          ),
        ]),
        const SizedBox(width: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: const TextStyle(fontSize: 36)),
        ]),
      ],
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
