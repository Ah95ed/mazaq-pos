import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_db.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<void> init() async {
    databaseFactory = databaseFactoryFfi;
    if (_database != null) {
      return;
    }
    final dbPath = await _getDbPath();
    _database = await openDatabase(
      dbPath,
      version: 8,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final hasPriceText = await _columnExists(
            db,
            AppDbTables.items,
            AppDbColumns.priceText,
          );
          if (!hasPriceText) {
            await db.execute(
              'ALTER TABLE ${AppDbTables.items} '
              'ADD COLUMN ${AppDbColumns.priceText} TEXT',
            );
          }
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${AppDbTables.printerSettings} (
              ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${AppDbColumns.printerType} TEXT NOT NULL,
              ${AppDbColumns.printerIp} TEXT,
              ${AppDbColumns.printerPort} INTEGER,
              ${AppDbColumns.usbModelKey} TEXT,
              ${AppDbColumns.updatedAt} TEXT NOT NULL
            )
            ''');
          await db.execute(
            'UPDATE ${AppDbTables.items} '
            'SET ${AppDbColumns.priceText} = ${AppDbColumns.price} '
            'WHERE ${AppDbColumns.priceText} IS NULL',
          );
        }
        if (oldVersion < 3) {
          final hasCategory = await _columnExists(
            db,
            AppDbTables.items,
            AppDbColumns.category,
          );
          if (!hasCategory) {
            await db.execute(
              'ALTER TABLE ${AppDbTables.items} '
              'ADD COLUMN ${AppDbColumns.category} TEXT DEFAULT "BOTH"',
            );
          }
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${AppDbTables.itemCategories} (
              ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${AppDbColumns.category} TEXT NOT NULL UNIQUE,
              ${AppDbColumns.createdAt} TEXT NOT NULL,
              ${AppDbColumns.updatedAt} TEXT NOT NULL
            )
            ''');
        }
        if (oldVersion < 5) {
          final hasCategoriesTable = await _tableExists(
            db,
            AppDbTables.itemCategories,
          );
          if (hasCategoriesTable) {
            await db.delete(AppDbTables.itemCategories);
          }
        }
        if (oldVersion < 6) {
          final hasPrinterName = await _columnExists(
            db,
            AppDbTables.printerSettings,
            AppDbColumns.printerName,
          );
          if (!hasPrinterName) {
            await db.execute(
              'ALTER TABLE ${AppDbTables.printerSettings} '
              'ADD COLUMN ${AppDbColumns.printerName} TEXT',
            );
          }
        }
        if (oldVersion < 7) {
          final hasPrinterRole = await _columnExists(
            db,
            AppDbTables.printerSettings,
            AppDbColumns.printerRole,
          );
          if (!hasPrinterRole) {
            await db.execute(
              'ALTER TABLE ${AppDbTables.printerSettings} '
              'ADD COLUMN ${AppDbColumns.printerRole} TEXT',
            );
          }
        }
        if (oldVersion < 8) {
          await _createPrinterConfigsTable(db);
        }
      },
    );
  }

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError('Database is not initialized.');
    }
    return db;
  }

  Future<String> _getDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, AppConfig.databaseName);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.items} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.nameAr} TEXT NOT NULL,
        ${AppDbColumns.nameEn} TEXT NOT NULL,
        ${AppDbColumns.price} REAL NOT NULL,
        ${AppDbColumns.priceText} TEXT,
        ${AppDbColumns.imagePath} TEXT,
        ${AppDbColumns.isActive} INTEGER NOT NULL,
        ${AppDbColumns.category} TEXT NOT NULL DEFAULT "BOTH",
        ${AppDbColumns.createdAt} TEXT NOT NULL,
        ${AppDbColumns.updatedAt} TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.itemCategories} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.category} TEXT NOT NULL UNIQUE,
        ${AppDbColumns.createdAt} TEXT NOT NULL,
        ${AppDbColumns.updatedAt} TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.orders} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.orderType} TEXT NOT NULL,
        ${AppDbColumns.status} TEXT NOT NULL,
        ${AppDbColumns.customerName} TEXT,
        ${AppDbColumns.customerPhone} TEXT,
        ${AppDbColumns.customerAddress} TEXT,
        ${AppDbColumns.subtotal} REAL NOT NULL,
        ${AppDbColumns.tax} REAL NOT NULL,
        ${AppDbColumns.discount} REAL NOT NULL,
        ${AppDbColumns.total} REAL NOT NULL,
        ${AppDbColumns.createdAt} TEXT NOT NULL,
        ${AppDbColumns.updatedAt} TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.orderItems} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.orderId} INTEGER NOT NULL,
        ${AppDbColumns.itemId} INTEGER NOT NULL,
        ${AppDbColumns.itemName} TEXT NOT NULL,
        ${AppDbColumns.unitPrice} REAL NOT NULL,
        ${AppDbColumns.quantity} INTEGER NOT NULL,
        ${AppDbColumns.lineTotal} REAL NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.sales} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.orderId} INTEGER NOT NULL,
        ${AppDbColumns.orderType} TEXT NOT NULL,
        ${AppDbColumns.total} REAL NOT NULL,
        ${AppDbColumns.paidAt} TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppDbTables.printerSettings} (
        ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppDbColumns.printerType} TEXT NOT NULL,
        ${AppDbColumns.printerIp} TEXT,
        ${AppDbColumns.printerPort} INTEGER,
        ${AppDbColumns.usbModelKey} TEXT,
        ${AppDbColumns.printerName} TEXT,
        ${AppDbColumns.printerRole} TEXT,
        ${AppDbColumns.updatedAt} TEXT NOT NULL
      )
      ''');

    await _createPrinterConfigsTable(db);
  }

  Future<void> _createPrinterConfigsTable(Database db) async {
    final tableExists = await _tableExists(db, AppDbTables.printerConfigs);
    if (!tableExists) {
      await db.execute('''
        CREATE TABLE ${AppDbTables.printerConfigs} (
          ${AppDbColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppDbColumns.printerRole} TEXT NOT NULL UNIQUE,
          ${AppDbColumns.printerName} TEXT,
          ${AppDbColumns.printerIp} TEXT,
          ${AppDbColumns.printerPort} INTEGER NOT NULL DEFAULT 9100,
          ${AppDbColumns.updatedAt} TEXT NOT NULL
        )
      ''');
      // Seed the 3 default roles
      final now = DateTime.now().toIso8601String();
      for (final role in ['Cashier', 'Kitchen', 'Grill']) {
        await db.insert(AppDbTables.printerConfigs, {
          AppDbColumns.printerRole: role,
          AppDbColumns.printerName: null,
          AppDbColumns.printerIp: null,
          AppDbColumns.printerPort: 9100,
          AppDbColumns.updatedAt: now,
        });
      }
    }
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    for (final row in columns) {
      if ((row['name'] as String?) == columnName) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final rows = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', tableName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
