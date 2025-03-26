import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:movetopia/utils/health_utils.dart';
import 'package:movetopia/utils/tracking_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackingRecording extends StatelessWidget {

  final Activity? activity;
  final Function onStop;

  const TrackingRecording({required this.activity, required this.onStop});

  @override
  Widget build(BuildContext context) {
   return  Container(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.spaceAround,
       crossAxisAlignment: CrossAxisAlignment.center,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(getTranslatedActivityType(Localizations.localeOf(context), HealthWorkoutActivityType.values.firstWhere((t) => t.name == activity?.activityType?.name) ), style: const TextStyle(fontSize: 30),),
             getIcon(activity?.activityType ?? ActivityType.unknown, size: 48)
           ],

         ),
         _buildDetailEntry(context, AppLocalizations.of(context)!.activity_distance, "${activity?.distance} km"),
         _buildDetailEntry(context, AppLocalizations.of(context)!.activity_duration, "${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(activity?.startDateTime ?? 0)).inSeconds} min"),
         if(activity?.steps != null) _buildDetailEntry(context, AppLocalizations.of(context)!.activity_steps, "${activity?.steps}"),

         _buildActionButtons(context, onStop),
       ],
     ),
   );
  }

  Widget _buildDetailEntry(BuildContext context, String title, String value, ) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 28),),
        Text(value, style: const TextStyle(fontSize: 36),),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Function onStop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(onPressed: () => onStop(), child: Icon(Icons.stop, color: Theme.of(context).colorScheme.onError,), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),),
      //  ElevatedButton(onPressed: () => {}, child: Text(AppLocalizations.of(context)!.activity_pause)),
      ],
    );
  }
}