import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:activity_tracking/activity_tracking.dart';
import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:activity_tracking/model/event.dart';
import 'package:activity_tracking/model/message.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/repositories/base_local_health_impl.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod/riverpod.dart';

final trackingViewModelProvider =
    StateNotifierProvider.autoDispose<TrackingViewModel, TrackingState?>((ref) {
  return TrackingViewModel(ref);
});

class TrackingViewModel extends StateNotifier<TrackingState?> {
  late final Ref ref;
  final activityTrackingPlugin = ActivityTracking();
  late StreamSubscription activityStreamSubscription;
  final log = Logger('TrackingViewModel');

  TrackingViewModel(this.ref) : super(TrackingState.initial());

  Future<void> checkTrackingPermission() async {
    var permissionGranted =
        ref.read(permissionsProvider).healthWritePermissionStatus;
    var locationPermissionGranted =
        ref.read(permissionsProvider).locationPermissionStatus;
    var activityPermissionGranted =
        ref.read(permissionsProvider).activityPermissionStatus;
    var notificationPermissionGranted =
        ref.read(permissionsProvider).notificationPermissionStatus;

    state = state?.copyWith(
        newPermissionsGranted: _isPermissionGranted(
            permissionGranted,
            locationPermissionGranted,
            activityPermissionGranted,
            notificationPermissionGranted));

    log.info("Permissions granted: ${state?.permissionsGranted}");
  }

  _isPermissionGranted(bool writePermissionGranted, PermissionStatus location,
      PermissionStatus activityRecognition, PermissionStatus notification) {
    final bool isPlatformAndroid = Platform.isAndroid;

    return writePermissionGranted &&
        location == PermissionStatus.granted &&
        notification == PermissionStatus.granted &&
        (isPlatformAndroid
            ? activityRecognition == PermissionStatus.granted
            : true);
  }

  startTracking(ActivityType activityType) async {
    Activity? startedActivity =
        await activityTrackingPlugin.startActivity(activityType);
    state = state?.copyWith(newActivity: startedActivity, newIsRecording: true);
    activityStreamSubscription =
        activityTrackingPlugin.getNativeEvents().listen((e) {
      _onActivityUpdate(e);
    });
  }

  togglePauseTracking() async {
    if (state!.isRecording) {
      // result indicates whether the toggle was successful or not
      var result = await activityTrackingPlugin.togglePauseActivity();
      if (result != null && result) {
        state = state?.copyWith(newIsPaused: !state!.isPaused);

        log.info("Activity paused: ${state?.isPaused}");
        if (state?.isPaused == false) {
          startTimer();
        }
      } else {
        log.warning("Failed to pause activity");
      }
    }
  }

  stopTracking() async {
    await activityStreamSubscription.cancel();
    var finalResult = await activityTrackingPlugin.stopCurrentActivity();
    if (finalResult != null) {
      state = state?.copyWith(newActivity: finalResult, newIsRecording: false);

      await ref
          .read(localHealthRepositoryProvider)
          .writeTrackingToHealth(finalResult);
    }
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      ref
          .read(trackingViewModelProvider.notifier)
          .updateDuration(state!.durationMillis + 1000);
      if (state?.isRecording == true && state?.isPaused == false) {
        startTimer();
      } else {
        return;
      }
    });
  }

  updateDuration(int durationMillis) {
    state = state?.copyWith(newDurationMillis: durationMillis);
  }

  clearState() {
    state = TrackingState.initial();
  }

  _onActivityUpdate(dynamic e) {
    var eventMessage = Message.fromJson(jsonDecode(e));
    switch (eventMessage.type) {
      case Event.step:
        state?.activity.steps =
            ((state?.activity.steps ?? 0) + (eventMessage.data ?? 0)) as int?;
        state =
            state?.copyWith(newActivity: state?.activity, newIsRecording: true);
      case Event.location:
        if (eventMessage.data != null) {
          state?.activity.locations?.addAll(eventMessage.data);
          state = state?.copyWith(
              newActivity: state?.activity, newIsRecording: true);
        }

      case Event.distance:
        if (eventMessage.data != null && eventMessage.data != 0) {
          state?.activity.distance = eventMessage.data;
          state = state?.copyWith(
              newActivity: state?.activity, newIsRecording: true);
        }
      case Event.pause:
        if (eventMessage.data != null) {
          state = state?.copyWith(
              newActivity: eventMessage.data as Activity, newIsPaused: true);
        }
      case Event.resume:
        if (eventMessage.data != null) {
          state = state?.copyWith(
              newActivity: eventMessage.data as Activity, newIsPaused: false);
          startTimer();
        }
      case Event.stop:
        if (eventMessage.data != null) {
          state = state?.copyWith(
              newActivity: eventMessage.data as Activity,
              newIsRecording: false);
        }
      case null:
        log.info("Event is null");
    }
  }
}
