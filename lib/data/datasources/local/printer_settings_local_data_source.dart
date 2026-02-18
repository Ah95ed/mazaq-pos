import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_db.dart';
import '../../../core/printing/printer_config.dart';
import '../../models/printer_settings_model.dart';

class PrinterSettingsLocalDataSource {
  final Database database;

  PrinterSettingsLocalDataSource(this.database);

  Future<PrinterSettingsModel?> getByType(PrinterType type) async {
    final rows = await database.query(
      AppDbTables.printerSettings,
      where: '${AppDbColumns.printerType} = ?',
      whereArgs: [type == PrinterType.usb ? 'USB' : 'TCP'],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return PrinterSettingsModel.fromMap(rows.first);
  }

  Future<PrinterSettingsModel?> getByRole(String role) async {
    final rows = await database.query(
      AppDbTables.printerSettings,
      where: '${AppDbColumns.printerRole} = ?',
      whereArgs: [role],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return PrinterSettingsModel.fromMap(rows.first);
  }

  Future<void> upsert(PrinterSettingsModel model) async {
    // If it has a role, we identify by role. Otherwise by type (fallback)
    final existing = model.role != null
        ? await getByRole(model.role!)
        : await getByType(model.type);

    if (existing == null) {
      await database.insert(
        AppDbTables.printerSettings,
        model.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }

    await database.update(
      AppDbTables.printerSettings,
      model.toMap(includeId: false),
      where: '${AppDbColumns.id} = ?',
      whereArgs: [existing.id],
    );
  }

  Future<List<PrinterSettingsModel>> getAll() async {
    final rows = await database.query(AppDbTables.printerSettings);
    return rows.map((e) => PrinterSettingsModel.fromMap(e)).toList();
  }
}
