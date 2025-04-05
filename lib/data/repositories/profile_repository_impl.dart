import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final logger = Logger('ProfileRepositoryImpl');
  final _prefs = SharedPreferences.getInstance();

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await _prefs;
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is DateTime) {
      await prefs.setString(key, value.toIso8601String());
    } else if (value is AppThemeMode) {
      await prefs.setInt(key, value.index);
    } else {
      throw Exception('Unsupported type');
    }
  }

  @override
  Future<dynamic> loadSetting(String key) async {
    final prefs = await _prefs;
    return prefs.get(key);
  }

  @override
  Future<int> getStepGoal() async {
    final value = await loadSetting(stepGoalKey);
    return value != null ? value as int : 5000; // Default step goal
  }

  @override
  Future<void> saveStepGoal(int stepGoal) async {
    await saveSetting(stepGoalKey, stepGoal);
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    final value = await loadSetting(themeModeKey);
    if (value != null) {
      final index = value as int;
      // Stelle sicher, dass der Index gültig ist
      if (index >= 0 && index < AppThemeMode.values.length) {
        return AppThemeMode.values[index];
      }
    }
    return AppThemeMode.system; // Standardeinstellung
  }

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    await saveSetting(themeModeKey, themeMode);
  }

  @override
  Future<int> getUserEP() async {
    final value = await loadSetting(userEPKey);
    return value != null ? value as int : 0; // Default EP
  }

  @override
  Future<void> saveUserEP(int ep) async {
    await saveSetting(userEPKey, ep);
  }

  @override
  Future<int> getUserLevel() async {
    final value = await loadSetting(userLevelKey);
    return value != null ? value as int : 1; // Default level
  }

  @override
  Future<void> saveUserLevel(int level) async {
    await saveSetting(userLevelKey, level);
  }

  @override
  Future<DateTime> getInstallationDate() async {
    final value = await loadSetting(installationDateKey);
    if (value != null) {
      try {
        return DateTime.parse(value as String);
      } catch (e) {
        logger.warning('Failed to parse installation date', e);
      }
    }
    // Default: Heute
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Gleich speichern
    await saveInstallationDate(today);
    return today;
  }

  @override
  Future<void> saveInstallationDate(DateTime date) async {
    await saveSetting(installationDateKey, date);
  }

  @override
  Future<DateTime> getLastUpdated() async {
    final value = await loadSetting(lastUpdatedKey);
    if (value != null) {
      try {
        return DateTime.parse(value as String);
      } catch (e) {
        logger.warning('Failed to parse last updated date', e);
      }
    }
    // Default: Heute
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Gleich speichern
    await saveLastUpdated(today);
    return today;
  }

  @override
  Future<void> saveLastUpdated(DateTime date) async {
    await saveSetting(lastUpdatedKey, date);
  }
}
