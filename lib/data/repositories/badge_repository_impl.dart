import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:movetopia/presentation/common/app_assets.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  static const String tableName = 'badges';
  static Database? _database;
  final DeviceInfoRepository _deviceInfoRepository;
  final _log = Logger('BadgeRepositoryImpl');

  BadgeRepositoryImpl(this._deviceInfoRepository);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = path.join(await getDatabasesPath(), 'badges.db');
    _log.info('Initializing badge database at: $dbPath');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        _log.info('Creating new badge database');
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            tier INTEGER NOT NULL,
            category INTEGER NOT NULL,
            threshold INTEGER NOT NULL,
            iconPath TEXT NOT NULL,
            isAchieved INTEGER NOT NULL,
            achievedCount INTEGER NOT NULL,
            lastAchievedDate INTEGER,
            isRepeatable INTEGER NOT NULL,
            epValue INTEGER NOT NULL
          )
        ''');

        // Initialize badges from JSON
        _log.info('About to initialize badges from JSON');
        await _initializeBadges(db);
      },
    );
  }

  Future<void> _initializeBadges(Database db) async {
    try {
      _log.info('Attempting to load badges.json');

      // Load JSON from assets
      const String jsonPath = AppAssets.badgesAssets;
      _log.info('Loading badges from path: $jsonPath');

      String jsonString;
      try {
        jsonString = await rootBundle.loadString(jsonPath);
        _log.info(
            'JSON string loaded successfully from assets: length: ${jsonString.length}');
        _log.info(
            'JSON content (preview): ${jsonString.substring(0, min(100, jsonString.length))}...');
      } catch (assetError) {
        _log.severe('Failed to load badges.json from assets: $assetError');
        return; // Early return on asset loading failure
      }

      List<dynamic> jsonData;
      try {
        jsonData = json.decode(jsonString);
        _log.info('JSON decoded successfully, found ${jsonData.length} badges');
      } catch (jsonError) {
        _log.severe('Error decoding JSON: $jsonError');
        return; // Early return on JSON parsing failure
      }

      if (jsonData.isEmpty) {
        _log.warning('No badges found in JSON data');
        return; // Early return when no data is available
      }

      // Convert JSON to Badge objects
      final List<AchievementBadge> badges = jsonData.map((data) {
        _log.fine('Processing badge: ${data['name']}');
        return AchievementBadge(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          tier: data['tier'] ?? 1,
          category: AchievementBadgeCategory.values[data['category']],
          threshold: data['threshold'],
          iconPath: data['iconPath'],
          isRepeatable: data['isRepeatable'] == 0 ? false : true,
          epValue: data['epValue'] ?? 0,
        );
      }).toList();

      _log.info('Parsed ${badges.length} badges from JSON');

      // Check and insert badges only if they don't exist
      int insertedCount = 0;
      for (var badge in badges) {
        final existingBadge = await db.query(
          tableName,
          where: 'id = ?',
          whereArgs: [badge.id],
        );

        if (existingBadge.isEmpty) {
          await db.insert(tableName, badge.toMap());
          insertedCount++;
        }
      }

      _log.info('Inserted $insertedCount new badges into database');
    } catch (e, stackTrace) {
      _log.severe('Error initializing badges: $e', e, stackTrace);
    }
  }

  // Rest of the repository implementation remains the same
  @override
  Future<void> saveBadge(AchievementBadge badge) async {
    final db = await database;
    await db.update(
      tableName,
      badge.toMap(),
      where: 'id = ?',
      whereArgs: [badge.id],
    );
  }

  @override
  Future<List<AchievementBadge>> getBadgesByCategory(
      AchievementBadgeCategory category) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category.index],
    );

    return List.generate(maps.length, (i) => AchievementBadge.fromMap(maps[i]));
  }

  @override
  Future<List<AchievementBadge>> getAllBadges() async {
    final db = await database;
    final maps = await db.query(tableName);

    return List.generate(maps.length, (i) => AchievementBadge.fromMap(maps[i]));
  }

  @override
  Future<AchievementBadge> getBadgeById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return AchievementBadge.fromMap(maps.first);
  }

  @override
  Future<void> initializeAppDates() async {
    // Beim Badge-Repository verwenden wir die gleichen Daten wie im DeviceInfoRepository
    // Nichts tun, da die Initialisierung bereits im DeviceInfoRepository erfolgt
  }

  @override
  Future<DateTime> getFirstOpenDate() async {
    // Verwende das Installations-Datum aus dem DeviceInfoRepository
    return await _deviceInfoRepository.getInstallationDate();
  }

  @override
  Future<DateTime> getLastCheckDate() async {
    // Verwende das LastOpened-Datum aus dem DeviceInfoRepository
    return await _deviceInfoRepository.getLastOpenedDate();
  }

  @override
  Future<void> updateLastCheckDate(DateTime date) async {
    // Aktualisiere das LastOpened-Datum im DeviceInfoRepository
    await _deviceInfoRepository.updateLastOpenedDate(date);
  }

  Future<void> resetDatabase() async {
    final db = await _database;
    if (db != null) {
      await db.delete(tableName);
      await _initializeBadges(db);
      _log.info('Badge database has been reset');
    } else {
      _log.severe('Could not reset database: database is null');
    }
  }

  @override
  Future<void> validateAllBadges() async {
    final db = await _database;
    if (db == null) {
      _log.severe('Cannot validate badges: database is null');
      return;
    }

    try {
      _log.info('Validating badge database');

      // Check if we have any badges
      final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ??
          0;
      _log.info('Current badge count in database: $count');

      if (count == 0) {
        _log.warning('No badges found in database, initializing');
        await _initializeBadges(db);

        // Verify initialization
        final newCount = Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ??
            0;
        _log.info('Badge count after initialization: $newCount');

        if (newCount == 0) {
          _log.severe(
              'Failed to initialize badges, possible asset loading issue');
        }
      } else {
        // Verify badge data integrity by retrieving one badge
        final testBadge = await db.query(tableName, limit: 1);
        if (testBadge.isEmpty) {
          _log.warning(
              'Badge validation found inconsistent data, reinitializing');
          await db.delete(tableName);
          await _initializeBadges(db);
        } else {
          _log.info('Badge database validation successful');
        }
      }
    } catch (e, stackTrace) {
      _log.severe('Error validating badge database', e, stackTrace);
      // Try to recover by reinitializing
      try {
        await db.delete(tableName);
        await _initializeBadges(db);
      } catch (reinitError) {
        _log.severe(
            'Failed to recover badge database during validation', reinitError);
      }
    }
  }

  // Statische Methode zum Schließen der Datenbankverbindung
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return BadgeRepositoryImpl(deviceInfoRepository);
});
