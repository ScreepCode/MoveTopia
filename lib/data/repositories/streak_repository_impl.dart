import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final logger = Logger('StreakRepositoryImpl');
  late Future<SharedPreferences> _prefsInstance;

  StreakRepositoryImpl() {
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
}
