import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/device_info_repository_impl.dart';
import '../../../data/repositories/local_health_impl.dart';
import '../../../data/repositories/streak_repository_impl.dart';
import '../../profile/view_model/profile_view_model.dart';

// Logger für Streak-Provider
final _logger = Logger('StreakProvider');

// Provider für SharedPreferences
final sharedPreferencesProvider = Provider<Future<SharedPreferences>>((ref) {
  return SharedPreferences.getInstance();
});

// StreamProvider für Aktualisierungen
final streakRefreshProvider = StateProvider<int>((ref) => 0);

// Provider für die aktuelle Streak-Anzahl
final streakCountProvider = FutureProvider<int>((ref) async {
  // Beobachte den Refresh-Provider, um Aktualisierungen zu erhalten
  ref.watch(streakRefreshProvider);
  final repository = ref.watch(streakRepositoryProvider);
  return repository.getStreakCount();
});

// Provider für die Liste der abgeschlossenen Tage
final completedDaysProvider = FutureProvider<List<DateTime>>((ref) async {
  // Beobachte den Refresh-Provider, um Aktualisierungen zu erhalten
  ref.watch(streakRefreshProvider);
  final repository = ref.watch(streakRepositoryProvider);
  return repository.getCompletedDays();
});

// Provider für das letzte abgeschlossene Datum
final lastCompletedDateProvider = FutureProvider<DateTime?>((ref) async {
  final streakRepository = ref.watch(streakRepositoryProvider);
  return streakRepository.getLastCompletedDate();
});

// Provider für die Überprüfung und Aktualisierung der Streak
final updateStreakProvider =
    Provider<Future<void> Function(UpdateStreakParams)>((ref) {
  return (params) async {
    final streakRepository = ref.read(streakRepositoryProvider);
    final updated =
        await streakRepository.checkAndUpdateStreak(params.steps, params.goal);
    if (updated) {
      ref.read(streakRefreshProvider.notifier).state++;
    }
  };
});

// Provider zum Aktualisieren der Streak-Daten anhand von echten Health-Daten
final refreshStreakFromHealthDataProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    _logger.info('Aktualisiere Streak-Daten mit echten Health-Daten...');

    final deviceInfoRepository = ref.read(deviceInfoRepositoryProvider);
    final streakRepository = ref.read(streakRepositoryProvider);
    final healthRepository = ref.read(localHealthRepositoryProvider);
    final profileRepository = ref.read(profileRepositoryProvider);

    try {
      // Lade das Installationsdatum und das Schrittziel
      final installationDate = await deviceInfoRepository.getInstallationDate();
      final stepGoal = await profileRepository.getStepGoal();

      _logger.info(
          'Installationsdatum: $installationDate, Schrittziel: $stepGoal');

      // Hole die bestehenden abgeschlossenen Tage
      final existingCompletedDays = await streakRepository.getCompletedDays();
      _logger.info(
          'Bestehende abgeschlossene Tage: ${existingCompletedDays.length}');

      // Prüfe jeden Tag seit der Installation
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final completedDaysSet = <String>{};
      final newCompletedDays = <DateTime>[];

      // Setze alle bestehenden Tage zurück
      _logger.info('Setze bestehende Tage zurück...');
      await streakRepository.saveCompletedDaysList([]);

      // Streak-Zähler zurücksetzen, damit auch eine Korrektur nach unten möglich ist
      await streakRepository.saveStreakCount(0);
      _logger.info('Streak-Zähler zurückgesetzt');

      // Iteriere über alle Tage seit der Installation
      for (var day = installationDate;
          day.isBefore(today) || day.isAtSameMomentAs(today);
          day = day.add(const Duration(days: 1))) {
        final normalizedDay = DateTime(day.year, day.month, day.day);

        // Hole die Schritte für diesen Tag
        final startOfDay = normalizedDay;
        final endOfDay = DateTime(normalizedDay.year, normalizedDay.month,
            normalizedDay.day, 23, 59, 59);

        final steps =
            await healthRepository.getStepsInInterval(startOfDay, endOfDay);
        _logger.info('Tag: $normalizedDay, Schritte: $steps, Ziel: $stepGoal');

        // Prüfe, ob das Tagesziel erreicht wurde
        if (steps >= stepGoal) {
          _logger.info('Tagesziel erreicht für $normalizedDay');
          newCompletedDays.add(normalizedDay);
          // Vermerke den Tag als abgeschlossen
          completedDaysSet.add(normalizedDay.toIso8601String().split('T')[0]);
        }
      }

      // Speichere alle neuen Tage auf einmal, um Performanz zu verbessern
      await streakRepository.saveCompletedDaysList(newCompletedDays);
      _logger.info(
          '${newCompletedDays.length} Tage als abgeschlossen gespeichert');

      // Berechne die Streak neu basierend auf den neuen Tagen
      final updatedDays = await streakRepository.getCompletedDays();
      _logger
          .info('Neuberechnung der Streak mit ${updatedDays.length} Tagen...');

      // Verwende die öffentliche Methode zur Neuberechnung der Streak
      await streakRepository.checkAndUpdateStreaksSinceInstallation(
          installationDate, stepGoal);
      _logger.info(
          'Streak-Länge wurde mit checkAndUpdateStreaksSinceInstallation neu berechnet');

      // Hole die aktuelle Streak-Länge zur Kontrolle
      final currentStreak = await streakRepository.getStreakCount();
      _logger.info('Aktuelle Streak-Länge: $currentStreak');

      // Aktualisiere den letzten Aktualisierungszeitpunkt
      await deviceInfoRepository.updateLastOpenedDate(today);

      // Aktualisiere den UI-Provider erst nach Abschluss aller Berechnungen
      ref.read(streakRefreshProvider.notifier).state++;
      _logger.info('UI-Refresh-Counter erhöht, UI sollte aktualisiert werden');

      _logger.info(
          'Streak-Aktualisierung abgeschlossen. ${completedDaysSet.length} Tage erfüllt.');
    } catch (e, stackTrace) {
      _logger.severe(
          'Fehler beim Aktualisieren der Streak-Daten', e, stackTrace);
      throw Exception('Fehler beim Aktualisieren der Streak-Daten: $e');
    }
  };
});

