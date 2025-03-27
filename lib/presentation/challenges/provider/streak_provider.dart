import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/device_info_repository_impl.dart';
import '../../../data/repositories/local_health_impl.dart';
import '../../../data/repositories/streak_repository_impl.dart';
import '../../../domain/repositories/local_health.dart';
import '../../../domain/repositories/streak_repository.dart';
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

      // Setze alle bestehenden Tage zurück
      _logger.info('Setze bestehende Tage zurück...');
      await streakRepository.saveCompletedDaysList([]);

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
          await streakRepository.saveCompletedDay(normalizedDay);
          // Vermerke den Tag als abgeschlossen
          completedDaysSet.add(normalizedDay.toIso8601String().split('T')[0]);
        }
      }

      // Aktualisiere den letzten Aktualisierungszeitpunkt
      await deviceInfoRepository.updateLastOpenedDate(today);

      // Aktualisiere den UI-Provider
      ref.read(streakRefreshProvider.notifier).state++;

      _logger.info(
          'Streak-Aktualisierung abgeschlossen. ${completedDaysSet.length} Tage erfüllt.');
    } catch (e, stackTrace) {
      _logger.severe(
          'Fehler beim Aktualisieren der Streak-Daten', e, stackTrace);
      throw Exception('Fehler beim Aktualisieren der Streak-Daten: $e');
    }
  };
});

// Parameter-Klasse für die Streak-Aktualisierung
class UpdateStreakParams {
  final int steps;
  final int goal;

  UpdateStreakParams({required this.steps, required this.goal});
}

// Erweiterung der DateTime-Klasse für einfachere Handhabung
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  Color getStreakColor(List<DateTime> completedDays) {
    // Prüfe, ob der aktuelle Tag abgeschlossen ist
    final isCompleted = completedDays.any((completedDay) =>
        year == completedDay.year &&
        month == completedDay.month &&
        day == completedDay.day);

    if (!isCompleted) {
      return Colors.grey.shade300; // Hellgrau für nicht erreichte Tage
    }

    // Sortiere die abgeschlossenen Tage
    final sortedDays = List<DateTime>.from(completedDays)..sort();

    // Finde die aktuelle Streak (die bis heute reicht)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Prüfe, ob heute in der Liste der abgeschlossenen Tage ist
    final isTodayCompleted = sortedDays.any((day) =>
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day);

    // Finde die aktuelle aktive Streak (die bis heute reicht oder gestern endet)
    DateTime currentStreakStart = today;
    bool isPartOfCurrentStreak = false;

    if (isTodayCompleted) {
      // Wenn heute erledigt ist, prüfe wie weit die aktuelle Streak zurückreicht
      DateTime checkDate = today;
      while (true) {
        final previousDay = checkDate.subtract(const Duration(days: 1));
        if (previousDay.isBefore(DateTime(2024, 1, 1))) break;

        final isPreviousDayCompleted = sortedDays.any((day) =>
            day.year == previousDay.year &&
            day.month == previousDay.month &&
            day.day == previousDay.day);

        if (isPreviousDayCompleted) {
          checkDate = previousDay;
          currentStreakStart = previousDay;
        } else {
          break;
        }
      }

      // Prüfe, ob der aktuelle Tag Teil der aktuellen Streak ist
      isPartOfCurrentStreak =
          (this.isAfter(currentStreakStart.subtract(const Duration(days: 1))) ||
                  this.year == currentStreakStart.year &&
                      this.month == currentStreakStart.month &&
                      this.day == currentStreakStart.day) &&
              (this.isBefore(today.add(const Duration(days: 1))) ||
                  this.year == today.year &&
                      this.month == today.month &&
                      this.day == today.day);
    } else {
      // Wenn heute nicht erledigt ist, prüfe ob gestern erledigt wurde (dann ist das noch Teil der aktuellen Streak)
      final yesterday = today.subtract(const Duration(days: 1));
      final isYesterdayCompleted = sortedDays.any((day) =>
          day.year == yesterday.year &&
          day.month == yesterday.month &&
          day.day == yesterday.day);

      if (isYesterdayCompleted) {
        currentStreakStart = yesterday;
        DateTime checkDate = yesterday;

        while (true) {
          final previousDay = checkDate.subtract(const Duration(days: 1));
          if (previousDay.isBefore(DateTime(2024, 1, 1))) break;

          final isPreviousDayCompleted = sortedDays.any((day) =>
              day.year == previousDay.year &&
              day.month == previousDay.month &&
              day.day == previousDay.day);

          if (isPreviousDayCompleted) {
            checkDate = previousDay;
            currentStreakStart = previousDay;
          } else {
            break;
          }
        }

        // Prüfe, ob der aktuelle Tag Teil der gestern endenden Streak ist
        isPartOfCurrentStreak = (this.isAfter(
                    currentStreakStart.subtract(const Duration(days: 1))) ||
                this.year == currentStreakStart.year &&
                    this.month == currentStreakStart.month &&
                    this.day == currentStreakStart.day) &&
            (this.isBefore(yesterday.add(const Duration(days: 1))) ||
                this.year == yesterday.year &&
                    this.month == yesterday.month &&
                    this.day == yesterday.day);
      }
    }

    if (isPartOfCurrentStreak) {
      return const Color(0xFFAF52DE); // Lila für aktive Streak
    } else {
      return Colors.red.shade300; // Rot für unterbrochene Streak
    }
  }
}
