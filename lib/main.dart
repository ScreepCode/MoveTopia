import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathon/presentation/common/theme.dart';
import 'package:hackathon/presentation/me/view_model/profile_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:hackathon/core/navigation_host.dart';
import 'core/health_authorized_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: HackathonApp()),
  );
}

final myAppProvider = Provider((ref) {
  return HackathonAppViewModel(ref);
});

interface class HackathonAppViewModel {
  final Ref ref;
  final log = Logger('HackathonAppViewModel');

  init() {
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

    HealthAuthViewModelState state = ref.watch(healthViewModelProvider);
    // React to changes in the health authorization state
    switch (state) {
      case HealthAuthViewModelState.authorized:
        // Proceed with actions that require health data
        log.info('Health data access authorized.');
      case HealthAuthViewModelState.authorizationNotGranted:
        // Handle user denial of authorization
        log.info('Health data access not granted.');
      case HealthAuthViewModelState.error:
        // Handle authorization error
        log.severe('Health data access authorization error.');
      default:
        // Handle unexpected state (optional)
        log.warning("Unrecognized HealthAuthViewModelState: $state");
    }
  }

  HackathonAppViewModel(this.ref);
}

class HackathonApp extends HookConsumerWidget {
  const HackathonApp({super.key});

  MaterialApp buildMaterialApp(theme) {
    return MaterialApp.router(
      routerConfig: navigationRoutes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
      // darkTheme: const MaterialTheme(Typography.whiteHelsinki).dark(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(myAppProvider);
    var isDarkMode = ref.watch(profileProvider)['isDarkMode'];
    var theme = isDarkMode
        ? const MaterialTheme(Typography.whiteHelsinki).dark()
        : const MaterialTheme(Typography.whiteHelsinki).light();
    provider.init();
    return buildMaterialApp(theme);
  }
}