/// Klasse für die Streak-Farben
class StreakColors {
  /// Lila Farbe für aktive Streaks
  static const Color active = Color(0xFFAF52DE);

  /// Rote Farbe für unterbrochene Streaks
  static const Color broken = Color(0xFFFF8A80);

  /// Graue Farbe für nicht abgeschlossene Tage
  static const Color notCompleted = Color(0xFFE0E0E0);
}

/// Parameter-Klasse für die Streak-Aktualisierung
class UpdateStreakParams {
  final int steps;
  final int goal;

  UpdateStreakParams({required this.steps, required this.goal});
}

/// Erweiterung für DateTime, um mit Streak-Daten zu arbeiten
extension StreakDateTimeExtension on DateTime {
  /// Prüft, ob das Datum heute ist
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Prüft, ob das Datum gestern war
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Prüft, ob das Datum im abgeschlossenen Tage-Array ist
  bool isCompletedIn(List<DateTime> completedDays) {
    return completedDays.any((completedDay) =>
        year == completedDay.year &&
        month == completedDay.month &&
        day == completedDay.day);
  }

  /// Bestimmt die Farbe für die Streak-Anzeige im Kalender
  Color getStreakColor(List<DateTime> completedDays) {
    // Wenn dieser Tag nicht erledigt ist, grau anzeigen
    if (!isCompletedIn(completedDays)) {
      return StreakColors.notCompleted;
    }

    // Aktuelle Streak bis heute oder gestern berechnen
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Prüfen ob heute oder gestern abgeschlossen ist
    final isTodayCompleted = today.isCompletedIn(completedDays);
    final isYesterdayCompleted = yesterday.isCompletedIn(completedDays);

    // Wenn weder heute noch gestern abgeschlossen ist, zeige alle als unterbrochen an
    if (!isTodayCompleted && !isYesterdayCompleted) {
      return StreakColors.broken;
    }

    // Bestimme das letzte gültige Streak-Datum (heute oder gestern)
    final lastValidStreakDate = isTodayCompleted ? today : yesterday;

    // Wenn dieser Tag Teil der aktuellen Streak ist, lila anzeigen
    final streakStartDate =
        _findStreakStartDate(lastValidStreakDate, completedDays);
    final normalizedThisDate = DateTime(year, month, day);

    // Wenn das Datum zwischen dem Streak-Startdatum und dem letzten gültigen Datum liegt
    if ((normalizedThisDate.isAtSameMomentAs(streakStartDate) ||
            normalizedThisDate.isAfter(streakStartDate)) &&
        (normalizedThisDate.isAtSameMomentAs(lastValidStreakDate) ||
            normalizedThisDate.isBefore(lastValidStreakDate))) {
      return StreakColors.active;
    }

    // Ansonsten ist es ein unterbrochener Streak-Tag
    return StreakColors.broken;
  }

  /// Hilfsmethode zum Finden des Startdatums einer Streak
  DateTime _findStreakStartDate(
      DateTime endDate, List<DateTime> completedDays) {
    var currentDate = endDate;

    while (true) {
      final previousDay = currentDate.subtract(const Duration(days: 1));

      if (previousDay.isCompletedIn(completedDays)) {
        currentDate = previousDay;
      } else {
        break;
      }
    }

    return currentDate;
  }
}
