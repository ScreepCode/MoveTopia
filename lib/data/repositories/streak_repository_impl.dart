import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/repositories/streak_repository.dart';

const streakCountKey = 'streakCount';
const streakDaysCompletedKey = 'streakDaysCompleted';
const streakLastCompletedDateKey = 'streakLastCompletedDate';

class StreakRepositoryImpl implements StreakRepository {
  final logger = Logger('StreakRepositoryImpl');
  late Future<SharedPreferences> _prefsInstance;
  final DeviceInfoRepository _deviceInfoRepository;

  StreakRepositoryImpl(this._deviceInfoRepository) {
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

    // Hole die Liste der bereits abgeschlossenen Tage
    final allCompletedDays = await getCompletedDays() ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool daysAdded = false;

    // Überprüfe jeden Tag vom Installationsdatum bis heute
    final oldestDay = installationDate;
    for (var day = oldestDay;
        !(day.isAfter(today) || day.isAtSameMomentAs(today));
        day = day.add(const Duration(days: 1))) {
      // Format date as string in format "yyyy-MM-dd"
      final dayString = day.toIso8601String();

      // Prüfe, ob der Tag bereits in der Liste der abgeschlossenen Tage ist
      final dayExists =
          allCompletedDays.any((d) => d.toIso8601String() == dayString);
      if (!dayExists) {
        // Tag hinzufügen, wenn er noch nicht in der Liste ist
        logger.info('Adding day $dayString to completed days');
        await saveCompletedDay(day);
        daysAdded = true;
      }
    }

    if (daysAdded) {
      // Aktualisiere die Liste der abgeschlossenen Tage
      final updatedCompletedDays = await getCompletedDays() ?? [];
      logger.info(
          'Updated completed days list, new length: ${updatedCompletedDays.length}');

      // Berechne die aktuelle Streak-Länge neu
      await _recalculateStreakCount(updatedCompletedDays);

      // Zum Schluss das aktuelle Datum als letztes geprüftes Datum speichern
      await _deviceInfoRepository.updateLastOpenedDate(today);
    } else {
      logger.info('No new days to add to streak history');
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

    // Prüfe ob heute oder gestern in der Liste ist
    bool hasTodayOrYesterday = completedDays
        .any((d) => _isSameDay(d, today) || _isSameDay(d, yesterday));

    if (!hasTodayOrYesterday) {
      // Wenn weder heute noch gestern in der Liste ist, ist die Streak unterbrochen
      await saveStreakCount(0);
      return;
    }

    // Zähle die aktuelle Streak (vom letzten Tag rückwärts)
    int currentStreak = 0;
    DateTime checkDate;

    // Entscheide, welcher Tag der letzte in der Serie ist
    if (completedDays.any((d) => _isSameDay(d, today))) {
      checkDate = today;
    } else {
      checkDate = yesterday;
    }

    while (true) {
      if (completedDays.any((d) => _isSameDay(d, checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    await saveStreakCount(currentStreak);
    logger.info('Updated streak count to $currentStreak');
  }
}

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return StreakRepositoryImpl(deviceInfoRepository);
});
