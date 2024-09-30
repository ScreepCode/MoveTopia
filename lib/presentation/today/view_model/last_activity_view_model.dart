import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/repositories/local_health_impl.dart';
import 'package:movetopia/presentation/today/view_model/last_activity_state.dart';
import 'package:riverpod/riverpod.dart';

final lastActivityViewModelProvider = StateNotifierProvider.autoDispose<
    LastTrainingViewModel, LastActivityState?>((ref) {
  return LastTrainingViewModel(ref);
});

class LastTrainingViewModel extends StateNotifier<LastActivityState?> {
  late final Ref ref;
  final log = Logger('LastTrainingViewModel');

  LastTrainingViewModel(this.ref) : super(LastActivityState.initial());

  Future<void> fetchLastTraining() async {
    // This should fetch the last training. Currently thats only mock data
    ActivityPreview? healthValue =
        await ref.read(localHealthRepositoryProvider).getLastActivity();
    if (healthValue != null) {
      state = LastActivityState(
          calories: healthValue.caloriesBurnt,
          duration:
              healthValue.end.difference(healthValue.start).inMinutes.abs(),
          date: DateFormat(
            'dd.MM.yyyy',
          ).format(healthValue.start),
          activityType: healthValue.activityType,
          comment: "");
    } else {
      state = null;
    }
  }

  ActivityPreview? get activityPreview => state != null
      ? ActivityPreview(
          activityType: state!.activityType,
          caloriesBurnt: state!.calories,
          distance: 0.0, // You might need to add distance to LastActivityState
          start: DateTime.now().subtract(Duration(minutes: state!.duration)),
          end: DateTime.now(),
        )
      : null;
}
