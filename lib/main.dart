import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/app_logger.dart';
import 'package:movetopia/core/navigation_host.dart';
import 'package:movetopia/domain/service/app_startup_service.dart';
import 'package:movetopia/presentation/challenges/provider/badge_repository_provider.dart';
import 'package:movetopia/presentation/common/theme.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/profile/debug_settings/provider/debug_provider.dart';
import 'package:movetopia/presentation/profile/view_model/profile_view_model.dart';

import 'core/health_authorized_view_model.dart';
import 'data/service/health_service_impl.dart';
import 'domain/repositories/profile_repository.dart';

final initLoggerProvider = Provider((ref) {
  AppLogger.init();

  ref.listen<AsyncValue<bool>>(isDebugBuildProvider, (_, next) {
    next.whenData((isDebug) {
      AppLogger.updateDebugStatus(isDebug);
    });
  });

  return true; // Dummy-Wert
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.init();
  final log = AppLogger.getLogger('main');
  log.info('App gestartet');

  runApp(
    const ProviderScope(
      child: MoveTopiaApp(),
    ),
  );
}

final appInitProvider = Provider((ref) {
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

  ref.watch(initLoggerProvider);

  hasCompletedOnboarding.whenData((isCompleted) {
    if (isCompleted) {
      ref.read(myAppProvider).init();
    }
  });

  return hasCompletedOnboarding;
});

final myAppProvider = Provider((ref) {
  return MoveTopiaAppViewModel(ref);
});

interface class MoveTopiaAppViewModel {
  final Ref ref;
  final log = Logger('MoveTopiaAppViewModel');
  bool _isInitialized = false;

  MoveTopiaAppViewModel(this.ref);

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    log.info('Starting app initialization...');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
    ));

    try {
      await _initializeAppDates();
      await _checkAuthorization();
      await _initializeStreaks();
      await _forceCacheRefresh();

      log.info('App initialization completed successfully');
    } catch (e) {
      log.severe('Error during app initialization: $e');
    }
  }

  Future<void> _initializeAppDates() async {
    final deviceInfoRepository = ref.read(deviceInfoRepositoryProvider);
    await deviceInfoRepository.initializeAppDates();
  }

  Future<void> _initializeStreaks() async {
    try {
      ref.read(appInitializationProvider);
    } catch (e) {
      log.severe('Error during streak initialization: $e');
    }
  }

  Future<void> _checkAuthorization() async {
    try {
      final healthAuthViewModel = ref.read(healthViewModelProvider.notifier);
      await healthAuthViewModel.authorize();
      final state = ref.read(healthViewModelProvider);

      switch (state) {
        case HealthAuthViewModelState.authorized:
          log.info('Health data access authorized (basic).');
          break;
        case HealthAuthViewModelState.authorizedWithHistoricalAccess:
          log.info('Health data access authorized with historical access.');
          break;
        case HealthAuthViewModelState.authorizationNotGranted:
          log.warning(
              'Health data access not granted. Some features may not work properly.');
          break;
        case HealthAuthViewModelState.error:
          log.severe(
              'Health data access authorization error. Some features may not work properly.');
          break;
        case HealthAuthViewModelState.notAuthorized:
          log.warning(
              'Health data not authorized yet. App will prompt user for permissions.');
          break;
        default:
          log.warning("Unrecognized HealthAuthViewModelState: $state");
      }
    } catch (e) {
      log.severe('Error checking health authorization: $e');
    }
  }

  Future<void> _forceCacheRefresh() async {
    try {
      log.info('Forcing cache refresh for health data...');

      final healthServiceInstance = ref.read(healthService);
      healthServiceInstance.clearCache();
      log.info('Health data cache cleared');
    } catch (e) {
      log.warning('Failed to force cache refresh: $e');
    }
  }
}

class MoveTopiaApp extends HookConsumerWidget {
  const MoveTopiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(profileProvider).themeMode;
    final onboardingStatus = ref.watch(appInitProvider);

    ThemeData theme;
    bool useDarkTheme;

    switch (themeMode) {
      case AppThemeMode.light:
        useDarkTheme = false;
        break;
      case AppThemeMode.dark:
        useDarkTheme = true;
        break;
      case AppThemeMode.system:
        // System-Theme verwenden
        final Brightness platformBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        useDarkTheme = platformBrightness == Brightness.dark;
        break;
    }

    theme = useDarkTheme ? darkTheme : lightTheme;

    if (onboardingStatus is AsyncLoading) {
      return MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final router = ref.watch(navigationRoutesProvider);

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
    );
  }
}
