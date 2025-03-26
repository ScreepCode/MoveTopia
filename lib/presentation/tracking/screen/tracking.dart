import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';
import 'package:movetopia/presentation/tracking/widgets/current_activity.dart';
import 'package:movetopia/presentation/tracking/widgets/start_activity.dart';

class TrackingScreen extends HookConsumerWidget {

  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);

    void _showBackDialog() {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'Are you sure you want to leave this page?\nLeaving will cause the activity recording to be stopped.',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Nevermind'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Leave'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    bool canPop() {
      return trackingState == null || trackingState.isRecording == false;
    }

    return PopScope(canPop: canPop(),onPopInvoked: (bool didPop){
        if(didPop) {
          return;
        } else {
          _showBackDialog();
        }
      }, child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.tracking_title),
          ),
          body: trackingState?.activity?.activityType == ActivityType.unknown ? StartActivity(onStart: (activityType) {
            ref.read(trackingViewModelProvider.notifier).startTracking(activityType);
          },) : CurrentActivity(activity: trackingState?.activity, onStop: () {
            ref.read(trackingViewModelProvider.notifier).stopTracking();
          }, isRecording: trackingState!.isRecording,)
      )
    );

  }

}
