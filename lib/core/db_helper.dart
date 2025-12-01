import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/location_entry.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // Jika platform Windows → gunakan FFI
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'location_history.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE locations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              latitude REAL,
              longitude REAL,
              address TEXT
            )
          ''');
        },
      ),
    );
  }

  Future<int> insertLocation(LocationEntry entry) async {
    final db = await database;
    return await db.insert('locations', entry.toMap());
  }

  Future<List<LocationEntry>> getAllLocations() async {
    final db = await database;
    final result = await db.query(
      'locations',
      orderBy: 'date DESC',
    );
    return result.map((e) => LocationEntry.fromMap(e)).toList();
  }

  Future<LocationEntry?> getLocationByDate(DateTime date) async {
    final db = await database;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await db.query(
      'locations',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return LocationEntry.fromMap(result.first);
  }
}
