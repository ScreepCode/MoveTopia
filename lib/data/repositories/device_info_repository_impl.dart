import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const installationDateKey = 'installationDate';
const lastOpenedDateKey = 'lastOpenedDate'; // Renamed key

class DeviceInfoRepositoryImpl implements DeviceInfoRepository {
  @override
  Future<void> initializeAppDates() async {
    final prefs = await SharedPreferences.getInstance();
    final installationDate = prefs.getString(installationDateKey);

    if (installationDate == null) {
      final now = DateTime.now().subtract(const Duration(days: 30));
      await prefs.setString(installationDateKey, now.toIso8601String());
      await prefs.setString(
          lastOpenedDateKey, now.toIso8601String()); // Renamed key
    }
  }

  @override
  Future<DateTime> getInstallationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(installationDateKey);
    return dateString != null ? DateTime.parse(dateString) : DateTime.now();
  }

  @override
  Future<DateTime> getLastOpenedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(lastOpenedDateKey);
    return dateString != null
        ? DateTime.parse(dateString)
        : DateTime.now().subtract(Duration(days: 30));
  }

  @override
  Future<void> updateLastOpenedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastOpenedDateKey, date.toIso8601String());
  }
}

final deviceInfoRepositoryProvider = Provider<DeviceInfoRepository>((ref) {
  return DeviceInfoRepositoryImpl();
});
