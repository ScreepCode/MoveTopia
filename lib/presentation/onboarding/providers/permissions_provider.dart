import 'dart:async';

import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/health_authorized_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionsState>(
  (ref) => PermissionsNotifier(ref),
);

class PermissionsState {
  final PermissionStatus locationPermissionStatus;
  final PermissionStatus activityPermissionStatus;
  final PermissionStatus notificationPermissionStatus;
  final bool healthPermissionStatus;
  final bool healthWritePermissionStatus;

  bool get hasRequiredPermissions => healthPermissionStatus;

  PermissionsState({
    this.locationPermissionStatus = PermissionStatus.denied,
    this.activityPermissionStatus = PermissionStatus.denied,
    this.notificationPermissionStatus = PermissionStatus.denied,
    this.healthPermissionStatus = false,
    this.healthWritePermissionStatus = false,
  });

  PermissionsState copyWith({
    PermissionStatus? locationPermissionStatus,
    PermissionStatus? activityPermissionStatus,
    PermissionStatus? notificationPermissionStatus,
    bool? healthPermissionStatus,
    bool? healthWritePermissionStatus,
  }) {
    return PermissionsState(
      locationPermissionStatus:
          locationPermissionStatus ?? this.locationPermissionStatus,
      activityPermissionStatus:
          activityPermissionStatus ?? this.activityPermissionStatus,
      notificationPermissionStatus:
          notificationPermissionStatus ?? this.notificationPermissionStatus,
      healthPermissionStatus:
          healthPermissionStatus ?? this.healthPermissionStatus,
      healthWritePermissionStatus:
          healthWritePermissionStatus ?? this.healthWritePermissionStatus,
    );
  }

  @override
  String toString() {
    return 'PermissionsState(location: $locationPermissionStatus, activity: $activityPermissionStatus, notification: $notificationPermissionStatus, health: $healthPermissionStatus, healthWrite: $healthWritePermissionStatus)';
  }
}

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  final Ref ref;
  final _health = Health();
  final neededPermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED
  ];

  final writePermissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WORKOUT
  ];

  final log = Logger('PermissionsNotifier');

  PermissionsNotifier(this.ref) : super(PermissionsState()) {
    try {
      _health.configure();
    } catch (e) {
      log.severe(
          'Failed to configure health package in PermissionsNotifier: $e');
    }
    checkAllPermissions();
  }

  // Check all permissions
  Future<void> checkAllPermissions() async {
    try {
      await checkLocationPermission();
      await checkActivityPermission();
      await checkNotificationPermission();
      await checkHealthPermission();
      await checkHealthWritePermission();
    } catch (e) {
      log.severe('Error checking all permissions: $e');
    }
  }

  // Check location permission
  Future<void> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      state = state.copyWith(locationPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking location permission: $e');
    }
  }

  // Request location permission
  Future<void> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      state = state.copyWith(locationPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting location permission: $e');
    }
  }

  // Check activity recognition permission
  Future<void> checkActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.status;
      state = state.copyWith(activityPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking activity recognition permission: $e');
    }
  }

  // Request activity recognition permission
  Future<void> requestActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      state = state.copyWith(activityPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting activity recognition permission: $e');
    }
  }

  // Check notification permission
  Future<void> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      state = state.copyWith(notificationPermissionStatus: status);
    } catch (e) {
      log.severe('Error checking notification permission: $e');
    }
  }

  // Request notification permission
  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      state = state.copyWith(notificationPermissionStatus: status);
    } catch (e) {
      log.severe('Error requesting notification permission: $e');
    }
  }

  Future<void> checkHealthPermission() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(neededPermissions);

      state = state.copyWith(healthPermissionStatus: hasPermissions ?? false);

      final healthViewModel = ref.read(healthViewModelProvider);

      if (healthViewModel == HealthAuthViewModelState.authorized &&
          !state.healthPermissionStatus) {
        state = state.copyWith(healthPermissionStatus: true);
      }
    } catch (e) {
      log.severe("Error checking health permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
      state = state.copyWith(healthPermissionStatus: false);
    }
  }

  // Check health write permissions
  Future<void> checkHealthWritePermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // If read permissions aren't granted, write permissions can't be granted
        state = state.copyWith(healthWritePermissionStatus: false);
        return;
      }

      // Check for WRITE permissions on the optional write permissions
      bool? hasWritePermissions = await _health.hasPermissions(
        writePermissions,
        permissions:
            List.filled(writePermissions.length, HealthDataAccess.WRITE),
      );

      state = state.copyWith(
          healthWritePermissionStatus: hasWritePermissions ?? false);
    } catch (e) {
      log.severe("Error checking health write permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
      state = state.copyWith(healthWritePermissionStatus: false);
    }
  }

  // Request health permission
  Future<void> requestHealthPermission() async {
    try {
      // Rufe die authorize-Methode von HealthAuthViewModel auf
      final healthViewModel = ref.read(healthViewModelProvider.notifier);
      await healthViewModel.authorize();

      final result = ref.read(healthViewModelProvider);

      state = state.copyWith(
          healthPermissionStatus:
              result == HealthAuthViewModelState.authorized);

      // After updating read permissions, check write permissions as well
      if (result == HealthAuthViewModelState.authorized) {
        await checkHealthWritePermission();
      }
    } catch (e) {
      log.severe("Error requesting health permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
    }
  }

  // Request health write permissions
  Future<void> requestHealthWritePermission() async {
    try {
      if (!state.healthPermissionStatus) {
        // Can't request write permissions if read permissions aren't granted
        return;
      }

      // Request write permissions
      final healthViewModel = ref.read(healthViewModelProvider.notifier);
      bool success = await healthViewModel.authorizeWriteAccess();

      // Update state
      state = state.copyWith(healthWritePermissionStatus: success);
    } catch (e) {
      log.severe("Error requesting health write permission: $e");
      log.severe("Stack trace: ${StackTrace.current}");
    }
  }
}
