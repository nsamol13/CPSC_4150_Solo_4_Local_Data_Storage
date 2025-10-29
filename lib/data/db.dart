import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static const _dbName = 'solo4.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<String> _resolvePath() async {
    // On web, a simple file name maps to IndexedDB; no filesystem path.
    if (kIsWeb) return _dbName;
    return p.join(await getDatabasesPath(), _dbName);
  }

  Future<Database> _init() async {
    final path = await _resolvePath();
    // Use the global databaseFactory (set in main.dart for web/desktop).
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              text TEXT NOT NULL,
              created_at INTEGER NOT NULL
            );
          ''');
        },
        // Keep for future migrations.
        onUpgrade: (db, oldV, newV) async {},
      ),
    );
  }

  // Safe reset that works on web/desktop/mobile and never blocks callers.
  Future<void> reset() async {
    final path = await _resolvePath();
    try {
      await databaseFactory.deleteDatabase(path);
    } catch (_) {
      // Ignore delete errors; we'll recreate below.
    }
    // Recreate the database schema so next open is clean.
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              text TEXT NOT NULL,
              created_at INTEGER NOT NULL
            );
          ''');
        },
      ),
    );
    await db.close();
    _db = null; // force a fresh open on next access
  }
}
