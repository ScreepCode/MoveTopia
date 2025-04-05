import 'package:logging/logging.dart';

/// Eine zentrale Klasse zur Konfiguration und Verwaltung des App-Loggings
class AppLogger {
  static bool _isInitialized = false;
  static final Logger _logger = Logger('AppLogger');
  static bool _isDebugBuild = false;

  static final List<LogRecord> allLogs = [];

  /// Initialisiert das Logging-System für die gesamte App
  /// Sollte so früh wie möglich im App-Lebenszyklus aufgerufen werden
  static void init() {
    if (_isInitialized) {
      return;
    }

    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((record) {
      String emoji = '📃';
      if (record.level == Level.CONFIG) emoji = '⚙️';
      if (record.level == Level.INFO) emoji = 'ℹ️';
      if (record.level == Level.WARNING) emoji = '⚠️';
      if (record.level == Level.SEVERE) emoji = '🔥';

      // Konsolenausgabe nur im Debug-Modus
      if (_isDebugBuild) {
        print(
            '$emoji ${record.time}: [${record.loggerName}] ${record.level.name}: ${record.message}');

        if (record.error != null) {
          print('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          print('StackTrace: ${record.stackTrace}');
        }
      }

      allLogs.insert(0, record);

      if (allLogs.length > 2000) {
        allLogs.removeLast();
      }
    });

    _isInitialized = true;
    _logger.info('Logging-System initialisiert');
  }

  /// Aktualisiert den Debug-Status basierend auf dem Wert aus dem DebugRepository
  static void updateDebugStatus(bool isDebug) {
    _isDebugBuild = isDebug;
    _logger.info('Debug-Status aktualisiert: $_isDebugBuild');
  }

  /// Erstellt einen benannten Logger für eine bestimmte Klasse oder Komponente
  static Logger getLogger(String name) {
    if (!_isInitialized) {
      init();
    }
    return Logger(name);
  }

  /// Prüft, ob das Logging-System initialisiert wurde
  static bool get isInitialized => _isInitialized;

  /// Gibt zurück, ob die App im Debug-Modus läuft
  static bool get isDebugBuild => _isDebugBuild;
}
