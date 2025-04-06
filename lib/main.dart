import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/app_logger.dart';
import 'package:movetopia/core/navigation_host.dart';
import 'package:movetopia/domain/service/app_startup_service.dart';
import 'package:movetopia/presentation/common/theme.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/profile/debug_settings/provider/debug_provider.dart';
import 'package:movetopia/presentation/profile/view_model/profile_view_model.dart';

import 'core/health_authorized_view_model.dart';
import 'data/repositories/device_info_repository_impl.dart';
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
    ));

    await _initializeAppDates();
    await _initializeStreaks();
    await _checkAuthorization();
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
    final healthAuthViewModel = ref.read(healthViewModelProvider.notifier);
    await healthAuthViewModel.authorize();
    final state = ref.read(healthViewModelProvider);
    switch (state) {
      case HealthAuthViewModelState.authorized:
        log.info('Health data access authorized.');
        break;
      case HealthAuthViewModelState.authorizationNotGranted:
        log.info('Health data access not granted.');
        break;
      case HealthAuthViewModelState.error:
        log.severe('Health data access authorization error.');
        break;
      default:
        log.warning("Unrecognized HealthAuthViewModelState: $state");
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
