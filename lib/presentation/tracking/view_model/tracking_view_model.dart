import 'dart:async';
import 'dart:convert';

import 'package:activity_tracking/activity_tracking.dart';
import 'package:activity_tracking/model/activity.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:activity_tracking/model/message.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:movetopia/utils/tracking_utils.dart';
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

  startTracking(ActivityType activityType) async {
    var sucess = await checkPermission();
    if (!sucess) {
      return;
    }
    Activity? startedActivity =
        await activityTrackingPlugin.startActivity(activityType);
    state = state?.copyWith(newActivity: startedActivity, newIsRecording: true);
    //  log.info('startTracking: $type');
    activityStreamSubscription =
        activityTrackingPlugin.getNativeEvents().listen(_onActivityUpdate);
  }

  stopTracking() async {
    activityStreamSubscription.cancel();
    var finalResult = await activityTrackingPlugin.stopCurrentActivity();
    if (finalResult != null) {
      print(finalResult.steps);
      print(finalResult.startDateTime);
      print(finalResult.endDateTime);
      print(finalResult.locations?.values);
      state = state?.copyWith(
          newActivity: finalResult, newIsRecording: false, newDuration: "");
    }
  }

  updateDuration(String duration) {
    state = state?.copyWith(newDuration: duration);
  }

  _onActivityUpdate(dynamic e) {
    var eventMessage = Message.fromJson(jsonDecode(e));
    switch (eventMessage.type) {
      case "step":
        state?.activity.steps =
            ((state?.activity.steps ?? 0) + (eventMessage.data ?? 0)) as int?;
        state =
            state?.copyWith(newActivity: state?.activity, newIsRecording: true);
      case "location":
        if (eventMessage.data != null) {
          state?.activity.locations?.addAll(eventMessage.data);
          state = state?.copyWith(
              newActivity: state?.activity, newIsRecording: true);
        }

      case "distance":
        if (eventMessage.data != null && eventMessage.data != 0) {
          state?.activity.distance = eventMessage.data;
          state = state?.copyWith(
              newActivity: state?.activity, newIsRecording: true);
        }
    }
  }
}
