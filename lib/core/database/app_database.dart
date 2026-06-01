import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  static const String databaseName = 'app_financeiro.db';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      databaseName,
    );

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        firebase_uid TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_id TEXT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        value REAL NOT NULL,
        is_income INTEGER NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final transactionColumns = await db.rawQuery(
        'PRAGMA table_info(transactions)',
      );

      final hasFirebaseId = transactionColumns.any(
        (column) => column['name'] == 'firebase_id',
      );

      if (!hasFirebaseId) {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN firebase_id TEXT',
        );
      }

      final userColumns = await db.rawQuery(
        'PRAGMA table_info(users)',
      );

      final hasFirebaseUid = userColumns.any(
        (column) => column['name'] == 'firebase_uid',
      );

      if (!hasFirebaseUid) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN firebase_uid TEXT',
        );
      }
    }
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
