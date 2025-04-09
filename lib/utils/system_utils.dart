import 'dart:typed_data';

import 'package:installed_apps/installed_apps.dart';
import 'package:logging/logging.dart';

Future<Uint8List?> getInstalledAppIcon(String sourceId) async {
  final log = Logger("InstalledAppIcon");
  if (sourceId.isNotEmpty) {
    try {
      var appIcon =
          (await InstalledApps.getAppInfo(sourceId.toString(), null))?.icon;
      if (appIcon != null && appIcon.isNotEmpty) {
        return appIcon;
      }
    } catch (_) {
      log.info("App icon fetching failed");
    }
  }
  return null;
}

DateTime toUtc(DateTime date) {
  return date.toUtc();
}

DateTime toLocal(DateTime date) {
  // Convert UTC to local time
  return date.toLocal();
}
