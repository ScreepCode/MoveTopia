import 'package:activity_tracking/model/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackingRecording extends StatelessWidget {
  final Activity? activity;
  final Function onStop;
  final String duration;

  const TrackingRecording(
      {super.key,
      required this.activity,
      required this.onStop,
      required this.duration});

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
            duration.toString()),
        if (activity?.locations != null)
          _buildDetailEntry(context, Icons.speed, l10n.activity_current_speed,
              "${activity!.locations!.isEmpty ? "--" : ((activity?.locations?.entries.last.value.speed ?? 0) * 10).roundToDouble() / 10} km/h"),
        if (activity?.steps != null)
          _buildDetailEntry(context, Icons.nordic_walking, l10n.activity_steps,
              "${activity?.steps ?? "--"}"),
        _buildActionButtons(context, onStop),
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

  Widget _buildActionButtons(BuildContext context, Function onStop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => onStop(),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: const CircleBorder(),
              padding: EdgeInsets.all(24)),
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
