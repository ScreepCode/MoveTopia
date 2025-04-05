import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/service/health_service_impl.dart';
import 'package:riverpod/riverpod.dart';

import 'last_activity_state.dart';

final lastActivityViewModelProvider = StateNotifierProvider.autoDispose<
    LastTrainingViewModel, LastActivityState?>((ref) {
  return LastTrainingViewModel(ref);
});

class LastTrainingViewModel extends StateNotifier<LastActivityState?> {
  late final Ref ref;
  final log = Logger('LastTrainingViewModel');

  LastTrainingViewModel(this.ref) : super(LastActivityState.initial());

  Future<void> fetchLastTraining() async {
    // This should fetch the last training.
    ActivityPreview? healthValue =
        await ref.read(healthService).getLastActivity();
    if (healthValue != null) {
      state = LastActivityState(
          activityPreview: ActivityPreview(
              activityType: healthValue.activityType,
              caloriesBurnt: healthValue.caloriesBurnt,
              distance: healthValue.distance,
              start: healthValue.start,
              end: healthValue.end,
              sourceId: healthValue.sourceId));
    } else {
      state = null;
    }
  }
}
