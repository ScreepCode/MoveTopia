import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/authorizationWrapper.dart';
import 'package:movetopia/core/navigation_host.dart';
import 'package:movetopia/presentation/common/theme.dart';
import 'package:movetopia/presentation/profile/view_model/profile_view_model.dart';

import 'core/health_authorized_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: MoveTopiaApp()),
  );
}

final myAppProvider = Provider((ref) {
  return MoveTopiaAppViewModel(ref);
});

interface class MoveTopiaAppViewModel {
  final Ref ref;
  final log = Logger('MoveTopiaAppViewModel');
  bool _isInitialized = false;

  MoveTopiaAppViewModel(this.ref);

  void init() {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.message}');
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
    ));

    _checkAuthorization();
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

  MaterialApp buildMaterialApp(ThemeData theme) {
    return MaterialApp.router(
      routerConfig: navigationRoutes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(myAppProvider);
    var isDarkMode = ref.watch(profileProvider).isDarkMode;
    var theme = isDarkMode ? darkTheme : lightTheme;
    provider.init();
    return AuthorizationWrapper(
      child: buildMaterialApp(theme),
    );
  }
}
