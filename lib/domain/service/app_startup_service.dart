import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';

import '../../data/repositories/device_info_repository_impl.dart';
import '../../data/repositories/streak_repository_impl.dart';
import '../../presentation/challenges/provider/streak_provider.dart';
import '../../presentation/profile/view_model/profile_view_model.dart';
import '../repositories/device_info_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/streak_repository.dart';
import '../service/badge_service.dart';

final logger = Logger('AppStartupService');

class AppStartupService {
  final ProfileRepository profileRepository;
  final StreakRepository streakRepository;
  final BadgeService badgeService;
  final DeviceInfoRepository deviceInfoRepository;

  AppStartupService({
    required this.profileRepository,
    required this.streakRepository,
    required this.badgeService,
    required this.deviceInfoRepository,
  });

  Future<void> initialize() async {
    logger.info('Initializing app...');

    // Stelle sicher, dass die App-Daten initialisiert sind
    await deviceInfoRepository.initializeAppDates();

    // Lade das Installationsdatum und das aktuelle Schrittziel
    final installationDate = await deviceInfoRepository.getInstallationDate();
    final stepGoal = await profileRepository.getStepGoal();

    logger.info('Installation date: $installationDate, Step goal: $stepGoal');

    // Aktualisiere die Streak-Daten basierend auf dem Installationsdatum
    await streakRepository.checkAndUpdateStreaksSinceInstallation(
        installationDate, stepGoal);

    // Überprüfe und aktualisiere die Badges
    try {
      logger.info('Checking and updating badges...');
      await badgeService.checkAndUpdateBadges();
      logger.info('Badge update completed.');
    } catch (e) {
      logger.severe('Error updating badges: $e');
    }

    // Die letzte Aktualisierung auf heute setzen
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    await deviceInfoRepository.updateLastOpenedDate(todayNormalized);

    logger.info('App initialization completed');
  }
}

final appStartupServiceProvider = Provider<AppStartupService>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final streakRepository = ref.watch(streakRepositoryProvider);
  final badgeService = ref.watch(badgeServiceProvider);
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);

  return AppStartupService(
    profileRepository: profileRepository,
    streakRepository: streakRepository,
    badgeService: badgeService,
    deviceInfoRepository: deviceInfoRepository,
  );
});

// Provider, der beim App-Start die Initialisierung auslöst
final appInitializationProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.watch(appStartupServiceProvider);
  await service.initialize();
});
