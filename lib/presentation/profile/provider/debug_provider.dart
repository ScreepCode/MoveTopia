import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/debug_repository_impl.dart';
import '../../../data/repositories/device_info_repository_impl.dart';
import '../../../data/repositories/streak_repository_impl.dart';
import '../../../domain/repositories/debug_repository.dart';
import '../../../domain/repositories/device_info_repository.dart';
import '../../challenges/provider/streak_provider.dart';

// Provider für das Debug-Repository
final debugRepositoryProvider = Provider<DebugRepository>((ref) {
  final streakRepository = ref.watch(streakRepositoryProvider);
  return DebugRepositoryImpl(streakRepository);
});

// Provider um zu prüfen, ob die App im Debug-Modus läuft
final isDebugBuildProvider = FutureProvider<bool>((ref) async {
  final debugRepository = ref.watch(debugRepositoryProvider);
  return debugRepository.isDebugBuild();
});

// Provider für das Installationsdatum
final installationDateProvider = FutureProvider<DateTime>((ref) async {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return await deviceInfoRepository.getInstallationDate();
});

// Provider für das letzte Aktualisierungsdatum
final lastOpenedDateProvider = FutureProvider<DateTime>((ref) async {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return await deviceInfoRepository.getLastOpenedDate();
});

// Provider zum Aktualisieren des Installationsdatums
final updateInstallationDateProvider =
    Provider<Future<void> Function(DateTime)>((ref) {
  return (DateTime newDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('installationDate', newDate.toIso8601String());
    // Refresh the provider
    ref.refresh(installationDateProvider);
  };
});

// Provider zum Aktualisieren des letzten Aktualisierungsdatums
final updateLastOpenedDateProvider =
    Provider<Future<void> Function(DateTime)>((ref) {
  return (DateTime newDate) async {
    final deviceInfoRepository = ref.read(deviceInfoRepositoryProvider);
    await deviceInfoRepository.updateLastOpenedDate(newDate);
    // Refresh the provider
    ref.refresh(lastOpenedDateProvider);
  };
});

// Provider für das Zurücksetzen der Streak-Daten
final resetStreakProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final debugRepository = ref.read(debugRepositoryProvider);
    await debugRepository.resetStreakData();
    ref.read(streakRefreshProvider.notifier).state++;
  };
});

// Provider für die Simulation von vergangenen Tagen
final simulateStreakForPastDaysProvider =
    Provider<Future<void> Function(int)>((ref) {
  return (days) async {
    final debugRepository = ref.read(debugRepositoryProvider);
    await debugRepository.simulateStreakForPastDays(days);
    ref.read(streakRefreshProvider.notifier).state++;
  };
});

// Provider für die Simulation eines bestimmten Tages
final simulateStreakForDateProvider =
    Provider<Future<void> Function(DateTime)>((ref) {
  return (date) async {
    final debugRepository = ref.read(debugRepositoryProvider);
    await debugRepository.simulateStreakForSpecificDate(date);
    ref.read(streakRefreshProvider.notifier).state++;
  };
});
