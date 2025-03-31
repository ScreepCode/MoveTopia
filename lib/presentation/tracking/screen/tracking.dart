import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';
import 'package:movetopia/presentation/tracking/widgets/current_activity.dart';
import 'package:movetopia/presentation/tracking/widgets/start_activity.dart';
import 'package:movetopia/utils/health_utils.dart';
import 'package:movetopia/utils/tracking_utils.dart';

class TrackingScreen extends HookConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);
    void startTimer() {
      Future.delayed(const Duration(seconds: 1), () {
        ref.read(trackingViewModelProvider.notifier).updateDuration(getDuration(
            trackingState?.activity?.startDateTime ?? 0,
            DateTime.now().millisecondsSinceEpoch));
        if (trackingState?.isRecording == true) {
          startTimer();
        } else {
          return;
        }
      });
    }

    void _showBackDialog() {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.tracking_leave_title),
            content: Text(AppLocalizations.of(context)!.tracking_leave_message),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child:
                    Text(AppLocalizations.of(context)!.tracking_leave_cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child:
                    Text(AppLocalizations.of(context)!.tracking_leave_confirm),
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

    useEffect(() {
      if (trackingState?.isRecording == true) {
        startTimer();
      }
      return null;
    }, [trackingState?.isRecording]);

    bool canPop() {
      return trackingState == null || trackingState.isRecording == false;
    }

    return PopScope(
        canPop: canPop(),
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          } else {
            _showBackDialog();
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: trackingState!.isRecording
                  ? Text(getTranslatedActivityType(
                      context,
                      HealthWorkoutActivityType.values.firstWhere((t) =>
                          t.name == trackingState.activity.activityType?.name)))
                  : Text(AppLocalizations.of(context)!.tracking_title),
            ),
            body: trackingState.activity.activityType == ActivityType.unknown
                ? StartActivity(
                    onStart: (activityType) {
                      ref
                          .read(trackingViewModelProvider.notifier)
                          .startTracking(activityType);
                    },
                  )
                : CurrentActivity(
                    activity: trackingState.activity,
                    onStop: () {
                      ref
                          .read(trackingViewModelProvider.notifier)
                          .stopTracking();
                    },
                    startTimer: startTimer,
                    duration: trackingState.duration,
                    isRecording: trackingState!.isRecording,
                  )));
  }
}
