import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/streak_repository_impl.dart';
import '../../../domain/repositories/streak_repository.dart';

// Provider für SharedPreferences
final sharedPreferencesProvider = Provider<Future<SharedPreferences>>((ref) {
  return SharedPreferences.getInstance();
});

// Provider für das Streak-Repository
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepositoryImpl();
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

    // Finde die längste zusammenhängende Streak, die diesen Tag enthält
    DateTime streakStart = this;
    DateTime streakEnd = this;

    // Prüfe nach vorwärts
    DateTime currentDate = this;
    while (true) {
      final nextDay = currentDate.add(const Duration(days: 1));
      if (nextDay.isAfter(DateTime.now())) break;

      if (sortedDays.any((day) =>
          day.year == nextDay.year &&
          day.month == nextDay.month &&
          day.day == nextDay.day)) {
        currentDate = nextDay;
        streakEnd = nextDay;
      } else {
        break;
      }
    }

    // Prüfe nach rückwärts
    currentDate = this;
    while (true) {
      final previousDay = currentDate.subtract(const Duration(days: 1));
      if (previousDay.isBefore(DateTime(2024, 1, 1))) break;

      if (sortedDays.any((day) =>
          day.year == previousDay.year &&
          day.month == previousDay.month &&
          day.day == previousDay.day)) {
        currentDate = previousDay;
        streakStart = previousDay;
      } else {
        break;
      }
    }

    // Nur wenn es mindestens 2 zusammenhängende Tage gibt, ist es eine aktive Streak
    final isPartOfActiveStreak = streakEnd.difference(streakStart).inDays >= 1;

    if (isPartOfActiveStreak) {
      return const Color(0xFFAF52DE); // Lila für aktive Streak
    } else {
      return Colors.red.shade300; // Rot für verfallene Streak
    }
  }
}
