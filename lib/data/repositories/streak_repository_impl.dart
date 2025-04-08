import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/service/health_service_impl.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/streak_repository.dart';
import '../../presentation/challenges/provider/badge_repository_provider.dart';

const streakCountKey = 'streakCount';
const streakDaysCompletedKey = 'streakDaysCompleted';
const streakLastCompletedDateKey = 'streakLastCompletedDate';

class StreakRepositoryImpl implements StreakRepository {
  final logger = Logger('StreakRepositoryImpl');
  late Future<SharedPreferences> _prefsInstance;
  final DeviceInfoRepository _deviceInfoRepository;
  final HealthServiceImpl _healthService;

  StreakRepositoryImpl(this._deviceInfoRepository, this._healthService) {
    _prefsInstance = SharedPreferences.getInstance();
  }

  @override
  Future<int> getStreakCount() async {
    final prefs = await _prefsInstance;
    return prefs.getInt(streakCountKey) ?? 0;
  }

  @override
  Future<List<DateTime>> getCompletedDays() async {
    final prefs = await _prefsInstance;
    final daysString = prefs.getString(streakDaysCompletedKey);

    if (daysString == null) return [];

    final List<dynamic> jsonList = jsonDecode(daysString);
    return jsonList.map((dateStr) => DateTime.parse(dateStr)).toList();
  }

  @override
  Future<DateTime?> getLastCompletedDate() async {
    final prefs = await _prefsInstance;
    final dateString = prefs.getString(streakLastCompletedDateKey);
    if (dateString == null) return null;

    return DateTime.parse(dateString);
  }

  @override
  Future<void> saveStreakCount(int count) async {
    final prefs = await _prefsInstance;
    await prefs.setInt(streakCountKey, count);
  }

  @override
  Future<void> saveLastCompletedDate(DateTime date) async {
    final prefs = await _prefsInstance;
    final dateString = date.toIso8601String();
    await prefs.setString(streakLastCompletedDateKey, dateString);
  }

  @override
  Future<void> saveCompletedDay(DateTime date) async {
    final days = await getCompletedDays();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (!days.any((d) => _isSameDay(d, normalizedDate))) {
      days.add(normalizedDate);
      await saveCompletedDaysList(days);
    }
  }

