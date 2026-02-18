import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_db.dart';
import '../../../core/printing/printer_config_model.dart';

class PrinterConfigLocalDataSource {
  final Database database;

  PrinterConfigLocalDataSource(this.database);

  static const _roles = ['Cashier', 'Kitchen', 'Grill'];

  Future<List<PrinterConfig>> getAll() async {
    final rows = await database.query(
      AppDbTables.printerConfigs,
      orderBy: AppDbColumns.id,
    );
    return rows.map(_fromMap).toList();
  }

  Future<PrinterConfig?> getByRole(String role) async {
    final rows = await database.query(
      AppDbTables.printerConfigs,
      where: '${AppDbColumns.printerRole} = ?',
      whereArgs: [role],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> updateByRole({
    required String role,
    String? printerName,
    String? ip,
    int port = 9100,
  }) async {
    final existing = await getByRole(role);
    final now = DateTime.now().toIso8601String();

    if (existing == null) {
      await database.insert(AppDbTables.printerConfigs, {
        AppDbColumns.printerRole: role,
        AppDbColumns.printerName: printerName,
        AppDbColumns.printerIp: ip,
        AppDbColumns.printerPort: port,
        AppDbColumns.updatedAt: now,
      });
    } else {
      await database.update(
        AppDbTables.printerConfigs,
        {
          AppDbColumns.printerName: printerName,
          AppDbColumns.printerIp: ip,
          AppDbColumns.printerPort: port,
          AppDbColumns.updatedAt: now,
        },
        where: '${AppDbColumns.printerRole} = ?',
        whereArgs: [role],
      );
    }
  }

  /// Seeds default rows for all 3 roles if they don't exist.
  Future<void> seedDefaults() async {
    for (final role in _roles) {
      final existing = await getByRole(role);
      if (existing == null) {
        await database.insert(AppDbTables.printerConfigs, {
          AppDbColumns.printerRole: role,
          AppDbColumns.printerName: null,
          AppDbColumns.printerIp: null,
          AppDbColumns.printerPort: 9100,
          AppDbColumns.updatedAt: DateTime.now().toIso8601String(),
        });
      }
    }
  }

  PrinterConfig _fromMap(Map<String, Object?> map) {
    return PrinterConfig(
      id: map[AppDbColumns.id] as int,
      role: map[AppDbColumns.printerRole] as String,
      printerName: map[AppDbColumns.printerName] as String?,
      ip: map[AppDbColumns.printerIp] as String?,
      port: (map[AppDbColumns.printerPort] as int?) ?? 9100,
      updatedAt: DateTime.parse(map[AppDbColumns.updatedAt] as String),
    );
  }
}
