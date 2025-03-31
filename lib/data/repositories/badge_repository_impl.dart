import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  static const String tableName = 'badges';
  static Database? _database;
  final DeviceInfoRepository _deviceInfoRepository;

  BadgeRepositoryImpl(this._deviceInfoRepository);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = path.join(await getDatabasesPath(), 'badges.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
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
        await _initializeBadges(db);
      },
    );
  }

  Future<void> _initializeBadges(Database db) async {
    try {
      // Load JSON from assets
      final String jsonString =
          await rootBundle.loadString('assets/data/badges.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert JSON to Badge objects
      final List<AchievementBadge> badges = jsonData.map((data) {
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

      // Check and insert badges only if they don't exist
      for (var badge in badges) {
        final existingBadge = await db.query(
          tableName,
          where: 'id = ?',
          whereArgs: [badge.id],
        );

        if (existingBadge.isEmpty) {
          await db.insert(tableName, badge.toMap());
        }
      }
    } catch (e) {
      print('Error initializing badges: $e');
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
}

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return BadgeRepositoryImpl(deviceInfoRepository);
});