  @override
  Future<void> saveCompletedDaysList(List<DateTime> days) async {
    final prefs = await _prefsInstance;
    final jsonList = days.map((date) => date.toIso8601String()).toList();
    await prefs.setString(streakDaysCompletedKey, jsonEncode(jsonList));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<bool> checkAndUpdateStreak(int steps, int goal) async {
    if (steps < goal) return false;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final lastCompletedDate = await getLastCompletedDate();
    var currentStreak = await getStreakCount();

    bool updatedStreak = false;

    if (lastCompletedDate == null) {
      currentStreak = 1;
      updatedStreak = true;
    } else {
      final normalizedLastDate = DateTime(lastCompletedDate.year,
          lastCompletedDate.month, lastCompletedDate.day);

      if (_isSameDay(normalizedToday, normalizedLastDate)) {
        return false;
      }

      final difference = normalizedToday.difference(normalizedLastDate).inDays;

      if (difference == 1) {
        currentStreak++;
        updatedStreak = true;
      } else if (difference > 1) {
        currentStreak = 1;
        updatedStreak = true;
      }
    }

    if (updatedStreak) {
      await saveStreakCount(currentStreak);
      await saveLastCompletedDate(normalizedToday);
      await saveCompletedDay(normalizedToday);
    }

    return updatedStreak;
  }

  @override
  Future<void> checkAndUpdateStreaksSinceInstallation(
      DateTime installationDate, int currentGoal) async {
    logger.info(
        'Checking streaks since installation date: $installationDate with goal: $currentGoal');

    final localHealthRepository = _healthService;

    // Hole die Liste der bereits abgeschlossenen Tage - WICHTIG: Wir behalten diese bei!
    final allCompletedDays = await getCompletedDays() ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool daysAdded = false;

    logger.info('Bestehende abgeschlossene Tage: ${allCompletedDays.length}');

    final oldestDay = installationDate;
    for (var day = oldestDay;
        !(day.isAfter(today) || day.isAtSameMomentAs(today));
        day = day.add(const Duration(days: 1))) {
      final normalizedDay = DateTime(day.year, day.month, day.day);

      final isPastDay = normalizedDay.isBefore(today);

      final dayAlreadyCompleted =
          allCompletedDays.any((d) => _isSameDay(d, normalizedDay));

      final startOfDay = normalizedDay;
      final endOfDay = DateTime(normalizedDay.year, normalizedDay.month,
          normalizedDay.day, 23, 59, 59);
      final steps =
          (await localHealthRepository.getStepsInInterval(startOfDay, endOfDay))
              .sum;

      if (isPastDay) {
        if (dayAlreadyCompleted) {
          logger.info(
              'Vergangener Tag $normalizedDay bleibt als erfüllt markiert');
        } else {
          logger.info(
              'Vergangener Tag $normalizedDay bleibt als nicht erfüllt markiert');
        }
      } else {
        logger.info(
            'Heutiger Tag: $normalizedDay, Schritte: $steps, Aktuelles Ziel: $currentGoal');

        if (steps >= currentGoal && !dayAlreadyCompleted) {
          logger.info('Füge heutigen Tag als erfüllt hinzu');
          await saveCompletedDay(normalizedDay);
          daysAdded = true;
        } else if (steps < currentGoal && dayAlreadyCompleted) {
          logger.info(
              'Heutiger Tag bleibt als erfüllt markiert, obwohl Schritte unter Ziel sind');
        }
      }
    }

    final updatedCompletedDays = await getCompletedDays() ?? [];
    await _recalculateStreakCount(updatedCompletedDays);
    logger.info('Streak count recalculated');

    await _deviceInfoRepository.updateLastOpenedDate(today);

    if (daysAdded) {
      logger.info('Neue Tage wurden zur Streak-Historie hinzugefügt');
    } else {
      logger.info('Keine neuen Tage zur Streak-Historie hinzugefügt');
    }
  }

  // Hilfsmethode zur Neuberechnung der Streak-Länge
  Future<void> _recalculateStreakCount(List<DateTime> completedDays) async {
    if (completedDays.isEmpty) {
      await saveStreakCount(0);
      return;
    }

    // Sortiere die Tage
    completedDays.sort();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Prüfe ob gestern in der Liste ist - das ist entscheidend für die Streak
    bool hasYesterdayCompleted =
        completedDays.any((d) => _isSameDay(d, yesterday));

    // Wenn gestern nicht in der Liste ist, ist die Streak unterbrochen
    if (!hasYesterdayCompleted) {
      await saveStreakCount(0);
      return;
    }

    // Zähle die aktuelle Streak vom Vortag rückwärts
    int currentStreak = 1; // Gestern ist mindestens erfüllt
    DateTime checkDate =
        yesterday.subtract(const Duration(days: 1)); // Beginne mit vorgestern

    // Zähle zurück, bis ein Tag in der Serie fehlt
    while (true) {
      if (completedDays.any((d) => _isSameDay(d, checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Prüfe ob heute bereits erfüllt ist und füge es zur Streak hinzu
    bool hasTodayCompleted = completedDays.any((d) => _isSameDay(d, today));
    if (hasTodayCompleted) {
      currentStreak++;
    }

    await saveStreakCount(currentStreak);
    logger.info(
        'Updated streak count to $currentStreak (today completed: $hasTodayCompleted)');
  }
}

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  final healthServiceImpl = ref.watch(healthService);
  return StreakRepositoryImpl(deviceInfoRepository, healthServiceImpl);
});
