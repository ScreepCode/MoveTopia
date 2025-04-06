import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/device_info_repository_impl.dart';
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
    final profileRepository = ref.read(profileRepositoryProvider);

    try {
      final installationDate = await deviceInfoRepository.getInstallationDate();
      final currentStepGoal = await profileRepository.getStepGoal();

      _logger.info(
          'Installationsdatum: $installationDate, Aktuelles Schrittziel: $currentStepGoal');

      await streakRepository.checkAndUpdateStreaksSinceInstallation(
          installationDate, currentStepGoal);
      _logger.info('Streak wurde mit aktuellem Ziel aktualisiert');

      final currentStreak = await streakRepository.getStreakCount();
      final updatedDays = await streakRepository.getCompletedDays();
      _logger.info(
          'Aktuelle Streak-Länge: $currentStreak, Erfüllte Tage: ${updatedDays.length}');

      ref.read(streakRefreshProvider.notifier).state++;
      _logger.info('UI-Refresh-Counter erhöht, UI sollte aktualisiert werden');
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
    return completedDays.any((completedDay) => isSameDay(this, completedDay));
  }

  /// Prüft, ob zwei Tage das gleiche Datum haben (ignoriert Uhrzeit)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Normalisiert ein DateTime-Objekt auf Tagesebene (setzt Stunden, Minuten, Sekunden auf 0)
  static DateTime normalizeDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Findet den Beginn der aktuellen Streak basierend auf dem letzten aktiven Tag
  static DateTime findStreakStartDate(
      DateTime lastActiveDate, List<DateTime> completedDays) {
    var streakStartDate = lastActiveDate;
    var currentDate = lastActiveDate.subtract(const Duration(days: 1));

    while (currentDate.isCompletedIn(completedDays)) {
      streakStartDate = currentDate;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streakStartDate;
  }

  /// Prüft, ob alle Tage zwischen Start und Ende (inklusive) in der Liste der
  /// abgeschlossenen Tage sind
  static bool hasAllDaysCompleted(
      DateTime startDate, DateTime endDate, List<DateTime> completedDays) {
    // Wenn Start nach Ende liegt, ist etwas falsch
    if (startDate.isAfter(endDate)) return false;

    // Wenn Start und Ende gleich sind, einfach prüfen, ob dieser Tag abgeschlossen ist
    if (isSameDay(startDate, endDate)) {
      return endDate.isCompletedIn(completedDays);
    }

    // Alle Tage im Zeitraum prüfen
    var currentDate = normalizeDay(startDate);

    while (!isSameDay(currentDate, endDate)) {
      if (!completedDays.any((day) => isSameDay(day, currentDate))) {
        return false;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Prüfe auch den letzten Tag (endDate)
    return completedDays.any((day) => isSameDay(day, endDate));
  }

  /// Bestimmt die Farbe für die Streak-Anzeige im Kalender
  Color getStreakColor(List<DateTime> completedDays) {
    // Wenn dieser Tag nicht abgeschlossen ist, grau anzeigen
    if (!isCompletedIn(completedDays)) {
      // Sonderfall: Heutiger Tag mit aktiver Streak von gestern
      if (isToday) {
        final yesterday = subtract(const Duration(days: 1));
        final isYesterdayCompleted = yesterday.isCompletedIn(completedDays);

        // Wenn gestern abgeschlossen wurde, ist heute Teil der potentiellen Streak
        if (isYesterdayCompleted) {
          // Prüfen, ob gestern Teil einer aktiven Streak war
          final yesterdayColor = yesterday.getStreakColor(completedDays);
          if (yesterdayColor == StreakColors.active) {
            // Heute ist noch nicht abgeschlossen, aber Teil einer aktiven Streak
            // Spezielle Farbe zurückgeben oder .notCompleted, je nach UI-Anforderung
            return StreakColors.notCompleted;
          }
        }
      }

      return StreakColors.notCompleted;
    }

    // Aktuelle Streak-Daten ermitteln
    final StreakInfo streakInfo = getStreakInfo(completedDays);

    // Wenn keine aktive Streak existiert, sind alle abgeschlossenen Tage unterbrochen
    if (!streakInfo.hasActiveStreak) {
      return StreakColors.broken;
    }

    // Prüfe, ob dieser Tag Teil der aktiven Streak ist
    final normalizedThisDate = normalizeDay(this);

    // Wir wissen, dass diese Werte nicht null sind, wenn hasActiveStreak true ist
    final streakStartDate = streakInfo.streakStartDate!;
    final lastActiveDate = streakInfo.lastActiveDate!;

    // Tag liegt innerhalb der Streak-Zeitraums
    if (!normalizedThisDate.isBefore(streakStartDate) &&
        !normalizedThisDate.isAfter(lastActiveDate)) {
      // Prüfe, ob der Tag der Startpunkt der Streak ist oder nicht
      if (isSameDay(normalizedThisDate, streakStartDate)) {
        return StreakColors.active;
      }

      // Für alle anderen Tage in der aktiven Streak:
      // Prüfe, ob alle Tage vom Streak-Start bis zu diesem Tag lückenlos abgeschlossen sind
      bool allPreviousDaysCompleted = true;
      var checkDate = normalizeDay(streakStartDate);

      while (!isSameDay(checkDate, normalizedThisDate)) {
        if (!completedDays.any((day) => isSameDay(day, checkDate))) {
          allPreviousDaysCompleted = false;
          break;
        }
        checkDate = checkDate.add(const Duration(days: 1));
      }

      // Wenn alle Tage bis zu diesem Datum ohne Lücke abgeschlossen sind, aktiv, sonst unterbrochen
      return allPreviousDaysCompleted
          ? StreakColors.active
          : StreakColors.broken;
    }

    // Sonderfall: Prüfe, ob der Tag unmittelbar an eine aktive Streak anschließt
    final previousDay = normalizedThisDate.subtract(const Duration(days: 1));

    // Wenn der Vortag das letzte aktive Datum der Streak ist, kann dieser Tag
    // als potenzielle Fortsetzung der Streak betrachtet werden
    if (isSameDay(previousDay, lastActiveDate)) {
      return StreakColors.active;
    }

    // Der Tag liegt außerhalb der aktuellen Streak und schließt nicht unmittelbar an
    return StreakColors.broken;
  }

  /// Gibt Informationen über die aktuelle Streak zurück
  static StreakInfo getStreakInfo(List<DateTime> completedDays) {
    final now = DateTime.now();
    final today = normalizeDay(now);
    final yesterday = today.subtract(const Duration(days: 1));

    // Aktive Streak existiert, wenn heute oder gestern abgeschlossen ist
    final isTodayCompleted = today.isCompletedIn(completedDays);
    final isYesterdayCompleted = yesterday.isCompletedIn(completedDays);

    // Wenn weder heute noch gestern abgeschlossen ist, gibt es keine aktive Streak
    if (!isTodayCompleted && !isYesterdayCompleted) {
      return StreakInfo(
          hasActiveStreak: false,
          lastActiveDate: null,
          streakStartDate: null,
          streakLength: 0);
    }

    // Das letzte abgeschlossene Datum bestimmt das Ende der aktuellen Streak
    final lastActiveDate = isTodayCompleted ? today : yesterday;

    // Finde den Beginn der aktuellen Streak
    final streakStartDate = findStreakStartDate(lastActiveDate, completedDays);

    // Berechne die Länge der Streak in Tagen
    final streakLength = lastActiveDate.difference(streakStartDate).inDays + 1;

    return StreakInfo(
        hasActiveStreak: true,
        lastActiveDate: lastActiveDate,
        streakStartDate: streakStartDate,
        streakLength: streakLength);
  }
}

/// Enthält alle relevanten Informationen über eine Streak
class StreakInfo {
  final bool hasActiveStreak;
  final DateTime? lastActiveDate;
  final DateTime? streakStartDate;
  final int streakLength;

  StreakInfo({
    required this.hasActiveStreak,
    required this.lastActiveDate,
    required this.streakStartDate,
    required this.streakLength,
  });
}
