import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  static const String tableName = 'badges';
  static Database? _database;

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
            category INTEGER NOT NULL,
            threshold INTEGER NOT NULL,
            iconPath TEXT NOT NULL,
            isAchieved INTEGER NOT NULL,
            achievedCount INTEGER NOT NULL,
            lastAchievedDate INTEGER
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
      final List<AchivementBadge> badges = jsonData.map((data) {
        return AchivementBadge(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          category: AchivementBadgeCategory.values[data['category']],
          threshold: data['threshold'],
          iconPath: data['iconPath'],
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
  Future<void> saveBadge(AchivementBadge badge) async {
    final db = await database;
    await db.update(
      tableName,
      badge.toMap(),
      where: 'id = ?',
      whereArgs: [badge.id],
    );
  }

  @override
  Future<List<AchivementBadge>> getBadgesByCategory(
      AchivementBadgeCategory category) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category.index],
    );

    return List.generate(maps.length, (i) => AchivementBadge.fromMap(maps[i]));
  }

  @override
  Future<List<AchivementBadge>> getAllBadges() async {
    final db = await database;
    final maps = await db.query(tableName);

    return List.generate(maps.length, (i) => AchivementBadge.fromMap(maps[i]));
  }

  @override
  Future<AchivementBadge> getBadgeById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return AchivementBadge.fromMap(maps.first);
  }

  @override
  Future<void> initializeAppDates() async {
    final prefs = await SharedPreferences.getInstance();
    final firstOpenDate = prefs.getString('firstOpenDate');

    if (firstOpenDate == null) {
      final now = DateTime.now();
      await prefs.setString('firstOpenDate', now.toIso8601String());
      await prefs.setString('lastCheckDate', now.toIso8601String());
    }
  }

  @override
  Future<DateTime> getFirstOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('firstOpenDate');
    return DateTime.parse(dateString!);
  }

  @override
  Future<DateTime> getLastCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('lastCheckDate');
    return DateTime.parse(dateString!);
  }

  @override
  Future<void> updateLastCheckDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCheckDate', date.toIso8601String());
  }
}

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});
