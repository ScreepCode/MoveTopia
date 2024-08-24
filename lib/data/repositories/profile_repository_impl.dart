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
}
