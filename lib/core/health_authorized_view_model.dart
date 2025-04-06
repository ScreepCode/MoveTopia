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
      _checkInitialState();
    } catch (e) {
      log.severe('Failed to configure health package: $e');
    }
  }

  // Prüft den initialen Zustand der Gesundheitsberechtigungen
  Future<void> _checkInitialState() async {
    try {
      bool? hasBasicPermissions =
          await _health.hasPermissions(requiredReadPermissions);

      if (hasBasicPermissions == true) {
        state = HealthAuthViewModelState.authorized;

        try {
          bool hasHistorical = await _health.isHealthDataHistoryAuthorized();
          if (hasHistorical) {
            state = HealthAuthViewModelState.authorizedWithHistoricalAccess;
            log.info('Initial state: Historical health data access authorized');
          } else {
            log.info(
                'Initial state: Basic health data access authorized, no historical access');
          }
        } catch (e) {
          log.warning('Failed to check historical permissions initially: $e');
        }
      } else {
        log.info('Initial state: No health data access authorized');
      }
    } catch (e) {
      log.warning('Failed to check initial health permissions: $e');
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
            if (state !=
                HealthAuthViewModelState.authorizedWithHistoricalAccess) {
              state = HealthAuthViewModelState.authorized;
            }
          } else {
            state = HealthAuthViewModelState.authorizationNotGranted;
          }
        } catch (error) {
          log.severe('Health permission authorization error: $error');
          state = HealthAuthViewModelState.error;
        }
      } else {
        if (state != HealthAuthViewModelState.authorizedWithHistoricalAccess) {
          state = HealthAuthViewModelState.authorized;
        }
      }
    } catch (error) {
      log.severe('Health permission error: $error');
      state = HealthAuthViewModelState.error;
    }
  }

  /// Request OPTIONAL WRITE-Permissions
  /// You can only request WRITE when READ is already granted
  Future<bool> authorizeWriteAccess() async {
    if (state != HealthAuthViewModelState.authorized &&
        state != HealthAuthViewModelState.authorizedWithHistoricalAccess) {
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

  /// Request OPTIONAL HISTORICAL-Permissions
  /// You can only request HISTORICAL when READ is already granted
  Future<bool> authorizeHistoricalAccess() async {
    // Nur wenn grundlegende Read-Berechtigungen bereits gewährt wurden
    if (state != HealthAuthViewModelState.authorized &&
        state != HealthAuthViewModelState.authorizedWithHistoricalAccess) {
      return false;
    }

    try {
      log.info('Checking and requesting historical health data access');

      bool isHistoricalAuthorized =
          await _health.isHealthDataHistoryAuthorized();

      if (isHistoricalAuthorized) {
        log.info('Historical health data access already authorized');
        state = HealthAuthViewModelState.authorizedWithHistoricalAccess;
        return true;
      }

      log.info('Requesting historical health data access');
      bool success = await _health.requestHealthDataHistoryAuthorization();

      if (success) {
        log.info('Historical health data access granted');
        state = HealthAuthViewModelState.authorizedWithHistoricalAccess;
      } else {
        log.info('Historical health data access denied');
      }

      return success;
    } catch (error) {
      log.severe('Health historical permission error: $error');
      return false;
    }
  }

  Future<void> authorize() async {
    try {
      await authorizeReadAccess();

      if (state == HealthAuthViewModelState.authorized ||
          state == HealthAuthViewModelState.authorizedWithHistoricalAccess) {
        try {
          bool hasHistoricalPermissions =
              await _health.isHealthDataHistoryAuthorized();

          if (hasHistoricalPermissions &&
              state == HealthAuthViewModelState.authorized) {
            state = HealthAuthViewModelState.authorizedWithHistoricalAccess;
            log.info(
                'Historical health data access detected during authorization');
          }
        } catch (e) {
          log.warning(
              'Failed to check historical permissions during authorization: $e');
        }
      }
    } catch (e) {
      log.severe('Basic authorization failed: $e');
    }
  }
}

enum HealthAuthViewModelState {
  notAuthorized, // App started
  authorized,
  authorizedWithHistoricalAccess,
  authorizationNotGranted,
  error,
}
