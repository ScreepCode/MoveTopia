import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

class HealthConnectState {
  final bool isHealthConnectInstalled;
  final bool isAndroidBelow14;
  final bool isLoading;
  final String error;

  HealthConnectState({
    this.isHealthConnectInstalled = false,
    this.isAndroidBelow14 = false,
    this.isLoading = true,
    this.error = '',
  });

  HealthConnectState copyWith({
    bool? isHealthConnectInstalled,
    bool? isAndroidBelow14,
    bool? isLoading,
    String? error,
  }) {
    return HealthConnectState(
      isHealthConnectInstalled:
          isHealthConnectInstalled ?? this.isHealthConnectInstalled,
      isAndroidBelow14: isAndroidBelow14 ?? this.isAndroidBelow14,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HealthConnectNotifier extends StateNotifier<HealthConnectState> {
  final _health = Health();
  final _log = Logger('HealthConnectNotifier');

  HealthConnectNotifier() : super(HealthConnectState()) {
    _checkHealthConnect();
  }

  Future<void> _checkHealthConnect() async {
    if (!Platform.isAndroid) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      // Check Android version
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final isAndroidBelow14 =
          androidInfo.version.sdkInt < 34; // Android 14 is API level 34

      // Check if Health Connect is available
      final isHealthConnectInstalled = await _health.isHealthConnectAvailable();

      state = state.copyWith(
        isHealthConnectInstalled: isHealthConnectInstalled,
        isAndroidBelow14: isAndroidBelow14,
        isLoading: false,
        error: '',
      );
    } catch (e) {
      _log.severe('Error checking Health Connect status: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'error_checking_health_connect',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _checkHealthConnect();
  }

  /// Forcibly checks if Health Connect is installed by bypassing any caching
  Future<void> forceRefreshAfterResuming() async {
    state = state.copyWith(isLoading: true);

    if (!Platform.isAndroid) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      // Request a fresh check from the Health plugin
      final isHealthConnectInstalled = await _health.isHealthConnectAvailable();

      // Update state only if there's a change or if we previously had an error
      if (isHealthConnectInstalled != state.isHealthConnectInstalled ||
          state.error.isNotEmpty) {
        state = state.copyWith(
          isHealthConnectInstalled: isHealthConnectInstalled,
          isLoading: false,
          error: '',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _log.severe('Error forcibly checking Health Connect status: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'error_checking_health_connect',
      );
    }
  }

  /// Checks if Health Connect is installed with multiple attempts
  Future<bool> checkWithRetries(
      {int maxRetries = 3, int delaySeconds = 2}) async {
    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(Duration(seconds: delaySeconds + i));
      await forceRefreshAfterResuming(); // Use the more aggressive refresh

      if (state.isHealthConnectInstalled) {
        return true;
      }
    }
    return state.isHealthConnectInstalled;
  }

  /// Install Google Health Connect on this phone.
  Future<void> installHealthConnect() async {
    try {
      await _health.installHealthConnect();
    } catch (e) {
      _log.severe('Error installing Health Connect: $e');
      throw e;
    }
  }
}

final healthConnectProvider =
    StateNotifierProvider<HealthConnectNotifier, HealthConnectState>(
  (ref) => HealthConnectNotifier(),
);
