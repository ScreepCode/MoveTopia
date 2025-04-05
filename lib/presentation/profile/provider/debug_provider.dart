import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/core/app_logger.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/repositories/badge_repository_impl.dart';
import '../../../data/repositories/debug_repository_impl.dart';
import '../../../data/repositories/device_info_repository_impl.dart';
import '../../../data/repositories/streak_repository_impl.dart';
import '../../../domain/repositories/debug_repository.dart';
import '../../../domain/service/badge_service.dart';
import '../../challenges/badgeLists/viewmodel/badge_lists_view_model.dart';
import '../../challenges/provider/streak_provider.dart';

/// Ein StateNotifier für das Sammeln und Filtern von LogRecords
class AppLogNotifier extends StateNotifier<List<LogRecord>> {
  final _logger = AppLogger.getLogger('AppLogNotifier');

  AppLogNotifier() : super([]) {
    state = List.from(AppLogger.allLogs);

    Logger.root.onRecord.listen((record) {
      state = List.from(AppLogger.allLogs);
    });

    _logger.info('AppLogNotifier initialisiert');
  }

  void clearLogs() {
    AppLogger.allLogs.clear();
    state = [];
    _logger.info('Logs wurden gelöscht');
  }

  List<LogRecord> getFilteredLogs(String? category) {
    if (category == null || category.isEmpty) {
      return state;
    }
    return state.where((log) => log.loggerName.contains(category)).toList();
  }
}

/// Provider für alle App-Logs
final appLogsProvider = StateNotifierProvider<AppLogNotifier, List<LogRecord>>(
  (ref) => AppLogNotifier(),
);

// Provider für das Debug-Repository
final debugRepositoryProvider = Provider<DebugRepository>((ref) {
  final streakRepository = ref.watch(streakRepositoryProvider);
  final badgeRepository = ref.watch(badgeRepositoryProvider);
  final badgeService = ref.watch(badgeServiceProvider);
  return DebugRepositoryImpl(streakRepository, badgeRepository, badgeService);
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

// Provider für das Zurücksetzen der Badge-Daten
final resetBadgesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final debugRepository = ref.read(debugRepositoryProvider);

    // Badges zurücksetzen
    await debugRepository.resetBadgeData();
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

// Provider für die Validation aller Badges
final validateAllBadgesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final debugRepository = ref.read(debugRepositoryProvider);
    await debugRepository.validateAllBadges();

    // Badges im UI aktualisieren
    ref.read(badgeListsViewModelProvider.notifier).refreshBadges();
  };
});

// Provider für das Umschalten des Status eines einzelnen Badges
final toggleBadgeStatusProvider =
    Provider<Future<void> Function(int, bool)>((ref) {
  return (badgeId, achieved) async {
    final debugRepository = ref.read(debugRepositoryProvider);
    await debugRepository.toggleBadgeStatus(badgeId, achieved);

    // Badges im UI aktualisieren
    ref.read(badgeListsViewModelProvider.notifier).refreshBadges();
  };
});

// Provider für alle Badges
final allBadgesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final badgeRepository = ref.watch(badgeRepositoryProvider);
  final badges = await badgeRepository.getAllBadges();

  return badges
      .map((badge) => {
            'id': badge.id,
            'name': badge.name,
            'category': badge.category.toString().split('.').last,
            'isAchieved': badge.isAchieved,
          })
      .toList();
});

// Provider zum Löschen der Badges-Datenbank und Erzwingen eines kompletten Neustarts
final resetBadgesDatabaseProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      final databasePath = await getDatabasesPath();
      final badgesDbPath = path.join(databasePath, 'badges.db');
      final badgesDbFile = File(badgesDbPath);

      if (await badgesDbFile.exists()) {
        await badgesDbFile.delete();
        await BadgeRepositoryImpl.closeDatabase();

        ref.invalidate(allBadgesProvider);

        return;
      }
    } catch (e) {
      throw Exception('Fehler beim Zurücksetzen der Badges-Datenbank: $e');
    }
  };
});
