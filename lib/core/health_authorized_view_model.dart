import 'dart:async';

import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';

final healthViewModelProvider =
    StateNotifierProvider<HealthAuthViewModel, HealthAuthViewModelState>(
  (ref) => HealthAuthViewModel(ref),
);

class HealthAuthViewModel extends StateNotifier<HealthAuthViewModelState> {
  final Ref ref;
  final _health = Health();
  final log = Logger('HealthAuthViewModel');

  final requiredReadPermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED
  ];

  final optionalWritePermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WORKOUT
  ];

  HealthAuthViewModel(this.ref)
      : super(HealthAuthViewModelState.notAuthorized) {
    try {
      _health.configure();
    } catch (e) {
      log.severe('Failed to configure health package: $e');
    }
  }

  /// Request REQUIRED READ-Permissions
  Future<void> authorizeReadAccess() async {
    try {
      bool? hasPermissions =
          await _health.hasPermissions(requiredReadPermissions);

      if (hasPermissions == null || !hasPermissions) {
        try {
          List<HealthDataAccess> accessPermissions = List.filled(
              requiredReadPermissions.length, HealthDataAccess.READ);

          bool authorized = await _health.requestAuthorization(
              requiredReadPermissions,
              permissions: accessPermissions);

          if (authorized) {
            state = HealthAuthViewModelState.authorized;
          } else {
            state = HealthAuthViewModelState.authorizationNotGranted;
          }
        } catch (error) {
          log.severe('Health permission authorization error: $error');
          state = HealthAuthViewModelState.error;
        }
      } else {
        state = HealthAuthViewModelState.authorized;
      }
    } catch (error) {
      log.severe('Health permission error: $error');
      state = HealthAuthViewModelState.error;
    }
  }

  /// Request OPTIONAL WRITE-Permissions
  /// You can only request WRITE when READ is already granted
  Future<bool> authorizeWriteAccess() async {
    if (state != HealthAuthViewModelState.authorized) {
      return false;
    }

    try {
      List<HealthDataAccess> accessPermissions =
          List.filled(optionalWritePermissions.length, HealthDataAccess.WRITE);

      bool authorized = await _health.requestAuthorization(
          optionalWritePermissions,
          permissions: accessPermissions);
      return authorized;
    } catch (error) {
      log.severe('Health write permission error: $error');
      return false;
    }
  }

  Future<void> authorize() async {
    await authorizeReadAccess();
  }
}

enum HealthAuthViewModelState {
  notAuthorized, // App started
  authorized,
  authorizationNotGranted,
  error,
}
