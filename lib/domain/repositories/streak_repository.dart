const streakCountKey = 'streakCount';
const streakLastCompletedDateKey = 'streakLastCompletedDate';
const streakDaysCompletedKey = 'streakDaysCompleted';

abstract class StreakRepository {
  Future<int> getStreakCount();

  Future<void> saveStreakCount(int count);

  Future<DateTime?> getLastCompletedDate();

  Future<void> saveLastCompletedDate(DateTime date);

  Future<void> saveCompletedDay(DateTime date);

  Future<List<DateTime>> getCompletedDays();

  Future<void> saveCompletedDaysList(List<DateTime> days);

  Future<bool> checkAndUpdateStreak(int steps, int goal);
}
