import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Owns the single SQLite connection and schema for BLOOM.
///
/// This is the only file that should import `sqflite` directly — everything
/// above it (DAOs, services, UI) talks to plain Dart models so the storage
/// layer can be swapped for a cloud database later without touching them.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'bloom.db';
  static const _dbVersion = 1;

  Database? _database;
  Future<Database>? _initFuture;

  /// Concurrent callers (AccountService, TransactionService, GoalService all
  /// call this during app startup) must await the *same* initialization
  /// rather than each racing to open the database file themselves.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _initFuture ??= _initDatabase();
    _database = await _initFuture;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Desktop platforms need the FFI sqlite implementation; mobile/iOS use
    // the native sqflite plugin transparently.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'PHP',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        account_id TEXT NOT NULL,
        to_account_id TEXT,
        date TEXT NOT NULL,
        description TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (to_account_id) REFERENCES accounts (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        target_date TEXT NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        monthly_contribution REAL NOT NULL DEFAULT 0,
        notes TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_contributions (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_transactions_account ON transactions (account_id)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions (date)');
    await db.execute('CREATE INDEX idx_goal_contributions_goal ON goal_contributions (goal_id)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Wipes all local data. Used for testing / "reset app" flows only.
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('goal_contributions');
    await db.delete('goals');
    await db.delete('transactions');
    await db.delete('accounts');
  }
}
