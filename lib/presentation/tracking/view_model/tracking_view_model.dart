import 'dart:async';
import 'dart:convert';

import 'package:activity_tracking/activity_tracking.dart';
import 'package:activity_tracking/model/activity_type.dart';
import 'package:activity_tracking/model/message.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_state.dart';
import 'package:riverpod/riverpod.dart';

final trackingViewModelProvider = StateNotifierProvider.autoDispose<
    TrackingViewModel, TrackingState?>((ref) {
  return TrackingViewModel(ref);
});

class TrackingViewModel extends StateNotifier<TrackingState?> {
  late final Ref ref;
  final activityTrackingPlugin = ActivityTracking();
  late StreamSubscription activityStreamSubscription;
  final log = Logger('TrackingViewModel');

  TrackingViewModel(this.ref) : super(TrackingState.initial());

  startTracking(ActivityType activityType) async {
    String type = await activityTrackingPlugin.startActivity(activityType) ?? ActivityType.unknown.name;
    log.info('startTracking: $type');
    activityStreamSubscription = activityTrackingPlugin.getNativeEvents().listen(_onActivityUpdate);
  }

  _onActivityUpdate(dynamic e) {
    var eventMessage = Message.fromJson(jsonDecode(e));
    switch (eventMessage.type) {
      case "step":
        state?.activity?.steps =
        ((state?.activity?.steps ?? 0) + (eventMessage.data ?? 0)) as int?;
      case "location":
        if (eventMessage.data != null) {
        state?.activity?.locations?.addAll(eventMessage.data);
        }
      case "distance":
        if (eventMessage.data != null && eventMessage.data != 0) {
        state?.activity?.distance = eventMessage.data;
        }
    }
  }

}
