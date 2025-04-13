import 'package:activity_tracking/model/activity_type.dart' as activity_type;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movetopia/presentation/tracking/widgets/activity_button.dart';

class StartActivity extends StatelessWidget {
  final Function onStart;

  const StartActivity({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    Future<void> startTracking(activity_type.ActivityType type) async {
      if (!(await Geolocator.isLocationServiceEnabled())) {
        if (Theme.of(context).platform == TargetPlatform.android) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!
                    .tracking_permissions_location_title),
                content: Text(AppLocalizations.of(context)!
                    .tracking_permissions_location_description),
                actions: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(context)!
                        .tracking_permissions_location_cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FilledButton(
                    child: Text(AppLocalizations.of(context)!
                        .tracking_permissions_location_settings),
                    onPressed: () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.location);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        onStart(type);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.tracking_start_activity,
          style: const TextStyle(fontSize: 36),
        ),
        const SizedBox(height: 20),
        _buildTrackingButtons(
          context,
          (activityType) => () => startTracking(activityType),
        )
      ],
    );
  }

  Widget _buildTrackingButtons(BuildContext context, Function onPressed) {
    final types = List.empty(growable: true);
    types.addAll(activity_type.ActivityType.values);
    types.remove(activity_type.ActivityType.unknown);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
          types.map((e) => _buildActivityItem(context, e, onPressed)).toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context,
      activity_type.ActivityType activityType, Function onPressed) {
    return Row(children: [
      ActivityButton(activityType: activityType, onPressed: onPressed),
      const SizedBox(width: 10)
    ]);
  }
}
