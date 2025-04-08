import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:movetopia/presentation/tracking/screen/permission_screen.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';
import 'package:movetopia/presentation/tracking/widgets/current_activity.dart';
import 'package:movetopia/presentation/tracking/widgets/start_activity.dart';
import 'package:movetopia/utils/health_utils.dart';

class TrackingScreen extends HookConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);
    final permissionsState = ref.watch(permissionsProvider);

    useEffect(() {
      if (trackingState?.isRecording == true) {
        ref.read(trackingViewModelProvider.notifier).startTimer();
      }
      return null;
    }, [trackingState?.isRecording]);

    useEffect(() {
      Future.microtask(() {
        ref.read(trackingViewModelProvider.notifier).checkTrackingPermission();
      });
      return null;
    }, [
      permissionsState.healthWritePermissionStatus,
      permissionsState.activityPermissionStatus,
      permissionsState.locationPermissionStatus,
      permissionsState.notificationPermissionStatus
    ]);

    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            if (trackingState.isRecording == false) {
              ref.read(trackingViewModelProvider.notifier).clearState();
            }
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
            body: trackingState.permissionsGranted
                ? _buildTracking(
                    context,
                    trackingState,
                    ref.read(trackingViewModelProvider.notifier).startTracking,
                    ref.read(trackingViewModelProvider.notifier).stopTracking,
                    ref
                        .read(trackingViewModelProvider.notifier)
                        .togglePauseTracking,
                    ref.read(trackingViewModelProvider.notifier).startTimer)
                : PermissionScreen()));
  }

  Widget _buildTracking(
      BuildContext ref,
      TrackingState trackingState,
      Function startTracking,
      Function stopTracking,
      Function togglePauseTracking,
      Function startTimer) {
    return trackingState.activity.activityType == ActivityType.unknown
        ? StartActivity(
            onStart: (activityType) {
              startTracking(activityType);
            },
          )
        : CurrentActivity(
            activity: trackingState.activity,
            onStop: () {
              stopTracking();
            },
            onPause: () {
              togglePauseTracking();
            },
            startTimer: startTimer,
            durationMillis: trackingState.durationMillis,
            isRecording: trackingState.isRecording,
            isPaused: trackingState.isPaused,
          );
  }
}
