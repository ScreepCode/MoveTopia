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
  Future<bool> getIsDarkMode() async {
    final value = await loadSetting(isDarkModeKey);
    return value != null ? value as bool : false; // Default mode
  }

  @override
  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await saveSetting(isDarkModeKey, isDarkMode);
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
}
