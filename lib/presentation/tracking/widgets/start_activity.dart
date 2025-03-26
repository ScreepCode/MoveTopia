import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:movetopia/presentation/tracking/widgets/activity_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartActivity extends StatelessWidget{
  final Function onStart;

  const StartActivity({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center,children: [
        Text(AppLocalizations.of(context)!.tracking_start_activity, style: const TextStyle(fontSize: 36),),
      const SizedBox(height: 20),
      _buildTrackingButtons(context, (activityType) => () => onStart(activityType),)

    ],);
  }


  Widget _buildTrackingButtons(BuildContext context, Function onPressed) {
    final types = List.empty(growable: true);
    types.addAll(ActivityType.values);
    types.remove(ActivityType.unknown);

    return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,children: types.map((e) => _buildActivityItem(context, e, onPressed )).toList(),);
  }

  Widget _buildActivityItem(BuildContext context, ActivityType activityType, Function onPressed) {
    return Row(children: [ActivityButton(activityType: activityType, onPressed: onPressed), const SizedBox(width: 10)]);
  }

}

